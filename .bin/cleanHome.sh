#!/bin/bash

# vacuum firefox's sqlite files
vacuumFirefox()
{
  pidof firefox && {
    echo "ERROR: firefox is still running, close it first!"
    return 1
  }
  which sqlite3 &>/dev/null || {
    echo "ERROR: sqlite3 is not installed. Do 'sudo apt-get install sqlite3' first"
    return 1
  }

  local counterBefore=0
  local counterAfter=0
  local fileSizeBefore fileSizeAfter
  local hDir=$homeDir
  [ -z "$hDir" ] && hDir=~/

  for i in "$hDir"/.mozilla/firefox/*/*.sqlite; do
    fileSizeBefore=$(wc -c < $i)
    counterBefore=$((counterBefore + fileSizeBefore))
    sqlite3 "$i" vacuum
    fileSizeAfter=$(wc -c < $i)
    counterAfter=$((counterAfter + fileSizeAfter))
    echo "$fileSizeBefore $fileSizeAfter - $(basename $i)"
  done
  echo "Firefox Bytes saved: $(( counterBefore - counterAfter ))"
  return 0
}

homeSizeBefore=$(du -sb $HOME 2>/dev/null|awk '{ print $1 }')

# cleaning phase
vacuumFirefox || exit 1
cd "$HOME"
xargs -d \\n -I {} bash -c "echo 'Cleaning $HOME/{}';rm -rf $HOME/{}" <<EOLIST
.thumbnails/*
.cache/*
.local/share/Trash/*
.adobe/Flash_Player/AssetCache/*
.mozilla/firefox/*/Cache/*
.davfs2/cache/*
.config/sublime-text-3/Cache/*
EOLIST

homeSizeAfter=$(du -sb $HOME 2>/dev/null|awk '{ print $1 }')

echo "Home total bytes saved: $(( homeSizeBefore - homeSizeAfter ))"
