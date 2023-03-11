# PVdiary2-Docker

Still learning about Docker images.

I have another container running SBFspot and generating the CSV files.

The folder with those CSV files gets attached ReadOnly in this container to process them in PVdiary2

See: https://github.com/Stan-Gobien/sbfspot-Docker


## Setup

### Preparations

Create the folders.<br>
If you change the paths remember to adjust the docker-compose.yml to reflect that.<br>
I use absolute paths because if prefer deploying my compose stacks using portainer.

    mkdir -p /data/containers/pvdiary2/data/
    mkdir -p /data/containers/pvdiary2/scripts/

Put the entrypoint.sh script in the /data/containers/pvdiary2/scripts/ folder. Make it executable.

    curl -o /data/containers/pvdiary2/scripts/entrypoint.sh https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/entrypoint.sh
    chmod +x /data/containers/pvdiary2/scripts/entrypoint.sh

### Portainer

If you use portainer then paste the content of docker-compose.yml in a new stack,<br>
or you can create the stack in portainer with the URL of the file on Github.

### or CLI with docker-compose

You can of course also download the docker-compose.yml file and put it in /data/containers/pvdiary2/<br>
The -d option starts the stack in background mode so it keeps running if you close your shell.

    curl -o /data/containers/pvdiary2/docker-compose.yml https://raw.githubusercontent.com/Stan-Gobien/PVdiary2-Docker/main/docker-compose.yml
    cd /data/containers/pvdiary2/ && docker-compose up -d

### Startup

At the start of the container, the entrypoint.sh script will get executed.<br>
The entrypoint.sh script will first download the other scripts.

Dependencies will be installed using the dependencies.sh script. <br>
PVdiary will be installed using the install.sh script. <br>
A demo configuration will be setup in PVdiary using the firstrun.sh script. <br>
An rclone config will be set (for FTP) using the rclone.sh script and reading the env variables for user/pass/host. <br>
<br>
If you did not set the environment variables in your shell or in Portainer then rclone config will not be made. <br>
<br>
See [example-stack-portainer.png](https://github.com/Stan-Gobien/PVdiary2-Docker/blob/main/example-stack-portainer.png) for an example of deploying this in portainer with environment variables.<br>
<br>
The entrypoint.sh script will then execute the normal startup of pvdiary.<br>
<br>
The dashboard web UI can be reached on port 8082<br>
<br>
Don't use this config on the public internet, because I removed the user/password need for the dashboard.<br>
you can ofcourse set this back in the framework admin.<br>
<br>
### Read the scripts to see what they all do. I made the scripts easy to follow.
