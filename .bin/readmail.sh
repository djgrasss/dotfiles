#!/bin/bash

fetchmail -s -f ~/fetchmail/.fetchmailrc --mda "~/bin/catmail.sh %T %F" 2>>/tmp/fetchmail.err
