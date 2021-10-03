#!/usr/bin/env bash

function notify_and_exit {
  notify-send "$1" > /dev/null && exit 1
}

if [ "$1" == "mount" ]; then 
  udisksctl unlock \
    --block-device /dev/disk/by-partlabel/t7-part \
    --key-file <(pass device/t7 | head -n 1 | tr -d '\n') || notify_and_exit "Failed mounting T7"

  udisksctl mount -b /dev/disk/by-label/t7 || notify_and_exit "Failed mounting T7"
  notify-send "T7 mounted as /run/media/marc/t7" > /dev/null
fi

if [ "$1" == "unmount" ]; then 
  udisksctl unmount -b /dev/disk/by-label/t7 || notify_and_exit "Failed unmounting T7"
  udisksctl lock -b /dev/disk/by-partlabel/t7-part || notify_and_exit "Failed unmounting T7"
  udisksctl power-off -b /dev/disk/by-partlabel/t7-part || notify_and_exit "Failed unmounting T7"

  notify-send "T7 is powered-off" > /dev/null
fi
