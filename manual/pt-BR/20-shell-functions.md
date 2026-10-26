# Funções de shell

O Omarchy vem com um conjunto de funções de shell para simplificar tarefas comuns e encapsular chamadas de parâmetros complicadas.

## Compressão

- `compress [file/dir]`: Cria um arquivo tar.gz a partir do arquivo/diretório.
- `decompress [file.tar.gz]`: Expande um arquivo tar.gz.

## Unidades

- `iso2sd [image.iso]`: Cria uma unidade inicializável em um cartão SD usando o arquivo iso referenciado e escolhendo a unidade interativamente.
- `format-drive [device] [name]`: Formata um disco inteiro com uma única partição exFAT (que também funciona no Windows e no macOS). Execute sem argumentos para ver as unidades disponíveis. Cuidado!

## Layouts de desenvolvimento

Layouts de desenvolvimento instantâneos com vários painéis para o tmux:

- `tdl [ai]`: Cria um Tmux Dev Layout com seu editor, um agente de IA e um terminal. Use os aliases de agente, como `tdl c` para o opencode ou `tdl cx` para o Claude Code, ou passe um segundo agente para executar os dois, como `tdl c cx`.
- `tds`: Cria um Tmux Dev Square com editor, monitoramento de diff (com `hunk diff --watch`), terminal e opencode.
- `tdlm [ai]`: Cria uma janela `tdl` para cada subdiretório do diretório atual.
- `tsl [count] [command]`: Cria um enxame de painéis lado a lado em uma.grade, todos executando o mesmo comando (ótimo para agentes de IA).

Os mesmos layouts estão disponíveis para o Herdr como `hdl`, `hds`, `hdlm` e `hsl`.

## Worktrees do Git

- `ga [branch]`: Cria um novo worktree e branch ao lado do repositório atual e entra nele.
- `gd`: Remove o worktree atual e seu branch (pede confirmação primeiro).

## Observadores Rsync

- `rsw [source] [destination]`: Inicia um observador em segundo plano que sincroniza com rsync a origem para o destino sempre que algo muda. O destino pode ser um host remoto, como `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Lista todos os observadores ativos.
- `dsw`: Interrompe todos os observadores ativos.

## Redirecionamento de portas SSH

Ideal para fazer desenvolvimento web com privilégios de contexto seguro do localhost contra uma máquina remota.

- `fip`: Redireciona uma ou mais portas de um host remoto para o localhost via SSH.
- `dip`: Desconecta uma ou mais portas redirecionadas.
- `lip`: Lista todos os redirecionamentos de porta SSH ativos.

Digamos que você inicie um servidor de desenvolvimento na porta `3000` em uma máquina acessível como `nyc-dev`; então você pode executar `fip nyc-dev 3000` para redirecionar essa porta, de forma que `localhost:3000` realmente alcance `nyc-dev:3000`, mas sem a necessidade de certificados SSL para estabelecer o contexto seguro necessário para testar web sockets ou coisas do tipo.

## Reconexão SSH

O próprio `ssh` está envolvido em uma função que limpa o terminal se uma conexão cair enquanto um tmux, Herdr ou editor remoto o tiver assumido, e então se reconecta automaticamente quando uma sessão interativa cai (Ctrl-C interrompe o loop de novas tentativas).
