# GUIs

## Files

O Files (Nautilus) é o gestor de ficheiros gráfico. O `Super + Shift + F` abre-o, e o `Super + Shift + Alt + F` abre-o na pasta onde o teu terminal está, o que poupa muitos cliques. O `Ctrl + L` permite-te escrever um caminho, e carregar em `Space` num ficheiro qualquer dá-te uma pré-visualização rápida sem abrir nada.

Liga uma pen USB ou um cartão SD e ele é montado automaticamente, por isso aparece logo na barra lateral. Para tudo o que for mais a sério — formatar uma unidade, verificar o estado SMART, criar partições — arranca o _Disks_ a partir do lançador de aplicações (`Super + Space`).

O duplo clique segue predefinições sensatas: as imagens abrem no imv, o vídeo no mpv, os PDFs no Document Viewer e o texto simples no Neovim.

## Disktree

Quando a unidade fica cheia e não fazes ideia do que a está a ocupar, arranca o [Disktree](https://github.com/tobi/disktree) a partir do lançador de aplicações (`Super + Space`). Ele mostra um treemap gráfico da tua pasta pessoal. Os blocos maiores ocupam mais espaço; entra nas pastas com o teclado ou o rato, marca o que deve sair e revê as tuas seleções antes de removeres seja o que for. Executa `disktree --disk` para analisar o disco inteiro.

## Obsidian

O [Obsidian](https://obsidian.md/) é uma aplicação de notas gratuita e altamente extensível que usa ficheiros Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, incluindo utilização pessoal, comercial e sem fins lucrativos.

O Obsidian também oferece um [suplemento comercial para sincronização](https://obsidian.md/sync) com aplicações móveis no iOS e no Android. (https://obsidian.md/pricing).

Arranca o Obsidian com `Super + Shift + O`. Para usares a sincronização de temas, tens de selecionar o tema `Omarchy` nas definições.

## Omawrite

A [Omawrite](https://github.com/omacom-io/omawrite) é a aplicação de escrita em Markdown incrivelmente simples do próprio Omarchy. Sem cofres, sem plugins, só tu e as palavras.

Arranca a Omawrite com `Super + Shift + W`.

## Pinta

A [Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagem, ótima para recortar, redimensionar e fazer outras manipulações básicas. Só não esperes uma alternativa ao Photoshop. Mas mesmo assim tem Magic Wand e camadas!

Arranca a Pinta através do lançador de aplicações (`Super + Space`).

## Aether

A [Aether](https://github.com/bjarneo/aether) é uma aplicação de temas que consegue extrair cores de uma imagem de fundo e transformá-las num tema completo e coeso. É a forma mais fácil de [criares o teu próprio tema](43-making-your-own-theme.md).

Arranca a Aether através do lançador de aplicações (`Super + Space`).

## LocalSend

O [LocalSend](https://localsend.org/) permite-te enviar ficheiros para outros dispositivos na mesma rede que estejam a executar a aplicação, como o AirDrop da Apple. No entanto, é multiplataforma, por isso podes enviar ficheiros de e para Windows, macOS, Android, iOS e, claro, Linux.

Podes abrir o menu Share com `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Ele dá-te quatro opções:

- **Clipboard** envia tudo o que copiaste como um ficheiro de texto. Ótimo para passares uma ligação ou um excerto para o telemóvel sem teres de enviar um e-mail a ti próprio.
- **File** abre um seletor de ficheiros onde podes selecionar vários de uma só vez.
- **Folder** envia uma pasta inteira.
- **Receive** abre o LocalSend propriamente dito para que outro dispositivo te possa enviar alguma coisa.

A mesma coisa funciona a partir do terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Deixa o caminho de fora e obténs o seletor.

Também podes enviar diretamente a partir do gestor de ficheiros: clica com o botão direito do rato numa seleção qualquer no Nautilus e escolhe _Send via LocalSend_.

A firewall do Omarchy está fechada por predefinição, exceto quanto à porta do LocalSend, por isso isto funciona imediatamente numa instalação nova. Vê [segurança](48-security.md).

## LibreOffice

O [LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, folha de cálculo, apresentações, aplicação de desenho e muito mais. É compatível com ficheiros do Microsoft Office, por isso esta é uma ótima forma de conseguires abrir esses documentos do Word.

Arranca o LibreOffice através do lançador de aplicações (`Super + Space`).

## Hype

O [Hype](https://github.com/omacom/hype) é a aplicação de apresentações incrivelmente simples do próprio Omarchy. A tua apresentação é um único ficheiro Markdown com as imagens e os vídeos ao lado: escreve cada diapositivo por baixo de uma pré-visualização ao vivo, arrasta os diapositivos para os pôr por ordem e depois apresenta em ecrã inteiro ou exporta para PDF e PowerPoint. Ele até adopta o teu tema do Omarchy.

Arranca o Hype através do lançador de aplicações (`Super + Space`). Carrega em `?` dentro dele para veres todos os atalhos.

## Signed

O [Signed](https://github.com/omacom/signed) é a forma incrivelmente simples do próprio Omarchy para assinar PDFs e preenchê-los. Coloca a tua assinatura guardada, texto e a data de hoje em qualquer ponto de uma página e depois guarda uma cópia assinada ao lado do original. Vê [Preencher PDFs](27-filling-out-pdfs.md) para saberes como.

Arranca o Signed através do lançador de aplicações (`Super + Space`), ou abre um PDF com ele a partir do gestor de ficheiros.

## Omacalc

A [Omacalc](https://github.com/omacom-io/omacalc) é a calculadora incrivelmente simples do próprio Omarchy, que abre numa janela flutuante.

Arranca a Omacalc com `Super + Shift + Q` (ou com a tecla da calculadora, se o teu teclado tiver uma).

## Signal

O [Signal](https://signal.org/) é o pioneiro das mensagens com encriptação E2E e uma ótima opção de comunicação para quem prefira não passar por um dos grandes conglomerados tecnológicos.

Arranca o Signal com `Super + Shift + G`. Ele não faz parte da instalação base, por isso, da primeira vez que carregares nisso, o Omarchy vai oferecer-se para o instalar por ti (ele também está em _Install > Service_ no menu do Omarchy).

## mpv

O [mpv](https://mpv.io/) é um leitor multimédia simples e rápido que reproduz quase tudo a partir de qualquer fonte. Ótimo para ver vídeos.

Arranca o mpv através do lançador de aplicações (`Super + Space`) ou simplesmente faz duplo clique num vídeo no gestor de ficheiros.

## Omacut

O [Omacut](https://github.com/omacom-io/omacut) é o aparador de vídeo incrivelmente simples do próprio Omarchy. Quando só precisas de cortar o início e o fim de um clipe, bate largamente ter de arrancar um editor de vídeo completo.

Arranca o Omacut através do lançador de aplicações (`Super + Space`).

## Monologue

O [Monologue](https://github.com/omacom/monologue) é o gravador de webcam incrivelmente simples do próprio Omarchy. Escolhe a tua câmara e o teu microfone uma vez e depois carrega em `Space` para gravar, e outra vez para pausar e retomar a mesma tomada. Ele grava sempre na resolução mais alta da tua câmara, com um medidor de microfone ao vivo para poderes verificar os teus níveis antes de começares.

Pára a tomada e ela abre imediatamente num editor incorporado. Faz duplo clique num clipe para o dividir, arrasta as pegas para aparar cada pedaço e remove as partes que não queres. Depois guarda-o como um MP4. A tua gravação original é mantida até a descartares, por isso podes sempre voltar atrás e cortá-la de outra forma.

Arranca o Monologue através do lançador de aplicações (`Super + Space`).
