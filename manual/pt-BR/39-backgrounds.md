# Planos de fundo

Todo tema vem com seu próprio conjunto de planos de fundo, e você pode adicionar extras seus em `~/.config/omarchy/backgrounds/[theme]`. Se você quiser adicionar uma imagem de plano de fundo extra ao tema nord, por exemplo, basta colocar o arquivo em `~/.config/omarchy/backgrounds/nord`.

A maneira mais fácil de fazer isso é ir em _Install > Style > Background_ no Omarchy Menu. Isso vai abrir a pasta onde os planos de fundo daquele tema estão armazenados. Pressione `Super + Shift + F` para abrir outro gerenciador de arquivos, encontre seu plano de fundo e copie ele para lá. Agora ele será incluído nas opções de planos de fundo entre as quais você pode escolher usando `Super + Ctrl + W`.

Um tema sem planos de fundo próprios ganha um gerado a partir das suas cores: o logotipo do Omarchy na cor de destaque do tema sobre a sua cor de fundo. Adicione os seus para substituí-lo.

Planos de fundo também podem ser vídeos, além de imagens estáticas. Solte um arquivo `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparece junto com as imagens. Os vídeos são reproduzidos pelo mecanismo de papel de parede OWE. Ele decodifica o vídeo uma vez para todos os monitores e reproduz o som dele pela saída de áudio padrão, e interrompe a reprodução sempre que nada pode vê-lo. Um papel de parede em vídeo ainda consome muito mais energia do que um estático.

Os temas podem incluir uma introdução curta para um plano de fundo estático. Para `backgrounds/road.webp`, o vídeo correspondente fica em `backgrounds/intros/road.mp4`. Ele é reproduzido automaticamente na inicialização, ao trocar para um tema com aquele plano de fundo selecionado e ao escolher aquele plano de fundo, e depois volta para a imagem estática. Os vídeos de introdução ficam fora do seletor de planos de fundo e nunca são repetidos em loop.

Escolher _Appearance > Animations Off_ também desativa as introduções de plano de fundo. O Omarchy faz isso por padrão em uma máquina virtual. O comando `omarchy theme bg intro toggle` pode ativar e desativar as introduções separadamente. Atualizar um tema não reproduz uma introdução.

Uma imagem estática também pode ter um loop, uma versão discreta da mesma imagem que continua se movendo, em `backgrounds/loops/road.mp4`. Ele é reproduzido no lugar da imagem estática, depois da sua introdução, se ela tiver uma, e para quando as animações são desativadas. Na bateria, a imagem estática é exibida em seu lugar, e o loop volta assim que você conectar na tomada. Os loops ficam fora do seletor de planos de fundo.

Você pode encontrar uma coleção enorme de planos de fundo legais e selecionados em [dharmx/walls](https://github.com/dharmx/walls).

A tela de bloqueio mostra um quadro estático de um plano de fundo em vídeo, do mesmo jeito que mostra um quadro estático de um GIF animado.
