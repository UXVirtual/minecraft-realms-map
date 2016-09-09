Minecraft Realms Map
====================

An automation tool to allow Minecraft Realms backups to be downloaded and have maps generated from them.

Specifically this is designed to run on a Raspberry Pi to generate maps from your world and upload them to a remote
FTP server. To do this the tool reverse engineers the Minecraft authentication and Realms private API calls to download
the world backups from the Realms Amazon S3 bucket url.

Note: The installer only supports Debian/Ubuntu and OSX at this time.

## Features

*   Nightly backups with 7 days retention
*   Automatic map generation
*   Logging map generation / upload to disk

## TODO

*   Add encryption to Minecraft username and password stored on disk.

## Compatibility

This tool has been tested and works with Minecraft 1.10. Map generation is optimized for Minecraft 1.9 so there may be
specific rendering issues until the []Mapcrafter](https://mapcrafter.org/index) team provide an update to fix this.

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

10) If you're using an AWS S3 bucket to upload the map, run the below to configure your connection to S3:

    ```
    mkdir ~/.aws
    sudo nano ~/.aws/credentials
    ```

    Add the following to the `~/.aws/credentials` file:

    ```
    [default]
    aws_access_key_id = AWS_IAM_USER_KEY
    aws_secret_access_key = AWS_IAM_USER_SECRET
    ```

    You need to set two keys `AWS_IAM_USER_KEY` and `AWS_IAM_USER_SECRET` - copy and paste them from your confirmation
    email or from your Amazon account page. Be careful when copying them! They are case sensitive and must be entered
    accurately or you'll keep getting errors about invalid signatures or similar when attempting to sync to s3.

    If you don't have an IAM user set up, create one in the [IAM Dashboard](https://console.aws.amazon.com/iam/home)
    and add the following policy to it:

    ```
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "Stmt1397834652000",
                "Effect": "Allow",
                "Action": [
                    "s3:ListAllMyBuckets"
                ],
                "Resource": [
                    "arn:aws:s3:::*"
                ]
            },
            {
                "Sid": "Stmt1397834745000",
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket",
                    "s3:PutObject",
                    "s3:PutObjectAcl",
                    "s3:DeleteObject",
                    "s3:DeleteObjectVersion",
                    "s3:PutLifeCycleConfiguration"
                ],
                "Resource": [
                    "arn:aws:s3:::BUCKET_NAME*",
                    "arn:aws:s3:::BUCKET_NAME/*"
                ]
            }
        ]
    }
    ```

    where `BUCKET_NAME` is the name of the S3 bucket you will be uploading the map to.

## Disclaimer

THIS PROGRAM AND ITS REQUIRED DEPENDENCIES ARE PROVIDED AS-IS AND NO WARRANTY IS IMPLIED. I WILL NOT BE RESPONSIBLE FOR
LOSS OF DATA OR MINECRAFT ACCOUNT ACCESS CAUSED BY IMPROPER USE OF THIS PROGRAM.

Use of this tool is not endorsed by Mojang. While the original authentic version of this tool will not use your
Minecraft username and password or access token for malicious purposes, it is your responsibility to ensure that the
computer or server you install it on is secure as your password will be stored in plain text on disk.