#!/bin/bash
# Script that should only run on first setup - but should manually be ran if removing/updating a disk and the UUID changes. 
# When adding a disk in Azure normally you have sds/sdb added normally - so first data disk is sda
# setting vars
DISK_LIST=("/dev/sda1,/dev/sdb1,/dev/sdc1") # adding a/b/c as the script logic will skip them if mounted and UUID is in fstab anyway. 
IFS=',' read -r -a DISKS <<< "$DISK_LIST"
MOUNT="/data01"
FST="ext4"
# Setting functions
check_part() { # should return "part"
    local DISK=$1
    sudo lsblk -n -o TYPE "${DISK}" 2>/dev/null | grep "part"
}
grab_uuid() { # returns the UUID of the disk being ran
    local UUID=$1
    blkid -s UUID -o value "${UUID}"
    #UUID=$(sudo blkid -s UUID -o value "${DISK}")
}
check_uuid() {
    local UUID=$1
    grep "UUID=$UUID" /etc/fstab
}
part_disk() { # partitions the disk duh - stripping the 1 off the disk here to simplify the script.
    local DISK=$1
    PART_DISK=$(echo "$DISK" | sed 's/[0-9]*$//' )
    sudo parted ${PART_DISK} --script mklabel gpt mkpart data01 $FST 0% 100%
    sleep 1
    sudo mkfs.ext4 ${DISK}
    sleep 1
    sudo partprobe ${DISK}
}
adding_fstab() { # As the name suggests, but a check here for the variable being zero length and continue to next loop if it is.
    local DISK=$1
    local UUID
    UUID=$(blkid -s UUID -o value "${DISK}")
    if [ -z "$UUID" ]; then
        echo "UUID is empty, exiting this loop as not to add bad entries to /etc/fstab"
        continue
    else 
        sudo cp /etc/fstab /etc/fstab.bak
        echo "UUID=$UUID $MOUNT $FST defaults 0 2" | tee -a /etc/fstab
        echo "Added UUID $UUID of ${DISK} to fstab"
        #blkid -s UUID -o value "${DISK}"
    fi
}
# Main logic loop
for DISK in "${DISKS[@]}"; do 
# Check the partition is actually present should be sda/sdc checked as a block device  
# continue if not found, move to next in list/loop - just a safety measure here.
    PART_DISK=$(echo "$DISK" | sed 's/[0-9]*$//' )
    echo "$DISK $PART_DISK"
    if [ ! -b "${PART_DISK}" ]; then
        echo "The base disk ${PART_DISK} of ${DISK} was not found - this must not be attached - moving to next in list"
        continue
    fi 
# Check if the disk is a part - should return "part" from this function output. 
    if check_part "${DISK}"; then
        echo "The disk ${DISK} is already parted"
# Grab the UUID and check if it is mounted already    
        UUID=$(grab_uuid "$UUID")
        if check_uuid "$UUID"; then 
            echo "Disk ${DISK} UUID $UUID is already in fstab."
            continue 
        else
            echo "Disk ${DISK} UUID $UUID is NOT in fstab - adding now"
            adding_fstab "${DISK}"
        fi 
    else
        echo "Disk ${DISK} is NOT parted - doing that now"
        part_disk "${DISK}"
        adding_fstab "${DISK}"
        echo "Disk ${DISK} is now parted and has been added to fstab under $MOUNT"
    fi
done
echo "Script complete"        