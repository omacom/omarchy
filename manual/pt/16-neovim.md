# Neovim

[Neovim](https://neovim.io/) é uma implementação moderna do [editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) criado por Bill Joy já em 1976. É um editor modal em que o modo de inserção e o modo de comando estão separados, e é quase um superpoder quando aprendes apenas um subconjunto do conjunto incrivelmente profundo de comandos de teclas. Mas também tem uma curva de aprendizagem considerável!

Se és completamente novo na edição ao estilo vim, recomendo que vejas a série [ThePrimeagen's Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) no YouTube. Isso vai ensinar-te as noções básicas. Fica apenas a saber que, ao contrário de editores mais convencionais e semelhantes, vais demorar mais tempo a atingir um nível básico de proficiência com o vim. Mas, quando o conseguires, a recompensa também é maior.

Ora, o Neovim é basicamente infinitamente configurável. Se queres mesmo ir ao extremo, podes criar a tua própria configuração do Neovim de raiz. Há um curso excelente do [Typecraft sobre como configurar o Neovim de raiz](https://www.youtube.com/watch?v=zHTeCSVAFNY). E [o ThePrimeagen também tem um](https://www.youtube.com/watch?v=w7i4amO_zaE).

Mas o Omarchy vem com uma configuração completa do Neovim — o pacote `omarchy-nvim` — que foi afinada com todo o carinho para mostrar o melhor do que é possível conseguir logo de início. Sem teres de escrever uma única linha de configuração! É construída sobre o [LazyVim](https://www.lazyvim.org/), uma distribuição de plugins e configurações para o Neovim. É incrível.

## Noções básicas do LazyVim

Como já referi, não vou ensinar-te vim nesta breve introdução, mas posso mostrar-te algumas noções básicas do LazyVim e como te orientares.

Em primeiro lugar, o Neovim tem o conceito da tecla leader. É basicamente a porta de entrada para todos os comandos. O LazyVim definiu-a como `Space`. Por isso, basta premires essa tecla, esperares um segundo e verás um conjunto de opções explicadas em linha, assim:

Aqui estão alguns comandos básicos que uso a toda a hora:

- `Space Space` - Procurar qualquer ficheiro no diretório atual por correspondência aproximada.
- `Space S G` - Pesquisar todos os ficheiros com o grep, com uma pré-visualização.
- `Space E` - Mostrar ou ocultar a árvore de ficheiros.
- `Ctrl + W W` - Saltar da árvore de ficheiros para o editor e vice-versa.
- `Shift + H` - Mover para a esquerda entre os separadores abertos (o vim chama-lhes buffers).
- `Shift + L` - Mover para a direita entre os separadores abertos.
- `Space B D` - Fechar um separador.
- `Space B O` - Fechar todos os outros separadores, exceto o atual.
- `Space G G` - Abrir o LazyGit num painel flutuante a partir do diretório atual.
- `Space U W` - Alternar a quebra suave de linhas.

Enquanto estiveres na árvore de ficheiros (`Space E` para a mostrar, `Ctrl + W W` para saltares para lá), podes adicionar um ficheiro novo com `a` ou um diretório novo com `A`. Prime `?` enquanto estiveres na árvore para veres todos os comandos.

Se queres aprender a linguagem básica do vim, escrevi sobre [a sintaxe em três partes](https://world.hey.com/dhh/wonderful-vi-a1d034d3) e sobre como executar aquelas combinações incríveis!

Podes ver todos os comandos possíveis na [página de atalhos de teclado do LazyVim](https://www.lazyvim.org/keymaps).

## Iniciar o Neovim

`Super + Shift + N` abre o teu editor predefinido, que nas instalações novas é o Plain; escolhe o Neovim em _Setup > Defaults > Editor_ para que, em vez disso, seja o Neovim a abrir. Mas normalmente é mais fácil utilizá-lo a partir do terminal, navegando para o diretório em que queres trabalhar e escrevendo `n`. O `n` é o alias de `nvim`, que por predefinição abre o diretório atual. Podes abrir um único ficheiro com `n myfile.txt`.

## Utilizar o Neovim para edições com sudo

Se precisares de editar ficheiros que só podes alterar como superutilizador, executa `sudoedit /etc/sudoers.d/00-sudo-only-file`. Isto abre o teu editor predefinido, por isso define o Neovim em _Setup > Defaults > Editor_ se o queres utilizar ali com todos os teus plugins.
