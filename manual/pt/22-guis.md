# GUI

## Ficheiros

O Ficheiros (Nautilus) é o gestor de ficheiros gráfico. `Super + Shift + F` abre-o, e `Super + Shift + Alt + F` abre-o no diretório onde o teu terminal está, o que poupa muitos cliques. `Ctrl + L` permite-te escrever um caminho, e carregar em `Space` em qualquer ficheiro dá-te uma pré-visualização rápida sem abrires nada.

Liga uma pen USB ou um cartão SD e ele é montado automaticamente, por isso aparece logo na barra lateral. Para qualquer coisa mais envolvida — formatar uma unidade, verificar o estado SMART, criar partições — inicia os _Discos_ a partir do lançador de aplicações (`Super + Space`).

O duplo clique segue predefinições sensatas: as imagens abrem no imv, o vídeo no mpv, os PDF no Document Viewer e o texto simples no Neovim.

## Disktree

Quando a unidade enche e não fazes ideia do que a está a devorar, inicia o [Disktree](https://github.com/tobi/disktree) a partir do lançador de aplicações (`Super + Space`). Mostra um mapa de árvore gráfico do teu diretório pessoal. Os blocos maiores ocupam mais espaço; entra nos diretórios com o teclado ou o rato, marca o que deve desaparecer e revê as tuas seleções antes de removeres alguma coisa. Executa `disktree --disk` para analisar o disco inteiro.

## Obsidian

O [Obsidian](https://obsidian.md/) é uma aplicação de notas gratuita e altamente extensível que usa ficheiros Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, incluindo uso pessoal, comercial e sem fins lucrativos.

O Obsidian também oferece um [complemento comercial de sincronização](https://obsidian.md/sync) com aplicações móveis para iOS e Android. (https://obsidian.md/pricing).

Inicias o Obsidian com `Super + Shift + O`. Para usares a sincronização de tema, tens de selecionar o tema `Omarchy` nas definições.

## Omawrite

O [Omawrite](https://github.com/omacom-io/omawrite) é a aplicação de escrita Markdown incrivelmente simples do próprio Omarchy. Sem cofres, sem plugins, só tu e as palavras.

Inicias o Omawrite com `Super + Shift + W`.

## Pinta

O [Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagem, ótima para cortar, redimensionar e outras manipulações básicas. Só não esperes uma alternativa ao Photoshop. Mas ainda assim tem Varinha Mágica e camadas!

Inicias o Pinta através do lançador de aplicações (`Super + Space`).

## Aether

O [Aether](https://github.com/bjarneo/aether) é uma aplicação de temas que consegue extrair cores de uma imagem de fundo e transformá-las num tema completo e coeso. É a forma mais fácil de [criares o teu próprio tema](43-making-your-own-theme.md).

Inicias o Aether através do lançador de aplicações (`Super + Space`).

## LocalSend

O [LocalSend](https://localsend.org/) permite-te enviar ficheiros para outros dispositivos na mesma rede que estejam a correr a aplicação, como o AirDrop da Apple. No entanto, é multiplataforma, por isso podes enviar ficheiros de e para Windows, macOS, Android, iOS e, claro, Linux.

Podes abrir o menu Partilhar com `Super + Ctrl + S` ou em _Acionar > Partilhar_ no menu Omarchy. Dá-te quatro opções:

- **Área de transferência** envia aquilo que copiaste como um ficheiro de texto. Ótimo para colocares uma ligação ou um excerto no teu telemóvel sem te enviares um e-mail a ti próprio.
- **Ficheiro** abre um seletor de ficheiros onde podes selecionar vários de uma vez.
- **Pasta** envia um diretório inteiro.
- **Receber** abre o próprio LocalSend para que outro dispositivo te possa enviar alguma coisa.

A mesma coisa funciona a partir do terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Omite o caminho e obténs o seletor.

Também podes enviar diretamente a partir do gestor de ficheiros: clica com o botão direito em qualquer seleção no Nautilus e escolhe _Enviar via LocalSend_.

A firewall do Omarchy está fechada por predefinição, exceto para a porta do LocalSend, por isso isto funciona de origem numa instalação nova. Vê [segurança](48-security.md).

## LibreOffice

O [LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, folha de cálculo, apresentações, aplicação de desenho e muito mais. É compatível com ficheiros do Microsoft Office, por isso é uma ótima forma de poderes abrir esses documentos Word.

Inicias o LibreOffice através do lançador de aplicações (`Super + Space`).

## Hype

O [Hype](https://github.com/omacom/hype) é a aplicação de apresentações incrivelmente simples do próprio Omarchy. A tua apresentação é um único ficheiro Markdown com as suas imagens e vídeos ao lado: escreve cada diapositivo por baixo de uma pré-visualização em direto, arrasta os diapositivos para a ordem pretendida e depois apresenta em ecrã inteiro ou exporta para PDF e PowerPoint. Até adota o teu tema Omarchy.

Inicias o Hype através do lançador de aplicações (`Super + Space`). Carrega em `?` dentro dele para veres todos os atalhos.

## Signed

O [Signed](https://github.com/omacom/signed) é a forma incrivelmente simples do próprio Omarchy de assinar PDF e preenchê-los. Coloca a tua assinatura guardada, texto e a data de hoje em qualquer lugar de uma página e depois guarda uma cópia assinada ao lado do original. Vê [Preencher PDF](27-filling-out-pdfs.md) para saberes como.

Inicias o Signed através do lançador de aplicações (`Super + Space`), ou abres um PDF com ele a partir do gestor de ficheiros.

## Omacalc

O [Omacalc](https://github.com/omacom-io/omacalc) é a calculadora incrivelmente simples do próprio Omarchy, que abre numa janela flutuante.

Inicias o Omacalc com `Super + Ctrl + Q` (ou com a tecla da calculadora, se o teu teclado tiver uma).

## Signal

O [Signal](https://signal.org/) é o pioneiro das mensagens com encriptação ponto a ponto, e uma ótima opção de comunicação para quem preferir não passar por um dos grandes conglomerados tecnológicos.

Inicias o Signal com `Super + Shift + G`. Não faz parte da instalação base, por isso, da primeira vez que carregares nisto, o Omarchy oferece-se para o instalar por ti (também está em _Instalar > Serviço_ no menu Omarchy).

## mpv

O [mpv](https://mpv.io/) é um leitor multimédia simples e rápido que reproduz quase tudo, de qualquer fonte. Ótimo para ver vídeos.

Inicias o mpv através do lançador de aplicações (`Super + Space`) ou simplesmente fazes duplo clique num vídeo no gestor de ficheiros.

## Omacut

O [Omacut](https://github.com/omacom-io/omacut) é o aparador de vídeo incrivelmente simples do próprio Omarchy. Quando só precisas de cortar o início e o fim de um clipe, bate ter de abrir um editor de vídeo completo.

Inicias o Omacut através do lançador de aplicações (`Super + Space`).

## Monologue

O [Monologue](https://github.com/omacom/monologue) é o gravador de webcam incrivelmente simples do próprio Omarchy. Escolhe a tua câmara e o teu microfone uma vez, depois carrega em `Space` para gravar, e outra vez para pausar e retomar a mesma tomada. Grava sempre na resolução mais alta da tua câmara, com um medidor de microfone em direto para poderes verificar os teus níveis antes de começares.

Para a tomada e ele abre de imediato num editor integrado. Faz duplo clique num clipe para o dividires, arrasta as pegas para aparares cada pedaço e remove as partes que não queres. Depois guarda-o como MP4. A tua gravação original é mantida até a descartares, por isso podes sempre voltar e cortá-la de forma diferente.

Inicias o Monologue através do lançador de aplicações (`Super + Space`).
