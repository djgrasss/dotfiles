#!/bin/bash

wpath=${1:-~/wallpapers}
feh --bg-scale "$(find "${wpath}" -iname '*'|shuf|head -n1)"

