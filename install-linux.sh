#!/usr/bin/env bash

#install build tools
sudo apt-get update
sudo apt-get install -y python libpng-dev libjpeg-dev libboost-iostreams-dev \
libboost-system-dev libboost-filesystem-dev libboost-program-options-dev \
build-essential cmake

#install mapcrafter
git clone https://github.com/mapcrafter/mapcrafter.git bin/mapcrafter
cd bin/mapcrafter
cmake . -DJPEG_INCLUDE_DIR=/usr/local/opt/jpeg-turbo/include/ -DJPEG_LIBRARY=/usr/local/opt/jpeg-turbo/lib/libjpeg.dylib
make
cd ../../

#install minecraft textures
cp ~/.minecraft/versions/1.9.4/1.9.4.jar ~/minecraft-realms-map/jar
python bin/mapcrafter/src/tools/mapcrafter_textures.py ~/minecraft-realms-map/jar/1.9.4.jar bin/mapcrafter/src/data/textures

#create default render.conf file
echo "output_dir = output\n[world:myworld]\ninput_dir = world\n[map:map_myworld]\nname = $WORLD_NAME\nworld = myworld" > render.conf