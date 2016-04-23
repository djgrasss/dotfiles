#!/bin/bash

wpath=${1:-~/wallpapers}
img_count=$(ls -1 ${wpath}/* | wc -l)

feh --bg-scale $(sed -n $(( (RANDOM % img_count)+1))p <(ls -1 ${wpath}/*))

