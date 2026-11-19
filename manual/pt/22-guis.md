# GUIs

## Ficheiros

O Files (Nautilus) é o gestor de ficheiros gráfico. `Super + Shift + F` abre-o, e `Super + Shift + Alt + F` abre-o no diretório onde o teu terminal está, o que te poupa imensos cliques. `Ctrl + L` permite-te escrever um caminho, e premir `Space` em qualquer ficheiro mostra-te uma pré-visualização rápida sem abrir nada.

Liga uma pen USB ou um cartão SD e é montado automaticamente, por isso aparece logo na barra lateral. Para qualquer coisa mais avançada — formatar uma unidade, verificar o estado SMART, criar partições — abre _Disks_ a partir do lançador de aplicações (`Super + Space`).

O duplo clique segue predefinições sensatas: imagens, vídeos e música abrem no Omaview, PDFs no Document Viewer, Markdown no Omawrite e texto simples no editor escolhido em _Setup > Default > Editor_.

## Disktree

Quando a unidade fica cheia e não fazes ideia do que está a ocupar o espaço, abre [Disktree](https://github.com/tobi/disktree) a partir do lançador de aplicações (`Super + Space`). Mostra um mapa em árvore gráfico do teu diretório pessoal. Os blocos maiores ocupam mais espaço; navega pelos diretórios com o teclado ou o rato, marca o que deve sair e revê as tuas seleções antes de removeres seja o que for. Executa `disktree --disk` para analisar o disco inteiro.

## Obsidian

[Obsidian](https://obsidian.md/) é uma aplicação de notas gratuita e altamente extensível que usa ficheiros Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, nomeadamente para utilização pessoal, comercial e sem fins lucrativos.

O Obsidian também oferece um [extra comercial para sincronização](https://obsidian.md/sync) com aplicações móveis em iOS e Android. (https://obsidian.md/pricing).

Inicias o Obsidian com `Super + Shift + O`. Para usares a sincronização do tema, tens de selecionar o tema `Omarchy` nas definições.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) é a aplicação de escrita Markdown extremamente simples do Omarchy. Sem cofres, sem plugins, só tu e as palavras.

Inicias o Omawrite com `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagem que é ótima para recortar, redimensionar e outras manipulações básicas. Só não esperes uma alternativa ao Photoshop. Mas mesmo assim tem Magic Wand e camadas!

Inicias o Pinta através do lançador de aplicações (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) é uma aplicação de temas que consegue extrair cores de uma imagem de fundo e transformá-las num tema completo e coeso. É a forma mais fácil de [criares o teu próprio tema](43-making-your-own-theme.md).

Inicias o Aether através do lançador de aplicações (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) permite-te enviar ficheiros para outros dispositivos na mesma rede que estejam a executar a aplicação, como o AirDrop da Apple. No entanto, é multiplataforma, por isso podes enviar ficheiros de e para Windows, macOS, Android, iOS e, claro, Linux.

Podes abrir o menu Partilhar em `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Oferece-te quatro opções:

- **Clipboard** envia tudo o que copiaste como um ficheiro de texto. Ótimo para passares uma ligação ou um excerto para o teu telemóvel sem teres de te enviar um e-mail a ti próprio.
- **File** abre um seletor de ficheiros onde podes selecionar vários de uma só vez.
- **Folder** envia um diretório inteiro.
- **Receive** abre o LocalSend a sério para que outro dispositivo te possa enviar alguma coisa.

O mesmo funciona a partir do terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Omite o caminho e aparece-te o seletor.

Também podes enviar diretamente a partir do gestor de ficheiros: clica com o botão direito em qualquer seleção no Nautilus e escolhe _Send via LocalSend_.

A firewall do Omarchy está fechada por predefinição, exceto na porta do LocalSend, por isso isto funciona logo de origem numa instalação nova. Vê [segurança](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, folha de cálculo, apresentações, aplicação de desenho e muito mais. É compatível com ficheiros do Microsoft Office, por isso é uma ótima forma de conseguires abrir esses documentos Word.

Inicias o LibreOffice através do lançador de aplicações (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) é a aplicação de apresentações extremamente simples do Omarchy. A tua apresentação é um único ficheiro Markdown com as imagens e os vídeos ao seu lado: escreve cada diapositivo por baixo de uma pré-visualização em tempo real, arrasta os diapositivos para os ordenares e depois apresenta em ecrã inteiro ou exporta para PDF e PowerPoint. Até adota o teu tema Omarchy.

Inicias o Hype através do lançador de aplicações (`Super + Space`). Prime `?` dentro da aplicação para veres todos os atalhos.

## Signed

[Signed](https://github.com/omacom/signed) é a forma extremamente simples do Omarchy para assinares PDFs e preencheres formulários neles. Coloca a tua assinatura guardada, texto e a data de hoje em qualquer ponto de uma página e depois guarda uma cópia assinada ao lado do original. Vê [Preencher PDFs](27-filling-out-pdfs.md) para saberes como.

Inicias o Signed através do lançador de aplicações (`Super + Space`), ou abre um PDF com ele a partir do gestor de ficheiros.

## Game Vibes

O Game Vibes, no lançador de aplicações (`Super + Space`), é onde vivem os joguinhos do Omarchy: Checkmate, um jogo de xadrez 3D contra um amigo ou contra o adversário integrado; Cards, paciência Klondike; e Neon Swarm, um jogo de tiros arcade. Cada um é uma única página web que segue o teu tema. Escolhe um com as setas e `Enter` e volta à lista com `Esc` a partir do ecrã inicial de um jogo ou com `Q` enquanto está em pausa. Abre em ecrã inteiro: `Super + F` transforma-o numa janela e `Super + W` fecha-o.

Os jogos que crias com um agente também aparecem aqui: escolhe _Make something cool → Game_ no painel de agentes e descreve um, ou indica o nome de um jogo já existente no Game Vibes para continuares a trabalhar nele. O agente copia-o para `~/Games/vibes`, onde é teu para alterares, e abre-o quando termina. Tu próprio podes fazer essa cópia com `omarchy games vibes copy <game>`. Um jogo partilhado por outra pessoa instala-se como um tema: escolhe _Install > Gaming > Game Vibes_ e cola o seu endereço git, ou executa `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ remove um outra vez e _Update > Game Vibes Games_ obtém novas versões. Os jogos carregam three.js a partir da web, por isso precisam de uma ligação para arrancarem.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) é a calculadora extremamente simples do Omarchy, que abre numa janela flutuante.

Inicias o Omacalc com `Super + Shift + Q` (ou com a tecla da calculadora, se o teu teclado tiver uma).

## Signal

[Signal](https://signal.org/) é o pioneiro das mensagens encriptadas E2E e uma ótima opção de comunicação para quem prefere não passar por um dos grandes conglomerados tecnológicos.

Inicias o Signal com `Super + Shift + G`. Não faz parte da instalação base, por isso, da primeira vez que carregares nessa combinação, o Omarchy vai propor instalar-to (também está em _Install > Service_ no menu do Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) é o visualizador de imagens e leitor multimédia extremamente simples do Omarchy: uma janela para as tuas fotografias, vídeos e música. Abre uma fotografia e as teclas de seta percorrem o resto da pasta, `N` e `P` fazem-no para qualquer ficheiro, e `Ctrl + M` mostra a pasta inteira como uma grelha. Também mostra fotografias HEIC, AVIF e JPEG XL, e retoma onde ficaste em qualquer conteúdo longo.

Prime `F` para ecrã inteiro, `E` para editares uma imagem no Omasnap ou aparares um vídeo no Omacut, `Ctrl + P` para imprimires uma imagem e `Delete` para moveres um ficheiro para o Lixo (`Ctrl + Z` trá-lo de volta). Prime `?` dentro da aplicação para veres todos os atalhos.

Inicias o Omaview como _Media Viewer_ através do lançador de aplicações (`Super + Space`), ou basta fazeres duplo clique numa fotografia, vídeo ou música no gestor de ficheiros.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) é o aparador de vídeo extremamente simples do Omarchy. Quando só precisas de cortar o início e o fim de um clip, compensa muito mais do que abrir um editor de vídeo completo.

Inicias o Omacut através do lançador de aplicações (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) é o gravador de webcam extremamente simples do Omarchy. Escolhe a câmara e o microfone uma vez, depois prime `Space` para gravares e outra vez para pausares e retomares a mesma gravação. Grava sempre na resolução máxima da tua câmara, com um medidor de microfone em tempo real para poderes verificar os teus níveis antes de começares.

Para a gravação e ela abre de imediato num editor integrado. Faz duplo clique num excerto para o dividires, arrasta as pegas para aparares cada pedaço e remove as partes que não queres. Depois guarda-o como um MP4. A tua gravação original é mantida até a descartares, por isso podes sempre voltar atrás e cortá-la de outra forma.

Inicias o Monologue através do lançador de aplicações (`Super + Space`).
