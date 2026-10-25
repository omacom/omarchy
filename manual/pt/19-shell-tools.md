# Ferramentas de shell

Além das ferramentas Linux habituais, o Omarchy também traz uma série de ferramentas de shell melhoradas. Eis as principais.

## fzf

O [fzf](https://junegunn.github.io/fzf/) dá-te pesquisa difusa de ficheiros através do alias `ff`. Vai a qualquer diretório, escreve `ff` e poderás encontrar, por pesquisa difusa, qualquer ficheiro nessa árvore, enquanto vês uma pré-visualização dos ficheiros que vais filtrando no lado direito.

Podes usar `Ctrl + R` para usar o fzf para pesquisar, de forma difusa, no teu histórico de comandos.

Esta ferramenta também é usada pelo Neovim quando escreves `Space Space`.

O manual completo pode ser consultado com `man fzf`.

## Zoxide

O [Zoxide](https://github.com/ajeetdsouza/zoxide) é um substituto do cd. Lembra-se dos diretórios onde já estiveste, para poderes saltar para eles mais facilmente da próxima vez. Imagina que fazes `cd ~/.config/omarchy` uma vez. Da próxima vez, podes simplesmente fazer `cd omarchy` (ou até apenas `cd oma`), e o Zoxide leva-te diretamente para lá.

O manual completo pode ser consultado com `man zoxide`.

## ripgrep

O [ripgrep](https://github.com/BurntSushi/ripgrep) pesquisa o conteúdo dos ficheiros com `rg <pattern> <path>`, como `rg Controller app/` para encontrar todas as menções a `Controller` no diretório app.

Esta ferramenta também é usada pelo Neovim quando escreves `Space S G`.

O manual completo pode ser consultado com `man rg`.

## eza

O [eza](https://eza.rocks/) é um substituto do ls. Dá-te listagens de diretórios com mais informação, cor e ícones. Por predefinição, o eza tem o alias ls. Também podes usar `lt` para obter uma listagem com dois níveis de aninhamento. O `lsa` dá-te uma listagem que inclui os ficheiros ocultos. E o `lta` uma listagem aninhada com ficheiros ocultos.

O manual completo pode ser consultado com `man eza`.

## fd

O [fd](https://github.com/sharkdp/fd) é um substituto mais fácil de usar do `find`. Usa `fd person.rb` para encontrar um ficheiro chamado `person.rb` na árvore atual. `fd person.rb /` pesquisa em todo o sistema de ficheiros. `fd person.rb / -H` pesquisa em todo o sistema de ficheiros, incluindo os diretórios ocultos.

O manual completo pode ser consultado com `man fd`.

## bat

O [bat](https://github.com/sharkdp/bat) é o `cat` com realce de sintaxe, números de linha e paginação. Executa `bat somefile.rb` e vais perceber por que é difícil voltar atrás. Também está discretamente a trabalhar por ti noutros sítios: é ele que coloca cor nas tuas páginas man e que renderiza as pré-visualizações no `ff`.

O manual completo pode ser consultado com `man bat`.

## tldr

O [tldr](https://tldr.sh/) é o antídoto para as páginas man que abrem com três ecrãs de história antes de te mostrarem um único exemplo. `tldr tar` dá-te o punhado de invocações que realmente querias.

## yt-dlp

O [yt-dlp](https://github.com/yt-dlp/yt-dlp) transfere vídeo do YouTube e de centenas de outros sites. `yt-dlp <url>` obtém a melhor qualidade disponível para o diretório atual.

O manual completo pode ser consultado com `man yt-dlp`.

## try

O [try](https://github.com/tobi/try) facilita a gestão de experiências de programação com diretórios com carimbo de data. Todas as experiências vivem em `~/Work/tries` e podes aceder-lhes com `try`.

O Omarchy não adiciona automaticamente o diretório `bin/` de um projeto ao `PATH`. Executa ferramentas locais do projeto em que confies com um caminho relativo explícito, como `bin/rails` ou `./bin/dev`.
