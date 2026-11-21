# GUIs

## Files

O Files (Folio) é o gestor de ficheiros gráfico. `Super + Shift + F` abre-o, e `Super + Shift + Alt + F` abre-o no diretório onde o teu terminal se encontra, o que poupa muitos cliques. `Ctrl + L` permite-te escrever um caminho, e premir `Space` sobre qualquer ficheiro pré-visualiza-o em tamanho completo sem o abrir.

Ligues uma pen USB ou um cartão SD e este é montado automaticamente, por isso aparece logo na barra lateral. Para algo mais avançado — formatar uma unidade, verificar o estado SMART, criar partições — inicia o _Disks_ a partir do lançador de aplicações (`Super + Space`).

O duplo clique segue predefinições sensatas: imagens, vídeos e música abrem no Omaview, PDFs no Document Viewer, Markdown no Omawrite, e texto simples no teu editor, o Plain a menos que escolhas outro em _Setup > Defaults > Editor_.

## Disktree

Quando a unidade fica cheia e não fazes ideia do que está a ocupar o espaço, inicia o [Disktree](https://github.com/tobi/disktree) a partir do lançador de aplicações (`Super + Space`). Mostra um mapa em árvore gráfico do teu diretório pessoal. Os blocos maiores ocupam mais espaço; navega pelos diretórios com o teclado ou o rato, marca o que deve ser removido e revê as tuas seleções antes de removeres o que quer que seja. Executa `disktree --disk` para analisares o disco inteiro.

## Obsidian

O [Obsidian](https://obsidian.md/) é uma aplicação de notas gratuita e altamente extensível que utiliza ficheiros Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, incluindo utilização pessoal, comercial e sem fins lucrativos.

O Obsidian também oferece um [complemento comercial para sincronização](https://obsidian.md/sync) com aplicações móveis em iOS e Android. (https://obsidian.md/pricing).

Inicias o Obsidian com `Super + Shift + O`. Para utilizares a sincronização de temas, tens de selecionar o tema `Omarchy` nas definições.

## Omawrite

O [Omawrite](https://github.com/omacom-io/omawrite) é a aplicação de escrita Markdown incrivelmente simples do Omarchy. Sem cofres, sem plugins, só tu e as palavras.

Inicias o Omawrite com `Super + Shift + W`.

## Pinta

O [Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagem, excelente para cortar, redimensionar e outras manipulações básicas. Só não esperes uma alternativa ao Photoshop. Mas mesmo assim tem Varinha Mágica e camadas!

Inicias o Pinta através do lançador de aplicações (`Super + Space`).

## Aether

O [Aether](https://github.com/bjarneo/aether) é uma aplicação de temas que consegue extrair cores de uma imagem de fundo e transformá-las num tema completo e coeso. É a forma mais fácil de [criares o teu próprio tema](43-making-your-own-theme.md).

Inicias o Aether através do lançador de aplicações (`Super + Space`).

## LocalSend

O [LocalSend](https://localsend.org/) permite-te enviar ficheiros para outros dispositivos na mesma rede que estejam a executar a aplicação, como o AirDrop da Apple. No entanto, é multiplataforma, por isso podes enviar ficheiros de e para Windows, macOS, Android, iOS e, naturalmente, Linux.

Podes abrir o menu Partilhar com `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Dá-te quatro opções:

- **Clipboard** envia tudo o que copiaste como um ficheiro de texto. Excelente para teres um link ou um excerto no teu telemóvel sem enviares um e-mail a ti próprio.
- **File** abre um seletor de ficheiros onde podes selecionar vários de uma só vez.
- **Folder** envia um diretório inteiro.
- **Receive** abre o LocalSend propriamente dito para que outro dispositivo te possa enviar alguma coisa.

O mesmo funciona a partir do terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Omite o caminho e aparece o seletor.

Também podes enviar diretamente a partir do gestor de ficheiros: clica com o botão direito do rato numa seleção no Files e partilha-a com o LocalSend.

A firewall do Omarchy está fechada por predefinição, exceto quanto à porta do LocalSend, por isso isto funciona logo após a instalação. Consulta [segurança](48-security.md).

## LibreOffice

O [LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, folha de cálculo, apresentações, aplicação de desenho e muito mais. É compatível com ficheiros do Microsoft Office, por isso é uma excelente forma de conseguires abrir esses documentos do Word.

Inicias o LibreOffice através do lançador de aplicações (`Super + Space`).

## Hype

O [Hype](https://github.com/omacom/hype) é a aplicação de apresentações incrivelmente simples do Omarchy. A tua apresentação é um único ficheiro Markdown com as respetivas imagens e vídeos ao lado: escreve cada diapositivo por baixo de uma pré-visualização ao vivo, arrasta os diapositivos para os ordenares e depois apresenta em ecrã inteiro ou exporta para PDF e PowerPoint. Até adota o teu tema Omarchy.

Inicias o Hype através do lançador de aplicações (`Super + Space`). Prime `?` lá dentro para veres todos os atalhos.

## Signed

O [Signed](https://github.com/omacom/signed) é a forma incrivelmente simples do Omarchy de assinar PDFs e preenchê-los. Coloca a tua assinatura guardada, texto e a data de hoje em qualquer ponto de uma página e depois guarda uma cópia assinada ao lado do original. Consulta [Preencher PDFs](27-filling-out-pdfs.md) para saberes como.

Inicias o Signed através do lançador de aplicações (`Super + Space`), ou abres um PDF com ele a partir do gestor de ficheiros.

## Game Vibes

O Game Vibes, no lançador de aplicações (`Super + Space`), é onde vivem os joguinhos do Omarchy: Checkmate, um jogo de xadrez em 3D contra um amigo ou contra o adversário integrado; Cards, o solitário Klondike; Death Wish, um jogo de plataformas de precisão milimétrica com dez salas cheias de espigões e serras; e Neon Swarm, um jogo de tiro arcade. Cada um é uma única página web que segue o teu tema. Escolhe um com as setas e `Enter` e volta à lista com `Esc` no ecrã de título de um jogo ou com `Q` enquanto está em pausa. Abre em ecrã inteiro: `Super + F` transforma-o numa janela e `Super + W` fecha-o.

Os jogos que crias com um agente também aparecem aqui: escolhe _Make something cool → Game_ no painel de agentes e descreve um, ou indica o nome de um jogo já existente no Game Vibes para continuares a trabalhar nele. O agente copia-o para `~/Games/vibes`, onde é teu para alterares, e abre-o quando termina. Podes fazer essa cópia tu mesmo com `omarchy games vibes copy <game>`. Um jogo partilhado por outra pessoa instala-se como um tema: escolhe _Install > Gaming > Game Vibes_ e cola o respetivo endereço git, ou executa `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ volta a removê-lo e _Update > Game Vibes Games_ obtém novas versões. Os jogos carregam o three.js a partir da web, por isso precisam de uma ligação para arrancar.

## Omacalc

O [Omacalc](https://github.com/omacom-io/omacalc) é a calculadora incrivelmente simples do Omarchy, que abre numa janela flutuante.

Inicias o Omacalc com `Super + Shift + Q` (ou com a tecla da calculadora, se o teu teclado tiver uma).

## Signal

O [Signal](https://signal.org/) é o pioneiro da troca de mensagens com encriptação E2E, e uma excelente opção de comunicação para quem prefere não passar por um dos grandes conglomerados tecnológicos.

Inicias o Signal com `Super + Shift + G`. Não faz parte da instalação de base, por isso, na primeira vez que premires essa combinação, o Omarchy propõe instalá-lo por ti (também está em _Install > Service_ no menu do Omarchy).

## Omaview

O [Omaview](https://github.com/omacom/omaview) é o visualizador de imagens e leitor multimédia incrivelmente simples do Omarchy: uma janela para as tuas fotografias, vídeos e música. Abre uma fotografia e as teclas de seta percorrem o resto da sua pasta, `N` e `P` fazem-no para qualquer ficheiro, e `Ctrl + M` mostra a pasta inteira como uma grelha. Também mostra fotografias HEIC, AVIF e JPEG XL e retoma qualquer conteúdo longo no ponto onde o deixaste.

Prime `F` para ecrã inteiro, `E` para editares uma imagem no Omasnap ou cortares um vídeo no Omacut, `Ctrl + P` para imprimires uma imagem e `Delete` para moveres um ficheiro para o Lixo (`Ctrl + Z` repõe-no). Prime `?` lá dentro para veres todos os atalhos.

Inicias o Omaview como _Media Viewer_ através do lançador de aplicações (`Super + Space`), ou basta fazeres duplo clique numa imagem, num vídeo ou numa música no gestor de ficheiros.

## Omacut

O [Omacut](https://github.com/omacom-io/omacut) é a ferramenta de corte de vídeo incrivelmente simples do Omarchy. Quando só precisas de cortar o início e o fim de um clip, compensa muito mais do que abrires um editor de vídeo completo.

Inicias o Omacut através do lançador de aplicações (`Super + Space`).

## Monologue

O [Monologue](https://github.com/omacom/monologue) é o gravador de webcam incrivelmente simples do Omarchy. Escolhe a tua câmara e o teu microfone uma vez, depois prime `Space` para gravares e outra vez para pausares e retomares a mesma gravação. Grava sempre na resolução máxima da tua câmara, com um medidor de microfone em tempo real para poderes verificar os teus níveis antes de começares.

Termina a gravação e ela abre logo num editor integrado. Faz duplo clique num clip para o dividires, arrasta as pegas para aparares cada pedaço e remove as partes que não queres. Depois guarda-o como um MP4. A tua gravação original é mantida até a descartares, por isso podes sempre voltar e cortá-la de outra forma.

Inicias o Monologue através do lançador de aplicações (`Super + Space`).
