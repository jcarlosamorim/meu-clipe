#!/bin/bash
# quadro.sh: tira um quadro de um vídeo como imagem.
# Serve para conferir uma tomada e para usar o último quadro de uma tomada como primeiro quadro da seguinte.
#
# uso: quadro.sh <video> <saida.png> [ultimo|primeiro|segundos]     (padrão: ultimo)
set -u
if [ $# -lt 2 ]; then sed -n '2,5p' "$0"; exit 2; fi
v="$1"; out="$2"; onde="${3:-ultimo}"
[ -f "$v" ] || { echo "ERRO: vídeo não encontrado: $v"; exit 2; }
mkdir -p "$(dirname "$out")"
case "$onde" in
  ultimo)   ffmpeg -nostdin -v error -y -sseof -0.25 -i "$v" -update 1 -q:v 1 "$out" ;;
  primeiro) ffmpeg -nostdin -v error -y -i "$v" -frames:v 1 -update 1 -q:v 1 "$out" ;;
  *)        ffmpeg -nostdin -v error -y -ss "$onde" -i "$v" -frames:v 1 -update 1 -q:v 1 "$out" ;;
esac
[ -s "$out" ] && echo "ok: $out (quadro: $onde)" || { echo "ERRO: não consegui tirar o quadro"; exit 1; }
