# Papéis de parede

Cada tema vem com seu próprio conjunto de papéis de parede, e você pode adicionar os seus extras em `~/.config/omarchy/backgrounds/[theme]`. Se você quiser adicionar uma imagem extra de papel de parede ao tema nord, por exemplo, basta colocar o arquivo em `~/.config/omarchy/backgrounds/nord`.

A maneira mais fácil de fazer isso é ir até _Install > Style > Background_ no Omarchy Menu. Isso abrirá a pasta onde os papéis de parede daquele tema estão armazenados. Pressione `Super + Shift + F` para abrir outro gerenciador de arquivos, encontre seu papel de parede e copie-o para lá. Agora ele estará incluído entre as opções de papéis de parede que você pode escolher usando `Super + Ctrl + W`.

Os papéis de parede também podem ser vídeos, além de imagens estáticas. Coloque um arquivo `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparecerá junto com as imagens. Os vídeos são reproduzidos pelo mecanismo de papel de parede OWE. Ele decodifica o vídeo uma vez para todos os monitores, reproduz o som pela saída de áudio padrão e interrompe a reprodução sempre que nada pode vê-lo. Um papel de parede em vídeo ainda consome muito mais energia do que um estático.

Os temas podem incluir uma introdução curta para um papel de parede estático. Para `backgrounds/road.webp`, o vídeo correspondente fica em `backgrounds/intros/road.mp4`. Ele é reproduzido automaticamente na inicialização, ao alternar para um tema com esse papel de parede selecionado e ao escolher esse papel de parede, depois retornando à imagem estática. Os vídeos de introdução ficam fora do seletor de papéis de parede e nunca entram em loop.

Desativar _Appearance > Animations_ também desativa as introduções dos papéis de parede. O Omarchy faz isso por padrão em uma máquina virtual. O comando `omarchy theme bg intro toggle` pode alternar as introduções separadamente. Atualizar um tema não reproduz uma introdução.

Uma imagem estática também pode ter um loop, uma versão tranquila da mesma imagem que continua se movendo, em `backgrounds/loops/road.mp4`. Ele é reproduzido no lugar da imagem estática, depois da sua introdução, se tiver uma, e para quando as animações são desativadas. Os loops ficam fora do seletor de papéis de parede e, como qualquer papel de parede em vídeo, consomem mais energia do que uma imagem estática.

Você pode encontrar uma enorme coleção de papéis de parede legais e selecionados em [dharmx/walls](https://github.com/dharmx/walls).

A tela de bloqueio mostra um quadro estático de um papel de parede em vídeo, da mesma forma que mostra um quadro estático de um GIF animado.
