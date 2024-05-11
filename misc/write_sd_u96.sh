#!/bin/bash

# Check if the device path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <device_path>"
    echo "Example: $0 /dev/sdg"
    exit 1
fi

DEVICE_PATH=$1
IMAGE_PATH="build/tmp/deploy/images/myhardware-u96v2-zynqmp/u96-image-myhardware-u96v2-zynqmp.wic"

# Display block device list
echo "Current block devices:"
lsblk -d -o NAME,SIZE,TYPE,RM
echo ""

# Print the command to be executed
echo "The following command will be executed:"
echo "dd if=$IMAGE_PATH of=$DEVICE_PATH bs=1M; sync; eject $DEVICE_PATH"

# Ask for user confirmation
read -p "Is this correct? (y/n): " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    # Execute the commands
    sudo dd if=$IMAGE_PATH of=$DEVICE_PATH bs=1M
    sync
    sudo eject $DEVICE_PATH
else
    echo "Operation canceled."
    exit 2
fi
