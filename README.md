# PVdiary2-Docker

Still in early devlopment.
Still learning about Docker images.

I have another stack running SBFspot and generating the CSV files.

The folder with those CSV files gets attached RO in this stack to process them in PVdiary2

See: https://github.com/Stan-Gobien/sbfspot-Docker


## Setup
The Dockerfile in the build/7-bullseye folder is used to create the image.

The docker-compose file is used to create the stack with the image.

When using portainer you have to build the image first manually.

In the PVdiary2 folder are the script assets.
