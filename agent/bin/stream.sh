#!/bin/sh
# Diffusion 24/7. Deux processus indépendants pour la résilience :
#  - HLS (premier plan) : le flux du site, ne doit JAMAIS mourir. Vidéo recopiée.
#  - push RTMP (arrière-plan, supervisé) : YouTube/Twitch ; s'il tombe (coupure
#    plateforme, réseau), il se relance seul SANS couper le site.
#
# Note FLV/boucle : le muxeur FLV rejette le codec_tag "avc1" (MP4/AVCC), et le
# filtre h264_mp4toannexb appliqué à un -stream_loop plante à chaque rebouclage
# ("non-NULL packet after EOF"). Solution : on convertit la boucle UNE fois en
# MPEG-TS (Annex-B) au démarrage, puis le push RTMP la lit en copie pure, sans
# filtre. C'est la méthode standard de restream RTMP. HLS garde le .mp4 d'origine.
set -eu
DATA=/data
VIDEO="$DATA/video/loop.mp4"
VIDEO_TS="$DATA/video/loop.ts"
PLAYLIST="$DATA/playlist.txt"
mkdir -p "$DATA/hls"
# Repart propre : purge les segments d'un run précédent (conflits d'écriture).
rm -f "$DATA"/hls/*.ts "$DATA"/hls/live.m3u8 2>/dev/null || true

# --- sorties RTMP (copie pure depuis le .ts Annex-B, aucun filtre) ---
RTMP_ENC="-c:v copy -c:a aac -b:a 160k -ar 44100 -ac 2 -f flv"
RTMP_OUT=""
if [ -n "${TWITCH_STREAM_KEY:-}" ]; then
  RTMP_OUT="$RTMP_OUT -map 0:v -map 1:a $RTMP_ENC rtmp://live.twitch.tv/app/$TWITCH_STREAM_KEY"
fi
if [ -n "${YOUTUBE_STREAM_KEY:-}" ]; then
  RTMP_OUT="$RTMP_OUT -map 0:v -map 1:a $RTMP_ENC rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_KEY"
fi
if [ -n "$RTMP_OUT" ]; then
  # Conversion unique mp4(avc1) -> ts(annexb) : passe finie, le filtre tourne
  # une seule fois, proprement. Le push boucle ensuite ce .ts en copie.
  ffmpeg -hide_banner -loglevel error -y -i "$VIDEO" \
    -c:v copy -bsf:v h264_mp4toannexb -an -f mpegts "$VIDEO_TS" || true
  (
    while true; do
      # shellcheck disable=SC2086
      ffmpeg -hide_banner -loglevel error \
        -re -stream_loop -1 -fflags +genpts -i "$VIDEO_TS" \
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
