#!/bin/bash
# ambiente.sh: confere o que o computador tem para montar o clipe. Não instala nada.
# uso: ambiente.sh
tem() { command -v "$1" >/dev/null 2>&1; }
echo "sistema: $(uname -s) $(uname -m)"
if tem ffmpeg; then echo "ffmpeg: sim ($(ffmpeg -version 2>/dev/null | head -1 | cut -d' ' -f3))"; else echo "ffmpeg: NÃO (obrigatório para montar)"; fi
if tem ffprobe; then echo "ffprobe: sim"; else echo "ffprobe: NÃO (vem junto com o ffmpeg)"; fi
if tem curl; then echo "curl: sim"; else echo "curl: NÃO (obrigatório para baixar e enviar arquivos)"; fi
if tem whisper-cli; then echo "transcrição: whisper-cli"
elif tem whisper; then echo "transcrição: whisper"
elif tem mlx_whisper; then echo "transcrição: mlx_whisper"
else echo "transcrição: nenhuma (opcional; sem ela, os tempos da letra são conferidos com a pessoa)"; fi
if tem ffmpeg; then
  for f in zoompan tile ebur128 silencedetect tpad amix; do
    ffmpeg -hide_banner -filters 2>/dev/null | grep -q " $f " || echo "aviso: este ffmpeg não tem o filtro $f"
  done
fi
echo "pasta atual: $(pwd)"
echo "espaço livre: $(df -h . | awk 'NR==2{ print $4 }')"
