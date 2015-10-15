#!/bin/bash

ffmpeg -f x11grab -s 1920x1080 -r 15 -i $DISPLAY -f alsa -i pulse -codec:v libx264 -b:v 1200k -maxrate 1200k -bufsize 1200k -preset faster -vf fps=25 -pix_fmt yuv420p -profile:v main -g 25 -codec:a aac -strict -2 -b:a 128k -f flv rtmp://192.168.2.131:1935/live/test
