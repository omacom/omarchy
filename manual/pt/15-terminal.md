# Terminal

O [Foot](https://codeberg.org/dnkl/foot) é o terminal predefinido do Omarchy. É rápido, leve e compatível até com computadores antigos. No entanto, não suporta separadores nem divisões nativos.

Se usares o Tmux, se calhar não te importas, mas se não usares, também suportamos totalmente o _Alacritty_, o _Ghostty_ e o _Kitty_ como opções. Escolhe a tua preferência em _Instalar > Terminal_ no menu do Omarchy.

Arrancas um novo terminal com `Super + Return`. (Esta associação aponta automaticamente para qualquer Terminal que tenhas instalado através de _Instalar > Terminal_, e podes mudar entre terminais instalados em _Configurar > Predefinições > Terminal_.)

## Tmux

O Tmux fornece uma interface consistente e programável para painéis, janelas (também conhecidos por separadores) e sessões que podem ser retomadas, independentemente do teu terminal. Funciona até em máquinas remotas, por isso quando estás a aceder a um servidor por SSH, podes usar a mesma abordagem.

Arrancas uma nova sessão do Tmux num terminal novo com `Super + Alt + Return`, e como o Tmux é um processo persistente, consegues retomar a tua sessão mesmo que feches esse terminal. Prime `Ctrl + Space` (chamada a tecla de prefixo) e depois `s` para veres todas as tuas sessões ativas.

O Omarchy vem com uma configuração do Tmux otimizada ergonomicamente, que tem muitos atalhos para aprender, por isso mantém [a folha de consulta à mão](07-hotkeys.md#tmux).

## Funções de disposição do Tmux

Como o Tmux é programável, podemos usar funções para criar disposições. O Omarchy vem com quatro funções diferentes para disposições comuns de programador.

`tdl [agente]` arranca uma interface dividida em três, ao estilo de um IDE, com o `$EDITOR` à esquerda, o agente de IA à tua escolha à direita (como `c` para o opencode, `cx` para o Claude ou `codex` para a OpenAI) e depois um terminal em baixo.

Por isso `tdl c` arranca isto (ou simplesmente `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Também podes arrancar um segundo agente com `tdl c cx` (opencode + claude) (ou simplesmente `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Também há o `tds`, que arranca um quadrado de quatro vias com o editor em cima à esquerda, um observador de diffs ao vivo em cima à direita, um terminal em baixo à esquerda e o opencode em baixo à direita.

Também podes arrancar esta configuração de disposição para cada subdiretório no diretório atual com `tdlm [agente]`, e depois navegar com `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Por fim, podes arrancar um enxame de agentes com `tsl [painéis] [comando]`. Por isso `tsl 4 c` dá-te uma grelha de quatro vias de agentes opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
