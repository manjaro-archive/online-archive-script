#!/bin/env bash

set -e

source /home/tuxboyeu/domains/manjaro.tuxboy.eu/public_html/.server_url

# Grab pkgs list from Manjaro repository
cd /home/tuxboyeu/domains/manjaro.tuxboy.eu/public_html/$1-archive
startdir=$(pwd)

url=$(cat $startdir/$1-list)
pkg=$(cat $startdir/$1-list | cut -d '/' -f5)
rm -f $startdir/.pkgs-list
rm -f $startdir/.files-name.list

# Create pkg's url
for line in $url; do
	echo "$server_url"/"$line" >> $startdir/.pkgs-list
    echo "$server_url"/"$line".sig >> $startdir/.pkgs-list
done

# Check if already pkg exist and then remove from pkgs list
for i in $pkg; do
    if [[ -f "$startdir/$i" ]]; then
        sed -i "/$i/d" "$startdir/.pkgs-list"
    fi
done

# Download only the necessary pkgs
if [[ -s "$startdir/.pkgs-list" ]]; then
    cat $startdir/.pkgs-list | xargs -n 1 -P 8 wget -nc -P $startdir
    echo "All files uploaded into $1 server"
else echo 'Nothing to do, all files already here.'
fi

# Create file wich containing unique filenames
ls | sed -e 's/-\([0-9]\)/ \1/' | awk '{print $1}' | uniq >> $startdir/.files-name.list

# Keep only the last 10 old versions of every file ( considering also the .sig files )
for name in $( cat $startdir/.files-name.list ); do 
    ls -t | grep -E "^$name-+[0-9]" | awk 'NR>20 {print $1}' | xargs rm -vf
done

echo 'Removed old files completed'

# List pkgs
ls > .$1-pkgs-list 
