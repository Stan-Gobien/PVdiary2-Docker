#!/bin/bash
#needs to be run as the pvdiary2 user
mkdir ~/.config
mkdir ~/.config/rclone
cat > ~/.config/rclone/rclone.conf << EOF
[pvdiary]
type = $RCLONE_TYPE
host = $RCLONE_HOST
user = $RCLONE_USER
pass = $RCLONE_PASS
explicit_tls = $RCLONE_EXPLICIT_TLS
no_check_certificate = $RCLONE_NO_CHECK_CERT

EOF