#!/bin/bash
# Restart the Shared Folder mount in VMWare guest with VMWare Tool installed
sudo mount -t fuse.vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
