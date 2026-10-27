# Funções de shell

O Omarchy vem com um conjunto de funções de shell para simplificar tarefas comuns e encapsular chamadas de parâmetros complicadas.

## Compressão

- `compress [file/dir]`: Cria um arquivo tar.gz a partir do ficheiro/diretório.
- `decompress [file.tar.gz]`: Expande um ficheiro tar.gz.

## Unidades

- `iso2sd [image.iso]`: Cria uma unidade arrancável num cartão SD usando o ficheiro iso indicado e escolhendo a unidade de forma interativa.
- `format-drive [device] [name]`: Formata um disco inteiro com uma única partição exFAT (que também funciona no Windows e no macOS). Executa-o sem argumentos para veres as unidades disponíveis. Tem cuidado!

## Disposições de desenvolvimento

Disposições de desenvolvimento instantâneas com vários painéis para o tmux:

- `tdl [ai]`: Cria uma Tmux Dev Layout com o teu editor, um agente de IA e um terminal. Usa os aliases dos agentes, como `tdl c` para o opencode ou `tdl cx` para o Claude Code, ou passa um segundo agente para executar os dois, como `tdl c cx`.
- `tds`: Cria um Tmux Dev Square com editor, observação de diffs (com `hunk diff --watch`), terminal e opencode.
- `tdlm [ai]`: Cria uma janela `tdl` para cada subdiretório no diretório atual.
- `tsl [count] [command]`: Cria um enxame de painéis em mosaico numa grelha, todos a executar o mesmo comando (ótimo para agentes de IA).

As mesmas disposições estão disponíveis para o Herdr como `hdl`, `hds`, `hdlm` e `hsl`.

## Git worktrees

- `ga [branch]`: Cria uma nova worktree e um novo ramo ao lado do repositório atual e salta para dentro dela.
- `gd`: Remove a worktree atual e o seu ramo (pede confirmação primeiro).

## Observadores Rsync

- `rsw [source] [destination]`: Inicia um observador em segundo plano que faz rsync da origem para o destino sempre que alguma coisa muda. O destino pode ser um anfitrião remoto, como `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Lista todos os observadores ativos.
- `dsw`: Para todos os observadores ativos.

## Reencaminhamento de portas SSH

Ideal para fazer desenvolvimento web com privilégios de contexto seguro do localhost contra uma máquina remota.

- `fip`: Reencaminha uma ou mais portas de um anfitrião remoto para o localhost via SSH.
- `dip`: Desliga uma ou mais portas reencaminhadas.
- `lip`: Lista todos os reencaminhamentos de portas SSH ativos.

Imagina que inicias um servidor de desenvolvimento na porta `3000` numa máquina acessível como `nyc-dev`; depois podes executar `fip nyc-dev 3000` para reencaminhar essa porta, de modo que `localhost:3000` chega, na prática, a `nyc-dev:3000`, mas sem precisares de certificados SSL para estabelecer o contexto seguro necessário para testar web sockets ou coisas do género.

## Reconexão SSH

O próprio `ssh` está envolvido numa função que limpa o terminal se uma ligação morrer enquanto um tmux, Herdr ou editor remoto o tiver reclamado, e depois volta a ligar automaticamente quando uma sessão interativa cai (o Ctrl-C para o ciclo de tentativas).
