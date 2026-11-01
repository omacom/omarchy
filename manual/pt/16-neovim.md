# Neovim

O [Neovim](https://neovim.io/) é uma implementação moderna do [editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) criado pelo Bill Joy lá atrás, em 1976. É um editor modal em que o modo de inserção e o modo de comandos estão separados, e é um pequeno superpoder assim que aprendes mesmo que seja só um subconjunto do conjunto incrivelmente profundo de comandos por teclas. Mas também tem uma curva de aprendizagem bem grande!

Se és completamente novo na edição ao estilo do vim, recomendo que dês uma vista de olhos à série [Vim As Your Editor do ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) no YouTube. Isso vai ensinar-te o básico. Apenas sabe que, ao contrário de editores mais conhecidos, vais demorar mais tempo a atingir uma proficiência básica com o vim. Mas quando lá chegares, a recompensa também é maior.

Ora, o Neovim é basicamente infinitamente configurável. Se quiseres mesmo exagerar, podes criar a tua própria configuração do Neovim a partir do zero. Há um ótimo curso do [Typecraft sobre configurar o Neovim a partir do zero](https://www.youtube.com/watch?v=zHTeCSVAFNY). E [o ThePrimeagen também tem um](https://www.youtube.com/watch?v=w7i4amO_zaE).

Mas o Omarchy vem com uma configuração completa do Neovim — o pacote `omarchy-nvim` — que foi afinada com carinho para mostrar o melhor do que é possível à saída da caixa. Sem teres de escrever uma única linha de configuração! É construída sobre o [LazyVim](https://www.lazyvim.org/), uma distribuição de plugins e configurações do Neovim. É fantástica.

## Noções básicas do LazyVim

Como mencionei, não vou ensinar-te vim nesta breve introdução, mas consigo mostrar-te algumas noções básicas do LazyVim e como te orientares por lá.

Primeiro, o Neovim tem a ideia da tecla leader. É basicamente a porta de entrada para todos os comandos. O LazyVim definiu-a como `Space`. Por isso basta premires isso, esperares um segundo, e vais ver uma série de opções explicadas em linha, assim:

Aqui ficam alguns comandos básicos que uso constantemente:

- `Space Space` - Procurar por aproximação qualquer ficheiro no diretório atual.
- `Space S G` - Pesquisar em todos os ficheiros usando o grep, com pré-visualização.
- `Space E` - Alternar a árvore de ficheiros ligada/desligada.
- `Ctrl + W W` - Saltar da árvore de ficheiros para o editor e voltar.
- `Shift + H` - Mover para a esquerda entre os separadores abertos (o vim chama-lhes buffers).
- `Shift + L` - Mover para a direita entre os separadores abertos.
- `Space B D` - Fechar um separador.
- `Space B O` - Fechar todos os outros separadores exceto o atual.
- `Space G G` - Lançar o LazyGit num painel flutuante a partir do diretório atual.
- `Space U W` - Alternar a quebra suave de linhas.

Enquanto estiveres na árvore de ficheiros (`Space E` para a revelar, `Ctrl + W W` para saltares para lá), podes adicionar um novo ficheiro com `a` ou um novo diretório com `A`. Prime `?` enquanto estiveres na árvore para veres todos os comandos.

Se quiseres apanhar a linguagem básica do vim, escrevi sobre [a sintaxe em três partes](https://world.hey.com/dhh/wonderful-vi-a1d034d3) e sobre como fazeres aqueles impressionantes movimentos combinados!

Podes ver todos os comandos possíveis na [página de Keymaps do LazyVim](https://www.lazyvim.org/keymaps).

## Arrancar o Neovim

Podes arrancar o Neovim com `Super + Shift + N` (a associação lança o teu editor predefinido, que, à saída da caixa, é o Neovim), mas normalmente é mais fácil conduzi-lo a partir do terminal, navegando até ao diretório onde queres trabalhar e escrevendo `n`. O `n` é o alias de `nvim`, que usa por predefinição o diretório presente para abrir. Podes abrir um único ficheiro com `n myfile.txt`.

## Usar o Neovim para edições com sudo

Se precisares de editar ficheiros que só consegues alterar como superutilizador, podes usar o neovim com todos os teus plugins configurados executando `sudoedit /etc/sudoers.d/00-sudo-only-file`.
