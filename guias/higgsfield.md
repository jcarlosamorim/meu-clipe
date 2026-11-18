# Higgsfield: como usar o conector neste fluxo

As ferramentas da Higgsfield chegam com um prefixo que muda de conta para conta. Procure pelo final do nome. Se elas aparecerem só como nomes sem definição, carregue de uma vez todas as que vai usar.

Modelos, preços e parâmetros mudam. Este guia diz o que consultar e o que funcionou em novembro de 2026. **Confira no catálogo antes de usar.**

## As ferramentas deste fluxo

| Para | Ferramenta | Observação |
|---|---|---|
| Ver saldo e plano | `balance` | Antes de cada lote |
| Ver o extrato | `transactions` | Quando o saldo não bater com o que você gastou |
| Escolher modelo e ver limites | `models_explore` | `recommend` para achar, `get` para ver formatos, durações e papéis de mídia |
| Cotar vídeo | `estimate_video_cost` | Mesmos parâmetros da geração. Não gera nada |
| Cotar imagem | `estimate_image_cost` | Idem |
| Enviar arquivo da pessoa | `media_upload`, depois `media_confirm` | Fotos dela, último quadro de uma tomada |
| Gerar imagens | `generate_image_batch` | Até 12 pedidos diferentes por chamada |
| Gerar vídeos | `generate_video_batch` | Até 12 pedidos diferentes por chamada |
| Esperar | `jobs_wait` | Até 12 trabalhos, 15 segundos por chamada. Repita até todos terminarem |
| Mostrar na galeria | `show_generation_by_ids` | Uma chamada por conjunto. Não substitui mandar o arquivo |
| Personagens já salvos na conta | `show_reference_elements` | Ação de listar |
| Fluxos prontos da Higgsfield | `get_workflow_instructions` | Sem argumento, lista. Veja se há um de folha de personagem |
| Música e efeitos sonoros | `generate_audio`, `estimate_audio_cost` | Só se o catálogo dela tiver modelo de música ou de efeito |

Siga a descrição de cada ferramenta sobre projeto e pasta de destino. Algumas pedem uma consulta de preferências antes da primeira geração.

## O que funcionou em novembro de 2026

**Vídeo.** Modelo `seedance_2_5`, com `mode: "omni_reference"`, `resolution: "720p"`, `generate_audio: false`, `duration` de 4 a 6, `aspect_ratio` `"16:9"` ou `"4:3"`. Em `medias`, o papel `image_references` para a folha do personagem e o cenário, e o papel `start_image` para fixar o primeiro quadro. Custava 7 créditos por segundo em 720p e 16 em 1080p. A saída em 720p é 1280x720 em 16:9 e 1112x834 em 4:3, a 24 quadros por segundo. Três tomadas em paralelo levaram cerca de 8 minutos.

**Imagem.** Modelo `gpt_image_2_6`. Cada imagem de referência custou cerca de 1 crédito em qualidade média.

Se esses modelos não existirem mais, peça ao catálogo um modelo de vídeo que aceite imagens de referência e primeiro quadro, e um modelo de imagem que aceite imagem de referência. São essas duas capacidades que o fluxo usa.

## Enviar um arquivo

1. `media_upload` com o nome do arquivo. Ele devolve um endereço de envio e, em geral, o comando pronto.
2. Envie os bytes com `curl`, método PUT. Use o comando que a ferramenta devolveu. No clipe de referência, o envio só passava com os cabeçalhos `Content-Type` do arquivo e `If-None-Match: *`.
3. Só depois de o `curl` responder 200, chame `media_confirm`.
4. O identificador devolvido é o que entra em `medias`. Endereço de internet não entra em `medias`.

Imagem ou vídeo que a própria Higgsfield gerou não precisa de envio: o identificador do trabalho já serve como referência.

## Gerar e esperar

1. Cote antes. Some o lote e compare com o que resta do teto.
2. Envie o lote. Guarde o identificador de cada trabalho junto com o nome que o arquivo vai ter.
3. Repita `jobs_wait` até todos terminarem. Não reenvie um pedido por achar que travou: confira o estado primeiro. Reenvio às cegas cobra duas vezes.
4. Baixe na hora para a pasta do clipe, com `ferramentas/baixa.sh`. Não confie que o endereço vai durar.
5. Um trabalho que falha traz o motivo. Leia, ajuste o pedido e diga à pessoa o que mudou. Bloqueio por conteúdo ou por marca se resolve mudando a descrição, não insistindo.

## Quando a ferramenta devolve uma pergunta

Se a geração voltar com uma escolha sobre gerações ilimitadas do plano ou créditos, a pergunta é da pessoa. Faça a pergunta a ela e repita o pedido com a resposta.

## O campo de contexto

Algumas ferramentas pedem uma frase sobre o objetivo. Escreva uma frase genérica, sem nome, sem contato e sem descrição do rosto de ninguém.
