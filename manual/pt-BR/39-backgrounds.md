# Planos de fundo

Cada tema vem com seu próprio conjunto de planos de fundo, e você pode adicionar extras seus em `~/.config/omarchy/backgrounds/[theme]`. Se quiser adicionar uma imagem de plano de fundo extra ao tema nord, por exemplo, basta colocar o arquivo em `~/.config/omarchy/backgrounds/nord`.

Você pode fazer isso da maneira mais fácil acessando _Install > Style > Background_ no Menu do Omarchy. Isso abrirá a pasta onde os planos de fundo daquele tema estão armazenados. Pressione `Super + Shift + F` para abrir outro gerenciador de arquivos, encontre seu plano de fundo e copie-o para lá. Agora ele será incluído nas opções de planos de fundo entre as quais você pode escolher usando `Super + Ctrl + W`.

Os planos de fundo também podem ser vídeos, além de imagens estáticas. Coloque um arquivo `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparecerá junto com as imagens. Os vídeos são reproduzidos pelo motor de papel de parede OWE. Ele decodifica o vídeo uma vez para todos os monitores e reproduz seu som pela saída de áudio padrão, e interrompe a reprodução sempre que nada pode vê-lo. Um papel de parede em vídeo ainda consome muito mais energia do que um estático.

Os temas podem incluir uma breve introdução para um plano de fundo estático. Para `backgrounds/road.webp`, o vídeo correspondente fica em `backgrounds/intros/road.mp4`. Ele é reproduzido automaticamente na inicialização, ao mudar para um tema com esse plano de fundo selecionado e ao escolher esse plano de fundo, e depois retorna à imagem estática. Os vídeos de introdução não aparecem no seletor de planos de fundo e nunca são repetidos em loop.

Desativar _Appearance > Animations_ também desativa as introduções dos planos de fundo. O Omarchy faz isso por padrão em uma máquina virtual. O comando `omarchy theme bg intro toggle` pode ativar e desativar as introduções separadamente. Atualizar um tema não reproduz uma introdução.

Uma imagem estática também pode ter um loop, uma versão discreta da mesma imagem que continua se movendo, em `backgrounds/loops/road.mp4`. Ele é reproduzido no lugar da imagem estática, depois da sua introdução, se tiver uma, e para quando as animações são desativadas. Na bateria, a imagem estática é exibida em seu lugar, e o loop volta assim que você conectar na tomada. Os loops não aparecem no seletor de planos de fundo.

Você pode encontrar uma enorme coleção de planos de fundo selecionados bem legais em [dharmx/walls](https://github.com/dharmx/walls).

A tela de bloqueio mostra um quadro estático de um plano de fundo em vídeo, da mesma forma que mostra um quadro estático de um GIF animado.
