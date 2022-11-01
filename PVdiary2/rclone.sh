#!/bin/bash
mkdir ~/.config
mkdir ~/.config/rclone
cat > ~/.config/rclone/rclone.conf << EOF
[pvdiary]
type = $RCLONE_type
host = $RCLONE_HOST
user = $RCLONE_USER
pass = $RCLONE_PASS
explicit_tls = $RCLONE_EXPLICIT_TLS
no_check_certificate = $RCLONE_NO_CHECK_CERT

EOF
