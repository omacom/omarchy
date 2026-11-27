# Fundos

Cada tema traz o seu próprio conjunto de fundos, e pode adicionar os seus extras em `~/.config/omarchy/backgrounds/[theme]`. Se quiser adicionar uma imagem de fundo extra, por exemplo, ao tema nord, basta colocar o ficheiro em `~/.config/omarchy/backgrounds/nord`.

A forma mais fácil de o fazer é ir a _Instalar > Estilo > Fundo_ no Menu Omarchy. Isso abre a pasta onde estão guardados os fundos desse tema. Prima `Super + Shift + F` para abrir outro gestor de ficheiros, encontre o seu fundo e copie-o para lá. Agora passa a estar incluído nas opções de fundos entre as quais pode escolher com `Super + Ctrl + W`.

Um tema sem fundos próprios recebe um desenhado a partir das suas cores: o logótipo do Omarchy na cor de destaque do tema sobre a sua cor de fundo. Adicione os seus para o substituir.

Os fundos também podem ser vídeos, e não apenas imagens fixas. Deixe um ficheiro `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparece ao lado das imagens. Os vídeos são reproduzidos pelo motor de fundos OWE. Este descodifica o vídeo uma única vez para todos os monitores, reproduz o som através da saída de áudio predefinida e interrompe a reprodução sempre que nada o consegue ver. Um fundo em vídeo continua a custar muito mais energia do que um fixo.

Os temas podem incluir uma introdução curta para um fundo fixo. Para `backgrounds/road.webp`, o vídeo correspondente está em `backgrounds/intros/road.mp4`. É reproduzido automaticamente no arranque, ao mudar para um tema com esse fundo selecionado e ao escolher esse fundo, e depois volta à imagem fixa. Os vídeos de introdução ficam fora do seletor de fundos e nunca entram em ciclo.

Escolher _Aspeto > Desligar Animações_ também desliga as introduções dos fundos. O Omarchy faz isto por predefinição numa máquina virtual. O comando `omarchy theme bg intro toggle` permite ligar e desligar as introduções separadamente. Atualizar um tema não reproduz uma introdução.

Uma imagem fixa também pode ter um ciclo, uma versão discreta da mesma imagem que se mantém em movimento, em `backgrounds/loops/road.mp4`. É reproduzido no lugar da imagem fixa, depois da introdução, se existir uma, e para quando as animações são desligadas. Com a bateria, é mostrada a imagem fixa, e o ciclo regressa assim que ligar o carregador. Os ciclos ficam fora do seletor de fundos.

Pode encontrar uma coleção enorme de fundos fixes, selecionados a dedo, em [dharmx/walls](https://github.com/dharmx/walls).

O ecrã de bloqueio mostra uma imagem fixa de um fundo em vídeo, da mesma forma que mostra uma imagem fixa de um GIF animado.
