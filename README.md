# PVdiary2-Docker

Still in early devlopment.
Still learning about Docker images.

I have another stack/container running SBFspot and generating the CSV files.

The folder with those CSV files gets attached RO in this stack to process them in PVdiary2

See: https://github.com/Stan-Gobien/sbfspot-Docker


## Setup
The Dockerfile in the build/7-bullseye folder is used to create the image.

The docker-compose file is used to create the stack using the built image.

When using portainer you have to build the image first manually.

In the PVdiary2 folder are the script assets.

At the start of the container PVdiary will be installed using the install.sh script.

Afterwards a demo configuration will be setup in PVdiary using the firstrun.sh script.

An rclone config will be set (for FTP) using the rclone.sh script and reading the env variabeles for user/pass/host.

The entrypoint.sh script is the main script that gets executed at start and governs all.

Read the scripts to see what it all does (PVdiary2 folder).
