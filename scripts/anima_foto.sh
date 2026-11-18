#!/bin/bash
# anima_foto.sh: transforma uma imagem parada em vídeo com zoom e deslocamento lentos.
# Use para telas com texto, fotos, cartazes e documentos: o texto fica nítido, o que não acontece em vídeo gerado.
#
# uso: anima_foto.sh <imagem> <saida.mp4> <duracao_s> <zoom_inicial> <zoom_final> [x0 y0 x1 y1]
#   zoom   1.0 mostra a imagem inteira; 1.3 aproxima 30%
#   x e y  para onde o quadro olha, de 0 a 1 (0.5 0.5 é o centro). Padrão: centro, sem deslocar.
# ambiente: LARGURA (1280), ALTURA (720), FPS (24)
# exemplo: anima_foto.sh telas/conversa.png tomadas/v1/tela.mp4 4 1.0 1.25 0.5 0.5 0.6 0.4
set -u
if [ $# -lt 5 ]; then sed -n '2,10p' "$0"; exit 2; fi
in="$1"; out="$2"; dur="$3"; z0="$4"; z1="$5"
x0="${6:-0.5}"; y0="${7:-0.5}"; x1="${8:-$x0}"; y1="${9:-$y0}"
W="${LARGURA:-1280}"; H="${ALTURA:-720}"; FPS="${FPS:-24}"
[ -f "$in" ] || { echo "ERRO: imagem não encontrada: $in"; exit 2; }
mkdir -p "$(dirname "$out")"
n="$(awk -v d="$dur" -v f="$FPS" 'BEGIN{ printf "%d", d*f+0.5 }')"
P="(on/(${n}-1))"
# a imagem é ampliada 4 vezes antes do zoom para o movimento sair liso, sem tremer
ffmpeg -nostdin -v error -y -loop 1 -i "$in" -vf "scale=$((W*4)):$((H*4)):force_original_aspect_ratio=increase:flags=lanczos,crop=$((W*4)):$((H*4)),zoompan=z='${z0}+(${z1}-${z0})*${P}':x='(iw-iw/zoom)*(${x0}+(${x1}-${x0})*${P})':y='(ih-ih/zoom)*(${y0}+(${y1}-${y0})*${P})':d=${n}:s=${W}x${H}:fps=${FPS},format=yuv420p" \
  -frames:v "$n" -c:v libx264 -crf 14 -preset medium "$out" || { echo "ERRO ao animar $in"; exit 1; }
echo "ok: $out | $(ffprobe -v error -show_entries format=duration -of csv=p=0 "$out")s | ${W}x${H}"
