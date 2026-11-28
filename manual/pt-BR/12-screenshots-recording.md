# Capturas de tela e gravação

Tudo o que você pode capturar da tela depende da tecla Print Screen. Sozinha, uma tecla tira uma foto, e os modificadores fazem uma gravação, capturam uma cor ou o texto dentro de uma região. Se o seu teclado não tiver tecla Print Screen nenhuma, `Super + Ctrl + Alt + C` faz a mesma captura de tela, e `Super + Ctrl + C` abre todo o conjunto como um menu.

| Tecla de atalho | Função |
| ------ | -------- |
| `Print Screen` | Captura de tela |
| `Super + Ctrl + Alt + C` | Captura de tela |
| `Alt + Print Screen` | Gravação de tela (ou parar a que estiver em andamento) |
| `Super + Print Screen` | Seletor de cor |
| `Super + Ctrl + Print Screen` | Extrair texto de uma região |
| `Super + Ctrl + C` | Menu de captura |
| `Super + Ctrl + .` | Transcodificar uma imagem ou um vídeo |

## Capturas de tela

Aperte `Print Screen` (ou `Super + Ctrl + Alt + C`) e o Omasnap captura o monitor em foco antes que sua sobreposição apareça, então nada se move embaixo de você enquanto você mira. Arraste uma região livre, clique em uma janela para capturá-la ou clique em um espaço aberto para capturar o monitor inteiro. Pressione `S` antes de desenhar para capturar uma região com rolagem. Mudou de ideia? Aperte a mesma tecla de novo para fechar o Omasnap.

Depois que você seleciona uma área, o Omasnap salva a captura, copia para a área de transferência e mostra uma notificação com a miniatura dela, como faz uma gravação de tela salva. Escolha Abrir para ver a captura salva no seu visualizador de imagens ou Editar para anotar nela.

O editor de anotações pode desenhar setas, linhas, formas, destaques, marcadores numerados, texto e tarjamentos seguros; recortar ou cortar parte da imagem; fazer OCR do texto dela; e adicionar um fundo. No editor, pressione `Enter` para copiar e salvar o PNG finalizado, `Ctrl + C` para copiá-lo sem salvar ou `Ctrl + S` para salvá-lo sem copiar.

As capturas de tela salvas vão para `~/Pictures/Screenshots` por padrão, com um nome como `screenshot-2026-08-13_14-22-05-firefox.png`. Defina `OMASNAP_SCREENSHOT_DIR` para usar outro diretório — consulte [o FAQ](46-faq.md) para saber onde colocar as variáveis de ambiente da sessão. O Omasnap cria o diretório quando salva a primeira captura. Defina `[output] autosave = false` em `~/.config/omasnap/omasnap.conf` para desativar o salvamento automático; as capturas então são apenas copiadas e mostradas em uma prévia por 7 segundos, que você pode manter na tela com o botão de fixar dela ou `Ctrl + P`.

Do terminal, `omarchy screenshot` abre a mesma sobreposição, e você pode escolher o modo inicial dela: `omarchy capture screenshot region`, `windows`, `fullscreen` ou `scroll`. Um segundo argumento de `copy` ou `save` envia a captura direto para esse destino. Para editar antes da saída, use `omarchy screenshot --editor=overlay` para um editor em tela cheia ou `omarchy screenshot --editor=window` para uma janela separada.

### Controlando o seletor pelo teclado

Enquanto a seleção estiver aberta, você não precisa usar o mouse para nada:

| Tecla | Função |
| --- | -------- |
| `S` | Alternar o modo de região com rolagem |
| `Super + Arrow keys` | Mover-se entre as janelas no modo de janela |
| `Return` | Capturar a janela destacada |
| `Ctrl + A` | Capturar o monitor em foco inteiro |
| `R` | Restaurar a última região desenhada nesta sessão |
| `Esc` | Fechar o Omasnap |

Esses atalhos só existem enquanto o Omasnap está aberto, então não podem entrar em conflito com nada na sua própria configuração.

## Gravação de tela

`Alt + Print Screen` abre _Trigger > Captura > Gravação de tela_, que pergunta o que você quer na trilha sonora: nenhum áudio, áudio da área de trabalho, área de trabalho mais microfone ou área de trabalho mais microfone mais webcam. Essa última opção só aparece se você realmente tiver uma câmera conectada. Escolha uma e o seletor de gravação do Omarchy permite arrastar uma região ou clicar em uma janela ou monitor.

A gravação roda no gpu-screen-recorder, que codifica na GPU a 60fps e recorre à CPU se precisar; em GPUs que ele não suporta, como as do Apple Silicon, o Omarchy grava com o wf-recorder. O resultado é um MP4 em `~/Videos`, chamado `screenrecording-2026-08-13_14-22-05.mp4`. Defina `OMARCHY_SCREENRECORD_DIR` para mudar isso — mas note que, ao contrário do diretório de capturas de tela, esse precisa já existir, ou a gravação se recusa a começar.

Enquanto você grava, um indicadorzinho aparece na barra. Clique nele para parar. Você também pode parar com `Alt + Print Screen` de novo ou com a entrada _Parar gravação de tela_ em _Trigger > Captura > Gravação de tela_, que só aparece enquanto algo está realmente sendo gravado.

Parar faz um pouco de arrumação antes de entregar o arquivo: o primeiro quadro é cortado e, se houver áudio, ele é normalizado para -14 LUFS, com o estalo da captura do PipeWire bem no começo silenciado. Depois aparece uma notificação com uma miniatura da gravação. Escolha _Abrir_ para reproduzir o arquivo no Omaview ou _Cortar_ para recortá-lo no Omacut.

### A sobreposição da webcam

Quando você grava com uma webcam, a câmera aparece como uma janela em retrato fixada e recortada no canto inferior direito do que você estiver gravando. Se ela estiver em cima de algo de que você precisa, redimensione-a na hora:

| Tecla de atalho | Função |
| ------ | -------- |
| `Super + Alt + [` | Deixar a sobreposição da webcam menor |
| `Super + Alt + ]` | Deixar a sobreposição da webcam maior |

Há três tamanhos — pequeno, médio e grande — e as teclas de atalho avançam entre eles. O médio é o padrão. Eles são proporcionais à gravação, então a câmera ocupa a mesma parcela do quadro quer você esteja gravando um monitor 1080p, quer um de 6K. E se você gravou uma região em vez de uma tela inteira, a sobreposição se ancora no canto dessa região, e não no do monitor, então ela fica dentro da captura.

Você também pode chamá-la diretamente com `omarchy-capture-webcam-resize small`, ou `reset` para voltar ao médio.

## Texto, códigos QR e cores

`Super + Ctrl + Print Screen` seleciona uma região e faz o OCR dela para a área de transferência. Isso é tratado direito em [Extração de texto e ditado](11-text-extraction-dictation.md).

_Trigger > Captura > Código QR_ faz o mesmo truque para códigos QR. Selecione a região com o código dentro dela, e o valor decodificado vai para a área de transferência. Ele só procura códigos QR — conteúdo de tela denso tem o hábito de gerar falso positivo como código de barras se não for assim. Vale saber: o valor decodificado vai para a área de transferência e para nenhum outro lugar. Ele não é impresso, não fica na notificação e é marcado como sensível para não ficar guardado no [histórico da área de transferência](08-unified-clipboard-history.md). Códigos QR costumam carregar segredos — a URI `otpauth://` por trás de um código de configuração de 2FA, por exemplo — e você não quer isso em um log. Colar continua funcionando normalmente.

`Super + Print Screen` (ou _Trigger > Captura > Cor_) transforma o cursor em um conta-gotas. Clique em qualquer coisa na tela e a cor vai parar na área de transferência. Pressione a tecla de atalho de novo para sair sem escolher nada.

## Transcodificação antes de compartilhar

Uma gravação de tela em 4K ou um HEIC bruto do seu celular costuma ser grande demais para simplesmente enviar. `Super + Ctrl + .` (ou _Trigger > Transcodificar_) resolve isso. Ele oferece um seletor de arquivos com busca aproximada em `~/Pictures` e `~/Videos` e depois pede um formato e um tamanho.

As imagens vão para jpg ou png em alta, média ou baixa, que limitam a largura a 3160, 2160 e 1080 pixels. Os vídeos vão para mp4 ou um gif animado em 4k, 1080p ou 720p. O arquivo convertido é gravado ao lado do original, com a resolução no nome — `demo-1080p.mp4` — e o caminho é copiado para a área de transferência como uma URI de arquivo, então você pode colá-lo diretamente em um aplicativo que aceite arquivos soltos nele.

Funciona do terminal também, se você já souber o que quer: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Também existe o `omarchy transcode ascii`, que transforma uma imagem em arte ASCII — esse serve mais para [branding](41-branding.md).

## Enviando para algum lugar

Quando você tiver o arquivo, `Super + Ctrl + S` abre o menu Compartilhar e o envia para outro dispositivo na sua rede via LocalSend. Consulte [GUIs](22-guis.md) para isso.
