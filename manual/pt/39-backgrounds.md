# Fundos

Cada tema inclui o seu próprio conjunto de fundos, e pode adicionar extras seus em `~/.config/omarchy/backgrounds/[theme]`. Se quiser adicionar uma imagem de fundo extra, por exemplo, ao tema nord, basta colocar o ficheiro em `~/.config/omarchy/backgrounds/nord`.

A forma mais fácil de o fazer é ir a _Install > Style > Background_ no Menu Omarchy. Isso vai abrir a pasta onde estão guardados os fundos desse tema. Prima `Super + Shift + F` para abrir outro gestor de ficheiros, encontre o seu fundo e copie-o para lá. Agora vai passar a estar incluído nas opções de fundos entre as quais pode escolher com `Super + Ctrl + W`.

Os fundos também podem ser vídeos, não apenas imagens fixas. Coloque um ficheiro `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e este aparece ao lado das imagens. Os vídeos são reproduzidos pelo motor de papel de parede OWE. Este descodifica o vídeo uma única vez para todos os monitores, reproduz o som através da saída de áudio predefinida e interrompe a reprodução sempre que nada o consegue ver. Um papel de parede em vídeo continua a consumir muito mais energia do que um fixo.

Os temas podem incluir uma introdução curta para um fundo fixo. Para `backgrounds/road.webp`, o vídeo correspondente fica em `backgrounds/intros/road.mp4`. É reproduzido automaticamente no arranque e ao mudar para um tema com esse fundo selecionado, regressando depois à imagem fixa. Os vídeos de introdução ficam fora do seletor de fundos e nunca são reproduzidos em ciclo.

Desativar _Appearance > Animations_ também desativa as introduções dos fundos. O Omarchy faz isto por predefinição numa máquina virtual. O comando `omarchy theme bg intro toggle` permite ativar ou desativar as introduções separadamente. Atualizar um tema ou escolher outro fundo dentro do mesmo tema não reproduz uma introdução.

Pode encontrar uma enorme coleção de fundos fixes e selecionados em [dharmx/walls](https://github.com/dharmx/walls).

O ecrã de bloqueio mostra um fotograma fixo de um fundo em vídeo, da mesma forma que mostra um fotograma fixo de um GIF animado.
