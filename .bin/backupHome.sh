#!/bin/bash

homeDir=$HOME
destDir=/media/nas/Alex/backup
archName="$(whoami).$(hostname)"

# files or directories to exclude
printExcludes()
{
awk '{printf("--exclude '\''%s'\'' ",$1)}'  <<EOEXCL
.gvfs
.qt
.adobe
ssmtp
.aptitude
.dbus
.gconf
.eagle
.encfs
.davfs2
.macromedia
.gnome
.java
.cache
.pulse*
.smbcredentials
.thumbnails
Books
Downloads
games
VirtualBox*
EOEXCL
}

~/bin/cleanHome.sh || exit 1

# creating an archive
if [ -d "$destDir" ]; then
  exe=$(echo "tar -czf \"${destDir}/${archName}.$(date +%Y-%m-%d).tgz\" $(printExcludes) -C $homeDir ./")
  echo "$exe" 
  eval "$exe" 
else
  echo "ERROR: Directory $destDir doesn't exist. Canno't create an archive"
  exit 1
fi

