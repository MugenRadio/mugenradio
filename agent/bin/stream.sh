#!/bin/sh
# Diffusion 24/7. Deux processus indépendants pour la résilience :
#  - HLS (premier plan) : le flux du site, ne doit JAMAIS mourir. Vidéo recopiée.
#  - push RTMP (arrière-plan, supervisé) : YouTube/Twitch ; s'il tombe (coupure
#    plateforme, réseau), il se relance seul SANS couper le site.
#
# Note FLV : le muxeur FLV de ffmpeg 5.1 rejette le codec_tag "avc1" (MP4/AVCC)
# de la boucle. Les sorties RTMP convertissent en Annex-B via h264_mp4toannexb
# (la vidéo reste en copie, pas de réencodage). HLS, lui, lit l'AVCC nativement.
set -eu
DATA=/data
VIDEO="$DATA/video/loop.mp4"
PLAYLIST="$DATA/playlist.txt"
mkdir -p "$DATA/hls"
# Repart propre : purge les segments d'un run précédent (évite les conflits
# d'écriture au démarrage). Le dossier appartient à l'uid du pod.
rm -f "$DATA"/hls/*.ts "$DATA"/hls/live.m3u8 2>/dev/null || true

# --- push RTMP, supervisé, isolé du HLS ---
RTMP_ENC="-c:v copy -bsf:v h264_mp4toannexb -c:a aac -b:a 160k -ar 44100 -ac 2 -f flv"
RTMP_OUT=""
if [ -n "${TWITCH_STREAM_KEY:-}" ]; then
  RTMP_OUT="$RTMP_OUT -map 0:v -map 1:a $RTMP_ENC rtmp://live.twitch.tv/app/$TWITCH_STREAM_KEY"
fi
if [ -n "${YOUTUBE_STREAM_KEY:-}" ]; then
  RTMP_OUT="$RTMP_OUT -map 0:v -map 1:a $RTMP_ENC rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_KEY"
fi
if [ -n "$RTMP_OUT" ]; then
  (
    while true; do
      # shellcheck disable=SC2086
      ffmpeg -hide_banner -loglevel error \
        -re -stream_loop -1 -fflags +genpts -i "$VIDEO" \
        -re -f concat -safe 0 -i "$PLAYLIST" \
        $RTMP_OUT || true
      sleep 5
    done
  ) &
fi

# --- HLS, premier plan : le processus qui doit rester en vie ---
exec ffmpeg -hide_banner -loglevel warning \
  -re -stream_loop -1 -fflags +genpts -i "$VIDEO" \
  -re -f concat -safe 0 -i "$PLAYLIST" \
  -progress "$DATA/.stream-progress" \
  -map 0:v -map 1:a -c:v copy -c:a aac -b:a 160k -ar 44100 -ac 2 \
  -f hls -hls_time 4 -hls_list_size 10 -hls_flags delete_segments \
  "$DATA/hls/live.m3u8"
