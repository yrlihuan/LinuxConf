#!/bin/sh

# add huan to admin group, and set sudo priviledge
useradd -m -G sudo,adm -s /bin/bash huan
echo "%sudo ALL=(ALL) NOPASSWD: NOPASSWD: ALL" >> /etc/sudoers

# ulimit -n 8192
# echo "huan            hard    nofile            8192" >> /etc/security/limits.conf
# echo "huan            soft    nofile            8192" >> /etc/security/limits.conf

