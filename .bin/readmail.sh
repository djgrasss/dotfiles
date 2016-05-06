#!/bin/bash

fetchmail -s -f ~/fetchmail/.fetchmailrc --mda "$HOME/bin/catmail.sh %T %F" 2>>/tmp/fetchmail.err
