# Capturas de ecrã e gravação

Tudo o que pode agarrar do ecrã está pendurado na tecla Print Screen. Uma tecla sozinha tira uma fotografia, e os modificadores tiram uma gravação, uma cor ou o texto dentro de uma região. Se o seu teclado não tiver de todo uma tecla Print Screen, `Super + Ctrl + Alt + C` tira a mesma captura de ecrã, e `Super + Ctrl + C` abre todo o conjunto como um menu.

| Tecla de atalho | Função |
| ------ | -------- |
| `Print Screen` | Captura de ecrã |
| `Super + Ctrl + Alt + C` | Captura de ecrã |
| `Alt + Print Screen` | Gravação de ecrã (ou parar a que estiver a decorrer) |
| `Super + Print Screen` | Seletor de cor |
| `Super + Ctrl + Print Screen` | Extrair texto de uma região |
| `Super + Ctrl + C` | Menu de captura |
| `Super + Ctrl + .` | Transcodificar uma imagem ou um vídeo |

## Capturas de ecrã

Prima `Print Screen` (ou `Super + Ctrl + Alt + C`) e o Omasnap captura o monitor em foco antes de a sua sobreposição aparecer, para que nada se desloque debaixo de si enquanto está a apontar. Arraste para desenhar uma região livre, clique numa janela para a capturar, ou clique num espaço aberto para capturar todo o monitor. Prima `S` antes de desenhar para capturar uma região com deslocamento. Mudou de ideias? Prima a mesma tecla outra vez para fechar o Omasnap.

Depois de selecionar uma área, o Omasnap guarda a captura, copia-a para a área de transferência e mostra uma notificação com a sua miniatura, tal como faz uma gravação de ecrã guardada. Escolha Abrir para ver a captura guardada no seu visualizador de imagens, ou Editar para a anotar.

O editor de anotações pode desenhar setas, linhas, formas, destaques, marcadores numerados, texto e ocultações seguras; recortar ou cortar parte da imagem; extrair o seu texto por OCR; e adicionar um fundo. No editor, prima `Enter` para copiar e guardar o PNG finalizado, `Ctrl + C` para o copiar sem guardar, ou `Ctrl + S` para o guardar sem copiar.

Por predefinição, as capturas de ecrã guardadas vão parar a `~/Pictures/Screenshots`, com um nome como `screenshot-2026-08-13_14-22-05-firefox.png`. Defina `OMASNAP_SCREENSHOT_DIR` para usar outro diretório — consulte [as perguntas frequentes](46-faq.md) para saber onde colocar as variáveis de ambiente da sessão. O Omasnap cria o diretório quando guarda a primeira captura. Defina `[output] autosave = false` em `~/.config/omasnap/omasnap.conf` para desativar a gravação automática; as capturas passam então a ser apenas copiadas, e mostradas numa pré-visualização durante 10 segundos que pode manter no ecrã com o seu botão de fixar ou com `Ctrl + P`.

A partir do terminal, `omarchy screenshot` abre a mesma sobreposição, e pode escolher o seu modo inicial: `omarchy capture screenshot region`, `windows`, `fullscreen` ou `scroll`. Um segundo argumento de `copy` ou `save` envia a captura diretamente para esse destino. Para editar antes da saída, use `omarchy screenshot --editor=overlay` para um editor em ecrã inteiro ou `omarchy screenshot --editor=window` para uma janela separada.

### Controlar o seletor a partir do teclado

Enquanto a seleção estiver aberta, não precisa de usar o rato de todo:

| Tecla | Função |
| --- | -------- |
| `S` | Alternar o modo de região com deslocamento |
| `Super + Arrow keys` | Mover-se entre janelas no modo Janela |
| `Return` | Capturar a janela destacada |
| `Ctrl + A` | Capturar todo o monitor em foco |
| `R` | Repor a última região desenhada nesta sessão |
| `Esc` | Fechar o Omasnap |

Estas ligações de teclas só existem enquanto o Omasnap está aberto, pelo que não podem entrar em conflito com nada na sua própria configuração.

## Gravação de ecrã

`Alt + Print Screen` abre _Trigger > Capture > Screenrecord_, onde lhe pergunta o que quer na banda sonora: sem áudio, áudio do ambiente de trabalho, ambiente de trabalho mais microfone, ou ambiente de trabalho mais microfone mais webcam. Essa última opção só aparece se tiver mesmo uma câmara ligada. Escolha uma e o seletor de gravação do Omarchy permite-lhe arrastar uma região ou clicar numa janela ou num monitor.

A gravação corre sobre o gpu-screen-recorder, que codifica na GPU a 60fps e recorre à CPU se tiver de ser. O resultado é um MP4 em `~/Videos`, com o nome `screenrecording-2026-08-13_14-22-05.mp4`. Defina `OMARCHY_SCREENRECORD_DIR` para alterar isso — mas note que, ao contrário do diretório das capturas de ecrã, este já tem de existir, ou a gravação recusa-se a arrancar.

Enquanto está a gravar, aparece um pequeno indicador na barra. Clique nele para parar. Também pode parar com `Alt + Print Screen` outra vez, ou com a entrada _Stop Screenrecording_ em _Trigger > Capture > Screenrecord_, que só aparece enquanto alguma coisa está mesmo a gravar.

Parar faz um pouco de arrumação antes de lhe entregar o ficheiro: o primeiro fotograma é cortado, e se houver áudio é normalizado para -14 LUFS, com o estalo da captura do PipeWire bem no início silenciado. Depois aparece uma notificação com uma miniatura da gravação. Clique nela para reproduzir o ficheiro no mpv.

### A sobreposição da webcam

Quando grava com uma webcam, a câmara aparece como uma janela em retrato fixada e recortada no canto inferior direito daquilo que está a gravar. Se estiver por cima de alguma coisa de que precisa, redimensione-a em tempo real:

| Tecla de atalho | Função |
| ------ | -------- |
| `Super + Alt + [` | Tornar a sobreposição da webcam mais pequena |
| `Super + Alt + ]` | Tornar a sobreposição da webcam maior |

Existem três tamanhos — pequeno, médio e grande — e as teclas de atalho avançam entre eles. Médio é a predefinição. São proporcionais à gravação, pelo que a câmara ocupa a mesma parcela do fotograma quer esteja a gravar um monitor 1080p ou um 6K. E se tiver gravado uma região em vez de um ecrã inteiro, a sobreposição ancora-se ao canto dessa região e não ao do monitor, para ficar dentro da captura.

Também pode chamá-la diretamente com `omarchy-capture-webcam-resize small`, ou `reset` para voltar ao tamanho médio.

## Texto, códigos QR e cores

`Super + Ctrl + Print Screen` seleciona uma região e extrai o seu texto por OCR para a área de transferência. Isso está explicado como deve ser em [Extração de Texto e Ditado](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ faz o mesmo truque para códigos QR. Selecione a região com o código nela, e o valor descodificado vai para a área de transferência. Procura apenas códigos QR — um conteúdo denso no ecrã tem o hábito de ser falsamente detetado como um código de barras, caso contrário. Vale a pena saber: o valor descodificado vai para a área de transferência e para mais lado nenhum. Não é impresso, não está na notificação, e está marcado como sensível para não ficar retido no [histórico da área de transferência](08-unified-clipboard-history.md). Os códigos QR transportam segredos com frequência — o URI `otpauth://` por trás de um código de configuração 2FA, por exemplo — e não quer isso num registo. Colar continua a funcionar bem.

`Super + Print Screen` (ou _Trigger > Capture > Color_) transforma o cursor num conta-gotas. Clique em qualquer coisa no ecrã e a cor vai parar à área de transferência. Prima a tecla de atalho outra vez para sair sem escolher.

## Transcodificar antes de partilhar

Uma gravação de ecrã 4K ou um HEIC puro do seu telemóvel são muitas vezes grandes demais para simplesmente enviar. `Super + Ctrl + .` (ou _Trigger > Transcode_) resolve isso. Oferece-lhe um seletor de ficheiros com pesquisa aproximada sobre `~/Pictures` e `~/Videos`, e depois pede um formato e um tamanho.

As imagens vão para jpg ou png em alta, média ou baixa, o que limita a largura a 3160, 2160 e 1080 píxeis. Os vídeos vão para mp4 ou um gif animado a 4k, 1080p ou 720p. O ficheiro convertido é escrito junto ao original, com a resolução no nome — `demo-1080p.mp4` — e o caminho é copiado para a área de transferência como um URI de ficheiro, para poder colá-lo diretamente numa aplicação que aceite ficheiros largados.

Também funciona a partir do terminal, se já souber o que quer: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Existe ainda `omarchy transcode ascii`, que transforma uma imagem em arte ASCII — esse serve sobretudo para [identidade visual](41-branding.md).

## Enviá-lo para algum lado

Assim que tiver o ficheiro, `Super + Ctrl + S` abre o menu Partilhar e envia-o para outro dispositivo na sua rede através do LocalSend. Consulte [GUIs](22-guis.md) para isso.
