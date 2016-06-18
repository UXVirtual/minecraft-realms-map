Minecraft Realms Map
====================

An automation tool to allow Minecraft Realms backups to be downloaded and have maps generated from them.

Specifically this is designed to run on a Raspberry Pi to generate maps from your world and upload them to a remote
FTP server.

Note: The installer only supports Debian/Ubuntu and OSX at this time.

## TODO

*   Add encryption to Minecraft username and password stored on disk.

## Dependencies

### OSX 10.9+

*   [XCode](https://itunes.apple.com/nz/app/xcode/id497799835)
*   [python 2.7](https://www.python.org/downloads/mac-osx/)
*   [Minecraft](https://minecraft.net/en/)
*   [Homebrew](http://brew.sh/)

### Debian / Ubuntu (Desktop / Raspberry Pi)

*   git (`apt-get install git`)
*   [Minecraft](https://minecraft.net/en/)

## Installation

1)  Make sure the above dependencies are installed first.

2)  Run the following commands to clone this repository:

    ```
    cd ~/
    git clone https://github.com/HAZARDU5/minecraft-realms-map.git
    ```

3)  Open Minecraft, login with your account and click *Edit Profile*

4)  Select *Release 1.9.4* and click *Save Profile*

5)  Click *Play* to download the Minecraft app and launch Minecraft.

6)  Close Minecraft.

7)  If on OSX open a Terminal and run the following command to copy Minecraft 1.9.4 jar into the `jar` folder:

    ```
    cp Library/Application\ Support/minecraft/versions/1.9.4/1.9.4.jar ~/minecraft-realms-map/jar
    ```

    If on Ubuntu open a Terminal and run the following command to copy Minecraft 1.9.4 jar into the `jar` folder:

    ```
    cp ~/.minecraft/versions/1.9.4/1.9.4.jar ~/minecraft-realms-map/jar
    ```

8)  Run the `install.sh` script that matches your OS.

9)  Edit the generated `render.conf` and `configuration.conf` files to suit your environment. Details on editing
    `render.conf` are [available here](https://docs.mapcrafter.org/builds/stable/configuration.html).

    Be sure to enter the Mojang account credentials for your Minecraft Realms account. Legacy Minecraft accounts that
    haven't been migrated will not be useable!

## Disclaimer

THIS PROGRAM AND ITS REQUIRED DEPENDENCIES ARE PROVIDED AS-IS AND NO WARRANTY IS IMPLIED. I WILL NOT BE RESPONSIBLE FOR
LOSS OF DATA OR MINECRAFT ACCOUNT ACCESS CAUSED BY IMPROPER USE OF THIS PROGRAM.

Use of this tool is not endorsed by Mojang. While the original authentic version of this tool will not use your
Minecraft username and password or access token for malicious purposes, it is your responsibility to ensure that the
computer or server you install it on is secure as your password will be stored in plain text on disk.