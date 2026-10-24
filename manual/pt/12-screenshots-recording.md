# Capturas de ecrã e gravação

Tudo o que consegues agarrar do ecrã pendura da tecla Print Screen. Uma tecla sozinha tira uma fotografia, e os modificadores tiram uma gravação, uma cor, ou o texto dentro de uma região. Se o teu teclado não tiver nenhuma tecla Print Screen, `Super + Ctrl + C` abre o mesmo conjunto como um menu.

| Atalho | Função |
| ------ | -------- |
| `Print Screen` | Captura de ecrã |
| `Alt + Print Screen` | Gravar ecrã (ou parar a gravação em curso) |
| `Super + Print Screen` | Seletor de cores |
| `Super + Ctrl + Print Screen` | Extrair texto de uma região |
| `Super + Ctrl + C` | Menu de captura |
| `Super + Ctrl + .` | Converter uma fotografia ou um vídeo |

## Capturas de ecrã

Prime `Print Screen` e o Omasnap captura o monitor em foco antes de a sua sobreposição aparecer, para nada se deslocar debaixo de ti enquanto apontas. Arrasta uma região livre, clica numa janela para a capturares, ou clica em espaço aberto para capturares o monitor inteiro. Prime `S` antes de desenhares para capturares uma região com deslocamento. Mudaste de ideias? Prime `Print Screen` outra vez para fechares o Omasnap.

Depois de selecionares uma área, o Omasnap guarda a captura, copia-a para a área de transferência e mostra uma pré-visualização durante 10 segundos. Usa o botão de fixar da pré-visualização ou `Ctrl + P` para a manteres no ecrã, ou escolhe Editar para a anotares.

O editor de anotações consegue desenhar setas, linhas, formas, destaques, marcadores numerados, texto e ocultações seguras; recortar ou cortar parte da imagem; aplicar OCR ao seu texto; e adicionar um fundo. No editor, prime `Enter` para copiar e guardar o PNG acabado, `Ctrl + C` para o copiar sem guardar, ou `Ctrl + S` para o guardar sem copiar.

As capturas de ecrã guardadas vão parar a `~/Pictures/Screenshots` por predefinição, com um nome como `screenshot-2026-08-13_14-22-05-firefox.png`. Define `OMASNAP_SCREENSHOT_DIR` para usar outro diretório — vê [as Perguntas Frequentes](46-faq.md) para saberes onde colocar variáveis de ambiente da sessão. O Omasnap cria o diretório quando guarda a primeira captura. Define `[output] autosave = false` em `~/.config/omasnap/omasnap.conf` para desativares a gravação automática.

A partir do terminal, `omarchy screenshot` abre a mesma sobreposição, e podes escolher o seu modo de arranque: `omarchy capture screenshot region`, `windows`, `fullscreen` ou `scroll`. Um segundo argumento `copy` ou `save` salta a pré-visualização e envia a captura diretamente para esse destino. Para editares antes de produzires o resultado, usa `omarchy screenshot --editor=overlay` para um editor de ecrã inteiro ou `omarchy screenshot --editor=window` para uma janela separada.

### Conduzir o seletor a partir do teclado

Enquanto a seleção estiver aberta, não tens de usar o rato de todo:

| Tecla | Função |
| --- | -------- |
| `S` | Alternar o modo de região com deslocamento |
| `Super + Arrow keys` | Mover entre janelas no modo Janela |
| `Return` | Capturar a janela destacada |
| `Ctrl + A` | Capturar o monitor em foco inteiro |
| `R` | Restaurar a última região desenhada nesta sessão |
| `Esc` | Fechar o Omasnap |

Estas associações só existem enquanto o Omasnap está aberto, por isso não conseguem colidir com nada na tua própria configuração.

## Gravação de ecrã

`Alt + Print Screen` abre _Acionar > Capturar > Gravar ecrã_, que pergunta o que queres na banda sonora: sem áudio, áudio do ambiente de trabalho, ambiente de trabalho mais microfone, ou ambiente de trabalho mais microfone mais webcam. Essa última opção só aparece se tiveres mesmo uma câmara ligada. Escolhes uma e o seletor de gravação do Omarchy deixa-te arrastar uma região ou clicar numa janela ou num monitor.

A gravação corre sobre o gpu-screen-recorder, que codifica na GPU a 60 fps e cai para a CPU se tiver de ser. O resultado é um MP4 em `~/Videos`, chamado `screenrecording-2026-08-13_14-22-05.mp4`. Define `OMARCHY_SCREENRECORD_DIR` para mudares isso — mas repara que, ao contrário do diretório das capturas de ecrã, este tem de existir de antemão, ou então a gravação recusa-se a arrancar.

Enquanto estás a gravar, aparece um pequeno indicador na barra. Clica nele para parar. Também podes parar com `Alt + Print Screen` outra vez, ou com a entrada _Parar gravação_ em _Acionar > Capturar > Gravar ecrã_, que só aparece enquanto algo está mesmo a gravar.

Parar faz um pequeno arrumo antes de te entregar o ficheiro: o primeiro fotograma é cortado e, se houver áudio, ele é normalizado para -14 LUFS, com o estalido de captura do PipeWire logo no início silenciado. Depois aparece uma notificação com uma miniatura da gravação. Clica nela para reproduzires o ficheiro no mpv.

### A sobreposição da webcam

Quando gravas com uma webcam, a câmara aparece como uma janela de retrato recortada e fixada no canto inferior direito daquilo que estás a gravar. Se ela ficar por cima de alguma coisa de que precisas, redimensiona-a em direto:

| Atalho | Função |
| ------ | -------- |
| `Super + Alt + [` | Tornar a sobreposição da webcam mais pequena |
| `Super + Alt + ]` | Tornar a sobreposição da webcam maior |

Há três tamanhos — pequeno, médio e grande — e os atalhos andam entre eles. O médio é a predefinição. São proporcionais à gravação, por isso a câmara ocupa a mesma porção do fotograma, estejas a gravar um monitor de 1080p ou um de 6K. E se gravares uma região em vez de um ecrã inteiro, a sobreposição ancora-se ao canto dessa região, em vez do monitor, para ficar dentro da imagem.

Também a podes chamar diretamente com `omarchy-capture-webcam-resize small`, ou `reset` para voltares ao médio.

## Texto, códigos QR e cores

`Super + Ctrl + Print Screen` seleciona uma região e aplica-lhe OCR para a área de transferência. Isso está tratado como deve ser em [Extração de texto e ditado](11-text-extraction-dictation.md).

_Acionar > Capturar > Código QR_ faz o mesmo truque para códigos QR. Seleciona a região com o código e o valor descodificado vai para a área de transferência. Só procura códigos QR — o conteúdo denso do ecrã tem o hábito de dar falsos positivos de código de barras, de outro modo. Vale a pena saber: o valor descodificado vai para a área de transferência e para mais lado nenhum. Não é impresso, não está na notificação e está marcado como sensível, para não ficar no [histórico da área de transferência](08-unified-clipboard-history.md). Os códigos QR transportam rotineiramente segredos — o URI `otpauth://` por trás de um código de configuração de 2FA, por exemplo — e não queres isso num registo. Colar continua a funcionar muito bem.

`Super + Print Screen` (ou _Acionar > Capturar > Cor_) transforma o cursor num conta-gotas. Clica em qualquer coisa no ecrã e a cor vai parar à área de transferência. Prime o atalho outra vez para saíres sem escolher.

## Converter antes de partilhares

Uma gravação de ecrã a 4K ou um HEIC bruto do telemóvel é muitas vezes demasiado grande para apenas enviar. `Super + Ctrl + .` (ou _Acionar > Converter_) resolve isso. Oferece-te um seletor de ficheiros por aproximação sobre `~/Pictures` e `~/Videos`, e depois pergunta por um formato e um tamanho.

As fotografias vão para jpg ou png em alto, médio ou baixo, que limitam a largura a 3160, 2160 e 1080 píxeis. Os vídeos vão para mp4 ou um gif animado a 4K, 1080p ou 720p. O ficheiro convertido é escrito ao lado do original, com a resolução no nome — `demo-1080p.mp4` — e o caminho é copiado para a área de transferência como um URI de ficheiro, para o poderes colar diretamente numa aplicação que aceite largadas de ficheiros.

Também funciona a partir do terminal, se já souberes o que queres: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Também há o `omarchy transcode ascii`, que transforma uma imagem em arte ASCII — esse é mais para [branding](41-branding.md).

## Enviar para algum lado

Depois de teres o ficheiro, `Super + Ctrl + S` abre o menu Partilhar e envia-o para outro dispositivo na tua rede através do LocalSend. Vê [GUIs](22-guis.md) para isso.
