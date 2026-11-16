# GUIs

## Ficheiros

O Files (Nautilus) é o gestor de ficheiros gráfico. `Super + Shift + F` abre-o, e `Super + Shift + Alt + F` abre-o no diretório em que o terminal está, o que poupa muitos cliques. `Ctrl + L` permite escrever um caminho, e premir `Space` em qualquer ficheiro dá-lhe uma pré-visualização rápida sem abrir nada.

Ligue uma pen USB ou um cartão SD e é montado automaticamente, por isso aparece logo na barra lateral. Para algo mais avançado — formatar uma unidade, verificar o estado SMART, criar partições — inicie o _Disks_ a partir do lançador de aplicações (`Super + Space`).

O duplo clique segue predefinições sensatas: fotografias, vídeos e música abrem no Omaview, PDFs no Document Viewer, Markdown no Omawrite e texto simples no editor escolhido em _Setup > Default > Editor_.

## Disktree

Quando a unidade fica cheia e não faz ideia do que a está a ocupar, inicie o [Disktree](https://github.com/tobi/disktree) a partir do lançador de aplicações (`Super + Space`). Mostra um mapa de árvore gráfico da sua pasta pessoal. Os blocos maiores ocupam mais espaço; navegue pelos diretórios com o teclado ou o rato, marque o que deve sair e reveja as suas seleções antes de remover o que quer que seja. Execute `disktree --disk` para analisar o disco inteiro.

## Obsidian

O [Obsidian](https://obsidian.md/) é uma aplicação de notas gratuita e altamente extensível que utiliza ficheiros Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, incluindo utilização pessoal, comercial e sem fins lucrativos.

O Obsidian também oferece um [suplemento comercial para sincronização](https://obsidian.md/sync) com aplicações móveis para iOS e Android. (https://obsidian.md/pricing).

Inicia o Obsidian com `Super + Shift + O`. Para utilizar a sincronização de temas, tem de selecionar o tema `Omarchy` nas definições.

## Omawrite

O [Omawrite](https://github.com/omacom-io/omawrite) é a aplicação de escrita em Markdown mesmo muito simples do Omarchy. Sem cofres, sem plugins, apenas você e as palavras.

Inicia o Omawrite com `Super + Shift + W`.

## Pinta

O [Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagem que é ótima para cortar, redimensionar e outras manipulações básicas. Não espere uma alternativa ao Photoshop. Mas mesmo assim tem Varinha Mágica e camadas!

Inicia o Pinta através do lançador de aplicações (`Super + Space`).

## Aether

O [Aether](https://github.com/bjarneo/aether) é uma aplicação de temas que consegue extrair cores de uma imagem de fundo e transformá-las num tema completo e coeso. É a maneira mais fácil de [criar o seu próprio tema](43-making-your-own-theme.md).

Inicia o Aether através do lançador de aplicações (`Super + Space`).

## LocalSend

O [LocalSend](https://localsend.org/) permite enviar ficheiros para outros dispositivos na mesma rede que estejam a executar a aplicação, como o AirDrop da Apple. Mas é multiplataforma, por isso pode enviar ficheiros de e para Windows, macOS, Android, iOS e, claro, Linux.

Pode abrir o menu Partilhar com `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Dá-lhe quatro opções:

- **Área de transferência** envia o que tiver copiado como um ficheiro de texto. Ótimo para pôr uma ligação ou um excerto no telemóvel sem enviar um e-mail a si próprio.
- **Ficheiro** abre um seletor de ficheiros onde pode selecionar vários de uma vez.
- **Pasta** envia um diretório inteiro.
- **Receber** abre o LocalSend a sério para que outro dispositivo lhe possa enviar algo.

A mesma coisa funciona a partir do terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Omita o caminho e aparece o seletor.

Também pode enviar diretamente a partir do gestor de ficheiros: clique com o botão direito numa seleção no Nautilus e escolha _Send via LocalSend_.

A firewall do Omarchy está fechada por predefinição, exceto quanto à porta do LocalSend, por isso isto funciona logo após uma instalação nova. Consulte [segurança](48-security.md).

## LibreOffice

O [LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, folha de cálculo, apresentações, aplicação de desenho e muito mais. É compatível com ficheiros do Microsoft Office, por isso é uma ótima maneira de conseguir abrir aqueles documentos do Word.

Inicia o LibreOffice através do lançador de aplicações (`Super + Space`).

## Hype

O [Hype](https://github.com/omacom/hype) é a aplicação de apresentações mesmo muito simples do Omarchy. A sua apresentação é um único ficheiro Markdown com as imagens e os vídeos ao lado: escreva cada diapositivo por baixo de uma pré-visualização em tempo real, arraste os diapositivos para os ordenar, depois apresente em ecrã inteiro ou exporte para PDF e PowerPoint. Até adota o seu tema Omarchy.

Inicia o Hype através do lançador de aplicações (`Super + Space`). Prima `?` dentro dele para ver todos os atalhos.

## Signed

O [Signed](https://github.com/omacom/signed) é a maneira mesmo muito simples do Omarchy de assinar PDFs e preenchê-los. Coloque a sua assinatura guardada, texto e a data de hoje em qualquer ponto de uma página, depois guarde uma cópia assinada ao lado do original. Consulte [Preencher PDFs](27-filling-out-pdfs.md) para saber como.

Inicia o Signed através do lançador de aplicações (`Super + Space`), ou abre um PDF com ele a partir do gestor de ficheiros.

## Checkmate

O [Checkmate](https://github.com/omacom/checkmate) é o jogo de xadrez 3D do Omarchy. Jogue com um amigo no mesmo computador ou contra o adversário integrado em três níveis, com quatro conjuntos esculpidos, cada um com a sua maneira própria de se mover: naves orbitais, madeira e marfim talhados, criaturas da floresta e doces. As partidas não têm relógio e são guardadas após cada jogada.

Inicia o Checkmate através do lançador de aplicações (`Super + Space`), onde aparece listado como Chess. Prima `?` dentro dele para ver todos os atalhos.

## Cards

O [Cards](https://github.com/omacom/cards) é o jogo de paciência Klondike do Omarchy. Tire três cartas, sem limite de passagens, em quatro séries de cartas: uma desenhada com as cores do seu tema e três com um visual próprio. Clique numa carta e depois no sítio para onde ela vai, arraste-a ou faça duplo clique para a enviar para o melhor sítio. As partidas são guardadas após cada jogada.

Inicia o Cards através do lançador de aplicações (`Super + Space`). Clique no nome dele, ou prima `?`, para ver todos os atalhos.

## Omacalc

O [Omacalc](https://github.com/omacom-io/omacalc) é a calculadora mesmo muito simples do Omarchy, que abre numa janela flutuante.

Inicia o Omacalc com `Super + Shift + Q` (ou com a tecla da calculadora, se o seu teclado tiver uma).

## Signal

O [Signal](https://signal.org/) é o pioneiro das mensagens com encriptação E2E e uma ótima opção de comunicação para quem prefere não passar por um dos grandes conglomerados tecnológicos.

Inicia o Signal com `Super + Shift + G`. Não faz parte da instalação base, por isso, na primeira vez que premir essa combinação, o Omarchy propõe instalá-lo por si (também está em _Install > Service_ no menu do Omarchy).

## Omaview

O [Omaview](https://github.com/omacom/omaview) é o visualizador de fotografias e leitor de multimédia mesmo muito simples do Omarchy: uma janela para as suas fotografias, vídeos e música. Abra uma fotografia e as teclas de seta percorrem o resto da pasta dela, `N` e `P` fazem isso para qualquer coisa e `Ctrl + M` mostra a pasta inteira como uma grelha. Também mostra fotografias HEIC, AVIF e JPEG XL, e retoma onde ficou em qualquer coisa longa.

Prima `F` para ecrã inteiro, `E` para editar uma fotografia no Omasnap ou aparar um vídeo no Omacut, `Ctrl + P` para imprimir uma fotografia e `Delete` para mover um ficheiro para o Lixo (`Ctrl + Z` traz o ficheiro de volta). Prima `?` dentro dele para ver todos os atalhos.

Inicia o Omaview como _Media Viewer_ através do lançador de aplicações (`Super + Space`), ou basta fazer duplo clique numa fotografia, num vídeo ou numa música no gestor de ficheiros.

## Omacut

O [Omacut](https://github.com/omacom-io/omacut) é o aparador de vídeo mesmo muito simples do Omarchy. Quando só precisa de cortar o início e o fim de um clipe, ganha a abrir um editor de vídeo completo.

Inicia o Omacut através do lançador de aplicações (`Super + Space`).

## Monologue

O [Monologue](https://github.com/omacom/monologue) é o gravador de webcam mesmo muito simples do Omarchy. Escolha a câmara e o microfone uma vez, depois prima `Space` para gravar, e outra vez para pausar e retomar a mesma gravação. Grava sempre na resolução mais alta da sua câmara, com um medidor de microfone em tempo real para poder verificar os seus níveis antes de começar.

Pare a gravação e ela abre logo num editor integrado. Faça duplo clique num clipe para o dividir, arraste as pegas para aparar cada pedaço e remova as partes que não quer. Depois guarde-o como um MP4. A sua gravação original é mantida até a descartar, por isso pode sempre voltar atrás e cortá-la de outra maneira.

Inicia o Monologue através do lançador de aplicações (`Super + Space`).
