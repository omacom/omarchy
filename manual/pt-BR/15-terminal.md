# Terminal

O [Foot](https://codeberg.org/dnkl/foot) é o terminal padrão do Omarchy. É rápido, leve e compatível até com computadores antigos. No entanto, ele não suporta abas ou divisões nativas.

Se você usa o Tmux, talvez não se importe, mas, caso contrário, também oferecemos suporte total ao _Alacritty_, ao _Ghostty_ e ao _Kitty_ como opções. Escolha sua preferência em _Instalar > Terminal_ no menu do Omarchy.

Você inicia um novo terminal usando `Super + Return`. (Esse atalho apontará automaticamente para qualquer Terminal que você tenha instalado via _Instalar > Terminal_, e você pode alternar entre os terminais instalados em _Configuração > Padrões > Terminal_.)

## Tmux

O Tmux fornece uma interface consistente e programável para painéis, janelas (também conhecidas como abas) e sessões retomáveis, independentemente do seu terminal. Ele até funciona em hosts remotos, então, quando você estiver fazendo SSH em um servidor, poderá usar a mesma abordagem.

Você inicia uma nova sessão do Tmux em um terminal novo usando `Super + Alt + Return` e, como o Tmux é um processo persistente, pode retomar sua sessão mesmo se fechar aquele terminal. Basta pressionar `Ctrl + Space` (chamada de tecla de prefixo) e depois `s` para ver todas as suas sessões ativas.

O Omarchy vem com uma configuração do Tmux otimizada ergonomicamente, que tem muitos atalhos para aprender, então mantenha [a cola à mão](07-hotkeys.md#tmux).

## Funções de layout do Tmux

Como o Tmux é programável, podemos usar funções para criar layouts. O Omarchy vem com quatro funções diferentes para layouts comuns de desenvolvedor.

`tdl [agent]` inicia uma interface dividida em três, estilo IDE, com o `$EDITOR` à esquerda, seu agente de IA escolhido à direita (como `c` para opencode ou `cx` para Claude ou `codex` para OpenAI) e depois um terminal na parte inferior.

Então `tdl c` iniciaria isto (ou apenas `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Você também pode iniciar um segundo agente com `tdl c cx` (opencode + claude) (ou apenas `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Há também o `tds`, que inicia um quadrado de quatro partes com o editor no canto superior esquerdo, um observador de diff ao vivo no canto superior direito, um terminal no canto inferior esquerdo e o opencode no canto inferior direito.

Você também pode iniciar essa configuração de layout para cada subdiretório no diretório atual usando `tdlm [agent]`, e depois navegar usando `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Por fim, você pode iniciar um enxame de agentes usando `tsl [panes] [command]`. Então `tsl 4 c` lhe dará uma grade de quatro agentes opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
