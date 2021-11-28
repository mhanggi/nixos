#!/usr/bin/env bash

now=$(date +"%Y-%m-%d")

src=/run/media/marc/t7
dst=~/backup/"$now"_confidential-archive.tar.gz.gpg

if [[ ! -d $src ]]
then
  echo "T7 is not mounted"
  read -s -n 1 -p "Press any key to exit"
  exit 1
fi

echo "Writing backup to $dst"
mkdir -p $dst_dir

if [[ -f $dst ]]
then
  echo "Deleting existing backup file"
  rm $dst
fi

echo "Touch the Yubikey!"
password=$(pass show backup/confidential)

echo "Creating TAR file T7 content"
tar --exclude="$src/lost+found" -cvzf  - $src | gpg \
  --symmetric \
  --s2k-mode 3 \
  --s2k-count 65011712 \
  --s2k-digest-algo SHA512 \
  --s2k-cipher-algo AES256 \
  --batch \
  --passphrase <(pass show backup/confidential) \
  -o $dst

echo "Done"
read -s -n 1 -p "Press any key to exit"
