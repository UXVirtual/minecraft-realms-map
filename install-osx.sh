#!/usr/bin/env bash

WORLD_NAME="My World"

#install homebrew if missing
$ command -v brew >/dev/null 2>&1 || { /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" }

#install build tools
brew install boost libpng cmake libjpeg-turbo

#install mapcrafter
git clone https://github.com/mapcrafter/mapcrafter.git bin/mapcrafter
cd bin/mapcrafter
cmake .
make
cd ../../

#install minecraft textures
cp Library/Application\ Support/minecraft/versions/1.9.4/1.9.4.jar ~/minecraft-realms-map/jar
python bin/mapcrafter/src/tools/mapcrafter_textures.py ~/minecraft-realms-map/jar/1.9.4.jar bin/mapcrafter/src/data/textures

#create default render.conf file
echo "output_dir = output\n[world:myworld]\ninput_dir = world\n[map:map_myworld]\nname = $WORLD_NAME\nworld = myworld" > render.conf

#create default ftp.conf file
echo "server=FTP_SERVER_ADDRESS\nusername=FTP_USERNAME\npassword=FTP_PASSWORD" > ftp.conf



