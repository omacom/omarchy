# Fundos

Todos os temas já trazem o seu próprio conjunto de fundos, e podes adicionar os teus extras em `~/.config/omarchy/backgrounds/[theme]`. Se quiseres adicionar uma imagem de fundo extra, por exemplo, ao tema nord, basta colocares o ficheiro em `~/.config/omarchy/backgrounds/nord`.

A forma mais fácil de o fazeres é ires a _Install > Style > Background_ no Omarchy Menu. Isso vai abrir a pasta onde estão guardados os fundos desse tema. Prime `Super + Shift + F` para abrir outro gestor de ficheiros, encontra o teu fundo e copia-o para lá. Agora vai ficar incluído nas opções de fundos entre as quais podes escolher com `Super + Ctrl + W`.

Os fundos podem ser vídeos, além de imagens fixas. Larga um ficheiro `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparece ao lado das imagens. Os vídeos são reproduzidos pelo motor de fundos OWE. Este descodifica o vídeo uma vez para todos os monitores e reproduz o som através da saída de áudio predefinida, e para a reprodução sempre que nada o consegue ver. Mesmo assim, um fundo em vídeo consome muito mais energia do que um fundo fixo.

Os temas podem incluir uma breve introdução para um fundo fixo. Para `backgrounds/road.webp`, o vídeo correspondente fica em `backgrounds/intros/road.mp4`. É reproduzido automaticamente no arranque, quando mudas para um tema com esse fundo selecionado e quando escolhes esse fundo, voltando depois à imagem fixa. Os vídeos de introdução ficam fora do seletor de fundos e nunca entram em loop.

Desativar _Appearance > Animations_ também desativa as introduções dos fundos. O Omarchy faz isto por predefinição numa máquina virtual. O comando `omarchy theme bg intro toggle` pode ativar e desativar as introduções em separado. Atualizar um tema não reproduz uma introdução.

Podes encontrar uma enorme coleção de fundos fixes e selecionados a dedo em [dharmx/walls](https://github.com/dharmx/walls).

O ecrã de bloqueio mostra um fotograma fixo de um fundo em vídeo, da mesma forma que mostra um fotograma fixo de um GIF animado.
