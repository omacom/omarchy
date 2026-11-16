# Interfaces gráficas

## Ficheiros

O Files (Nautilus) é o gestor de ficheiros gráfico. `Super + Shift + F` abre-o, e `Super + Shift + Alt + F` abre-o no diretório em que o terminal está, o que poupa muitos cliques. `Ctrl + L` permite escrever um caminho, e carregar em `Space` em qualquer ficheiro mostra uma pré-visualização rápida sem abrir nada.

Ligue uma pen USB ou um cartão SD e fica montado automaticamente, por isso aparece logo na barra lateral. Para algo mais avançado — formatar uma unidade, verificar a saúde SMART, criar partições — inicie o _Disks_ a partir do lançador de aplicações (`Super + Space`).

O duplo clique segue predefinições sensatas: imagens, vídeos e música abrem no Omaview, PDFs no Document Viewer e texto simples no Neovim.

## Disktree

Quando a unidade enche e não faz ideia do que está a ocupar espaço, inicie o [Disktree](https://github.com/tobi/disktree) a partir do lançador de aplicações (`Super + Space`). Mostra um mapa em árvore gráfico do seu diretório pessoal. Os blocos maiores ocupam mais espaço; navegue pelos diretórios com o teclado ou o rato, marque o que deve ser removido e reveja as suas seleções antes de remover qualquer coisa. Execute `disktree --disk` para analisar todo o disco.

## Obsidian

O [Obsidian](https://obsidian.md/) é uma aplicação de notas gratuita e altamente extensível que utiliza ficheiros Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, incluindo utilização pessoal, comercial e sem fins lucrativos.

O Obsidian também oferece um [complemento comercial para sincronização](https://obsidian.md/sync) com aplicações móveis no iOS e Android. (https://obsidian.md/pricing).

Inicia o Obsidian com `Super + Shift + O`. Para utilizar a sincronização de tema, tem de selecionar o tema `Omarchy` nas definições.

## Omawrite

O [Omawrite](https://github.com/omacom-io/omawrite) é a aplicação de escrita em Markdown mesmo muito simples do próprio Omarchy. Sem cofres, sem plugins, só tu e as palavras.

Inicia o Omawrite com `Super + Shift + W`.

## Pinta

O [Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagem, ótima para cortar, redimensionar e outras manipulações básicas. Não esperes uma alternativa ao Photoshop. Mas ainda tem Varinha Mágica e camadas!

Inicia o Pinta através do lançador de aplicações (`Super + Space`).

## Aether

O [Aether](https://github.com/bjarneo/aether) é uma aplicação de temas que consegue extrair cores de uma imagem de fundo e transformá-las num tema completo e coeso. É a forma mais fácil de [criares o teu próprio tema](43-making-your-own-theme.md).

Inicia o Aether através do lançador de aplicações (`Super + Space`).

## LocalSend

O [LocalSend](https://localsend.org/) permite enviar ficheiros para outros dispositivos na mesma rede que estejam a executar a aplicação, como o AirDrop da Apple. No entanto, é multiplataforma, por isso podes enviar ficheiros de e para Windows, macOS, Android, iOS e, claro, Linux.

Podes abrir o menu Partilhar em `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Dá-te quatro opções:

- **Clipboard** envia o que copiaste como um ficheiro de texto. Ótimo para colocares uma ligação ou um excerto no telemóvel sem te enviares um e-mail a ti próprio.
- **File** abre um seletor de ficheiros onde podes selecionar vários de uma só vez.
- **Folder** envia um diretório inteiro.
- **Receive** abre o LocalSend propriamente dito para que outro dispositivo te possa enviar alguma coisa.

O mesmo funciona a partir do terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Deixa o caminho de fora e aparece o seletor.

Também podes enviar diretamente a partir do gestor de ficheiros: clica com o botão direito em qualquer seleção no Nautilus e escolhe _Send via LocalSend_.

A firewall do Omarchy está fechada por predefinição, exceto na porta do LocalSend, por isso isto funciona imediatamente numa instalação nova. Ver [segurança](48-security.md).

## LibreOffice

O [LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, folha de cálculo, apresentações, aplicação de desenho e muito mais. É compatível com ficheiros do Microsoft Office, por isso é uma ótima forma de conseguir abrir esses documentos do Word.

Inicia o LibreOffice através do lançador de aplicações (`Super + Space`).

## Hype

O [Hype](https://github.com/omacom/hype) é a aplicação de apresentações mesmo muito simples do próprio Omarchy. A tua apresentação é um único ficheiro Markdown com as suas imagens e vídeos ao lado: escreve cada diapositivo abaixo de uma pré-visualização em tempo real, arrasta os diapositivos para a ordem pretendida e depois apresenta em ecrã inteiro ou exporta para PDF e PowerPoint. Até adota o teu tema do Omarchy.

Inicia o Hype através do lançador de aplicações (`Super + Space`). Carrega em `?` lá dentro para veres todos os atalhos.

## Signed

O [Signed](https://github.com/omacom/signed) é a forma mesmo muito simples do próprio Omarchy para assinar PDFs e preenchê-los. Coloca a tua assinatura guardada, texto e a data de hoje em qualquer ponto de uma página e depois guarda uma cópia assinada ao lado do original. Ver [Preencher PDFs](27-filling-out-pdfs.md) para saberes como.

Inicia o Signed através do lançador de aplicações (`Super + Space`), ou abre um PDF com ele a partir do gestor de ficheiros.

## Omacalc

O [Omacalc](https://github.com/omacom-io/omacalc) é a calculadora mesmo muito simples do próprio Omarchy, que abre numa janela flutuante.

Inicia o Omacalc com `Super + Shift + Q` (ou a tecla da calculadora, se o teu teclado tiver uma).

## Signal

O [Signal](https://signal.org/) é o pioneiro das mensagens com encriptação E2E e uma ótima opção de comunicação para quem prefere não passar por um dos grandes conglomerados tecnológicos.

Inicia o Signal com `Super + Shift + G`. Não faz parte da instalação base, por isso, na primeira vez que carregares nessa combinação, o Omarchy vai oferecer-se para o instalar por ti (também está em _Install > Service_ no menu do Omarchy).

## Omaview

O [Omaview](https://github.com/omacom/omaview) é o visualizador de imagens e leitor multimédia mesmo muito simples do próprio Omarchy: uma janela para as tuas fotografias, vídeos e música. Abre uma fotografia e as teclas de seta percorrem o resto da sua pasta, `N` e `P` fazem o mesmo para qualquer coisa e `Ctrl + M` mostra toda a pasta como uma grelha. Também mostra fotografias HEIC, AVIF e JPEG XL e retoma onde ficaste em qualquer conteúdo longo.

Carrega em `F` para ecrã inteiro, `E` para editar uma imagem no Omasnap ou cortar um vídeo no Omacut, `Ctrl + P` para imprimir uma imagem e `Delete` para mover um ficheiro para o Lixo (`Ctrl + Z` trá-lo de volta). Carrega em `?` lá dentro para veres todos os atalhos.

Inicia o Omaview como _Media Viewer_ através do lançador de aplicações (`Super + Space`), ou basta fazeres duplo clique numa imagem, num vídeo ou numa música no gestor de ficheiros.

## Omacut

O [Omacut](https://github.com/omacom-io/omacut) é a ferramenta de corte de vídeo mesmo muito simples do próprio Omarchy. Quando só precisas de cortar o início e o fim de um clip, compensa muito mais do que abrir um editor de vídeo completo.

Inicia o Omacut através do lançador de aplicações (`Super + Space`).

## Monologue

O [Monologue](https://github.com/omacom/monologue) é o gravador de webcam mesmo muito simples do próprio Omarchy. Escolhe a câmara e o microfone uma vez, depois carrega em `Space` para gravar e outra vez para pausar e retomar a mesma captação. Grava sempre na resolução mais alta da tua câmara, com um indicador do microfone em tempo real para poderes verificar os teus níveis antes de começares.

Para a captação e abre logo num editor incorporado. Faz duplo clique num clip para o dividir, arrasta as pegas para cortar cada parte e remove as partes que não queres. Depois guarda-o como um MP4. A tua gravação original é mantida até a descartares, por isso podes sempre voltar e cortá-la de outra forma.

Inicia o Monologue através do lançador de aplicações (`Super + Space`).
