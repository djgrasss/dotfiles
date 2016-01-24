#!/bin/bash

fetchmail -s -f ~/fetchmail/.fetchmailrc --mda "/home/alex/bin/catmail.sh %T %F" 2>>/tmp/fetchmail.err
