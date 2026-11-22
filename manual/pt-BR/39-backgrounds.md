# Planos de fundo

Cada tema vem com seu próprio conjunto de planos de fundo, e você pode adicionar os seus extras em `~/.config/omarchy/backgrounds/[theme]`. Se quiser adicionar uma imagem de plano de fundo extra, digamos, ao tema nord, basta colocar o arquivo em `~/.config/omarchy/backgrounds/nord`.

Você pode fazer isso da forma mais fácil acessando _Install > Style > Background_ no Omarchy Menu. Isso abrirá a pasta onde os planos de fundo daquele tema ficam armazenados. Pressione `Super + Shift + F` para abrir outro gerenciador de arquivos, encontre seu plano de fundo e copie-o para lá. Agora ele estará incluído entre as opções de planos de fundo que você pode selecionar usando `Super + Ctrl + W`.

Os planos de fundo podem ser vídeos, além de imagens estáticas. Coloque um arquivo `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparecerá junto com as imagens. Os vídeos são reproduzidos pelo mecanismo de papel de parede OWE. Ele decodifica o vídeo uma vez para todos os monitores e reproduz o som pela saída de áudio padrão, e interrompe a reprodução sempre que nada pode vê-lo. Um papel de parede em vídeo ainda consome muito mais energia do que um estático.

Os temas podem incluir uma breve introdução para um plano de fundo estático. Para `backgrounds/road.webp`, o vídeo correspondente fica em `backgrounds/intros/road.mp4`. Ele é reproduzido automaticamente na inicialização, ao alternar para um tema com esse plano de fundo selecionado e ao escolher esse plano de fundo, e depois retorna à imagem estática. Os vídeos de introdução não aparecem no seletor de planos de fundo e nunca são repetidos em loop.

Escolher _Appearance > Animations Off_ também desativa as introduções de plano de fundo. O Omarchy faz isso por padrão em uma máquina virtual. O comando `omarchy theme bg intro toggle` pode ativar ou desativar as introduções separadamente. Atualizar um tema não reproduz uma introdução.

Uma imagem estática também pode ter um loop, uma versão discreta da mesma imagem que continua se movendo, em `backgrounds/loops/road.mp4`. Ele é reproduzido no lugar da imagem estática, depois da sua introdução, se houver uma, e para quando as animações são desativadas. Na bateria, a imagem estática é exibida no lugar, e o loop volta assim que você conectar na tomada. Os loops não aparecem no seletor de planos de fundo.

Você pode encontrar uma enorme coleção de planos de fundo legais e selecionados em [dharmx/walls](https://github.com/dharmx/walls).

A tela de bloqueio mostra um quadro estático de um plano de fundo em vídeo, da mesma forma que mostra um quadro estático de um GIF animado.
