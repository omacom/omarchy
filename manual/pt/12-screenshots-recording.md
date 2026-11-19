# Capturas de Ecrã e Gravação

Tudo o que pode tirar do ecrã está pendurado na tecla Print Screen. Uma tecla sozinha tira uma fotografia e os modificadores tratam de uma gravação, de uma cor ou do texto dentro de uma região. Se o seu teclado não tiver de todo uma tecla Print Screen, `Super + Ctrl + Alt + C` faz a mesma captura de ecrã e `Super + Ctrl + C` abre o conjunto inteiro como um menu.

| Tecla de atalho | Função |
| ------ | -------- |
| `Print Screen` | Captura de ecrã |
| `Super + Ctrl + Alt + C` | Captura de ecrã |
| `Alt + Print Screen` | Gravação de ecrã (ou parar a que está a decorrer) |
| `Super + Print Screen` | Seletor de cor |
| `Super + Ctrl + Print Screen` | Extrair texto de uma região |
| `Super + Ctrl + C` | Menu de captura |
| `Super + Ctrl + .` | Transcodificar uma imagem ou um vídeo |

## Capturas de ecrã

Prima `Print Screen` (ou `Super + Ctrl + Alt + C`) e o Omasnap captura o monitor focado antes de a sua sobreposição aparecer, para que nada se desloque debaixo de si enquanto aponta. Arraste uma região livre, clique numa janela para a capturar ou clique num espaço vazio para capturar o monitor inteiro. Prima `S` antes de desenhar para capturar uma região com deslocamento. Mudou de ideias? Prima a mesma tecla outra vez para fechar o Omasnap.

Depois de selecionar uma área, o Omasnap guarda a captura, copia-a para a área de transferência e mostra uma notificação com a sua miniatura, tal como acontece com uma gravação de ecrã guardada. Escolha Abrir para ver a captura guardada no seu visualizador de imagens ou Editar para a anotar.

O editor de anotações pode desenhar setas, linhas, formas, destaques, marcadores numerados, texto e ocultações seguras; recortar ou cortar parte da imagem; fazer OCR ao seu texto; e adicionar um fundo. No editor, prima `Enter` para copiar e guardar o PNG final, `Ctrl + C` para o copiar sem guardar ou `Ctrl + S` para o guardar sem copiar.

As capturas de ecrã guardadas vão parar a `~/Pictures/Screenshots` por predefinição, com um nome como `screenshot-2026-08-13_14-22-05-firefox.png`. Defina `OMASNAP_SCREENSHOT_DIR` para usar outro diretório — consulte [as Perguntas Frequentes](46-faq.md) para saber onde colocar as variáveis de ambiente da sessão. O Omasnap cria o diretório quando guarda a primeira captura. Defina `[output] autosave = false` em `~/.config/omasnap/omasnap.conf` para desativar a gravação automática; as capturas passam então apenas a ser copiadas e mostradas numa pré-visualização durante 10 segundos, que pode manter no ecrã com o seu botão de fixar ou com `Ctrl + P`.

A partir do terminal, `omarchy screenshot` abre a mesma sobreposição e pode escolher o seu modo inicial: `omarchy capture screenshot region`, `windows`, `fullscreen` ou `scroll`. Um segundo argumento `copy` ou `save` envia a captura diretamente para esse destino. Para editar antes da saída, use `omarchy screenshot --editor=overlay` para um editor em ecrã inteiro ou `omarchy screenshot --editor=window` para uma janela separada.

### Controlar o seletor a partir do teclado

Enquanto a seleção estiver no ecrã, não precisa de usar o rato de todo:

| Tecla | Função |
| --- | -------- |
| `S` | Ativar/desativar o modo de região com deslocamento |
| `Super + Arrow keys` | Mover-se entre janelas no modo Janela |
| `Return` | Capturar a janela destacada |
| `Ctrl + A` | Capturar o monitor focado inteiro |
| `R` | Repor a última região desenhada nesta sessão |
| `Esc` | Fechar o Omasnap |

Estes atalhos só existem enquanto o Omasnap está aberto, por isso não podem entrar em conflito com nada na sua própria configuração.

## Gravação de ecrã

`Alt + Print Screen` abre _Trigger > Captura > Gravação de ecrã_, onde lhe é perguntado o que quer na banda sonora: sem áudio, áudio do ambiente de trabalho, ambiente de trabalho mais microfone ou ambiente de trabalho mais microfone mais webcam. Esta última opção só aparece se tiver mesmo uma câmara ligada. Escolha uma e o seletor de gravação do Omarchy permite-lhe arrastar uma região ou clicar numa janela ou num monitor.

A gravação funciona com o gpu-screen-recorder, que codifica na GPU a 60fps e recorre à CPU se tiver de ser. O resultado é um MP4 em `~/Videos`, com o nome `screenrecording-2026-08-13_14-22-05.mp4`. Defina `OMARCHY_SCREENRECORD_DIR` para mudar isso — mas note que, ao contrário do diretório das capturas de ecrã, este tem de já existir, caso contrário a gravação recusa-se a arrancar.

Enquanto está a gravar, aparece um pequeno indicador na barra. Clique nele para parar. Também pode parar com `Alt + Print Screen` outra vez ou com a entrada _Parar gravação de ecrã_ em _Trigger > Captura > Gravação de ecrã_, que só aparece enquanto alguma coisa está mesmo a ser gravada.

Ao parar, é feita uma pequena limpeza antes de lhe entregar o ficheiro: o primeiro fotograma é cortado e, se houver áudio, este é normalizado para -14 LUFS, com o estalido da captura do PipeWire bem no início silenciado. Depois aparece uma notificação com uma miniatura da gravação. Clique nela para reproduzir o ficheiro no Omaview.

### A sobreposição da webcam

Quando grava com uma webcam, a câmara aparece como uma janela vertical fixada e recortada no canto inferior direito daquilo que está a gravar. Se ela estiver por cima de alguma coisa de que precisa, redimensione-a em tempo real:

| Tecla de atalho | Função |
| ------ | -------- |
| `Super + Alt + [` | Tornar a sobreposição da webcam mais pequena |
| `Super + Alt + ]` | Tornar a sobreposição da webcam maior |

Existem três tamanhos — pequeno, médio e grande — e as teclas de atalho alternam entre eles. O médio é a predefinição. São proporcionais à gravação, por isso a câmara ocupa a mesma parte do fotograma quer esteja a gravar um monitor de 1080p ou um de 6K. E se tiver gravado uma região em vez de um ecrã inteiro, a sobreposição fica ancorada ao canto dessa região e não ao do monitor, para se manter dentro da captura.

Também pode chamá-la diretamente com `omarchy-capture-webcam-resize small`, ou `reset` para voltar ao médio.

## Texto, códigos QR e cores

`Super + Ctrl + Print Screen` seleciona uma região e faz OCR da mesma para a área de transferência. Isso está explicado como deve ser em [Extração de Texto e Ditado](11-text-extraction-dictation.md).

_Trigger > Captura > QR Code_ faz o mesmo truque com códigos QR. Selecione a região com o código e o valor descodificado vai para a área de transferência. Só procura códigos QR — o conteúdo denso do ecrã tem o hábito de ser falsamente detetado como um código de barras, caso contrário. Vale a pena saber: o valor descodificado vai para a área de transferência e para mais lado nenhum. Não é impresso, não está na notificação e está marcado como sensível para não ficar retido no [histórico da área de transferência](08-unified-clipboard-history.md). Os códigos QR transportam habitualmente segredos — o URI `otpauth://` por trás de um código de configuração de 2FA, por exemplo — e não vai querer isso num registo. Colar continua a funcionar perfeitamente.

`Super + Print Screen` (ou _Trigger > Captura > Cor_) transforma o cursor num conta-gotas. Clique em qualquer coisa no ecrã e a cor vai parar à área de transferência. Prima a tecla de atalho outra vez para sair sem escolher nenhuma cor.

## Transcodificar antes de partilhar

Uma gravação de ecrã em 4K ou um HEIC em bruto vindo do telemóvel é, muitas vezes, demasiado grande para simplesmente enviar. `Super + Ctrl + .` (ou _Trigger > Transcodificar_) resolve isso. Oferece-lhe um seletor de ficheiros com pesquisa aproximada em `~/Pictures` e `~/Videos`, e depois pede-lhe um formato e um tamanho.

As imagens passam para jpg ou png nos níveis alto, médio ou baixo, o que limita a largura a 3160, 2160 e 1080 píxeis. Os vídeos passam para mp4 ou para um gif animado em 4k, 1080p ou 720p. O ficheiro convertido é escrito ao lado do original, com a resolução no nome — `demo-1080p.mp4` — e o caminho é copiado para a área de transferência como um URI de ficheiro, para poder colá-lo diretamente numa aplicação que aceite ficheiros largados.

Também funciona a partir do terminal, se já souber o que quer: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Existe ainda o `omarchy transcode ascii`, que transforma uma imagem em arte ASCII — esse serve sobretudo para a [imagem de marca](41-branding.md).

## Enviar para outro sítio

Quando tiver o ficheiro, `Super + Ctrl + S` abre o menu Partilhar e envia-o para outro dispositivo na sua rede através do LocalSend. Consulte [GUIs](22-guis.md) para saber mais sobre isso.
