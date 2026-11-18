#!/bin/bash
# junta.sh: junta os blocos montados no clipe final, com a música por baixo, cada bloco no tempo certo da música.
#
# uso: junta.sh <blocos.txt> <musica> <saida.mp4> [sons.txt]
# ambiente: LARGURA (1280), ALTURA (720), FPS (24), FIM (segundo da música em que o clipe acaba; padrão: fim da música),
#           FADE (segundos de saída do som no final; padrão 1.2), FADE_VIDEO=1 para escurecer a imagem junto
#
# blocos.txt, uma linha por bloco, na ordem da música:
#   arquivo_do_bloco.mp4|segundo_da_musica_em_que_o_bloco_comeca
#   O clipe começa no início do primeiro bloco. Cada bloco ocupa o tempo até o início do seguinte:
#   se for mais curto, o último quadro é repetido; se for mais longo, é cortado. O programa avisa as diferenças.
#
# sons.txt (opcional), efeitos sonoros por cima da música:
#   arquivo.wav|segundo_da_musica|volume_em_dB      exemplo: sons/porta.wav|37.9|-2
set -u
if [ $# -lt 3 ]; then sed -n '2,16p' "$0"; exit 2; fi
blocos="$1"; musica="$2"; saida="$3"; sons="${4:-}"
W="${LARGURA:-1280}"; H="${ALTURA:-720}"; FPS="${FPS:-24}"; FADE="${FADE:-1.2}"
[ -f "$blocos" ] || { echo "ERRO: lista de blocos não encontrada: $blocos"; exit 2; }
[ -f "$musica" ] || { echo "ERRO: música não encontrada: $musica"; exit 2; }
durmus="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$musica")"
FIM="${FIM:-$durmus}"

arqs=(); inis=()
while IFS='|' read -r a t || [ -n "${a:-}" ]; do
  a="$(printf '%s' "${a:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [ -z "$a" ] && continue
  case "$a" in \#*) continue ;; esac
  [ -f "$a" ] || { echo "ERRO: bloco não existe: $a"; exit 2; }
  arqs+=("$a"); inis+=("$(printf '%s' "$t" | tr -d '[:space:]')")
done < "$blocos"
nb="${#arqs[@]}"
[ "$nb" -gt 0 ] || { echo "ERRO: a lista de blocos está vazia"; exit 1; }
INICIO="${inis[0]}"
total="$(awk -v a="$INICIO" -v b="$FIM" 'BEGIN{ printf "%.3f", b-a }')"

entradas=(); fc=""; rot=""
i=0
while [ "$i" -lt "$nb" ]; do
  if [ $((i+1)) -lt "$nb" ]; then prox="${inis[$((i+1))]}"; else prox="$FIM"; fi
  d="$(awk -v a="${inis[$i]}" -v b="$prox" 'BEGIN{ printf "%.3f", b-a }')"
  if awk -v d="$d" 'BEGIN{ exit !(d <= 0) }'; then echo "ERRO: o bloco ${arqs[$i]} começa em ${inis[$i]}s, depois do bloco seguinte ou do fim"; exit 1; fi
  real="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "${arqs[$i]}")"
  dif="$(awk -v r="$real" -v d="$d" 'BEGIN{ printf "%.2f", r-d }')"
  if awk -v x="$dif" 'BEGIN{ exit !(x > 0.25 || x < -0.25) }'; then
    echo "aviso: ${arqs[$i]} dura ${real}s e o espaço dele na música é de ${d}s (diferença de ${dif}s)"
  fi
  entradas+=(-i "${arqs[$i]}")
  fc="${fc}[${i}:v]fps=${FPS},scale=${W}:${H}:flags=lanczos,setsar=1,tpad=stop_mode=clone:stop_duration=${d},trim=duration=${d},setpts=PTS-STARTPTS[v${i}];"
  rot="${rot}[v${i}]"
  i=$((i+1))
done
fadev=""
if [ "${FADE_VIDEO:-0}" = "1" ]; then
  fadev=",fade=t=out:st=$(awk -v t="$total" -v f="$FADE" 'BEGIN{ printf "%.3f", t-f }'):d=${FADE}"
fi
fc="${fc}${rot}concat=n=${nb}:v=1:a=0,format=yuv420p${fadev}[v];"

entradas+=(-i "$musica"); im="$nb"
entrada_suave=""
if awk -v a="$INICIO" 'BEGIN{ exit !(a > 0.05) }'; then entrada_suave="afade=t=in:st=0:d=0.3,"; fi
saifade="$(awk -v t="$total" -v f="$FADE" 'BEGIN{ printf "%.3f", t-f }')"
fc="${fc}[${im}:a]atrim=start=${INICIO}:end=${FIM},asetpts=PTS-STARTPTS,${entrada_suave}afade=t=out:st=${saifade}:d=${FADE}[m]"

ns=0; mix="[m]"
if [ -n "$sons" ]; then
  [ -f "$sons" ] || { echo "ERRO: lista de sons não encontrada: $sons"; exit 2; }
  while IFS='|' read -r a t vol || [ -n "${a:-}" ]; do
    a="$(printf '%s' "${a:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [ -z "$a" ] && continue
    case "$a" in \#*) continue ;; esac
    [ -f "$a" ] || { echo "ERRO: som não existe: $a"; exit 2; }
    ns=$((ns+1)); idx=$((nb+ns))
    ms="$(awk -v t="$t" -v i="$INICIO" 'BEGIN{ x=(t-i)*1000; if (x<0) x=0; printf "%d", x }')"
    entradas+=(-i "$a")
    fc="${fc};[${idx}:a]aresample=48000,volume=${vol:-0}dB,adelay=${ms}:all=1[s${ns}]"
    mix="${mix}[s${ns}]"
  done < "$sons"
fi
if [ "$ns" -gt 0 ]; then
  fc="${fc};${mix}amix=inputs=$((ns+1)):normalize=0:duration=first,alimiter=limit=0.95:level=0[au]"
else
  fc="${fc};[m]anull[au]"
fi

# teto de taxa de bits proporcional ao tamanho do quadro: grão e ruído não podem inflar o arquivo
teto="$(awk -v w="$W" -v h="$H" -v f="$FPS" 'BEGIN{ printf "%d", w*h*f*0.30/1000 }')"
ffmpeg -nostdin -v error -y "${entradas[@]}" -filter_complex "$fc" -map "[v]" -map "[au]" \
  -c:v libx264 -crf 20 -maxrate "${teto}k" -bufsize "$((teto*2))k" -preset medium -c:a aac -b:a 256k -t "$total" -movflags +faststart "$saida" || { echo "ERRO ao juntar o clipe"; exit 1; }
echo "ok: $saida | blocos: $nb | sons: $ns | duração: $(ffprobe -v error -show_entries format=duration -of csv=p=0 "$saida")s | música de ${INICIO}s a ${FIM}s | ${W}x${H} | $(du -h "$saida" | cut -f1)"
