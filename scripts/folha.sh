#!/bin/bash
# folha.sh: junta várias imagens numa folha só, em grade de 4 colunas, para a pessoa aprovar tudo de uma vez.
# As imagens entram na ordem em que você passa, da esquerda para a direita e de cima para baixo.
#
# uso: folha.sh <saida.jpg> <imagem1> <imagem2> ...
set -u
if [ $# -lt 2 ]; then sed -n '2,5p' "$0"; exit 2; fi
out="$1"; shift
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
n=0
for f in "$@"; do
  [ -f "$f" ] || { echo "aviso: não existe, pulei: $f"; continue; }
  n=$((n+1))
  ffmpeg -nostdin -v error -y -i "$f" -vf "scale=480:360:force_original_aspect_ratio=decrease,pad=480:360:(ow-iw)/2:(oh-ih)/2:color=0x202020" -frames:v 1 -update 1 -q:v 3 "$tmp/$(printf '%03d' "$n").jpg"
done
[ "$n" -gt 0 ] || { echo "ERRO: nenhuma imagem válida"; exit 1; }
col=4; [ "$n" -lt 4 ] && col="$n"
lin=$(( (n + col - 1) / col ))
mkdir -p "$(dirname "$out")"
ffmpeg -nostdin -v error -y -framerate 1 -i "$tmp/%03d.jpg" -vf "tile=${col}x${lin}:padding=8:margin=8:color=0x202020" -frames:v 1 -update 1 -q:v 3 "$out" || { echo "ERRO ao criar a folha"; exit 1; }
echo "ok: $out | $n imagens em ${col} colunas"
