#!/bin/sh
# Diffusion 24/7. Processus indépendants pour la résilience :
#  - HLS (premier plan) : le flux du site, ne doit JAMAIS mourir. Vidéo recopiée.
#  - un push RTMP par plateforme (arrière-plan, supervisé, ISOLÉ) : si Twitch
#    tombe, ni YouTube ni le site n'en souffrent ; chaque push se relance seul.
#
# Chaque push écrit un battement de cœur /data/.rtmp-<nom> (que le réveil ops de
# l'agent surveille). HLS écrit /data/.stream-progress.
#
# Note FLV/boucle : le muxeur FLV rejette le codec_tag "avc1" (MP4/AVCC), et
# h264_mp4toannexb sur un -stream_loop plante au rebouclage. On convertit donc
# la boucle UNE fois en MPEG-TS (Annex-B) au démarrage ; le push la lit en copie
# pure. HLS garde le .mp4 d'origine.
set -eu
DATA=/data
VIDEO="$DATA/video/loop.mp4"
VIDEO_TS="$DATA/video/loop.ts"
PLAYLIST="$DATA/playlist.txt"
mkdir -p "$DATA/hls"
rm -f "$DATA"/hls/*.ts "$DATA"/hls/live.m3u8 "$DATA"/.rtmp-* 2>/dev/null || true

# Un push RTMP supervisé vers une plateforme. $1 = nom (heartbeat), $2 = url.
push_one() {
  _name=$1
  _url=$2
  while true; do
    ffmpeg -hide_banner -loglevel error \
      -re -stream_loop -1 -fflags +genpts -i "$VIDEO_TS" \
      -re -f concat -safe 0 -i "$PLAYLIST" \
      -map 0:v -map 1:a -c:v copy -c:a aac -b:a 160k -ar 44100 -ac 2 \
      -progress "$DATA/.rtmp-$_name" -f flv "$_url" || true
    sleep 5
  done
}

if [ -n "${TWITCH_STREAM_KEY:-}" ] || [ -n "${YOUTUBE_STREAM_KEY:-}" ]; then
  # Conversion unique mp4(avc1) -> ts(annexb) : passe finie, filtre propre.
  ffmpeg -hide_banner -loglevel error -y -i "$VIDEO" \
    -c:v copy -bsf:v h264_mp4toannexb -an -f mpegts "$VIDEO_TS" || true
  [ -n "${TWITCH_STREAM_KEY:-}" ] && \
    push_one twitch "rtmp://live.twitch.tv/app/$TWITCH_STREAM_KEY" &
  [ -n "${YOUTUBE_STREAM_KEY:-}" ] && \
    push_one youtube "rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_KEY" &
fi

# --- HLS, premier plan : le processus qui doit rester en vie ---
exec ffmpeg -hide_banner -loglevel warning \
  -re -stream_loop -1 -fflags +genpts -i "$VIDEO" \
  -re -f concat -safe 0 -i "$PLAYLIST" \
  -progress "$DATA/.stream-progress" \
  -map 0:v -map 1:a -c:v copy -c:a aac -b:a 160k -ar 44100 -ac 2 \
  -f hls -hls_time 4 -hls_list_size 10 -hls_flags delete_segments \
  "$DATA/hls/live.m3u8"
