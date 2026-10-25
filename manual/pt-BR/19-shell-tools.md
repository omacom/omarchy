# Ferramentas de shell

Além das ferramentas padrão do Linux, o Omarchy também vem com várias ferramentas de shell aprimoradas. Aqui estão as principais.

## fzf

O [fzf](https://junegunn.github.io/fzf/) oferece busca difusa de arquivos pelo alias `ff`. Vá a qualquer diretório, digite `ff` e você poderá navegar por busca difusa até qualquer arquivo daquela árvore, vendo uma pré-visualização dos arquivos que está filtrando no lado direito.

Você pode usar `Ctrl + R` para usar o fzf na busca difusa pelo histórico de comandos.

Essa ferramenta também é usada pelo Neovim quando você digita `Space Space`.

O manual completo pode ser encontrado com `man fzf`.

## Zoxide

O [Zoxide](https://github.com/ajeetdsouza/zoxide) é uma substituição para o cd. Ele se lembra dos diretórios em que você esteve, então você pode pular para eles com mais facilidade na próxima vez. Digamos que você faça `cd ~/.config/omarchy` uma vez. Na próxima, você pode simplesmente fazer `cd omarchy` (ou até mesmo `cd oma`), e o Zoxide o levará direto para lá.

O manual completo pode ser encontrado com `man zoxide`.

## ripgrep

O [ripgrep](https://github.com/BurntSushi/ripgrep) pesquisa o conteúdo de arquivos usando `rg <pattern> <path>`, como `rg Controller app/` para encontrar todas as menções a `Controller` no diretório app.

Essa ferramenta também é usada pelo Neovim quando você digita `Space S G`.

O manual completo pode ser encontrado com `man rg`.

## eza

O [eza](https://eza.rocks/) é uma substituição para o ls. Ele oferece listagens de diretórios com mais informações, cores e ícones. Por padrão, o eza está aliado como ls. Você também pode usar `lt` para obter uma listagem com dois níveis de profundidade. `lsa` oferece uma listagem incluindo arquivos ocultos. E `lta`, uma listagem aninhada com arquivos ocultos.

O manual completo pode ser encontrado com `man eza`.

## fd

O [fd](https://github.com/sharkdp/fd) é uma substituição mais fácil de usar para o `find`. Use `fd person.rb` para encontrar um arquivo chamado `person.rb` dentro da árvore atual. `fd person.rb /` pesquisa todo o sistema de arquivos. `fd person.rb / -H` pesquisa todo o sistema de arquivos, incluindo diretórios ocultos.

O manual completo pode ser encontrado com `man fd`.

## bat

O [bat](https://github.com/sharkdp/bat) é o `cat` com destaque de sintaxe, números de linha e paginação. Execute `bat somefile.rb` e você verá por que é difícil voltar atrás. Ele também trabalha silenciosamente por você em outros lugares: é ele que colore suas páginas man e que renderiza as pré-visualizações no `ff`.

O manual completo pode ser encontrado com `man bat`.

## tldr

O [tldr](https://tldr.sh/) é o antídoto para páginas man que começam com três telas de histórico antes de mostrar um único exemplo. `tldr tar` oferece as poucas invocações que você realmente queria.

## yt-dlp

O [yt-dlp](https://github.com/yt-dlp/yt-dlp) baixa vídeos do YouTube e de centenas de outros sites. `yt-dlp <url>` baixa a melhor qualidade disponível para o diretório atual.

O manual completo pode ser encontrado com `man yt-dlp`.

## try

O [try](https://github.com/tobi/try) facilita o gerenciamento de experimentos de programação com diretórios marcados com a data. Todos os experimentos ficam em `~/Work/tries` e você pode acessá-los com `try`.

O Omarchy não adiciona automaticamente o diretório `bin/` de um projeto ao `PATH`. Execute ferramentas confiáveis locais do projeto com um caminho relativo explícito, como `bin/rails` ou `./bin/dev`.
