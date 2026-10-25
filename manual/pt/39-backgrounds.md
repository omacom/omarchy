# Fundos

Cada tema traz o seu próprio conjunto de fundos, e pode adicionar extras seus em `~/.config/omarchy/backgrounds/[theme]`. Se quiser adicionar uma imagem de fundo extra, digamos, ao tema nord, basta colocar o ficheiro em `~/.config/omarchy/backgrounds/nord`.

A forma mais fácil de o fazer é ir a _Install > Style > Background_ no Omarchy Menu. Isso abre a pasta onde estão guardados os fundos desse tema. Prima `Super + Shift + F` para abrir outro gestor de ficheiros, encontre o seu fundo e copie-o para lá. Agora passa a estar incluído nas opções de fundos entre as quais pode escolher com `Super + Ctrl + W`.

Os fundos também podem ser vídeos, e não apenas imagens estáticas. Deixe um ficheiro `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparece ao lado das imagens. Os vídeos são reproduzidos pelo motor de wallpapers OWE. Descodifica o vídeo uma única vez para todos os monitores e reproduz o som através da saída de áudio predefinida, e para a reprodução sempre que nada o consegue ver. Um fundo em vídeo continua a custar muito mais energia do que um fundo estático.

Os temas podem incluir uma breve introdução para um fundo estático. Para `backgrounds/road.webp`, o vídeo correspondente fica em `backgrounds/intros/road.mp4`. É reproduzido automaticamente no arranque e ao mudar para um tema com esse fundo selecionado, e depois volta à imagem estática. Os vídeos de introdução ficam fora do seletor de fundos e nunca são reproduzidos em ciclo.

Desativar _Appearance > Animations_ também desativa as introduções dos fundos. O Omarchy faz isto por predefinição numa máquina virtual. O comando `omarchy theme bg intro toggle` permite ativar ou desativar as introduções em separado. Atualizar um tema ou escolher outro fundo dentro do mesmo tema não reproduz uma introdução.

Pode encontrar uma enorme coleção de fundos fantásticos, selecionados a dedo, em https://github.com/dharmx/walls.

O ecrã de bloqueio mostra um fotograma estático de um fundo em vídeo, da mesma forma que mostra um fotograma estático de um GIF animado.
