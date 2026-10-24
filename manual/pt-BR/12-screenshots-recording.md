# Capturas de Tela e Gravação

Tudo o que você pode pegar da tela depende da tecla Print Screen. Uma tecla sozinha tira uma foto, e os modificadores fazem uma gravação, pegam uma cor ou o texto dentro de uma região. Se o seu teclado não tem tecla Print Screen, `Super + Ctrl + C` abre o mesmo conjunto como um menu.

| Atalho | Função |
| ------ | -------- |
| `Print Screen` | Captura de tela |
| `Alt + Print Screen` | Gravação de tela (ou interromper a que está em andamento) |
| `Super + Print Screen` | Seletor de cor |
| `Super + Ctrl + Print Screen` | Extrair texto de uma região |
| `Super + Ctrl + C` | Menu de captura |
| `Super + Ctrl + .` | Transcodificar uma imagem ou vídeo |

## Capturas de tela

Pressione `Print Screen` e o Omasnap captura o monitor focado antes que sua sobreposição apareça, para que nada se mova sob você enquanto mira. Arraste uma região livre, clique em uma janela para capturá-la ou clique em espaço aberto para capturar o monitor inteiro. Pressione `S` antes de desenhar para capturar uma região com rolagem. Mudou de ideia? Pressione `Print Screen` novamente para dispensar o Omasnap.

Depois que você seleciona uma área, o Omasnap salva a captura, copia-a para a área de transferência e mostra uma pré-visualização por 10 segundos. Use o botão de fixar da pré-visualização ou `Ctrl + P` para mantê-la na tela, ou escolha Editar para anotá-la.

O editor de anotações pode desenhar setas, linhas, formas, destaques, marcadores numerados, texto e tarjas seguras; recortar ou cortar parte da imagem; fazer OCR do seu texto; e adicionar um fundo. No editor, pressione `Enter` para copiar e salvar o PNG final, `Ctrl + C` para copiá-lo sem salvar, ou `Ctrl + S` para salvá-lo sem copiar.

Capturas salvas vão para `~/Pictures/Screenshots` por padrão, com um nome como `screenshot-2026-08-13_14-22-05-firefox.png`. Defina `OMASNAP_SCREENSHOT_DIR` para usar outro diretório — veja [o FAQ](46-faq.md) para onde colocar variáveis de ambiente da sessão. O Omasnap cria o diretório quando salva a primeira captura. Defina `[output] autosave = false` em `~/.config/omasnap/omasnap.conf` para desativar o salvamento automático.

No terminal, `omarchy screenshot` abre a mesma sobreposição, e você pode escolher seu modo inicial: `omarchy capture screenshot region`, `windows`, `fullscreen` ou `scroll`. Um segundo argumento `copy` ou `save` pula a pré-visualização e envia a captura direto para aquele destino. Para editar antes da saída, use `omarchy screenshot --editor=overlay` para um editor em tela cheia ou `omarchy screenshot --editor=window` para uma janela separada.

### Controlando o seletor pelo teclado

Com a seleção aberta, você não precisa usar o mouse:

| Tecla | Função |
| --- | -------- |
| `S` | Alternar o modo de região com rolagem |
| `Super + Arrow keys` | Mover entre janelas no modo Janela |
| `Return` | Capturar a janela destacada |
| `Ctrl + A` | Capturar o monitor focado inteiro |
| `R` | Restaurar a última região desenhada nesta sessão |
| `Esc` | Dispensar o Omasnap |

Esses atalhos só existem enquanto o Omasnap está aberto, então não podem colidir com nada na sua própria configuração.

## Gravação de tela

`Alt + Print Screen` abre _Acionar > Capturar > Gravação de tela_, que pergunta o que você quer na trilha sonora: sem áudio, áudio do desktop, desktop mais microfone, ou desktop mais microfone mais webcam. Essa última opção só aparece se você realmente tiver uma câmera conectada. Escolha uma e o seletor de gravação do Omarchy permite arrastar uma região ou clicar em uma janela ou monitor.

A gravação roda no gpu-screen-recorder, que codifica na GPU a 60 fps e recorre à CPU se precisar. O resultado é um MP4 em `~/Videos`, chamado `screenrecording-2026-08-13_14-22-05.mp4`. Defina `OMARCHY_SCREENRECORD_DIR` para mudar isso — mas note que, ao contrário do diretório de capturas, este precisa já existir, ou a gravação se recusa a começar.

Enquanto grava, um pequeno indicador aparece na barra. Clique nele para parar. Você também pode parar com `Alt + Print Screen` novamente, ou com a entrada _Parar gravação de tela_ em _Acionar > Capturar > Gravação de tela_, que só aparece enquanto algo está realmente gravando.

Parar faz uma pequena organização antes de entregar o arquivo: o primeiro quadro é cortado e, se houver áudio, ele é normalizado para -14 LUFS com o estalo de captura do PipeWire bem no início silenciado. Depois aparece uma notificação com uma miniatura da gravação. Clique nela para reproduzir o arquivo no mpv.

### A sobreposição da webcam

Quando você grava com uma webcam, a câmera aparece como uma janela de retrato fixada e recortada no canto inferior direito do que você está gravando. Se ela estiver sobre algo de que você precisa, redimensione-a na hora:

| Atalho | Função |
| ------ | -------- |
| `Super + Alt + [` | Diminuir a sobreposição da webcam |
| `Super + Alt + ]` | Aumentar a sobreposição da webcam |

Há três tamanhos — pequeno, médio e grande — e os atalhos alternam entre eles. Médio é o padrão. Eles são proporcionais à gravação, então a câmera ocupa a mesma parcela do quadro quer você grave um monitor de 1080p ou um de 6K. E, se você gravou uma região em vez de uma tela inteira, a sobreposição se ancora no canto daquela região em vez do canto do monitor, para ficar dentro da cena.

Você também pode chamá-la diretamente com `omarchy-capture-webcam-resize small`, ou `reset` para voltar ao médio.

## Texto, códigos QR e cores

`Super + Ctrl + Print Screen` seleciona uma região e faz OCR dela para a área de transferência. Isso é tratado devidamente em [Extração de Texto e Ditado](11-text-extraction-dictation.md).

_Acionar > Capturar > Código QR_ faz o mesmo truque para códigos QR. Selecione a região com o código, e o valor decodificado vai para a área de transferência. Ele só procura códigos QR — conteúdo denso de tela tem o hábito de gerar falsos positivos como código de barras, caso contrário. Vale saber: o valor decodificado vai para a área de transferência e para nenhum outro lugar. Ele não é impresso, não está na notificação e é marcado como sensível para não ficar no [histórico da área de transferência](08-unified-clipboard-history.md). Códigos QR rotineiramente carregam segredos — a URI `otpauth://` por trás de um código de configuração de 2FA, por exemplo — e você não quer isso em um log. Colar continua funcionando bem.

`Super + Print Screen` (ou _Acionar > Capturar > Cor_) transforma o cursor em um conta-gotas. Clique em qualquer coisa na tela e a cor vai para a área de transferência. Pressione o atalho novamente para sair sem escolher.

## Transcodificando antes de compartilhar

Uma gravação de tela em 4K ou um HEIC bruto do seu telefone geralmente é grande demais para simplesmente enviar. `Super + Ctrl + .` (ou _Acionar > Transcodificar_) resolve isso. Ele oferece um seletor de arquivos fuzzy sobre `~/Pictures` e `~/Videos`, e depois pede um formato e um tamanho.

Imagens vão para jpg ou png em alto, médio ou baixo, que limitam a largura a 3160, 2160 e 1080 pixels. Vídeos vão para mp4 ou um gif animado em 4k, 1080p ou 720p. O arquivo convertido é escrito ao lado do original com a resolução no nome — `demo-1080p.mp4` — e o caminho é copiado para a área de transferência como uma URI de arquivo, para você colar direto em um aplicativo que aceita arquivos arrastados.

Também funciona no terminal, se você já sabe o que quer: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Há também `omarchy transcode ascii`, que transforma uma imagem em arte ASCII — esse é principalmente para [branding](41-branding.md).

## Enviando para algum lugar

Depois que você tem o arquivo, `Super + Ctrl + S` abre o menu Compartilhar e o envia para outro dispositivo na sua rede via LocalSend. Veja [GUIs](22-guis.md) para isso.
