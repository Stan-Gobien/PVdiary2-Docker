#!/bin/bash

OBSCURED_PASS=`/usr/bin/rclone obscure $RCLONE_PASS`
mkdir -p /home/pvdiary2/.config/rclone
cat > /home/pvdiary2/.config/rclone/rclone.conf << EOF
[pvdiary]
type = $RCLONE_TYPE
host = $RCLONE_HOST
user = $RCLONE_USER
pass = $OBSCURED_PASS
explicit_tls = $RCLONE_EXPLICIT_TLS
no_check_certificate = $RCLONE_NO_CHECK_CERT
EOF

chown -R pvdiary2:pvdiary2 /home/pvdiary2/.config
