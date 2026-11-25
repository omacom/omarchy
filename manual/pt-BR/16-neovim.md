# Neovim

[Neovim](https://neovim.io/) é uma implementação moderna do [editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) criado por Bill Joy lá em 1976. É um editor modal em que o modo de inserção e o modo de comando são separados, e é meio que um superpoder quando você aprende mesmo que só um subconjunto do conjunto incrivelmente profundo de comandos de teclas. Mas a curva de aprendizado também é considerável!

Se você é totalmente novo na edição no estilo vim, recomendo conferir a [série Vim As Your Editor, do ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) no YouTube. Ela vai te ensinar o básico. Só saiba que, ao contrário dos editores convencionais mais parecidos entre si, vai levar mais tempo para você atingir uma proficiência básica com o vim. Mas, quando conseguir, a recompensa também é maior.

Agora, o Neovim é basicamente infinitamente configurável. Se você realmente quiser enlouquecer, pode criar sua própria configuração do Neovim do zero. Há um ótimo curso do [Typecraft sobre como configurar o Neovim do zero](https://www.youtube.com/watch?v=zHTeCSVAFNY). E [o ThePrimeagen também tem um](https://www.youtube.com/watch?v=w7i4amO_zaE).

Mas o Omarchy vem com uma configuração completa do Neovim — o pacote `omarchy-nvim` — que foi ajustada com carinho para mostrar o melhor do que é possível logo de cara. Sem você precisar escrever uma única linha de configuração! Ela é construída sobre o [LazyVim](https://www.lazyvim.org/), uma distribuição de plugins e configurações do Neovim. É incrível.

## Noções básicas do LazyVim

Como mencionei, não vou te ensinar vim nesta introdução curta, mas posso mostrar algumas noções básicas do LazyVim e como se virar por lá.

Primeiro, o Neovim tem a ideia da tecla leader. Ela é basicamente a porta de entrada para todos os comandos. O LazyVim definiu essa tecla como `Space`. Então é só pressioná-la, esperar um segundo, e você verá um monte de opções explicadas na própria tela, assim:

Aqui estão alguns comandos básicos que uso o tempo todo:

- `Space Space` - Encontre qualquer arquivo no diretório atual com busca fuzzy.
- `Space S G` - Pesquise em todos os arquivos usando grep com uma pré-visualização.
- `Space E` - Alterne a árvore de arquivos entre exibida e oculta.
- `Ctrl + W W` - Pule da árvore de arquivos para o editor e de volta.
- `Shift + H` - Mova para a esquerda entre as abas abertas (o vim as chama de buffers).
- `Shift + L` - Mova para a direita entre as abas abertas.
- `Space B D` - Feche uma aba.
- `Space B O` - Feche todas as outras abas, menos a atual.
- `Space G G` - Abra o LazyGit em um painel flutuante a partir do diretório atual.
- `Space U W` - Alterne a quebra de linha suave.

Enquanto você estiver na árvore de arquivos (`Space E` para revelá-la, `Ctrl + W W` para pular para lá), você pode adicionar um novo arquivo com `a` ou um novo diretório com `A`. Pressione `?` enquanto estiver na árvore para ver todos os comandos.

Se você quiser aprender a linguagem básica do vim, escrevi sobre [a sintaxe em três partes](https://world.hey.com/dhh/wonderful-vi-a1d034d3) e como executar aqueles combos insanos!

Você pode ver todos os comandos possíveis na [página Keymaps do LazyVim](https://www.lazyvim.org/keymaps).

## Iniciando o Neovim

`Super + Shift + N` abre o seu editor padrão, que é o Plain em instalações novas; escolha o Neovim em _Setup > Defaults > Editor_ para que ele abra o Neovim em vez disso. Mas geralmente é mais fácil comandá-lo a partir do terminal, navegando até o diretório em que você deseja trabalhar e digitando `n`. O `n` é o alias de `nvim`, que usará o diretório atual para abrir por padrão. Você pode abrir um único arquivo com `n myfile.txt`.

## Usando o Neovim para edições com sudo

Se você precisar editar arquivos que só pode alterar como superusuário, execute `sudoedit /etc/sudoers.d/00-sudo-only-file`. Ele abre o seu editor padrão, então defina o Neovim em _Setup > Defaults > Editor_ se quiser usá-lo lá com todos os seus plugins.
