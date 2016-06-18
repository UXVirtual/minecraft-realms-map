#!/usr/bin/env bash

MINECRAFT_FOLDER=~/Library/Application\ Support/minecraft

#install homebrew if missing
$ command -v brew >/dev/null 2>&1 || { /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" }

#install build tools
brew install boost libpng cmake libjpeg-turbo jq

#install mapcrafter
git clone https://github.com/mapcrafter/mapcrafter.git bin/mapcrafter
cd bin/mapcrafter
cmake . -DJPEG_INCLUDE_DIR=/usr/local/opt/jpeg-turbo/include/ -DJPEG_LIBRARY=/usr/local/opt/jpeg-turbo/lib/libjpeg.dylib
make
cd ../../

#install minecraft textures
cp "$MINECRAFT_FOLDER/versions/1.9.4/1.9.4.jar" jar
python bin/mapcrafter/src/tools/mapcrafter_textures.py jar/1.9.4.jar bin/mapcrafter/src/data/textures

#create render.conf file
cp render.default render.conf

#get minecraft profile ID
MINECRAFT_PROFILE_ID=$(cat "$MINECRAFT_FOLDER"/launcher_profiles.json | jq -r '.selectedUser')

#create default configuration.conf file
printf "ftp_server=FTP_SERVER_ADDRESS\nftp_username=FTP_USERNAME\nftp_password=FTP_PASSWORD\nminecraft_username=MINECRAFT_USERNAME\nminecraft_password=MINECRAFT_PASSWORD\nminecraft_profile_id=$MINECRAFT_PROFILE_ID" > configuration.conf



