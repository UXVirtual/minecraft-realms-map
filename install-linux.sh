#!/usr/bin/env bash

MINECRAFT_FOLDER=~/.minecraft

#install build tools
sudo apt-get update
sudo apt-get install -y python libpng-dev libjpeg-dev libboost-iostreams-dev \
libboost-system-dev libboost-filesystem-dev libboost-program-options-dev \
build-essential cmake jq wget ncftp

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
printf "FTP_SERVER=\nFTP_USERNAME=\nFTP_PASSWORD=\nFTP_PATH=/htdocs\nMINECRAFT_USERNAME=$MINECRAFT_USERNAME\nMINECRAFT_PASSWORD=\nMINECRAFT_PROFILE_ID=$MINECRAFT_PROFILE_ID\nMINECRAFT_CLIENT_ID=$MINECRAFT_CLIENT_ID\nMINECRAFT_VERSION=1.10\nMINECRAFT_WORLD_NUM=1\nHW_THREADS=4" > configuration.conf
