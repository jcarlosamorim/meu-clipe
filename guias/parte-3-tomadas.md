# Parte 3. Tomadas

O que sai daqui: os vídeos de cada bloco da música em `tomadas/<bloco>/`, conferidos, e um rascunho de cada bloco montado com a música e aprovado pela pessoa.

Leia `guias/higgsfield.md` antes da primeira chamada e `guias/parte-4-montagem.md` antes de montar o primeiro rascunho.

## 1. O teste, antes de tudo

Duas ou três tomadas de 4 segundos, uma de cada camada visual, escolhidas entre as que o clipe vai usar de qualquer jeito. O teste responde quatro perguntas:

- O rosto segura? Compare com a folha do personagem.
- Cada camada ficou com a cara que a direção descreve?
- O preço cobrado bateu com a cotação?
- Quanto tempo leva um lote?

Mande as tomadas, diga o que funcionou e o que vai ajustar, e pergunte se pode seguir. Anote em `clipe.md` os ajustes de redação que o teste ensinou: eles valem para todas as tomadas seguintes. Tomada de teste aprovada entra no clipe.

## 2. Um bloco por vez

Um bloco é uma parte da música: um verso, um refrão, a ponte. Siga a ordem da música, deixando a introdução e o final por último. Não gere o clipe inteiro de uma vez: o que você aprende num bloco melhora o seguinte, e a pessoa aprova em pedaços que ela consegue assistir.

Para cada bloco:

1. Escreva os pedidos de todas as tomadas do bloco.
2. Cote o lote e confira com o que resta do teto.
3. Gere o lote inteiro em paralelo. Avise a pessoa de que leva alguns minutos.
4. Baixe cada tomada com `bash ferramentas/baixa.sh <endereço> tomadas/<bloco>/NN-nome.mp4 tomadas/<bloco>/folhas/NN-nome.jpg`.
5. Confira cada uma.
6. Refaça o que for preciso.
7. Monte o rascunho do bloco e mande.
8. Registre em `clipe.md`.

## 3. Como escrever o pedido de uma tomada

Escreva em inglês, em frases diretas, nesta ordem:

1. O tamanho do plano e o que está no centro do quadro.
2. O personagem, apontando para a referência, com o figurino por extenso.
3. **Uma** ação, com começo e fim dentro de 4 segundos.
4. O movimento de câmera, ou "câmera parada".
5. A luz e a hora do dia.
6. O que não pode aparecer: outras pessoas, texto, logotipo, objeto que não é da cena.

Não coloque no pedido o acabamento da camada: grão, barras, data, falha de fita. Isso entra na montagem e fica idêntico em todas as tomadas.

Cor e intensidade pedem adjetivo preciso. No clipe de referência, "luz verde" saiu como refletor e "manga verde" saiu verde-menta. Com "um banho fraco e pálido de luz verde, de sinal de trânsito distante" e "verde-sálvia apagado", saiu certo.

## 4. Quais referências entram em cada tomada

- A folha do personagem que aparece.
- O cenário, **só quando o cenário é o que está na frente da câmera**. Se a câmera está no lugar do monitor, olhando para o rosto, não passe a foto do quarto: o modelo coloca a mesa do computador atrás do personagem.
- O objeto, se ele é o assunto da tomada.

Poucas referências, as certas. Referência demais confunde o modelo.

## 5. Tomadas que emendam

Para manter o lugar e a luz entre duas tomadas seguidas, tire o último quadro da primeira com `bash ferramentas/quadro.sh <tomada.mp4> <saida.png> ultimo`, envie para a Higgsfield e use como primeiro quadro da segunda. É o conserto mais confiável para cenário que muda de uma tomada para outra.

Isso obriga a gerar em duas levas: a tomada seguinte só pode ser pedida depois que a anterior terminou.

## 6. Conferir

Abra a folha de 8 quadros de cada tomada e olhe. Para cada uma, decida:

| Decisão | Quando |
|---|---|
| **Boa** | O rosto é o do personagem, a ação aconteceu, nada estranho no quadro |
| **Boa com ressalva** | Tem um trecho usável. Anote de que segundo a que segundo. Um salto no meio da tomada pode virar um corte |
| **Refazer** | Rosto errado, mão ou membro deformado, objeto ou pessoa que não devia estar ali, texto borrado em destaque, cenário trocado, ação que não aconteceu |

O que procurar com mais cuidado: o rosto contra a folha do personagem, mãos, o fundo (objetos duplicados, um segundo monitor, uma segunda pessoa), e qualquer texto.

## 7. Refazer

- Uma tomada com defeito você refaz uma vez, sem perguntar, mudando o pedido. Diga o que mudou. Repetir o mesmo pedido só repete o defeito.
- Se a segunda também falhar, pare e mostre as duas para a pessoa, com três saídas: aceitar a melhor, trocar a ideia da tomada, ou tirar a tomada e cobrir com outra.
- A tomada rejeitada vai para `tomadas/<bloco>/descartadas/`. Não apague.

## 8. O rascunho do bloco

A pessoa aprova o bloco com música, não tomadas soltas. Escreva `montagem/<bloco>-cortes.txt`, rode `monta.sh` com o segundo da música em que o bloco começa e mande o vídeo. O guia da Parte 4 explica a lista de cortes e os acabamentos.

Diga junto, em duas ou três linhas: o que funcionou, o que tem ressalva, e o gasto do bloco.

**Portão:** ela aprova ou aponta. Ajuste de corte você faz na hora, sem custo. Tomada nova custa, então diga quanto antes de gerar.

## 9. Registro

Em `clipe.md`, para cada bloco: a tabela das tomadas (arquivo, verso, identificador, avaliação), o que você aprendeu para os próximos blocos, o custo do bloco e o saldo depois dele. Atualize o "Estado" com o próximo bloco.

Quando todos os blocos estiverem aprovados, o "Estado" vai para a Parte 4.
