#!/bin/bash
# monta.sh: monta um bloco do clipe a partir de uma lista de cortes e põe o trecho da música por cima.
#
# uso: monta.sh <cortes.txt> <musica|-> <inicio_na_musica_em_segundos> <saida.mp4> [looks.txt]
# ambiente: LARGURA (1280), ALTURA (720), FPS (24), MANTER=1 para não apagar a pasta temporária
#
# cortes.txt, uma linha por corte, na ordem em que aparecem:
#   arquivo|inicio|duracao|look|opcoes
#   arquivo   vídeo ou imagem parada (png, jpg, webp), caminho relativo à pasta onde o comando roda
#   inicio    segundo do arquivo em que o corte começa (ignorado em imagem)
#   duracao   duração do corte em segundos
#   look      nome de um acabamento definido em looks.txt, ou vazio
#   opcoes    separadas por vírgula, todas opcionais:
#               caixa=4:3          a imagem ocupa essa proporção dentro do quadro, com barras pretas
#               carimbo=arq.png    PNG transparente esticado por cima da imagem (data, moldura, marca)
#               flash              o corte entra com um clarão branco de 0,3 s
#   linhas vazias e linhas que começam com # são ignoradas
#
# looks.txt, uma linha por acabamento:  nome=filtros do ffmpeg separados por vírgula
#   exemplo:  memoria=noise=alls=9:allf=t,eq=saturation=1.06:contrast=1.03
set -u
if [ $# -lt 4 ]; then sed -n '2,20p' "$0"; exit 2; fi
lista="$1"; musica="$2"; ini="$3"; saida="$4"; looks="${5:-}"
W="${LARGURA:-1280}"; H="${ALTURA:-720}"; FPS="${FPS:-24}"
[ -f "$lista" ] || { echo "ERRO: lista de cortes não encontrada: $lista"; exit 2; }
if [ -n "$looks" ] && [ ! -f "$looks" ]; then echo "ERRO: arquivo de looks não encontrado: $looks"; exit 2; fi

tmp="$(dirname "$saida")/.tmp-$(basename "${saida%.*}")"
rm -rf "$tmp"; mkdir -p "$tmp"; : > "$tmp/concat.txt"
n=0; falhas=0
# teto de taxa de bits dos blocos (o dobro do clipe final), para o grão não inflar o arquivo
teto="$(awk -v w="$W" -v h="$H" -v f="$FPS" 'BEGIN{ printf "%d", w*h*f*0.60/1000 }')"

par() { awk -v v="$1" 'BEGIN{ x=int(v+0.5); if (x%2) x++; print x }'; }

while IFS='|' read -r arq t0 dur look opcoes || [ -n "${arq:-}" ]; do
  arq="$(printf '%s' "${arq:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [ -z "$arq" ] && continue
  case "$arq" in \#*) continue ;; esac
  n=$((n+1)); nome="$(printf '%03d' "$n").mp4"; seg="$tmp/$nome"
  if [ ! -f "$arq" ]; then echo "ERRO no corte $n: arquivo não existe: $arq"; falhas=$((falhas+1)); continue; fi

  # opções
  caixa=""; carimbo=""; flash=""
  IFS=',' read -r -a ops <<< "${opcoes:-}"
  for o in "${ops[@]:-}"; do
    o="$(printf '%s' "$o" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    case "$o" in
      caixa=*) caixa="${o#caixa=}" ;;
      carimbo=*) carimbo="${o#carimbo=}" ;;
      flash) flash="fade=t=in:st=0:d=0.30:color=white," ;;
      "") ;;
      *) echo "aviso no corte $n: opção desconhecida '$o'" ;;
    esac
  done

  # tamanho da imagem dentro do quadro
  iw="$W"; ih="$H"
  if [ -n "$caixa" ]; then
    a="${caixa%%:*}"; b="${caixa##*:}"
    if awk -v W="$W" -v H="$H" -v a="$a" -v b="$b" 'BEGIN{ exit !(W/H > a/b) }'; then
      ih="$H"; iw="$(par "$(awk -v H="$H" -v a="$a" -v b="$b" 'BEGIN{ print H*a/b }')")"
    else
      iw="$W"; ih="$(par "$(awk -v W="$W" -v a="$a" -v b="$b" 'BEGIN{ print W*b/a }')")"
    fi
  fi

  # acabamento
  filtro=""
  look="$(printf '%s' "${look:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  if [ -n "$look" ] && [ "$look" != "-" ]; then
    if [ -z "$looks" ]; then echo "ERRO no corte $n: look '$look' pedido, mas nenhum looks.txt foi passado"; falhas=$((falhas+1)); continue; fi
    filtro="$(grep -m1 "^${look}=" "$looks" | cut -d= -f2-)"
    if [ -z "$filtro" ]; then echo "ERRO no corte $n: look '$look' não está em $looks"; falhas=$((falhas+1)); continue; fi
    filtro=",${filtro}"
  fi

  base="scale=${iw}:${ih}:force_original_aspect_ratio=increase:flags=lanczos,crop=${iw}:${ih},fps=${FPS},setsar=1${filtro}"
  fc="[0:v]${base}[g]"; ult="g"
  entradas=()
  case "$(printf '%s' "$arq" | tr '[:upper:]' '[:lower:]')" in
    *.png|*.jpg|*.jpeg|*.webp) entradas+=(-loop 1 -t "$dur" -i "$arq") ;;
    *) entradas+=(-ss "$t0" -t "$dur" -i "$arq") ;;
  esac
  if [ -n "$carimbo" ]; then
    if [ ! -f "$carimbo" ]; then echo "ERRO no corte $n: carimbo não existe: $carimbo"; falhas=$((falhas+1)); continue; fi
    entradas+=(-i "$carimbo")
    fc="${fc};[1:v]scale=${iw}:${ih}[c];[g][c]overlay=0:0[g2]"; ult="g2"
  fi
  fc="${fc};[${ult}]${flash}pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:black,format=yuv420p[v]"

  ffmpeg -nostdin -v error -y "${entradas[@]}" -filter_complex "$fc" -map "[v]" -t "$dur" -an \
    -c:v libx264 -crf 16 -maxrate "${teto}k" -bufsize "$((teto*2))k" -preset fast "$seg"
  if [ ! -s "$seg" ]; then echo "ERRO no corte $n: o ffmpeg não gerou o segmento ($arq)"; falhas=$((falhas+1)); continue; fi
  echo "file '$nome'" >> "$tmp/concat.txt"
done < "$lista"

if [ "$n" -eq 0 ]; then echo "ERRO: a lista de cortes está vazia"; exit 1; fi
if [ "$falhas" -gt 0 ]; then echo "ERRO: $falhas de $n cortes falharam. Nada foi montado."; exit 1; fi

ffmpeg -nostdin -v error -y -f concat -safe 0 -i "$tmp/concat.txt" -c copy "$tmp/corte.mp4" || { echo "ERRO ao juntar os cortes"; exit 1; }
total="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$tmp/corte.mp4")"

if [ "$musica" = "-" ] || [ -z "$musica" ]; then
  cp "$tmp/corte.mp4" "$saida"
else
  [ -f "$musica" ] || { echo "ERRO: música não encontrada: $musica"; exit 2; }
  ffmpeg -nostdin -v error -y -i "$tmp/corte.mp4" -ss "$ini" -t "$total" -i "$musica" -map 0:v -map 1:a \
    -c:v copy -c:a aac -b:a 256k -shortest -movflags +faststart "$saida" || { echo "ERRO ao colocar a música"; exit 1; }
fi
[ "${MANTER:-0}" = "1" ] || rm -rf "$tmp"
fim="$(awk -v i="$ini" -v t="$total" 'BEGIN{ printf "%.2f", i+t }')"
echo "ok: $saida | cortes: $n | duração: ${total}s | cobre a música de ${ini}s a ${fim}s | ${W}x${H} a ${FPS} qps"
