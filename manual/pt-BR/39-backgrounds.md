# Planos de fundo

Todo tema vem com seu próprio conjunto de planos de fundo, e você pode adicionar os seus em `~/.config/omarchy/backgrounds/[theme]`. Se você quer adicionar uma imagem de fundo extra, digamos, ao tema nord, é só colocar o arquivo em `~/.config/omarchy/backgrounds/nord`.

A maneira mais fácil de fazer isso é ir até _Instalar > Estilo > Plano de fundo_ no menu do Omarchy. Isso vai abrir a pasta onde os planos de fundo desse tema ficam armazenados. Pressione `Super + Shift + F` para abrir outro gerenciador de arquivos, encontre seu plano de fundo e copie-o para lá. Agora ele estará incluído entre as opções de planos de fundo que você pode selecionar com `Super + Ctrl + Space`.

Os planos de fundo podem ser vídeos além de imagens estáticas. Solte um arquivo `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` na mesma pasta e ele aparece ao lado das imagens. Os vídeos são reproduzidos pelo motor de papel de parede OWE. Ele decodifica o vídeo uma vez para todos os monitores e reproduz o som pela saída de áudio padrão, e para a reprodução sempre que nada pode vê-lo. A tela de bloqueio desenha a mesma decodificação, sem som, pelo OWE. Um papel de parede em vídeo ainda custa muito mais energia do que um estático.

Os temas podem incluir uma introdução curta para um plano de fundo estático. Para `backgrounds/road.webp`, o vídeo correspondente fica em `backgrounds/intros/road.mp4`. Ele é reproduzido automaticamente na inicialização e ao alternar para um tema com esse plano de fundo selecionado, e depois retorna à imagem estática. Os vídeos de introdução ficam fora do seletor de planos de fundo e nunca se repetem.

Desativar _Acionar > Aparência > Animações_ também desativa as introduções de plano de fundo. O Omarchy faz isso por padrão em uma máquina virtual. O comando `omarchy theme bg intro toggle` pode alternar as introduções separadamente. Atualizar um tema ou escolher outro plano de fundo dentro do mesmo tema não reproduz uma introdução.

Você pode encontrar uma coleção enorme de planos de fundo legais e selecionados em https://github.com/dharmx/walls.

Os planos de fundo em vídeo mantêm uma imagem estática em cache na tela de bloqueio enquanto a reprodução está pausada ou indisponível. GIFs animados são reproduzidos na área de trabalho e mostram um quadro estático na tela de bloqueio.
