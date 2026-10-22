# Fundos

Cada tema vem com o seu próprio conjunto de fundos, e pode adicionar extras seus em `~/.config/omarchy/backgrounds/[theme]`. Se quiser adicionar uma imagem de fundo extra, digamos, ao tema nord, basta colocar o ficheiro em `~/.config/omarchy/backgrounds/nord`.

A forma mais fácil de o fazer é ir a _Instalar > Estilo > Fundo_ no menu Omarchy. Isso abre a pasta onde estão guardados os fundos desse tema. Prima `Super + Shift + F` para iniciar outro gestor de ficheiros, encontre o seu fundo e copie-o para lá.  Agora passará a estar incluído nas escolhas de fundos entre as quais pode selecionar usando `Super + Ctrl + Space`.

Os fundos podem ser vídeos, além de imagens fixas. Deixe um ficheiro `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparece ao lado das imagens. Os vídeos são reproduzidos pelo motor de wallpapers OWE. Ele descodifica o vídeo uma vez para todos os monitores e reproduz o seu som através da saída de áudio predefinida, e para a reprodução sempre que nada o consegue ver. O ecrã de bloqueio desenha a mesma descodificação, sem som, através do OWE. Um wallpaper em vídeo continua a custar muito mais energia do que um fixo.

Os temas podem incluir uma pequena introdução para um fundo fixo. Para `backgrounds/road.webp`, o vídeo correspondente vive em `backgrounds/intros/road.mp4`. Ele reproduz-se automaticamente no arranque e ao mudar para um tema com esse fundo selecionado, e depois regressa à imagem fixa. Os vídeos de introdução ficam fora do seletor de fundos e nunca entram em ciclo.

Desligar _Acionar > Aspeto > Animações_ também desliga as introduções dos fundos. O Omarchy faz isso por predefinição numa máquina virtual. O comando `omarchy theme bg intro toggle` pode alternar as introduções separadamente. Atualizar um tema ou escolher outro fundo dentro do mesmo tema não reproduz uma introdução.

Pode encontrar uma enorme coleção de fundos fantásticos e selecionados em https://github.com/dharmx/walls.

Os fundos em vídeo mantêm uma imagem fixa em cache no ecrã de bloqueio enquanto a reprodução está pausada ou indisponível. Os GIF animados reproduzem-se no ambiente de trabalho e mostram uma imagem fixa no ecrã de bloqueio.
