#!/bin/bash

# $1 - local delivery address
# $2 - from address

#echo "To: $1"
#echo "From: $2"

awk '{if(f==1){print $0};if(match($0,/^Message-ID/)){f=1;for(i=0;i<55;++i){printf("-")};print ""}}' -

