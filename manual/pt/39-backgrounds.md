# Fundos

Cada tema traz o seu próprio conjunto de fundos, e pode adicionar extras seus em `~/.config/omarchy/backgrounds/[theme]`. Se quiser adicionar uma imagem de fundo extra, por exemplo, ao tema nord, basta colocar o ficheiro em `~/.config/omarchy/backgrounds/nord`.

A forma mais fácil de o fazer é ir a _Instalar > Estilo > Fundo_ no Menu Omarchy. Isso vai abrir a pasta onde estão guardados os fundos desse tema. Prima `Super + Shift + F` para abrir outro gestor de ficheiros, encontre o seu fundo e copie-o para lá. Agora vai passar a estar incluído nas opções de fundos entre as quais pode escolher com `Super + Ctrl + W`.

Os fundos também podem ser vídeos, além de imagens fixas. Deixe um ficheiro `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparece ao lado das imagens. Os vídeos são reproduzidos pelo motor de wallpapers OWE. Ele descodifica o vídeo uma única vez para todos os monitores, reproduz o som através da saída de áudio predefinida e para a reprodução sempre que nada o consegue ver. Um wallpaper em vídeo continua a gastar muito mais energia do que um fixo.

Os temas podem incluir uma introdução curta para um fundo fixo. Para `backgrounds/road.webp`, o vídeo correspondente está em `backgrounds/intros/road.mp4`. É reproduzido automaticamente no arranque, ao mudar para um tema com esse fundo selecionado e ao escolher esse fundo, e depois volta à imagem fixa. Os vídeos de introdução ficam fora do seletor de fundos e nunca são reproduzidos em ciclo.

Escolher _Aparência > Animações Desativadas_ também desativa as introduções dos fundos. O Omarchy faz isto por predefinição numa máquina virtual. O comando `omarchy theme bg intro toggle` permite ativar ou desativar as introduções separadamente. Atualizar um tema não reproduz uma introdução.

Uma imagem fixa também pode ter um loop, uma versão discreta da mesma imagem que continua em movimento, em `backgrounds/loops/road.mp4`. É reproduzido no lugar da imagem fixa, depois da sua introdução, se tiver uma, e para quando as animações são desativadas. Com bateria, é mostrada a imagem fixa, e o loop regressa assim que ligar à corrente. Os loops ficam fora do seletor de fundos.

Pode encontrar uma enorme coleção de fundos fantásticos, cuidadosamente selecionados, em [dharmx/walls](https://github.com/dharmx/walls).

O ecrã de bloqueio mostra um fotograma fixo de um fundo em vídeo, da mesma forma que mostra um fotograma fixo de um GIF animado.
