#!/bin/bash
#needs to be run as the pvdiary2 user

sudo -u pvdiary2 OBSCURED_PASS=`/usr/bin/rclone obscure $RCLONE_PASS`
sudo -u pvdiary2 mkdir ~/.config
sudo -u pvdiary2 mkdir ~/.config/rclone
sudo -u pvdiary2 cat > ~/.config/rclone/rclone.conf << EOF
[pvdiary]
type = $RCLONE_TYPE
host = $RCLONE_HOST
user = $RCLONE_USER
pass = $OBSCURED_PASS
explicit_tls = $RCLONE_EXPLICIT_TLS
no_check_certificate = $RCLONE_NO_CHECK_CERT
EOF
