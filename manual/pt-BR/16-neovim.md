# Neovim

O [Neovim](https://neovim.io/) é uma implementação moderna [do editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) criado por Bill Joy lá em 1976. É um editor modal em que o modo de inserção e o modo de comando são separados, e é uma espécie de superpoder quando você aprende mesmo que apenas um subconjunto do conjunto de comandos de teclado incrivelmente profundo. Mas a curva de aprendizado também é considerável!

Se você é totalmente novo na edição estilo vim, recomendo conferir [a série Vim As Your Editor, do ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) no YouTube. Isso ensinará o básico. Apenas saiba que, ao contrário de editores mais populares semelhantes, você levará mais tempo para obter proficiência básica com o vim. Mas, quando conseguir, a recompensa também será maior.

Agora, o Neovim é basicamente infinitamente configurável. Se você realmente quiser enlouquecer, pode criar sua própria configuração do Neovim do zero. Há um ótimo curso do [Typecraft sobre configurar o Neovim do zero](https://www.youtube.com/watch?v=zHTeCSVAFNY). E [o ThePrimeagen também tem um](https://www.youtube.com/watch?v=w7i4amO_zaE).

Mas o Omarchy vem com uma configuração completa do Neovim — o pacote `omarchy-nvim` — que foi ajustado com carinho para mostrar o melhor do que é possível de imediato. Sem você ter que escrever uma única linha de configuração! Ele é construído sobre o [LazyVim](https://www.lazyvim.org/), uma distribuição de plugins e configurações do Neovim. É incrível.

## Fundamentos do LazyVim

Como mencionei, não vou lhe ensinar vim nesta breve introdução, mas posso mostrar alguns fundamentos do LazyVim e como se orientar.

Primeiro, o Neovim tem a ideia da tecla leader. Essa é basicamente a porta de entrada para todos os comandos. O LazyVim a definiu como `Space`. Então basta pressioná-la, esperar um segundo, e você verá um monte de opções explicadas inline, assim:

Aqui estão alguns comandos básicos que uso o tempo todo:

- `Space Space` - Busca fuzzy de qualquer arquivo no diretório atual.
- `Space S G` - Pesquisar em todos os arquivos usando grep com uma pré-visualização.
- `Space E` - Alternar a árvore de arquivos.
- `Ctrl + W W` - Saltar da árvore de arquivos para o editor e voltar.
- `Shift + H` - Mover para a esquerda entre as abas abertas (o vim as chama de buffers).
- `Shift + L` - Mover para a direita entre as abas abertas.
- `Space B D` - Fechar uma aba.
- `Space B O` - Fechar todas as outras abas, exceto a atual.
- `Space G G` - Abrir o LazyGit em um painel flutuante a partir do diretório atual.
- `Space U W` - Alternar a quebra suave de linha.

Enquanto estiver na árvore de arquivos (`Space E` para revelar, `Ctrl + W W` para saltar até lá), você pode adicionar um novo arquivo com `a` ou um novo diretório com `A`. Pressione `?` enquanto estiver na árvore para ver todos os comandos.

Se você quer aprender a linguagem básica do vim, eu escrevi sobre [a sintaxe de três partes](https://world.hey.com/dhh/wonderful-vi-a1d034d3) e como executar aqueles movimentos de combo sensacionais!

Você pode ver todos os comandos possíveis na [página de Keymaps do LazyVim](https://www.lazyvim.org/keymaps).

## Iniciando o Neovim

Você pode iniciar o Neovim usando `Super + Shift + N` (o atalho abre seu editor padrão, que é o Neovim de imediato), mas geralmente é mais fácil controlá-lo a partir do terminal navegando até o diretório em que você quer trabalhar e digitando `n`. O `n` é o alias de `nvim`, que usará o diretório atual para abrir por padrão. Você pode abrir um único arquivo com `n myfile.txt`.

## Usando o Neovim para edições com sudo

Se você precisar editar arquivos que só pode alterar como superusuário, pode usar o neovim com todos os seus plugins configurados executando `sudoedit /etc/sudoers.d/00-sudo-only-file`.
