# meu-clipe

Uma skill para o Claude Code que te guia a fazer o clipe de uma música sua, do arquivo de áudio ao vídeo final. As imagens e os vídeos saem da Higgsfield. A montagem sai do FFmpeg, no seu computador.

Ela não faz o clipe com um pedido só. Ela conversa com você. O Claude faz o volume: ouve a música, escreve a direção, gera as referências, gera as tomadas, corta e monta. Você faz as decisões: qual é a história, quem aparece, quanto gastar e o que está aprovado.

O método vem de um clipe real de 3 minutos e 20, feito em dois dias de conversa: cerca de 30 imagens de referência, 40 tomadas de vídeo e 72 cortes.

## O que você precisa

- O Claude Code instalado, no terminal ou no aplicativo de computador.
- O conector da Higgsfield ligado no Claude: Configurações, Conectores, adicionar, nome Higgsfield, endereço `https://mcp.higgsfield.ai/mcp`.
- Créditos na Higgsfield. O clipe de referência custou cerca de 1.600 créditos em novembro de 2026. Com menos, a skill propõe um trecho da música em vez do clipe inteiro.
- A sua música em arquivo, e a letra.
- macOS ou Linux. O FFmpeg a própria skill confere, e instala com você se faltar.

## Como instalar

Abra o Claude Code e cole:

```
Instala esta skill para mim: https://github.com/jcarlosamorim/meu-clipe
```

Ou, pelo terminal:

```bash
git clone https://github.com/jcarlosamorim/meu-clipe ~/.claude/skills/meu-clipe
```

## Como usar

Abra o Claude Code numa pasta vazia, que vai ser a pasta do clipe, e digite:

```
/meu-clipe
```

Ela pede a música, a letra e quem aparece. Depois segue em quatro partes:

1. **Direção.** A ideia em uma frase, a regra visual, a lista de imagens verso a verso e o orçamento. Você aprova a história e define o teto de créditos.
2. **Referências.** A folha de cada personagem, os cenários, os objetos e as telas, como imagem parada. Você aprova numa folha de contato.
3. **Tomadas.** Um teste, e depois um bloco da música por vez. Você assiste a cada bloco montado com a música e aprova.
4. **Montagem.** Os blocos entram no tempo exato da música e viram o clipe. Você pede os ajustes.

Dá para parar e voltar outro dia. Ela anota tudo em `clipe.md`, na pasta do clipe. É só abrir o Claude Code na mesma pasta e digitar `/meu-clipe` de novo.

## O que tem aqui

| Pasta | O que tem |
|---|---|
| `SKILL.md` | O roteiro da conversa e as regras |
| `guias/` | O ofício de cada parte, com o que funcionou e o que deu errado no clipe de referência |
| `modelos/` | O esqueleto do documento do clipe |
| `scripts/` | Os programas de montagem: mapa da música, lista de cortes, junção dos blocos, imagem parada com movimento |
