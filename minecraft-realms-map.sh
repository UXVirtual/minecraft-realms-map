#!/usr/bin/env bash

trap "exit 1" TERM
export TOP_PID=$$

AUTH_URL="https://authserver.mojang.com/authenticate"
REFRESH_URL="https://authserver.mojang.com/refresh"
WORLD_URL="https://mcoapi.minecraft.net/worlds"

DATE=`date +%Y-%m-%d`
FILE_PATH="backups/mcr_world_$DATE.tar.gz"
RETRIES=1

function exitNow {
    kill -s TERM $TOP_PID
}
function getFormat {
    SEPARATOR=$1
    echo `date "+%Y-%m-%d_%H$SEPARATOR%M$SEPARATOR%S"`
}

function log {
   DATE=$(getFormat ":")
   echo "[$DATE] $1"
}

function downloadWorld {

    if [ "$RETRIES" -gt "$DOWNLOAD_MAX_RETRIES" ]
        then
        log "Exceeded download retries count. Aborting...."
        exitNow
    fi

    log "Getting Minecraft authentication credentials..."

    #get auth server temp access token
    RESPONSE1=$(curl -s -X POST -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d "{
        \"requestUser\": true,
        \"agent\":\"Agent{name='Minecraft', version=1}\",
        \"username\":\"$MINECRAFT_USERNAME\",
        \"clientToken\":\"$MINECRAFT_CLIENT_ID\",
        \"password\":\"$MINECRAFT_PASSWORD\"
    }" "$AUTH_URL")

    #log "$RESPONSE1"

    #parse and store temp access token
    TEMP_ACCESS_TOKEN=$(echo $RESPONSE1 | jq -r '.accessToken')

    #get auth server long term access token
    RESPONSE2=$(curl -s -X POST -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d "{
        \"requestUser\": true,
        \"accessToken\":\"$TEMP_ACCESS_TOKEN\",
        \"clientToken\":\"$MINECRAFT_CLIENT_ID\",
        \"selectedProfile\":{
            \"id\": \"$MINECRAFT_PROFILE_ID\"
        }
    }" "$REFRESH_URL")

    #log "$RESPONSE2"

    #parse and store long term access token
    LONG_ACCESS_TOKEN=$(echo $RESPONSE2 | jq -r '.accessToken')
    MINECRAFT_USER=$(echo $RESPONSE2 | jq -r '.selectedProfile.name')

    log "Getting temporary download link for world backup..."

    #get Realms server ID
    RESPONSE3=$(curl -s -X GET -H "Content-Type: application/json" -H "Cookie: sid=token:$LONG_ACCESS_TOKEN:$MINECRAFT_PROFILE_ID;user=$MINECRAFT_USER;version=$MINECRAFT_VERSION" -H "Cache-Control: no-cache" -H "Pragma: no-cache" "$WORLD_URL")

    #log "$RESPONSE3"

    #parse and store server ID
    SERVER_ID=$(echo $RESPONSE3 | jq -r '.servers[0].id')
    DAYS_LEFT=$(echo $RESPONSE3 | jq -r '.servers[0].daysLeft')

    log "$DAYS_LEFT days remain for the current Realms subscription."

    #get world backup URL
    RESPONSE4=$(curl -s -X GET -H "Content-Type: application/json" -H "Cookie: sid=token:$LONG_ACCESS_TOKEN:$MINECRAFT_PROFILE_ID;user=$MINECRAFT_USER;version=$MINECRAFT_VERSION" -H "Cache-Control: no-cache" -H "Pragma: no-cache" "$WORLD_URL/$SERVER_ID/slot/$MINECRAFT_WORLD_NUM/download")

    #log "$RESPONSE4"

    if [ "$RESPONSE4" == 'Retry again later' ]
        then
            log "Couldn't get download link as API asked to retry again later. Waiting 30 seconds then restarting download $RETRIES/$DOWNLOAD_MAX_RETRIES..."
            RETRIES=$[RETRIES + 1]
            sleep 30
            downloadWorld
    fi

    DOWNLOAD_LINK=$(echo $RESPONSE4 | jq -r '.downloadLink')

    if [ -z "$DOWNLOAD_LINK" ]
        then
            log "Couldn't get download link. Restarting download $RETRIES/$DOWNLOAD_MAX_RETRIES..."
            RETRIES=$[RETRIES + 1]
            downloadWorld
    fi

    log "Downloading world backup from $DOWNLOAD_LINK. This may take several minutes..."
    wget "$DOWNLOAD_LINK" -O "$FILE_PATH"

    gunzip -c file.tar.gz | tar t > /dev/null;

    if [ $? -ne 0 ]
        then
            log "World file is corrupt. Restarting download $RETRIES/$DOWNLOAD_MAX_RETRIES..."
            RETRIES=$[RETRIES + 1]
            downloadWorld
    fi

}

NEW_DATE=$(getFormat ".")
exec > >(tee -i ./logs/map-generation-"$NEW_DATE".log)
exec 2>&1

#get config values
source configuration.conf

downloadWorld

log "Extracting world backup..."
tar -xvf "$FILE_PATH" world

log "Removing backups older than 2 days..."
find ./backups/*.tar.gz -mtime +2 -type f -delete

log "Generating map..."

DATE=`date +%Y-%m-%d:%H:%M:%S`
log "Started map generation at $DATE"

bin/mapcrafter/src/mapcrafter -c render.conf -j "$HW_THREADS"

DATE=`date +%Y-%m-%d:%H:%M:%S`
log "Finished map generation at $DATE"

log "Uploading map to web server..."

function s3_sync {
    log "Running S3 sync..."
    /usr/local/bin/aws s3 sync --delete output $S3_URL #$S3_URL must include trailing slash!
    log "S3 sync completed!"
}

#TODO: change to use configuration.conf to specify username and password info
function ftp_sync {
    log "Running FTP sync..."
    ncftpput -R -u "$FTP_USERNAME" -p "$FTP_PASSWORD" "$FTP_SERVER" "$FTP_PATH" ./output
    log "FTP sync completed!"
}

DATE=`date +%Y-%m-%d:%H:%M:%S`
log "Started transfer at $DATE"

case "$UPLOAD_TYPE" in
        s3)
            s3_sync
            ;;

        ftp)
            ftp_sync
            ;;

        *)
            ftp_sync
            exit 1

esac

DATE=`date +%Y-%m-%d:%H:%M:%S`
log "Finished transfer at $DATE"

log "Removing logs older than 7 days..."
find ./logs/*.log -mtime +7 -type f -delete

log "DONE!"