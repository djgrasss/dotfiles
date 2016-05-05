#!/bin/bash

wpath=${1:-~/wallpapers}
feh --bg-scale $(ls -1 ${wpath}/*|shuf|head -n1)

