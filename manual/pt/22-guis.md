# GUIs

## Ficheiros

O Files (Nautilus) é o gestor de ficheiros gráfico. `Super + Shift + F` abre-o, e `Super + Shift + Alt + F` abre-o no diretório onde o teu terminal está, o que te poupa muitos cliques. `Ctrl + L` permite-te escrever um caminho, e carregar em `Space` sobre qualquer ficheiro dá-te uma pré-visualização rápida sem abrires nada.

Liga uma pen USB ou um cartão SD e são montados automaticamente, por isso aparecem logo na barra lateral. Para qualquer coisa mais avançada — formatar uma unidade, verificar o estado SMART, criar partições — inicia os _Disks_ a partir do lançador de aplicações (`Super + Space`).

O duplo clique segue predefinições sensatas: as imagens, os vídeos e a música abrem no Omaview, os PDFs no Document Viewer, o Markdown no Omawrite e o texto simples no editor escolhido em _Setup > Default > Editor_.

## Disktree

Quando o disco fica cheio e não fazes ideia do que o está a ocupar, inicia o [Disktree](https://github.com/tobi/disktree) a partir do lançador de aplicações (`Super + Space`). Mostra um treemap gráfico do teu diretório pessoal. Os blocos maiores ocupam mais espaço; percorre os diretórios com o teclado ou o rato, marca o que deve ser removido e revê as tuas seleções antes de removeres seja o que for. Executa `disktree --disk` para analisares o disco inteiro.

## Obsidian

O [Obsidian](https://obsidian.md/) é uma aplicação de notas gratuita e altamente extensível que utiliza ficheiros Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, incluindo utilização pessoal, comercial e sem fins lucrativos.

O Obsidian oferece também um [suplemento comercial de sincronização](https://obsidian.md/sync) com aplicações móveis em iOS e Android. (https://obsidian.md/pricing).

Inicias o Obsidian com `Super + Shift + O`. Para utilizares a sincronização de temas, tens de selecionar o tema `Omarchy` nas definições.

## Omawrite

O [Omawrite](https://github.com/omacom-io/omawrite) é a aplicação de escrita Markdown extremamente simples do Omarchy. Sem cofres, sem plugins, só tu e as palavras.

Inicias o Omawrite com `Super + Shift + W`.

## Pinta

O [Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagem, excelente para cortar, redimensionar e outras manipulações básicas. Mas não esperes uma alternativa ao Photoshop. Ainda assim, tem Varinha Mágica e camadas!

Inicias o Pinta através do lançador de aplicações (`Super + Space`).

## Aether

O [Aether](https://github.com/bjarneo/aether) é uma aplicação de temas que consegue extrair cores de uma imagem de fundo e transformá-las num tema completo e coeso. É a forma mais fácil de [criares o teu próprio tema](43-making-your-own-theme.md).

Inicias o Aether através do lançador de aplicações (`Super + Space`).

## LocalSend

O [LocalSend](https://localsend.org/) permite-te enviar ficheiros para outros dispositivos na mesma rede que estejam a executar a aplicação, como o AirDrop da Apple. No entanto, é multiplataforma, por isso podes enviar ficheiros de e para Windows, macOS, Android, iOS e, claro, Linux.

Podes abrir o menu Share com `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Dá-te quatro opções:

- **Clipboard** envia tudo o que copiaste como um ficheiro de texto. É excelente para colocares uma ligação ou um excerto no teu telemóvel sem te enviares um e-mail a ti próprio.
- **File** abre um seletor de ficheiros onde podes selecionar vários de uma só vez.
- **Folder** envia um diretório inteiro.
- **Receive** abre o LocalSend propriamente dito para que outro dispositivo te possa enviar alguma coisa.

O mesmo funciona a partir do terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Se omitires o caminho, aparece o seletor.

Também podes enviar diretamente a partir do gestor de ficheiros: faz clique com o botão direito em qualquer seleção no Nautilus e escolhe _Send via LocalSend_.

A firewall do Omarchy está fechada por predefinição, exceto quanto à porta do LocalSend, por isso isto funciona logo de origem numa instalação nova. Vê [segurança](48-security.md).

## LibreOffice

O [LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, folha de cálculo, apresentações, aplicação de desenho e muito mais. É compatível com ficheiros do Microsoft Office, por isso é uma excelente forma de conseguires abrir esses documentos do Word.

Inicias o LibreOffice através do lançador de aplicações (`Super + Space`).

## Hype

O [Hype](https://github.com/omacom/hype) é a aplicação de apresentações extremamente simples do Omarchy. A tua apresentação é um único ficheiro Markdown com as respetivas imagens e vídeos ao lado: escreve cada diapositivo por baixo de uma pré-visualização em tempo real, arrasta os diapositivos para os ordenares e depois apresenta em ecrã inteiro ou exporta para PDF e PowerPoint. Até adota o teu tema do Omarchy.

Inicias o Hype através do lançador de aplicações (`Super + Space`). Prime `?` dentro dele para veres todos os atalhos.

## Signed

O [Signed](https://github.com/omacom/signed) é a forma extremamente simples do Omarchy de assinar PDFs e de os preencher. Coloca a tua assinatura guardada, texto e a data de hoje em qualquer ponto de uma página e depois guarda uma cópia assinada ao lado do original. Vê [Preencher PDFs](27-filling-out-pdfs.md) para saberes como.

Inicias o Signed através do lançador de aplicações (`Super + Space`), ou abres um PDF com ele a partir do gestor de ficheiros.

## Checkmate

O [Checkmate](https://github.com/omacom/checkmate) é o jogo de xadrez 3D do Omarchy. Joga com um amigo no mesmo computador ou contra o adversário incorporado em três níveis, em quatro conjuntos esculpidos, cada um com o seu modo próprio de se mover: naves orbitais, madeira talhada e marfim, criaturas da floresta e doces. As partidas não têm relógio e são guardadas após cada jogada.

Inicias o Checkmate através do lançador de aplicações (`Super + Space`), onde aparece listado como Chess. Prime `?` dentro dele para veres todos os atalhos.

## Omacalc

O [Omacalc](https://github.com/omacom-io/omacalc) é a calculadora extremamente simples do Omarchy, que abre numa janela flutuante.

Inicias o Omacalc com `Super + Shift + Q` (ou com a tecla da calculadora, se o teu teclado tiver uma).

## Signal

O [Signal](https://signal.org/) é o pioneiro das mensagens com encriptação E2E e uma excelente opção de comunicação para quem prefere não passar por um dos grandes conglomerados tecnológicos.

Inicias o Signal com `Super + Shift + G`. Não faz parte da instalação base, por isso, na primeira vez que carregares nessas teclas, o Omarchy propõe-se instalá-lo por ti (também está em _Install > Service_ no menu do Omarchy).

## Omaview

O [Omaview](https://github.com/omacom/omaview) é o visualizador de imagens e leitor multimédia extremamente simples do Omarchy: uma janela para as tuas fotografias, vídeos e música. Abre uma fotografia e as teclas de seta percorrem o resto da pasta, `N` e `P` fazem o mesmo com qualquer ficheiro, e `Ctrl + M` mostra a pasta inteira como uma grelha. Também mostra fotografias HEIC, AVIF e JPEG XL, e retoma onde ficaste em qualquer conteúdo longo.

Prime `F` para ecrã inteiro, `E` para editares uma imagem no Omasnap ou cortares um vídeo no Omacut, `Ctrl + P` para imprimires uma imagem e `Delete` para moveres um ficheiro para o Lixo (`Ctrl + Z` repõe-no). Prime `?` dentro dele para veres todos os atalhos.

Inicias o Omaview como _Media Viewer_ através do lançador de aplicações (`Super + Space`), ou basta fazeres duplo clique numa fotografia, num vídeo ou numa música no gestor de ficheiros.

## Omacut

O [Omacut](https://github.com/omacom-io/omacut) é o cortador de vídeo extremamente simples do Omarchy. Quando só precisas de cortar o início e o fim de um clipe, é bem melhor do que abrir um editor de vídeo completo.

Inicias o Omacut através do lançador de aplicações (`Super + Space`).

## Monologue

O [Monologue](https://github.com/omacom/monologue) é o gravador de webcam extremamente simples do Omarchy. Escolhe a câmara e o microfone uma vez, depois prime `Space` para gravares e outra vez para pausares e retomares a mesma tomada. Grava sempre na resolução máxima da tua câmara, com um medidor de microfone em tempo real para poderes verificar os teus níveis antes de começares.

Termina a tomada e ela abre de imediato num editor incorporado. Faz duplo clique num clipe para o dividires, arrasta as pegas para aparares cada pedaço e remove as partes que não queres. Depois guarda-o como um MP4. A gravação original é mantida até a descartares, por isso podes sempre regressar e cortá-la de forma diferente.

Inicias o Monologue através do lançador de aplicações (`Super + Space`).
