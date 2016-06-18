#!/usr/bin/env bash

MINECRAFT_FOLDER=~/.minecraft

#install build tools
sudo apt-get update
sudo apt-get install -y python libpng-dev libjpeg-dev libboost-iostreams-dev \
libboost-system-dev libboost-filesystem-dev libboost-program-options-dev \
build-essential cmake jq

#install mapcrafter
git clone https://github.com/mapcrafter/mapcrafter.git bin/mapcrafter
cd bin/mapcrafter
cmake .
make
cd ../../

#install minecraft textures
cp "$MINECRAFT_FOLDER/versions/1.9.4/1.9.4.jar" jar
python bin/mapcrafter/src/tools/mapcrafter_textures.py jar/1.9.4.jar bin/mapcrafter/src/data/textures

#create render.conf file
cp render.default render.conf

#create default configuration.conf file
printf "ftp_server=FTP_SERVER_ADDRESS\nftp_username=FTP_USERNAME\nftp_password=FTP_PASSWORD\nminecraft_username=MINECRAFT_USERNAME\nminecraft_password=MINECRAFT_PASSWORD\nminecraft_profile_id=$MINECRAFT_PROFILE_ID" > configuration.conf
