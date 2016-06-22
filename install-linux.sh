#!/usr/bin/env bash

MINECRAFT_FOLDER=~/.minecraft

function uuid
{
    local N B C='89ab'

    for (( N=0; N < 16; ++N ))
    do
        B=$(( $RANDOM%256 ))

        case $N in
            6)
                printf '4%x' $(( B%16 ))
                ;;
            8)
                printf '%c%x' ${C:$RANDOM%${#C}:1} $(( B%16 ))
                ;;
            3 | 5 | 7 | 9)
                printf '%02x-' $B
                ;;
            *)
                printf '%02x' $B
                ;;
        esac
    done

    echo
}

echo "Installing dependencies..."

#install build tools
sudo apt-get update
sudo apt-get install -y python libpng-dev libjpeg-dev libboost-iostreams-dev \
libboost-system-dev libboost-filesystem-dev libboost-program-options-dev \
build-essential cmake jq wget ncftp s3cmd imagemagick

#install mapcrafter
git clone https://github.com/mapcrafter/mapcrafter.git bin/mapcrafter
cd bin/mapcrafter
cmake .
make
cd ../../

#install minecraft textures
if [ -d "$MINECRAFT_FOLDER" ] && [ ! -f "jar/1.9.4.jar" ]; then
    cp "$MINECRAFT_FOLDER/versions/1.9.4/1.9.4.jar" jar
fi

if [ -f "jar/1.9.4.jar" ] ; then
    python bin/mapcrafter/src/tools/mapcrafter_textures.py jar/1.9.4.jar bin/mapcrafter/src/data/textures
else
    echo "Minecraft not installed on this computer. Manually download 1.9.4.jar and copy to the jar folder. Then run";
    echo "'python bin/mapcrafter/src/tools/mapcrafter_textures.py jar/1.9.4.jar bin/mapcrafter/src/data/textures' from";
    echo "the 'minecraft-realms-map' folder."
fi

#create render.conf file
echo "Creating render.conf..."
cp render.default render.conf

echo "Creating configuration.conf..."

if [ -d "$MINECRAFT_FOLDER" ]; then
    #get minecraft profile ID
    LAUNCHER_PROFILES=$(cat "$MINECRAFT_FOLDER"/launcher_profiles.json)
    MINECRAFT_PROFILE_ID=$(echo $LAUNCHER_PROFILES | jq -r '.selectedUser')
    MINECRAFT_USERNAME=$(echo $LAUNCHER_PROFILES | jq -r ".authenticationDatabase.$MINECRAFT_PROFILE_ID.username")
else
    echo "Minecraft is not installed on this computer. Manually update MINECRAFT_PROFILE_ID and MINECRAFT_USERNAME in configuration.conf";
fi

MINECRAFT_CLIENT_ID=$(uuid)

#create default configuration.conf file
printf "FTP_SERVER=\nFTP_USERNAME=\nFTP_PASSWORD=\nFTP_PATH=/htdocs\nMINECRAFT_USERNAME=$MINECRAFT_USERNAME\nMINECRAFT_PASSWORD=\nMINECRAFT_PROFILE_ID=$MINECRAFT_PROFILE_ID\nMINECRAFT_CLIENT_ID=$MINECRAFT_CLIENT_ID\nMINECRAFT_VERSION=1.10\nMINECRAFT_WORLD_NUM=1\nHW_THREADS=4\nUPLOAD_TYPE=ftp\nS3_URL=s3://bucket-name/" > configuration.conf