#!/bin/bash

set -e

source /home/tuxboyeu/domains/manjaro.tuxboy.eu/public_html/.server_url

#Grab pkgs list from Manjaro repository
cd /home/tuxboyeu/domains/manjaro.tuxboy.eu/public_html/$1-archive
startdir=$(pwd)

url=$(cat $startdir/$1-list)
rm -f $startdir/.pkgs-list
rm -f $startdir/.files-name.list

for line in $url; do
	echo "$server_url"/"$line" >> $startdir/.pkgs-list
    echo "$server_url"/"$line".sig >> $startdir/.pkgs-list
done

cat $startdir/.pkgs-list | xargs -n 1 -P 8 wget -nc -P $startdir

echo "All files are upload into $1 server"

# Create file wich containing unique filenames
ls | sed -e 's/-\([0-9]\)/ \1/' | awk '{print $1}' | uniq >> $startdir/.files-name.list

# Keep only the last 15 old versions of every file
for name in $( cat $startdir/.files-name.list ); do 
    ls -t | grep -E "^$name-+[0-9]" | awk 'NR>15 {print $1}' | xargs rm -vf
done

echo 'Removed old files completed'

# List pkgs
ls > .$1-pkgs-list 
