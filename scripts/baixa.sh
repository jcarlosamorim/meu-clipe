#!/bin/bash
# baixa.sh: baixa um arquivo gerado (imagem ou vídeo) para a pasta do clipe.
# Se for vídeo e você passar o terceiro argumento, cria também uma folha com 8 quadros para conferir a tomada de relance.
#
# uso: baixa.sh <endereço> <destino> [folha.jpg]
set -u
if [ $# -lt 2 ]; then sed -n '2,5p' "$0"; exit 2; fi
url="$1"; dest="$2"; folha="${3:-}"
mkdir -p "$(dirname "$dest")"
if [ -e "$dest" ]; then echo "ERRO: já existe um arquivo em $dest. Escolha outro nome para não apagar nada."; exit 1; fi
curl -sS -f -L --retry 2 -o "$dest" "$url" || { rm -f "$dest"; echo "ERRO: não consegui baixar para $dest"; exit 1; }
case "$(printf '%s' "$dest" | tr '[:upper:]' '[:lower:]')" in
  *.mp4|*.mov|*.webm)
    d="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$dest")"
    tam="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0:s=x "$dest")"
    if [ -n "$folha" ]; then
      mkdir -p "$(dirname "$folha")"
      ffmpeg -nostdin -v error -y -i "$dest" -vf "fps=8/${d},scale=480:-2,tile=4x2" -frames:v 1 -q:v 4 "$folha" || echo "aviso: não consegui criar a folha $folha"
    fi
    echo "ok: $dest | ${d}s | ${tam}${folha:+ | folha: $folha}" ;;
  *) echo "ok: $dest | $(du -h "$dest" | cut -f1)" ;;
esac
