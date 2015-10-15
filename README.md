# Home Live Streaming Setup

This repository contains everything you'll need to stream your desktop from your home machine to a streaming server to a client viewing your stream in their browser or on their mobile device.  To stream we'll use ffmpeg, which can also grab a webcam, network camera, portions of your desktop, etc. although another GREAT option is the Open Broadcaster Software (obs) Studio, available open-source for Windows, Mac, and Linux.  OBS is pretty point and click though, just enter "Custom Streaming Server" and copy the URL from the ffmpeg example and you're set.

# ffmpeg

This great open-source audio/video tool can be used to stream RTMP data to our streaming server (nginx).  The exact command you'll want is stored in the ffmpeg.sh file in this repository, copied below for your convenience:

    ffmpeg -f x11grab -s 1920x1080 -r 15 -i $DISPLAY \
           -f alsa -i pulse \
           -c:v libx264 -b:v 1200k -maxrate 1200k -bufsize 1200k -preset faster \
           -vf fps=25 -pix_fmt yuv420p -profile:v main -g 25 -c:a aac -strict -2 -b:a 128k -f flv \
           rtmp://<server URL here>:1935/live/test

In case you're not familiar with ffmpeg, here's what the various options are doing.  First, we specify the video source, here x11grab to grab the desktop, ``-s`` specifies the size of the screen to grab, ``-r`` is the framerate and ``-i $DISPLAY`` uses the current desktop/x11 display.  Next, we specify the audio source, ``-i pulse`` means grab whatever audio is playing on the machine, so we'll capture audio output from youtube or video games, for example.

Finally, we specify the encoding parameters, which, in summary, encode in x264 video and AAC audio FLV format and stream the result to rtmp://<server URL goes here>:1935/live/test.  The /live portion of the URL is called the RTMP Application and is merely the default I chose when creating the default nginx.conf I include with the Dockerfile, you can have multiple applications and they can have any names you want.  The /test portion is called the Stream Key and is unique to each stream you upload for that application.  It is NOT preselected, i.e. you can type whatever you want in the ffmpeg URL in place of /test and it'll still upload correctly.  You'll need the stream key when you view the stream in the browser though, so make sure you remember/store it.

# Nginx w/ RTMP plugin

This is the Dockerfile that's included with the repository.  Feel free to read it and modify the portions you choose, it basically downloads the Nginx source code, the Nginx-RTMP plugin source code, and compiles one into the other, after installing some dependencies.  Then it conveniently stores the configuration directory under /src/conf instead of /usr/local/nginx/conf which I found to be a bit verbose, but thats easily changed back if you don't like it.  I also add a default nginx.conf to make nginx run in the foreground ("daemon off"! very important!) and adds a default RTMP server running on port 1935 and listening for an application "live", serving up HLS and RTMP streams and allowing everyone to view it.  Check out https://github.com/arut/nginx-rtmp-module for full details on the RTMP module.

To build the Nginx-RTMP docker container, run

    docker build -t <your repo>/nginx-rtmp .

and to run Nginx w/ RTMP enabled using your own nginx.conf file

    docker run --rm -ti -v $(pwd)/nginx.conf:/src/conf/nginx.conf -p 1935:1935 <your repo>/nginx-rtmp

# Client Side Code

Here I've included a copy of an index.html that uses Video.JS to load a flash player that will read one of two streams with keys "test" and "test2" respectively.  You CAN stream to both simultaneously, from any machine that can reach the server.  There is NO authentication enabled, so ANYONE can stream to these keys, keep that in mind if you put in on the internet!  Just start a local webserver (or figure out where nginx stores HTML files by default, and have Nginx serve the files as well as stream RTMP) to serve the index.html and related javascript files and, once you've changed your server URL to point to your server (instead of mine), it should work.

# Change Your Server URL !

You need to change it in 2 files, ffmpeg.sh, and several times in index.html.

# Profit

You should be able to run

    ./ffmpeg.sh

to start streaming your desktop, ``docker run`` to start the NGINX w/ RTMP server, open your web browser and point it to the index.html file, and have your desktop stream through to your browser!  This should work in any flash-enabled browser or mobile device (using HLS).  Believe me, I tried other solutions, and there's nothing so clean and reliable as RTMP, at least not yet.  Enjoy!
