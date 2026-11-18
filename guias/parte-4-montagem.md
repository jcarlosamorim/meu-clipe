# Parte 4. Montagem

O que sai daqui: `clipe-final.mp4`, com todos os blocos no tempo exato da música.

A montagem inteira é texto. Uma lista diz qual pedaço de qual tomada entra, por quanto tempo e com qual acabamento. Mudar o clipe é mudar uma linha e rodar de novo. Não custa crédito.

Todos os comandos rodam da pasta do clipe. O tamanho do quadro é definido uma vez e repetido em todo comando: `LARGURA=1280 ALTURA=720 bash ferramentas/...`. O padrão é 1280x720 a 24 quadros por segundo. Não monte num tamanho maior do que o das tomadas: ampliar não cria detalhe.

## 1. Os acabamentos

Cada camada da regra visual vira uma linha em `montagem/looks.txt`: um nome e uma cadeia de filtros do FFmpeg.

```
memoria=noise=alls=9:allf=t,eq=saturation=1.06:contrast=1.03
frio=noise=alls=6:allf=t,eq=saturation=0.85
falha=rgbashift=rh=14:bh=-14,noise=alls=45:allf=t+u,eq=contrast=1.25:saturation=0.7
pb=hue=s=0,eq=contrast=1.1
```

Esses quatro são os do clipe de referência, mais um preto e branco. Escreva os da direção desta pessoa. Comece discreto: grão e cor fortes demais cansam em três minutos.

O que **não** é acabamento de `looks.txt`, e sim opção de cada corte:

- `caixa=4:3` coloca a imagem numa proporção diferente dentro do quadro, com barras pretas.
- `carimbo=arquivo.png` estica um PNG transparente por cima da imagem: uma data no canto, uma moldura, uma marca de câmera. Crie o PNG do tamanho da imagem. Confira antes se o FFmpeg deste computador escreve texto (`drawtext`): muitos não escrevem, e aí o PNG é feito com outra ferramenta ou gerado como imagem.
- `flash` faz o corte entrar com um clarão branco.

## 2. A lista de cortes

Um arquivo por bloco, `montagem/<bloco>-cortes.txt`. Uma linha por corte:

```
# arquivo|inicio|duracao|look|opcoes
tomadas/02-verso-1/01-porta.mp4|0.30|2.80|memoria|caixa=4:3,carimbo=montagem/data.png
tomadas/02-verso-1/02-moeda.mp4|0.40|2.20|memoria|caixa=4:3,carimbo=montagem/data.png
tomadas/02-verso-1/tela-lista.mp4|0.00|3.10|memoria|caixa=4:3
```

Como cortar:

- Cada corte cai no começo de um verso ou numa batida forte. Some as durações: o bloco tem que terminar onde o seguinte começa na música.
- De 2 a 4 segundos por corte. Mais curto em trecho agitado, mais longo em trecho calmo.
- Pule os primeiros décimos de cada tomada, que costumam sair parados, e use o trecho que você anotou na conferência.
- A mesma tomada pode voltar, em outro trecho ou em lampejos de meio segundo. É assim que 40 tomadas viram 72 cortes.
- Imagem parada entra direto na lista (fica imóvel) ou, melhor, passa antes por `anima_foto.sh` para ganhar um zoom lento.

## 3. Imagens paradas com movimento

```
bash ferramentas/anima_foto.sh referencias/telas/lista.png tomadas/02-verso-1/tela-lista.mp4 4 1.0 1.2 0.5 0.5 0.6 0.4
```

Duração, zoom inicial, zoom final e, se quiser deslocar, de onde para onde o quadro olha. Zoom entre 1.0 e 1.3. Mais do que isso amplia demais e a imagem perde nitidez.

Para uma mudança na tela (a luz que acende), anime as duas versões com os mesmos números e corte de uma para a outra na lista.

## 4. Montar um bloco

```
bash ferramentas/monta.sh montagem/02-verso-1-cortes.txt musica/<arquivo> 12.3 montagem/02-verso-1.mp4 montagem/looks.txt
```

O terceiro argumento é o segundo da música em que o bloco começa. O programa responde com o trecho da música que o bloco cobre. Confira com a tabela das partes: se o bloco acaba antes ou depois de onde o próximo começa, ajuste as durações.

Se um corte falhar, nada é montado e o programa diz qual linha. Corrija e rode de novo.

## 5. Juntar o clipe

`montagem/blocos.txt` lista os blocos e o segundo da música em que cada um começa:

```
montagem/01-intro.mp4|0
montagem/02-verso-1.mp4|12.3
montagem/03-refrao-1.mp4|40.7
```

```
bash ferramentas/junta.sh montagem/blocos.txt musica/<arquivo> clipe-final.mp4
```

Cada bloco ocupa o tempo até o início do seguinte. Se um bloco for mais curto que o espaço dele, o último quadro é repetido. Se for mais longo, é cortado. O programa avisa toda diferença maior que um quarto de segundo. **Um aviso desses é um erro de sincronia para corrigir na lista de cortes**, não para ignorar.

Se o clipe é só um trecho da música, o primeiro bloco começa no segundo em que o trecho começa e a variável `FIM` diz onde ele acaba: `FIM=82.2 bash ferramentas/junta.sh ...`. O som entra e sai suave.

Efeitos sonoros por cima da música entram por um quarto argumento, `montagem/sons.txt`, com arquivo, segundo da música e volume. Som de aplicativo, de marca ou de filme é material de terceiros: use som próprio, licenciado ou gerado.

## 6. Conferir antes de entregar

Você não assiste ao vídeo. Você confere por medida e por quadro:

- A duração do clipe é a da música, ou a do trecho.
- No começo de cada bloco, tire um quadro com `quadro.sh` no segundo exato e veja se é a imagem que a lista diz.
- Tire um quadro em cada ponto que a direção marcou como importante: a virada, o corte mais forte, a última imagem.
- O programa não deu nenhum aviso de sincronia.

Só então mande o clipe, com a duração e o tamanho do arquivo.

## 7. A rodada de ajustes

Peça os ajustes pelo tempo do clipe: "em 1:12 o corte entra atrasado". Ache o bloco pelo `blocos.txt` e a linha pela soma das durações, corrija, monte o bloco e junte de novo. Ajuste de corte e de acabamento é de graça. Tomada nova tem preço: diga antes.

Quando ela disser que está pronto, marque o clipe como concluído no "Estado" de `clipe.md`, com a data, o gasto total e o saldo final.

## Armadilhas técnicas

- Rode os scripts com `bash`. Laços escritos direto no terminal quebram em outros interpretadores.
- Todo comando do FFmpeg dentro de um laço precisa de `-nostdin`. Sem isso ele consome a lista que o laço está lendo e os cortes somem.
- Os scripts ficam em `ferramentas/`, dentro da pasta do clipe. Pasta temporária é apagada sem aviso e leva os scripts junto.
- Caminho com espaço vai sempre entre aspas.
- Guarde os blocos montados. Eles são o que permite remontar o clipe sem refazer tudo.

## Se não houver FFmpeg nem terminal

Este fluxo foi testado com FFmpeg no computador da pessoa. Se o ambiente não tem terminal, veja na lista de fluxos da Higgsfield se existe um de montagem de vídeo e siga o dele, avisando a pessoa de que esse caminho não é o que este guia testou.
