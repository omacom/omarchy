# Capturas de tela e gravação

Tudo o que você pode capturar da tela fica no Print Screen. Uma tecla sozinha tira uma foto, e os modificadores fazem uma gravação, pegam uma cor ou extraem o texto dentro de uma região. Se o seu teclado não tiver uma tecla Print Screen, `Super + Ctrl + Alt + C` faz a mesma captura de tela, e `Super + Ctrl + C` abre todo o conjunto como um menu.

| Tecla de atalho | Função |
| ------ | -------- |
| `Print Screen` | Captura de tela |
| `Super + Ctrl + Alt + C` | Captura de tela |
| `Alt + Print Screen` | Gravação de tela (ou parar a que estiver em execução) |
| `Super + Print Screen` | Seletor de cor |
| `Super + Ctrl + Print Screen` | Extrair texto de uma região |
| `Super + Ctrl + C` | Menu de captura |
| `Super + Ctrl + .` | Transcodificar uma imagem ou vídeo |

## Capturas de tela

Aperte `Print Screen` (ou `Super + Ctrl + Alt + C`) e o Omasnap captura o monitor em foco antes que sua sobreposição apareça, então nada se move embaixo de você enquanto você mira. Arraste uma região livre, clique em uma janela para capturá-la ou clique em um espaço aberto para capturar o monitor inteiro. Pressione `S` antes de desenhar para capturar uma região com rolagem. Mudou de ideia? Aperte a mesma tecla de novo para dispensar o Omasnap.

Depois que você seleciona uma área, o Omasnap salva a captura, copia para a área de transferência e mostra uma prévia por 10 segundos. Use o botão de fixar da prévia ou `Ctrl + P` para mantê-la na tela, ou escolha Editar para anotá-la.

O editor de anotações pode desenhar setas, linhas, formas, destaques, marcadores numerados, texto e redações seguras; recortar ou cortar parte da imagem; fazer OCR do texto dela; e adicionar um fundo. No editor, pressione `Enter` para copiar e salvar o PNG finalizado, `Ctrl + C` para copiá-lo sem salvar, ou `Ctrl + S` para salvá-lo sem copiar.

As capturas de tela salvas vão para `~/Pictures/Screenshots` por padrão, com um nome como `screenshot-2026-08-13_14-22-05-firefox.png`. Defina `OMASNAP_SCREENSHOT_DIR` para usar outro diretório — veja [o FAQ](46-faq.md) para saber onde colocar as variáveis de ambiente da sessão. O Omasnap cria o diretório quando salva a primeira captura. Defina `[output] autosave = false` em `~/.config/omasnap/omasnap.conf` para desativar o salvamento automático.

Do terminal, `omarchy screenshot` abre a mesma sobreposição, e você pode escolher seu modo inicial: `omarchy capture screenshot region`, `windows`, `fullscreen` ou `scroll`. Um segundo argumento de `copy` ou `save` pula a prévia e envia a captura direto para esse destino. Para editar antes da saída, use `omarchy screenshot --editor=overlay` para um editor em tela cheia ou `omarchy screenshot --editor=window` para uma janela separada.

### Controlando o seletor pelo teclado

Enquanto a seleção estiver aberta, você não precisa usar o mouse para nada:

| Tecla | Função |
| --- | -------- |
| `S` | Alternar o modo de região com rolagem |
| `Super + Arrow keys` | Mover-se entre as janelas no modo Janela |
| `Return` | Capturar a janela destacada |
| `Ctrl + A` | Capturar o monitor em foco inteiro |
| `R` | Restaurar a última região desenhada nesta sessão |
| `Esc` | Dispensar o Omasnap |

Esses atalhos só existem enquanto o Omasnap está aberto, então eles não podem entrar em conflito com nada da sua própria configuração.

## Gravação de tela

`Alt + Print Screen` abre _Trigger > Capture > Screenrecord_, que pergunta o que você quer na trilha sonora: sem áudio, áudio da área de trabalho, área de trabalho mais microfone, ou área de trabalho mais microfone mais webcam. Essa última opção só aparece se você realmente tiver uma câmera conectada. Escolha uma e o seletor de gravação do Omarchy permite arrastar uma região ou clicar em uma janela ou monitor.

A gravação roda no gpu-screen-recorder, que codifica na GPU a 60fps e recorre à CPU se precisar. O resultado é um MP4 em `~/Videos`, chamado `screenrecording-2026-08-13_14-22-05.mp4`. Defina `OMARCHY_SCREENRECORD_DIR` para mudar isso — mas note que, ao contrário do diretório de capturas de tela, esse precisa já existir, ou a gravação se recusa a começar.

Enquanto você está gravando, um pequeno indicador aparece na barra. Clique nele para parar. Você também pode parar com `Alt + Print Screen` de novo, ou com a entrada _Stop Screenrecording_ em _Trigger > Capture > Screenrecord_, que só aparece enquanto algo está realmente gravando.

Parar faz uma pequena limpeza antes de entregar o arquivo: o primeiro quadro é cortado e, se houver áudio, ele é normalizado para -14 LUFS, com o estalo de captura do PipeWire bem no início silenciado. Depois, aparece uma notificação com uma miniatura da gravação. Clique nela para reproduzir o arquivo no mpv.

### A sobreposição da webcam

Quando você grava com uma webcam, a câmera aparece como uma janela de retrato fixada e recortada no canto inferior direito do que você estiver gravando. Se ela estiver em cima de algo de que você precisa, redimensione na hora:

| Tecla de atalho | Função |
| ------ | -------- |
| `Super + Alt + [` | Diminuir a sobreposição da webcam |
| `Super + Alt + ]` | Aumentar a sobreposição da webcam |

São três tamanhos — pequeno, médio e grande — e as teclas de atalho alternam entre eles. Médio é o padrão. Eles são proporcionais à gravação, então a câmera ocupa a mesma parte do quadro quer você esteja gravando um monitor 1080p ou um de 6K. E se você gravou uma região em vez de uma tela inteira, a sobreposição se ancora no canto dessa região, e não no do monitor, então ela fica dentro da captura.

Você também pode chamar isso diretamente com `omarchy-capture-webcam-resize small`, ou `reset` para voltar ao médio.

## Texto, QR codes e cores

`Super + Ctrl + Print Screen` seleciona uma região e faz OCR dela para a área de transferência. Isso é abordado direito em [Extração de texto e ditado](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ faz o mesmo truque para QR codes. Selecione a região com o código nela, e o valor decodificado vai para a área de transferência. Ele só procura QR codes — conteúdo de tela denso tem o hábito de gerar falso positivo como código de barras, de outra forma. Vale saber: o valor decodificado vai para a área de transferência e para nenhum outro lugar. Ele não é impresso, não está na notificação e é marcado como sensível para não ficar no [histórico da área de transferência](08-unified-clipboard-history.md). QR codes costumam carregar segredos — a URI `otpauth://` por trás de um código de configuração de 2FA, por exemplo — e você não quer isso em um log. Colar continua funcionando normalmente.

`Super + Print Screen` (ou _Trigger > Capture > Color_) transforma o cursor em um conta-gotas. Clique em qualquer coisa na tela e a cor vai para a área de transferência. Pressione a tecla de atalho de novo para sair sem escolher.

## Transcodificando antes de compartilhar

Uma gravação de tela em 4K ou um HEIC bruto do seu celular costuma ser grande demais para simplesmente enviar. `Super + Ctrl + .` (ou _Trigger > Transcode_) resolve isso. Ele oferece um seletor de arquivos com busca aproximada sobre `~/Pictures` e `~/Videos`, depois pede um formato e um tamanho.

Imagens vão para jpg ou png em alto, médio ou baixo, que limitam a largura a 3160, 2160 e 1080 pixels. Vídeos vão para mp4 ou um gif animado em 4k, 1080p ou 720p. O arquivo convertido é escrito ao lado do original, com a resolução no nome — `demo-1080p.mp4` — e o caminho é copiado para a área de transferência como uma URI de arquivo, então você pode colá-lo direto em um app que aceite arquivos arrastados.

Funciona do terminal também, se você já sabe o que quer: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Há também `omarchy transcode ascii`, que transforma uma imagem em arte ASCII — esse é mais para [identidade visual](41-branding.md).

## Enviando para algum lugar

Depois que você tiver o arquivo, `Super + Ctrl + S` abre o menu Compartilhar e o envia para outro dispositivo na sua rede via LocalSend. Veja [GUIs](22-guis.md) para isso.
