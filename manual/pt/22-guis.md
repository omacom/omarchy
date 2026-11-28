# GUIs

## Files

O Files (Folio) é o gestor de ficheiros gráfico. `Super + Shift + F` abre-o, e `Super + Shift + Alt + F` abre-o no diretório onde o terminal está, o que poupa muitos cliques. `Ctrl + L` permite-te escrever um caminho, e carregar em `Space` em qualquer ficheiro mostra-o em pré-visualização em tamanho real sem o abrir.

Liga uma pen USB ou um cartão SD e é montado automaticamente, por isso aparece logo na barra lateral. Para algo mais avançado — formatar uma unidade, verificar o estado SMART, criar partições — abre o _Disks_ a partir do lançador de aplicações (`Super + Space`).

Uma unidade encriptada pede a palavra-passe quando é ligada. Para que uma se desbloqueie sozinha, adiciona-lhe um ficheiro de chave com `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` e coloca esse ficheiro de chave em `~/.config/omarchy/drive-keys/<UUID>`, com o nome do UUID que `lsblk -dno UUID /dev/sdX1` imprime para a partição encriptada, e legível apenas por ti (`chmod 600`). Se esse ficheiro de chave faltar ou for recusado, é-te pedida a palavra-passe como habitualmente.

O duplo clique segue predefinições sensatas: fotografias, vídeos e música abrem no Omaview, PDFs no Document Viewer, Markdown no Omawrite e texto simples no teu editor, o Plain a menos que escolhas outro em _Setup > Defaults > Editor_.

## Disktree

Quando a unidade fica cheia e não fazes ideia do que está a ocupá-la, abre o [Disktree](https://github.com/tobi/disktree) a partir do lançador de aplicações (`Super + Space`). Mostra um treemap gráfico do teu diretório pessoal. Os blocos maiores ocupam mais espaço; percorre os diretórios com o teclado ou o rato, marca o que deve sair e revê as tuas seleções antes de removeres seja o que for. Executa `disktree --disk` para analisar o disco inteiro.

## Obsidian

O [Obsidian](https://obsidian.md/) é uma aplicação de notas gratuita e altamente extensível que utiliza ficheiros Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, incluindo utilização pessoal, comercial e sem fins lucrativos.

O Obsidian também oferece um [complemento comercial para sincronização](https://obsidian.md/sync) com aplicações móveis no iOS e no Android. (https://obsidian.md/pricing).

Arrancas o Obsidian com `Super + Shift + O`. Para utilizares a sincronização de temas, tens de selecionar o tema `Omarchy` nas definições.

## Omawrite

O [Omawrite](https://github.com/omacom-io/omawrite) é a aplicação de escrita Markdown incrivelmente simples do próprio Omarchy. Sem cofres, sem plugins, só tu e as palavras.

Arrancas o Omawrite com `Super + Shift + W`.

## Pinta

O [Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagem, excelente para cortar, redimensionar e outras manipulações básicas. Só não esperes uma alternativa ao Photoshop. Mas mesmo assim tem Varinha Mágica e camadas!

Arrancas o Pinta através do lançador de aplicações (`Super + Space`).

## Aether

O [Aether](https://github.com/bjarneo/aether) é uma aplicação de temas que consegue extrair cores de uma imagem de fundo e transformá-las num tema completo e coeso. É a forma mais fácil de [criares o teu próprio tema](43-making-your-own-theme.md).

Arrancas o Aether através do lançador de aplicações (`Super + Space`).

## LocalSend

O [LocalSend](https://localsend.org/) permite-te enviar ficheiros para outros dispositivos na mesma rede que estejam a executar a aplicação, como o AirDrop da Apple. No entanto, é multiplataforma, por isso podes enviar ficheiros de e para Windows, macOS, Android, iOS e, claro, Linux.

Podes abrir o menu Share em `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Dá-te quatro opções:

- **Clipboard** envia tudo o que copiaste como ficheiro de texto. Excelente para pores uma ligação ou um excerto no telemóvel sem te enviares um e-mail a ti próprio.
- **File** abre um seletor de ficheiros onde podes selecionar vários de uma só vez.
- **Folder** envia um diretório inteiro.
- **Receive** abre o LocalSend propriamente dito para que outro dispositivo te possa enviar alguma coisa.

A mesma coisa funciona a partir do terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Omite o caminho e aparece-te o seletor.

Também podes enviar diretamente a partir do gestor de ficheiros: clica com o botão direito numa seleção no Files e partilha-a com o LocalSend.

A firewall do Omarchy está fechada por predefinição, exceto na porta do LocalSend, por isso isto funciona logo de origem numa instalação nova. Vê [segurança](48-security.md).

## LibreOffice

O [LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, folha de cálculo, apresentações, aplicação de desenho e muito mais. É compatível com ficheiros do Microsoft Office, por isso é uma excelente forma de conseguires abrir esses documentos do Word.

Arrancas o LibreOffice através do lançador de aplicações (`Super + Space`).

## Hype

O [Hype](https://github.com/omacom/hype) é a aplicação de apresentações incrivelmente simples do próprio Omarchy. A tua apresentação é um único ficheiro Markdown com as suas imagens e vídeos ao lado: escreve cada diapositivo por baixo de uma pré-visualização ao vivo, arrasta os diapositivos para os ordenares e depois apresenta em ecrã inteiro ou exporta para PDF e PowerPoint. Até vai buscar o teu tema do Omarchy.

Arrancas o Hype através do lançador de aplicações (`Super + Space`). Carrega em `?` dentro dele para veres todos os atalhos.

## Signed

O [Signed](https://github.com/omacom/signed) é a forma incrivelmente simples do próprio Omarchy para assinar PDFs e preenchê-los. Coloca a tua assinatura guardada, texto e a data de hoje onde quiseres numa página e depois guarda uma cópia assinada ao lado do original. Vê [Preencher PDFs](27-filling-out-pdfs.md) para saberes como.

Arrancas o Signed através do lançador de aplicações (`Super + Space`), ou abres um PDF com ele a partir do gestor de ficheiros.

## Game Vibes

Game Vibes, no lançador de aplicações (`Super + Space`), é onde vivem os joguinhos do Omarchy: Checkmate, um jogo de xadrez 3D contra um amigo ou contra o adversário integrado; Cards, o paciência Klondike; Death Wish, um jogo de plataformas de precisão ao píxel com dez salas cheias de espigões e serras; e Neon Swarm, um shooter arcade. Cada um é uma única página web que segue o teu tema. Escolhe um com as setas e `Enter`, e volta à lista com `Esc` a partir do ecrã de título de um jogo ou com `Q` enquanto está em pausa. Abre em ecrã inteiro: `Super + F` transforma-o numa janela e `Super + W` fecha-o.

Os jogos que fazes com um agente também aparecem aqui: escolhe _Make something cool → Game_ no painel de agentes e descreve um, ou indica o nome de um jogo que já está no Game Vibes para continuares a trabalhar nele. O agente copia-o para `~/Games/vibes`, onde é teu para alterares, e abre-o quando termina. Podes fazer essa cópia tu mesmo com `omarchy games vibes copy <game>`. Um jogo que outra pessoa partilhe instala-se como um tema: escolhe _Install > Gaming > Game Vibes_ e cola o seu endereço git, ou executa `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ volta a remover um, e _Update > Game Vibes Games_ vai buscar novas versões. Os jogos carregam o three.js a partir da web, por isso precisam de uma ligação para arrancar.

## Omacalc

O [Omacalc](https://github.com/omacom-io/omacalc) é a calculadora incrivelmente simples do próprio Omarchy, que abre numa janela flutuante.

Arrancas o Omacalc com `Super + Shift + Q` (ou a tecla da calculadora, se o teu teclado tiver uma).

## Signal

O [Signal](https://signal.org/) é o pioneiro das mensagens encriptadas E2E e uma excelente opção de comunicação para quem prefere não passar por um dos grandes conglomerados tecnológicos.

Arrancas o Signal com `Super + Shift + G`. Não faz parte da instalação base, por isso, da primeira vez que carregares nisso, o Omarchy propõe instalar-to (também está em _Install > Service_ no menu do Omarchy).

## Omaview

O [Omaview](https://github.com/omacom/omaview) é o visualizador de fotografias e leitor multimédia incrivelmente simples do próprio Omarchy: uma janela para as tuas fotografias, vídeos e música. Abre uma fotografia e as teclas de setas percorrem o resto da sua pasta, `N` e `P` fazem-no para qualquer coisa, e `Ctrl + M` mostra a pasta inteira como uma grelha. Também mostra fotografias HEIC, AVIF e JPEG XL, e retoma onde ficaste em qualquer coisa longa.

Carrega em `F` para ecrã inteiro, `E` para editar uma fotografia no Omasnap ou cortar um vídeo no Omacut, `Ctrl + P` para imprimir uma fotografia e `Delete` para mover um ficheiro para o Lixo (`Ctrl + Z` traz-lo de volta). Carrega em `?` dentro dele para veres todos os atalhos.

Arrancas o Omaview como _Media Viewer_ através do lançador de aplicações (`Super + Space`), ou simplesmente faz duplo clique numa fotografia, vídeo ou música no gestor de ficheiros.

## Omacut

O [Omacut](https://github.com/omacom-io/omacut) é o cortador de vídeo incrivelmente simples do próprio Omarchy. Quando só precisas de cortar o início e o fim de um clipe, bate bem o trabalho de abrir um editor de vídeo completo.

Arrancas o Omacut através do lançador de aplicações (`Super + Space`).

## Monologue

O [Monologue](https://github.com/omacom/monologue) é o gravador de webcam incrivelmente simples do próprio Omarchy. Escolhe a tua câmara e o teu microfone uma vez, depois carrega em `Space` para gravar e outra vez para pausar e retomar a mesma tomada. Grava sempre na resolução mais alta da tua câmara, com um medidor de microfone ao vivo para poderes verificar os teus níveis antes de começares.

Para a tomada e ela abre logo num editor integrado. Faz duplo clique num clipe para o dividir, arrasta as pegas para cortares cada parte e remove as partes que não queres. Depois guarda-o como MP4. A tua gravação original é mantida até a descartares, por isso podes sempre voltar e cortá-la de outra forma.

Arrancas o Monologue através do lançador de aplicações (`Super + Space`).
