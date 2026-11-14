# Planos de fundo

Todo tema vem com seu próprio conjunto de planos de fundo, e você pode adicionar outros por conta própria em `~/.config/omarchy/backgrounds/[theme]`. Se você quiser adicionar uma imagem extra de plano de fundo ao tema nord, por exemplo, basta colocar o arquivo em `~/.config/omarchy/backgrounds/nord`.

A maneira mais fácil de fazer isso é ir em _Install > Style > Background_ no Menu do Omarchy. Isso vai mostrar a pasta onde ficam os planos de fundo daquele tema. Aperte `Super + Shift + F` para abrir outro gerenciador de arquivos, encontre seu plano de fundo e copie ele para lá. Agora ele vai aparecer nas opções de planos de fundo entre as quais você pode alternar usando `Super + Ctrl + W`.

Os planos de fundo podem ser vídeos, além de imagens estáticas. Coloque um arquivo `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparece junto com as imagens. Os vídeos são reproduzidos pelo mecanismo de papel de parede OWE. Ele decodifica o vídeo uma vez para todos os monitores e reproduz o som pela saída de áudio padrão, e interrompe a reprodução sempre que nada pode vê-lo. Um papel de parede em vídeo ainda consome muito mais energia do que um estático.

Os temas podem incluir uma introdução curta para um plano de fundo estático. Para `backgrounds/road.webp`, o vídeo correspondente fica em `backgrounds/intros/road.mp4`. Ele é reproduzido automaticamente na inicialização, ao trocar para um tema com esse plano de fundo selecionado e ao escolher esse plano de fundo, e depois retorna à imagem estática. Os vídeos de introdução ficam fora do seletor de planos de fundo e nunca entram em loop.

Desativar _Appearance > Animations_ também desativa as introduções dos planos de fundo. O Omarchy faz isso por padrão em uma máquina virtual. O comando `omarchy theme bg intro toggle` pode alternar as introduções separadamente. Atualizar um tema não reproduz uma introdução.

Você pode encontrar uma coleção enorme de planos de fundo legais e selecionados em [dharmx/walls](https://github.com/dharmx/walls).

A tela de bloqueio mostra um quadro estático de um plano de fundo em vídeo, da mesma forma que mostra um quadro estático de um GIF animado.
