#!/bin/sh

useradd -m -G sudo,adm -s /bin/bash huan
echo "%sudo ALL=(ALL) NOPASSWD: NOPASSWD: ALL" >> /etc/sudoers

