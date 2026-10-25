# Planos de fundo

Cada tema vem com seu próprio conjunto de planos de fundo, e você pode adicionar extras seus em `~/.config/omarchy/backgrounds/[theme]`. Se você quiser adicionar uma imagem de plano de fundo extra ao tema nord, por exemplo, basta colocar o arquivo em `~/.config/omarchy/backgrounds/nord`.

A maneira mais fácil de fazer isso é ir até _Instalar > Estilo > Plano de fundo_ no Menu do Omarchy. Isso abrirá a pasta onde os planos de fundo daquele tema estão armazenados. Pressione `Super + Shift + F` para abrir outro gerenciador de arquivos, encontre seu plano de fundo e copie-o para lá. Agora ele será incluído nas opções de planos de fundo entre as quais você pode escolher usando `Super + Ctrl + W`.

Planos de fundo podem ser vídeos, além de imagens estáticas. Coloque um arquivo `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparece ao lado das imagens. Os vídeos são reproduzidos pelo mecanismo de papel de parede OWE. Ele decodifica o vídeo uma vez para todos os monitores e reproduz o som pela saída de áudio padrão, e interrompe a reprodução sempre que nada pode vê-lo. Um papel de parede em vídeo ainda consome muito mais energia do que um estático.

Os temas podem incluir uma introdução curta para um plano de fundo estático. Para `backgrounds/road.webp`, o vídeo correspondente fica em `backgrounds/intros/road.mp4`. Ele é reproduzido automaticamente na inicialização e ao mudar para um tema com esse plano de fundo selecionado, depois retorna à imagem estática. Os vídeos de introdução ficam fora do seletor de planos de fundo e nunca entram em loop.

Desativar _Aparência > Animações_ também desativa as introduções dos planos de fundo. O Omarchy faz isso por padrão em uma máquina virtual. O comando `omarchy theme bg intro toggle` pode ativar e desativar as introduções separadamente. Atualizar um tema ou escolher outro plano de fundo dentro do mesmo tema não reproduz uma introdução.

Você pode encontrar uma enorme coleção de planos de fundo legais e selecionados em https://github.com/dharmx/walls.

A tela de bloqueio mostra um quadro estático de um plano de fundo em vídeo, da mesma forma que mostra um quadro estático de um GIF animado.
