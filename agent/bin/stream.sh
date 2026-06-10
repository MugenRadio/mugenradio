#!/bin/sh
# Diffusion 24/7 : vidéo en boucle recopiée (CPU ~0) + playlist audio encodée.
# Les sorties RTMP ne sont ajoutées que si la clé existe ; HLS toujours actif.
# La playlist est au format ffconcat et s'auto-référence en dernière ligne :
# c'est ce qui fait boucler l'audio (-stream_loop ne marche pas sur concat).
set -eu
DATA=/data
VIDEO="$DATA/video/loop.mp4"
PLAYLIST="$DATA/playlist.txt"
mkdir -p "$DATA/hls"
OUTPUTS="[f=hls:hls_time=4:hls_list_size=10:hls_flags=delete_segments]$DATA/hls/live.m3u8"
if [ -n "${TWITCH_STREAM_KEY:-}" ]; then
  OUTPUTS="[f=flv:onfail=ignore]rtmp://live.twitch.tv/app/$TWITCH_STREAM_KEY|$OUTPUTS"
fi
if [ -n "${YOUTUBE_STREAM_KEY:-}" ]; then
  OUTPUTS="[f=flv:onfail=ignore]rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_KEY|$OUTPUTS"
fi
exec ffmpeg -hide_banner -loglevel warning \
  -re -stream_loop -1 -fflags +genpts -i "$VIDEO" \
  -re -f concat -safe 0 -i "$PLAYLIST" \
  -map 0:v -map 1:a -c:v copy -c:a aac -b:a 160k -ar 44100 -ac 2 \
  -progress "$DATA/.stream-progress" \
  -f tee "$OUTPUTS"
