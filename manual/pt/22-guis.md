# GUIs

## Ficheiros

O Files (Nautilus) é o gestor de ficheiros gráfico. `Super + Shift + F` abre-o, e `Super + Shift + Alt + F` abre-o na pasta onde o teu terminal está, o que poupa imensos cliques. `Ctrl + L` permite-te escrever um caminho, e carregar em `Space` sobre qualquer ficheiro dá-te uma pré-visualização rápida sem abrir nada.

Liga uma pen USB ou um cartão SD e ele é montado automaticamente, por isso aparece logo na barra lateral. Para qualquer coisa mais avançada — formatar uma unidade, verificar o estado SMART, criar partições — inicia o _Disks_ a partir do lançador de aplicações (`Super + Space`).

O duplo clique segue predefinições sensatas: fotografias, vídeos e música abrem no Omaview, PDFs no Document Viewer, Markdown no Omawrite, e texto simples no editor escolhido em _Setup > Default > Editor_.

## Disktree

Quando a unidade fica cheia e não fazes ideia do que a está a ocupar, inicia o [Disktree](https://github.com/tobi/disktree) a partir do lançador de aplicações (`Super + Space`). Mostra um mapa de árvore gráfico da tua pasta pessoal. Os blocos maiores ocupam mais espaço; entra nas pastas com o teclado ou o rato, marca o que deve sair e revê as tuas seleções antes de removeres seja o que for. Executa `disktree --disk` para analisar o disco inteiro.

## Obsidian

O [Obsidian](https://obsidian.md/) é uma aplicação de notas gratuita e altamente extensível que utiliza ficheiros Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, incluindo utilização pessoal, comercial e sem fins lucrativos.

O Obsidian também oferece um [complemento comercial para sincronização](https://obsidian.md/sync) com aplicações móveis em iOS e Android. (https://obsidian.md/pricing).

Inicias o Obsidian com `Super + Shift + O`. Para utilizares a sincronização de temas, tens de selecionar o tema `Omarchy` nas definições.

## Omawrite

O [Omawrite](https://github.com/omacom-io/omawrite) é a aplicação de escrita Markdown incrivelmente simples do próprio Omarchy. Sem cofres, sem plugins, só tu e as palavras.

Inicias o Omawrite com `Super + Shift + W`.

## Pinta

O [Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagem que é ótima para cortar, redimensionar e outras manipulações básicas. Só não esperes uma alternativa ao Photoshop. Mas continua a ter uma Varinha Mágica e camadas!

Inicias o Pinta através do lançador de aplicações (`Super + Space`).

## Aether

O [Aether](https://github.com/bjarneo/aether) é uma aplicação de temas que consegue extrair cores de uma imagem de fundo e transformá-las num tema completo e coeso. É a forma mais fácil de [criares o teu próprio tema](43-making-your-own-theme.md).

Inicias o Aether através do lançador de aplicações (`Super + Space`).

## LocalSend

O [LocalSend](https://localsend.org/) permite-te enviar ficheiros para outros dispositivos na mesma rede que estejam a executar a aplicação, como o AirDrop da Apple. No entanto, é multiplataforma, por isso podes enviar ficheiros de e para Windows, macOS, Android, iOS e, claro, Linux.

Podes abrir o menu Share em `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Dá-te quatro opções:

- **Clipboard** envia o que copiaste como um ficheiro de texto. Ótimo para fazer chegar uma ligação ou um excerto ao teu telemóvel sem teres de te enviar um e-mail a ti próprio.
- **File** abre um seletor de ficheiros onde podes selecionar vários de uma só vez.
- **Folder** envia uma pasta inteira.
- **Receive** abre o LocalSend propriamente dito para que outro dispositivo te possa enviar alguma coisa.

A mesma coisa funciona a partir do terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Omite o caminho e aparece-te o seletor.

Também podes enviar diretamente a partir do gestor de ficheiros: clica com o botão direito numa seleção no Nautilus e escolhe _Send via LocalSend_.

A firewall do Omarchy está fechada por predefinição, exceto quanto à porta do LocalSend, por isso isto funciona imediatamente numa instalação nova. Vê [segurança](48-security.md).

## LibreOffice

O [LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, folha de cálculo, apresentações, aplicação de desenho e muito mais. É compatível com ficheiros do Microsoft Office, por isso esta é uma ótima forma de conseguires abrir aqueles documentos Word.

Inicias o LibreOffice através do lançador de aplicações (`Super + Space`).

## Hype

O [Hype](https://github.com/omacom/hype) é a aplicação de apresentações incrivelmente simples do próprio Omarchy. A tua apresentação é um único ficheiro Markdown com as suas imagens e vídeos ao lado: escreve cada diapositivo por baixo de uma pré-visualização em tempo real, arrasta os diapositivos para os ordenares e depois apresenta em ecrã inteiro ou exporta para PDF e PowerPoint. Até vai buscar o teu tema Omarchy.

Inicias o Hype através do lançador de aplicações (`Super + Space`). Carrega em `?` dentro dele para veres todos os atalhos.

## Signed

O [Signed](https://github.com/omacom/signed) é a forma incrivelmente simples do próprio Omarchy para assinar PDFs e preenchê-los. Coloca a tua assinatura guardada, texto e a data de hoje em qualquer ponto de uma página e depois guarda uma cópia assinada ao lado do original. Vê [Preencher PDFs](27-filling-out-pdfs.md) para saberes como.

Inicias o Signed através do lançador de aplicações (`Super + Space`), ou abres um PDF com ele a partir do gestor de ficheiros.

## Omacalc

O [Omacalc](https://github.com/omacom-io/omacalc) é a calculadora incrivelmente simples do próprio Omarchy, que abre numa janela flutuante.

Inicias o Omacalc com `Super + Shift + Q` (ou com a tecla da calculadora, se o teu teclado tiver uma).

## Signal

O [Signal](https://signal.org/) é o pioneiro das mensagens com encriptação E2E e uma ótima opção de comunicação para quem prefere não passar por um dos grandes conglomerados tecnológicos.

Inicias o Signal com `Super + Shift + G`. Não faz parte da instalação base, por isso, na primeira vez que carregares nessa combinação, o Omarchy vai oferecer-se para o instalar por ti (também está em _Install > Service_ no menu do Omarchy).

## Omaview

O [Omaview](https://github.com/omacom/omaview) é o visualizador de fotografias e leitor multimédia incrivelmente simples do próprio Omarchy: uma janela para as tuas fotografias, vídeos e música. Abre uma fotografia e as teclas de seta percorrem o resto da sua pasta, `N` e `P` fazem-no para qualquer coisa, e `Ctrl + M` mostra a pasta inteira como uma grelha. Também mostra fotografias HEIC, AVIF e JPEG XL, e retoma onde tinhas ficado em qualquer coisa longa.

Carrega em `F` para ecrã inteiro, `E` para editar uma fotografia no Omasnap ou cortar um vídeo no Omacut, `Ctrl + P` para imprimir uma fotografia e `Delete` para mover um ficheiro para o Lixo (`Ctrl + Z` repõe-no). Carrega em `?` dentro dele para veres todos os atalhos.

Inicias o Omaview como _Media Viewer_ através do lançador de aplicações (`Super + Space`), ou basta fazeres duplo clique numa fotografia, num vídeo ou numa música no gestor de ficheiros.

## Omacut

O [Omacut](https://github.com/omacom-io/omacut) é a ferramenta de corte de vídeo incrivelmente simples do próprio Omarchy. Quando só precisas de cortar o início e o fim de um clip, compensa muito mais do que abrir um editor de vídeo completo.

Inicias o Omacut através do lançador de aplicações (`Super + Space`).

## Monologue

O [Monologue](https://github.com/omacom/monologue) é o gravador de webcam incrivelmente simples do próprio Omarchy. Escolhe a tua câmara e o teu microfone uma vez, depois carrega em `Space` para gravar, e outra vez para pausar e retomar a mesma gravação. Grava sempre na resolução máxima da tua câmara, com um medidor de microfone em tempo real para poderes verificar os teus níveis antes de começares.

Paras a gravação e ela abre logo num editor incorporado. Faz duplo clique num clip para o dividires, arrasta as pegas para cortares cada pedaço e remove as partes que não queres. Depois guarda-o como um MP4. A tua gravação original é mantida até a descartares, por isso podes sempre voltar atrás e cortá-la de outra forma.

Inicias o Monologue através do lançador de aplicações (`Super + Space`).
