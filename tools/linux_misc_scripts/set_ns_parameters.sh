#!/bin/bash
if pgrep docker; then
    echo "Docker detected! Skipping host..."
    exit
fi

param="kernel.unprivileged_userns_clone=0"
if grep -E "slackware|fedora" /etc/os-release >/dev/null; then
    param="user.max_user_namespaces=0"
fi

echo "$param" >> /etc/sysctl.conf
sysctl -p
