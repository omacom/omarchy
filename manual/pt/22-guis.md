# Interfaces Gráficas

## Files

O Files (Nautilus) é o gestor de ficheiros gráfico. `Super + Shift + F` abre-o, e `Super + Shift + Alt + F` abre-o na pasta onde o terminal está, o que poupa muitos cliques. `Ctrl + L` permite escrever um caminho, e premir `Space` sobre qualquer ficheiro mostra uma pré-visualização rápida sem abrir nada.

Ligue uma pen USB ou um cartão SD e este é montado automaticamente, por isso aparece logo na barra lateral. Para algo mais avançado — formatar uma unidade, verificar o estado SMART, criar partições — abra o _Disks_ a partir do lançador de aplicações (`Super + Space`).

O duplo clique segue predefinições sensatas: imagens, vídeos e música abrem no Omaview, PDFs no Document Viewer, Markdown no Omawrite, e texto simples no editor escolhido em _Setup > Default > Editor_.

## Disktree

Quando a unidade ficar cheia e não fazes ideia do que está a ocupar o espaço, abre o [Disktree](https://github.com/tobi/disktree) a partir do lançador de aplicações (`Super + Space`). Mostra um mapa em árvore gráfico da tua pasta pessoal. Os blocos maiores ocupam mais espaço; navega pelas pastas com o teclado ou o rato, marca o que deve sair e revê as tuas seleções antes de removeres seja o que for. Executa `disktree --disk` para analisar o disco inteiro.

## Obsidian

[Obsidian](https://obsidian.md/) é uma aplicação de notas gratuita e altamente extensível que usa ficheiros Markdown simples para armazenamento.

Obsidian é gratuito para todos os fins, incluindo uso pessoal, comercial e sem fins lucrativos.

Obsidian também oferece um [complemento comercial para sincronização](https://obsidian.md/sync) com aplicações móveis em iOS e Android. (https://obsidian.md/pricing).

Abre o Obsidian com `Super + Shift + O`. Para usar a sincronização de temas, tens de selecionar o tema `Omarchy` nas definições.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) é a aplicação de escrita Markdown extremamente simples do Omarchy. Sem cofres, sem plugins, só tu e as palavras.

Abre o Omawrite com `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagem, ótima para recortar, redimensionar e outras manipulações básicas. Não esperes uma alternativa ao Photoshop. Mas ainda tem Magic Wand e camadas!

Abre o Pinta através do lançador de aplicações (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) é uma aplicação de temas que consegue extrair cores de uma imagem de fundo e transformá-las num tema completo e coeso. É a forma mais fácil de [fazer o teu próprio tema](43-making-your-own-theme.md).

Abre o Aether através do lançador de aplicações (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) permite enviar ficheiros para outros dispositivos na mesma rede que estejam a executar a aplicação, como o AirDrop da Apple. No entanto, é multiplataforma, por isso podes enviar ficheiros de e para Windows, macOS, Android, iOS e, claro, Linux.

Podes abrir o menu Share em `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Dá-te quatro opções:

- **Clipboard** envia aquilo que copiaste como ficheiro de texto. Ótimo para pôr uma ligação ou um excerto no telemóvel sem enviares um e-mail a ti próprio.
- **File** abre um seletor de ficheiros onde podes selecionar vários de uma só vez.
- **Folder** envia uma pasta inteira.
- **Receive** abre o LocalSend propriamente dito para que outro dispositivo te possa enviar alguma coisa.

A mesma coisa funciona a partir do terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Deixa o caminho de fora e aparece o seletor.

Também podes enviar diretamente a partir do gestor de ficheiros: clica com o botão direito do rato em qualquer seleção no Nautilus e escolhe _Send via LocalSend_.

A firewall do Omarchy está fechada por predefinição, exceto quanto à porta do LocalSend, por isso isto funciona imediatamente numa instalação nova. Vê [segurança](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, folha de cálculo, apresentações, aplicação de desenho e muito mais. É compatível com ficheiros do Microsoft Office, por isso é uma ótima forma de conseguir abrir aqueles documentos do Word.

Abre o LibreOffice através do lançador de aplicações (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) é a aplicação de apresentações extremamente simples do Omarchy. A tua apresentação é um único ficheiro Markdown com as imagens e os vídeos ao lado: escreve cada diapositivo por baixo de uma pré-visualização em direto, arrasta os diapositivos para a ordem pretendida e depois apresenta em ecrã inteiro ou exporta para PDF e PowerPoint. Até adota o teu tema Omarchy.

Abre o Hype através do lançador de aplicações (`Super + Space`). Prime `?` dentro da aplicação para veres todos os atalhos.

## Signed

[Signed](https://github.com/omacom/signed) é a forma extremamente simples do Omarchy para assinar PDFs e preenchê-los. Coloca a tua assinatura guardada, texto e a data de hoje em qualquer ponto de uma página e depois guarda uma cópia assinada ao lado do original. Vê [Preencher PDFs](27-filling-out-pdfs.md) para saberes como.

Abre o Signed através do lançador de aplicações (`Super + Space`) ou abre um PDF com ele a partir do gestor de ficheiros.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) é o jogo de xadrez 3D do Omarchy. Joga com um amigo no mesmo computador ou contra o adversário integrado em três níveis, em quatro conjuntos esculpidos que se movem cada um à sua maneira: naves orbitais, madeira e marfim esculpidos, criaturas da floresta e doces. Os jogos não têm relógio e são guardados após cada jogada.

Abre o Checkmate através do lançador de aplicações (`Super + Space`). Prime `?` dentro da aplicação para veres todos os atalhos.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) é a calculadora extremamente simples do Omarchy, que se abre numa janela flutuante.

Abre o Omacalc com `Super + Shift + Q` (ou com a tecla de calculadora, se o teu teclado tiver uma).

## Signal

[Signal](https://signal.org/) é o pioneiro das mensagens encriptadas E2E e uma ótima opção de comunicação para quem preferir não passar por um dos grandes conglomerados tecnológicos.

Abre o Signal com `Super + Shift + G`. Não faz parte da instalação base, por isso, na primeira vez que carregares nessa combinação, o Omarchy oferece-se para o instalar por ti (também está em _Install > Service_ no menu do Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) é o visualizador de imagens e leitor multimédia extremamente simples do Omarchy: uma janela para as tuas fotografias, vídeos e música. Abre uma fotografia e as teclas de seta percorrem o resto da pasta, `N` e `P` fazem-no para qualquer ficheiro, e `Ctrl + M` mostra a pasta inteira como uma grelha. Também mostra fotografias HEIC, AVIF e JPEG XL e retoma onde ficaste em qualquer conteúdo longo.

Prime `F` para ecrã inteiro, `E` para editar uma imagem no Omasnap ou cortar um vídeo no Omacut, `Ctrl + P` para imprimir uma imagem e `Delete` para mover um ficheiro para o Lixo (`Ctrl + Z` trá-lo de volta). Prime `?` dentro da aplicação para veres todos os atalhos.

Abre o Omaview como _Media Viewer_ através do lançador de aplicações (`Super + Space`) ou faz simplesmente duplo clique sobre uma imagem, um vídeo ou uma música no gestor de ficheiros.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) é o cortador de vídeo extremamente simples do Omarchy. Quando só precisas de cortar o início e o fim de um clip, é melhor do que abrir um editor de vídeo completo.

Abre o Omacut através do lançador de aplicações (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) é o gravador de webcam extremamente simples do Omarchy. Escolhe a câmara e o microfone uma vez e depois prime `Space` para gravar e outra vez para fazer pausa e retomar a mesma gravação. Grava sempre na resolução mais alta da câmara, com um medidor de microfone em direto para poderes verificar os níveis antes de começar.

Para a gravação e ela abre logo num editor integrado. Faz duplo clique num clip para o dividir, arrasta as pegas para aparar cada pedaço e remove as partes que não queres. Depois guarda-o como MP4. A gravação original é mantida até a descartares, por isso podes sempre voltar atrás e cortá-la de outra forma.

Abre o Monologue através do lançador de aplicações (`Super + Space`).
