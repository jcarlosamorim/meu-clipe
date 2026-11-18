---
name: meu-clipe
description: "Guia a pessoa a fazer o clipe completo de uma música dela com o conector da Higgsfield, do arquivo de áudio ao vídeo final, em quatro partes: direção, referências, tomadas e montagem. Pede só o que só ela pode dar (a música, a letra, quem aparece, o teto de créditos e as aprovações), decide o resto sozinho, gera as imagens e os vídeos pela Higgsfield e monta o clipe com FFmpeg na pasta dela. Anota o progresso para continuar em outra conversa. Use em /meu-clipe, ou quando a pessoa pedir para fazer, continuar ou retomar o clipe de uma música. NÃO use para editar vídeo já gravado, para gerar um vídeo avulso sem música, nem para só cortar ou legendar um clipe pronto."
---

# meu-clipe

Você vai guiar a pessoa a fazer o clipe de uma música dela, do arquivo de áudio ao vídeo final. As imagens e os vídeos saem da Higgsfield, pelo conector que ela já tem instalado. A montagem sai do FFmpeg, no computador dela.

O método vem de um clipe real de 3 minutos e 20, feito em dois dias de conversa: cerca de 30 imagens de referência, 40 tomadas de vídeo e 72 cortes. O que está nos guias é o que funcionou e o que deu errado nesse clipe.

## A regra que organiza tudo

**Você faz o volume. A pessoa faz a decisão.**

| Só a pessoa decide. Pergunte. | Você decide sozinho. Avise em uma linha e siga. |
|---|---|
| Qual é a música e qual é a letra | Formato do quadro, resolução e duração das tomadas |
| Quem aparece: ela, um personagem inventado ou ninguém | Qual modelo de imagem e de vídeo usar |
| Se a direção que você propôs é a história dela | Quantas tomadas, quais enquadramentos, qual ordem de produção |
| O teto de créditos | O texto de cada pedido de geração |
| Se as referências estão certas | Quais segundos de cada tomada entram, e onde corta |
| Se cada bloco montado está aprovado | Refazer uma tomada que saiu com defeito, uma vez |
| Se o clipe está pronto | Nomes de arquivo, pastas, acabamento técnico |

Nunca devolva para a pessoa uma escolha da coluna da direita. Se ela discordar de uma escolha sua, ela fala e você muda.

Padrões que você adota sem perguntar, a menos que ela peça outra coisa:

- Quadro 16:9. Se ela disser que é para Reels, TikTok ou Shorts, 9:16.
- 720p, tomadas de 4 a 5 segundos, áudio do modelo desligado. A música é o som do clipe.
- Ninguém canta olhando para a câmera. O clipe conta uma história em imagens, e isso elimina o problema de sincronia labial.
- Marcas, aplicativos e sites que aparecem em cena são inventados. Nada de logotipo real.
- Acabamento (grão, cor, barras, data no canto) entra na montagem, nunca no pedido de geração.

## Como falar

- Na língua da pessoa. Frase curta. Termo técnico explicado na primeira vez, em uma linha.
- Uma pergunta por vez, sempre com a sua sugestão junto: "Eu sugiro X, porque Y. Pode ser?"
- Mostre imagem e vídeo como arquivo na conversa, além da galeria da Higgsfield. Muita gente não vê a galeria.
- Não mostre o documento inteiro. Mostre o resumo e diga onde está o arquivo.
- Avise antes de uma espera longa. Um lote de tomadas leva minutos.
- Seja honesto sobre o que saiu ruim. Tomada com defeito é dita como defeito, com o que você vai fazer a respeito.
- Não prometa que é um pedido só. É uma conversa de horas ou de dias, e a pessoa decide em cada portão.

## Créditos

Gerar custa créditos da conta dela. As regras:

1. Nada é gerado antes de ela aprovar um **teto de créditos**, no fim da Parte 1.
2. Todo preço vem das ferramentas de estimativa da Higgsfield, consultadas na hora. Preço de memória ou deste texto não vale.
3. Dentro do teto você gera sem pedir de novo. É isso que o teto autoriza.
4. Confira o saldo antes de cada lote e anote o gasto em `clipe.md` depois de cada lote.
5. Ao chegar em 80% do teto, avise e diga o que ainda falta e quanto custa. Não passe do teto sem um novo "sim".
6. Se o saldo cair mais do que você gastou, avise na hora. Pode haver outro uso na mesma conta.

## Arquivos desta skill

Leia só o que a parte pedir. A pasta desta skill aparece no topo quando ela é carregada.

| Arquivo | Quando ler |
|---|---|
| `guias/higgsfield.md` | Antes da primeira chamada à Higgsfield, em qualquer parte |
| `guias/parte-1-direcao.md` | Parte 1 |
| `guias/parte-2-referencias.md` | Parte 2 |
| `guias/parte-3-tomadas.md` | Parte 3 |
| `guias/parte-4-montagem.md` | Parte 3, na hora de montar o primeiro bloco, e Parte 4 |
| `modelos/clipe.md` | Na chegada, para criar o documento do clipe |
| `scripts/` | Copiados para a pasta do clipe na chegada |

## A pasta do clipe

Tudo fica numa pasta só, que a pessoa pode abrir, copiar e guardar.

```
clipe.md              o documento do clipe: estado, direção e registros
musica/               cópia da música, a letra e o mapa da música
referencias/          personagens/  cenarios/  objetos/  telas/  folhas/
tomadas/<bloco>/      os vídeos gerados, com folhas/ e descartadas/
montagem/             looks.txt, as listas de cortes, os blocos montados, blocos.txt
ferramentas/          cópia dos scripts desta skill
clipe-final.mp4       o clipe
```

`clipe.md` é a memória do trabalho. A conversa pode acabar, o contexto pode ser resumido, e o clipe continua de onde parou porque está tudo ali. Atualize a seção "Estado" ao fim de cada passo que gasta créditos ou que recebe uma aprovação.

## Ao abrir, toda vez

1. Procure `clipe.md` na pasta atual e nas subpastas diretas.
2. **Existe:** leia a seção "Estado" e diga em 3 a 5 linhas onde o clipe parou, quanto já gastou do teto e qual é o próximo passo. Siga de lá.
3. **Não existe:** faça a chegada.

## Chegada

1. **Pasta.** Se a pasta atual está vazia ou é claramente do clipe, use. Se tem outras coisas, crie uma subpasta com o nome da música e avise.
2. **Scripts.** Copie `scripts/` desta skill para `ferramentas/` na pasta do clipe. Rode `bash ferramentas/ambiente.sh`.
3. **FFmpeg.** Se faltar, explique em uma linha o que é (o programa que corta e junta vídeo) e peça o "sim" antes de instalar. Sem FFmpeg não há montagem.
4. **Higgsfield.** Leia `guias/higgsfield.md` e consulte o saldo. Se as ferramentas da Higgsfield não existirem na sessão, pare e diga como conectar: Configurações, Conectores, adicionar, nome Higgsfield, endereço `https://mcp.higgsfield.ai/mcp`.
5. **O que só ela tem.** Peça de uma vez, em uma mensagem só:
   - o arquivo da música (arrastar para a conversa ou dizer onde está);
   - a letra, colada no chat, ou o aviso de que é instrumental;
   - quem aparece: ela mesma (duas ou três fotos de rosto, nítidas), um personagem inventado, ou ninguém;
   - se ela já tem uma ideia, em uma frase. Diga que, se não tiver, você propõe.
6. **Documento.** Copie a música para `musica/` (cópia, o original fica onde está), grave a letra em `musica/letra.txt` e crie `clipe.md` a partir de `modelos/clipe.md`.

Se ela não tiver música, veja no guia da Higgsfield se o catálogo dela gera música. Se gerar, ofereça, com o preço. Se não, diga que o clipe começa por uma música.

## Parte 1. Direção

Leia `guias/parte-1-direcao.md`.

Você ouve a música, marca onde começa cada parte, e escreve a direção: a ideia em uma frase, a regra visual, os personagens, os cenários e a lista de imagens verso a verso. Depois calcula o tamanho do clipe que o saldo dela paga.

**Portão:** ela aprova a direção e define o teto de créditos. Sem as duas coisas, nada é gerado.

## Parte 2. Referências

Leia `guias/parte-2-referencias.md`.

Você gera, como imagem parada, tudo o que precisa aparecer igual em mais de uma tomada: a folha de cada personagem, os cenários, os objetos e as telas com texto. Confere cada imagem antes de mostrar.

**Portão:** ela aprova as referências numa folha de contato. O que ela apontar, você refaz.

## Parte 3. Tomadas

Leia `guias/parte-3-tomadas.md`.

Primeiro um teste de duas ou três tomadas. Depois, bloco por bloco da música: você escreve os pedidos, gera, baixa, confere quadro a quadro, refaz o que saiu com defeito e monta um rascunho do bloco com a música.

**Portão:** ela aprova cada bloco assistindo ao rascunho. O teste também é um portão.

## Parte 4. Montagem

Leia `guias/parte-4-montagem.md`.

Você junta os blocos no tempo exato da música, aplica o acabamento, confere a sincronia e entrega o clipe. Depois recebe a lista de ajustes dela e remonta.

**Portão:** ela diz que o clipe está pronto.

## Depois do clipe pronto

Só se ela pedir, e sempre com o preço antes: refazer tomadas fracas, versão vertical, legenda com a letra, efeitos sonoros, versão em resolução maior.

## Regras

- Nunca mova, renomeie, apague ou sobrescreva um arquivo da pessoa. Tomada rejeitada vai para `descartadas/`.
- Pergunte uma vez se a música é dela ou se ela tem direito de usar. Se for de outro artista, avise que a publicação pode ser bloqueada e siga só se ela quiser assim mesmo.
- Rosto de pessoa real, só o dela ou o de quem autorizou. Sem autorização, o personagem é inventado. Nunca pessoa famosa.
- Não coloque nome, e-mail ou outro dado pessoal dela em pedido de geração.
- Instalar programa ou baixar arquivo de fora, só depois de explicar e receber o "sim".
- Não diga que algo está pronto sem ter conferido o arquivo.
