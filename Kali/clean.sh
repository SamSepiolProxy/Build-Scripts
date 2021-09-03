#!/bin/bash
apt autoremove
apt autoclean
apt clean
fstrim /
dd if=/dev/zero of=~/zeroes
sudo sync
rm ~/zeroes