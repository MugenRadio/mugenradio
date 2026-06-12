#!/bin/sh
# Diffusion 24/7 : vidéo en boucle recopiée (CPU ~0) + playlist audio encodée.
# HLS toujours actif. Les sorties RTMP ne sont ajoutées que si la clé existe.
#
# Note architecture : on n'utilise pas -f tee car le muxeur FLV de ffmpeg 5.1
# rejette le codec_tag "avc1" (MP4/AVCC) à l'écriture de l'en-tête, même avec
# -bsf:v h264_mp4toannexb. Les sorties multiples ffmpeg natif + BSF par output
# contournent le problème : HLS reçoit la copie directe, FLV reçoit la même
# copie après conversion AVCC→Annex-B par h264_mp4toannexb.
set -eu
DATA=/data
VIDEO="$DATA/video/loop.mp4"
PLAYLIST="$DATA/playlist.txt"
mkdir -p "$DATA/hls"

# Arguments ffmpeg communs aux sorties RTMP (video copy + BSF + audio AAC).
RTMP_ENC="-c:v copy -bsf:v h264_mp4toannexb -c:a aac -b:a 160k -ar 44100 -ac 2 -f flv"

# RTMP — ajouté conditionnellement.
RTMP_OUT=""
if [ -n "${TWITCH_STREAM_KEY:-}" ]; then
  RTMP_OUT="$RTMP_OUT -map 0:v -map 1:a $RTMP_ENC rtmp://live.twitch.tv/app/$TWITCH_STREAM_KEY"
fi
if [ -n "${YOUTUBE_STREAM_KEY:-}" ]; then
  RTMP_OUT="$RTMP_OUT -map 0:v -map 1:a $RTMP_ENC rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_KEY"
fi

# shellcheck disable=SC2086
exec ffmpeg -hide_banner -loglevel warning \
  -re -stream_loop -1 -fflags +genpts -i "$VIDEO" \
  -re -f concat -safe 0 -i "$PLAYLIST" \
  -progress "$DATA/.stream-progress" \
  -map 0:v -map 1:a -c:v copy -c:a aac -b:a 160k -ar 44100 -ac 2 \
  -f hls -hls_time 4 -hls_list_size 10 -hls_flags delete_segments \
  "$DATA/hls/live.m3u8" \
  $RTMP_OUT
