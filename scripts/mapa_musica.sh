#!/bin/bash
# mapa_musica.sh: mede a música para ajudar a achar onde cada parte começa, sem depender de transcrição.
#
# uso: mapa_musica.sh <musica> [saida.txt]
# Mostra a duração, o volume segundo a segundo, os pontos em que o volume sobe ou cai de repente
# (candidatos a entrada de refrão, pausa e virada) e os silêncios.
set -u
if [ $# -lt 1 ]; then sed -n '2,6p' "$0"; exit 2; fi
m="$1"; out="${2:-}"
[ -f "$m" ] || { echo "ERRO: música não encontrada: $m"; exit 2; }
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$m")"
ffmpeg -nostdin -hide_banner -i "$m" -af "ebur128=peak=none:framelog=verbose" -v verbose -f null - 2> "$tmp/eb.txt"
ffmpeg -nostdin -hide_banner -i "$m" -af "silencedetect=noise=-38dB:d=0.5" -f null - 2> "$tmp/sil.txt"

# volume momentâneo (janela de 0,4 s): média de cada segundo
sed -n 's/.* t: *\([0-9.]*\) .* M: *\(-*[0-9.]*\) S:.*/\1 \2/p' "$tmp/eb.txt" \
  | awk '{ s=int($1); x=$2; if (x<-70) x=-70; soma[s]+=x; n[s]++; if (s>mx) mx=s } END{ for (i=0;i<=mx;i++) if (n[i]) printf "%d %.1f\n", i, soma[i]/n[i] }' > "$tmp/s.txt"

{
  echo "MAPA DA MÚSICA: $(basename "$m")"
  awk -v d="$dur" 'BEGIN{ printf "duração: %.2f s (%d:%05.2f)\n", d, int(d/60), d-60*int(d/60) }'
  grep -o 'I: *-*[0-9.]* LUFS' "$tmp/eb.txt" | tail -1 | sed 's/I: */volume médio: /'
  echo
  echo "VOLUME SEGUNDO A SEGUNDO (LUFS; quanto mais perto de zero, mais forte; -70 é silêncio)"
  awk '{ if ($1%10==0) printf "%s%4d s |", (NR>1?"\n":""), $1; printf " %6.1f", $2 } END{ print "" }' "$tmp/s.txt"
  echo
  echo "VIRADAS (a média de 2 segundos muda 2 LU ou mais em relação aos 2 segundos anteriores)"
  awk '{ t[NR]=$1; v[NR]=$2 }
       END{ ult=-10
            for (i=3;i<NR;i++) { d=(v[i]+v[i+1])/2-(v[i-1]+v[i-2])/2; a=(d>0?d:-d);
              if (a>=2) { if (t[i]-ult>=3) { if (ult>=0) printf "  %3d:%02d  %s %.1f LU\n", int(tm/60), tm%60, (dm>0?"sobe":"cai"), (dm>0?dm:-dm); tm=t[i]; dm=d; ult=t[i] }
                          else if (a>(dm>0?dm:-dm)) { tm=t[i]; dm=d } } }
            if (ult>=0) printf "  %3d:%02d  %s %.1f LU\n", int(tm/60), tm%60, (dm>0?"sobe":"cai"), (dm>0?dm:-dm); else print "  nenhuma virada forte: a música tem volume constante" }' "$tmp/s.txt"
  echo
  echo "SILÊNCIOS (abaixo de -38 dB por mais de meio segundo)"
  awk '/silence_start/ { ini=$NF } /silence_end/ { for (i=1;i<=NF;i++) if ($i=="silence_end:") fim=$(i+1); printf "  de %.2f s a %.2f s\n", ini, fim; n++ }
       END{ if (!n) print "  nenhum" }' "$tmp/sil.txt"
} > "$tmp/mapa.txt"

if [ -n "$out" ]; then mkdir -p "$(dirname "$out")"; cp "$tmp/mapa.txt" "$out"; fi
cat "$tmp/mapa.txt"
