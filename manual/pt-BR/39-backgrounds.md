# Planos de fundo

Todo tema vem com seu próprio conjunto de planos de fundo, e você pode adicionar os seus extras em `~/.config/omarchy/backgrounds/[theme]`. Se quiser adicionar uma imagem de plano de fundo extra, digamos, ao tema nord, basta colocar o arquivo em `~/.config/omarchy/backgrounds/nord`.

A maneira mais fácil de fazer isso é ir em _Instalar > Estilo > Plano de fundo_ no Menu do Omarchy. Isso vai abrir a pasta onde ficam armazenados os planos de fundo daquele tema. Aperte `Super + Shift + F` para abrir outro gerenciador de arquivos, encontre seu plano de fundo e copie o arquivo para lá. Agora ele vai aparecer entre as opções de planos de fundo que você pode alternar usando `Super + Ctrl + W`.

Os planos de fundo podem ser vídeos, além de imagens estáticas. Solte um arquivo `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparece ao lado das imagens. Os vídeos são reproduzidos pelo mecanismo de papel de parede OWE. Ele decodifica o vídeo uma única vez para todos os monitores, reproduz o som dele pela saída de áudio padrão e interrompe a reprodução sempre que nada consegue vê-lo. Um papel de parede em vídeo ainda consome muito mais energia do que um estático.

Os temas podem incluir uma introdução curta para um plano de fundo estático. Para `backgrounds/road.webp`, o vídeo correspondente fica em `backgrounds/intros/road.mp4`. Ele toca automaticamente na inicialização e ao trocar para um tema com esse plano de fundo selecionado, depois volta para a imagem estática. Os vídeos de introdução ficam fora do seletor de planos de fundo e nunca são reproduzidos em loop.

Desativar _Aparência > Animações_ também desativa as introduções dos planos de fundo. O Omarchy faz isso por padrão em uma máquina virtual. O comando `omarchy theme bg intro toggle` pode ativar e desativar as introduções separadamente. Atualizar um tema ou escolher outro plano de fundo dentro do mesmo tema não reproduz uma introdução.

Você pode encontrar uma coleção enorme de planos de fundo incríveis, selecionados a dedo, em [dharmx/walls](https://github.com/dharmx/walls).

A tela de bloqueio mostra um quadro estático de um plano de fundo em vídeo, do mesmo jeito que mostra um quadro estático de um GIF animado.
