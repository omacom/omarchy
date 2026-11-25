# GUIs

## Files

Files (Folio) é o gerenciador de arquivos gráfico. `Super + Shift + F` abre ele, e `Super + Shift + Alt + F` abre ele no diretório em que o seu terminal está, o que economiza um monte de cliques. `Ctrl + L` permite digitar um caminho, e apertar `Space` em qualquer arquivo mostra uma prévia dele em tamanho real sem abri-lo.

Conecte um pendrive USB ou um cartão SD e ele é montado automaticamente, então simplesmente aparece na barra lateral. Para qualquer coisa mais elaborada — formatar uma unidade, verificar a saúde SMART, criar partições — abra o _Disks_ pelo iniciador de aplicativos (`Super + Space`).

O clique duplo segue padrões sensatos: imagens, vídeos e músicas abrem no Omaview, PDFs no Document Viewer, Markdown no Omawrite e texto puro no seu editor, o Plain, a menos que você escolha outro em _Setup > Defaults > Editor_.

## Disktree

Quando a unidade encher e você não tiver ideia do que está consumindo o espaço, abra o [Disktree](https://github.com/tobi/disktree) pelo iniciador de aplicativos (`Super + Space`). Ele mostra um treemap gráfico do seu diretório inicial. Blocos maiores ocupam mais espaço; entre nos diretórios com o teclado ou o mouse, marque o que deve sair e revise suas seleções antes de remover qualquer coisa. Execute `disktree --disk` para escanear o disco inteiro.

## Obsidian

[Obsidian](https://obsidian.md/) é um aplicativo de notas gratuito e altamente extensível que usa arquivos Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, incluindo uso pessoal, comercial e sem fins lucrativos.

O Obsidian também oferece um [complemento comercial de sincronização](https://obsidian.md/sync) com aplicativos móveis no iOS e no Android. (https://obsidian.md/pricing).

Você abre o Obsidian com `Super + Shift + O`. Para usar a sincronização de tema, você precisa selecionar o tema `Omarchy` nas configurações.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) é o aplicativo de escrita em Markdown simplíssimo do próprio Omarchy. Sem cofres, sem plugins, só você e as palavras.

Você abre o Omawrite com `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagens que é ótima para cortar, redimensionar e outras manipulações básicas. Só não espere uma alternativa ao Photoshop. Mas ele ainda tem Varinha Mágica e camadas!

Você abre o Pinta pelo iniciador de aplicativos (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) é um aplicativo de temas que consegue extrair cores de uma imagem de fundo e transformá-las em um tema completo e coeso. É a maneira mais fácil de [criar seu próprio tema](43-making-your-own-theme.md).

Você abre o Aether pelo iniciador de aplicativos (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) permite enviar arquivos para outros dispositivos na mesma rede que estejam executando o aplicativo, como o AirDrop da Apple. Mas ele é multiplataforma, então você pode enviar e receber arquivos de Windows, macOS, Android, iOS e, claro, Linux.

Você pode abrir o menu Compartilhar com `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Ele oferece quatro opções:

- **Área de transferência** envia o que você copiou como um arquivo de texto. Ótimo para colocar um link ou um trecho no seu celular sem precisar mandar um e-mail para si mesmo.
- **Arquivo** abre um seletor de arquivos onde você pode selecionar vários de uma vez.
- **Pasta** envia um diretório inteiro.
- **Receber** abre o LocalSend propriamente dito para que outro dispositivo possa enviar algo para você.

A mesma coisa funciona pelo terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Deixe o caminho de fora e você ganha o seletor.

Você também pode enviar direto do gerenciador de arquivos: clique com o botão direito em qualquer seleção no Files e compartilhe com o LocalSend.

O firewall do Omarchy é fechado por padrão, exceto pela porta do LocalSend, então isso funciona de cara em uma instalação nova. Veja [segurança](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, planilha, apresentações, aplicativo de desenho e muito mais. Ele é compatível com arquivos do Microsoft Office, então é uma ótima maneira de conseguir abrir aqueles documentos do Word.

Você abre o LibreOffice pelo iniciador de aplicativos (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) é o aplicativo de apresentações simplíssimo do próprio Omarchy. Sua apresentação é um único arquivo Markdown com as imagens e os vídeos ao lado dele: escreva cada slide abaixo de uma prévia ao vivo, arraste os slides para colocá-los em ordem e depois apresente em tela cheia ou exporte para PDF e PowerPoint. Ele até adota o seu tema do Omarchy.

Você abre o Hype pelo iniciador de aplicativos (`Super + Space`). Aperte `?` dentro dele para ver todos os atalhos.

## Signed

[Signed](https://github.com/omacom/signed) é a maneira simplíssima do próprio Omarchy de assinar PDFs e preenchê-los. Coloque sua assinatura salva, um texto e a data de hoje em qualquer lugar de uma página e depois salve uma cópia assinada ao lado do original. Veja [Preenchendo PDFs](27-filling-out-pdfs.md) para saber como.

Você abre o Signed pelo iniciador de aplicativos (`Super + Space`), ou abre um PDF com ele pelo gerenciador de arquivos.

## Game Vibes

O Game Vibes, no iniciador de aplicativos (`Super + Space`), é onde vivem os joguinhos do Omarchy: Checkmate, um jogo de xadrez 3D contra um amigo ou o oponente integrado; Cards, paciência Klondike; Death Wish, um jogo de plataforma de precisão pixel a pixel com dez salas cheias de espinhos e serras; e Neon Swarm, um jogo de tiro arcade. Cada um é uma única página web que segue o seu tema. Escolha um com as setas e `Enter`, e volte à lista com `Esc` na tela de título de um jogo ou `Q` enquanto ele estiver pausado. Ele abre em tela cheia: `Super + F` transforma em janela, e `Super + W` fecha.

Os jogos que você cria com um agente também aparecem aqui: escolha _Make something cool → Game_ no painel de agentes e descreva um, ou mencione um jogo que já está no Game Vibes para continuar trabalhando nele. O agente copia ele para `~/Games/vibes`, onde ele é seu para alterar, e abre quando termina. Você pode fazer essa cópia você mesmo com `omarchy games vibes copy <game>`. Um jogo que outra pessoa compartilha é instalado como um tema: escolha _Install > Gaming > Game Vibes_ e cole o endereço git dele, ou execute `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ remove um novamente, e _Update > Game Vibes Games_ busca novas versões. Os jogos carregam o three.js da web, então precisam de uma conexão para iniciar.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) é a calculadora simplíssima do próprio Omarchy, que abre em uma janela flutuante.

Você abre o Omacalc com `Super + Shift + Q` (ou a tecla de calculadora, se o seu teclado tiver uma).

## Signal

[Signal](https://signal.org/) é o pioneiro das mensagens com criptografia E2E e uma ótima opção de comunicação para quem prefere não passar por um dos grandes conglomerados de tecnologia.

Você abre o Signal com `Super + Shift + G`. Ele não faz parte da instalação básica, então na primeira vez que você apertar isso, o Omarchy vai se oferecer para instalar para você (ele também está em _Install > Service_ no menu do Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) é o visualizador de imagens e reprodutor de mídia simplíssimo do próprio Omarchy: uma janela para suas fotos, vídeos e músicas. Abra uma foto e as teclas de seta percorrem o resto da pasta dela, `N` e `P` fazem isso para qualquer coisa, e `Ctrl + M` mostra a pasta inteira como uma grade. Ele também mostra fotos HEIC, AVIF e JPEG XL, e retoma de onde você parou em qualquer coisa longa.

Aperte `F` para tela cheia, `E` para editar uma imagem no Omasnap ou cortar um vídeo no Omacut, `Ctrl + P` para imprimir uma imagem e `Delete` para mover um arquivo para a Lixeira (`Ctrl + Z` traz ele de volta). Aperte `?` dentro dele para ver todos os atalhos.

Você abre o Omaview como _Media Viewer_ pelo iniciador de aplicativos (`Super + Space`), ou simplesmente clica duas vezes em uma imagem, vídeo ou música no gerenciador de arquivos.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) é o cortador de vídeo simplíssimo do próprio Omarchy. Quando tudo que você precisa é cortar o começo e o fim de um clipe, ele ganha de abrir um editor de vídeo completo.

Você abre o Omacut pelo iniciador de aplicativos (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) é o gravador de webcam simplíssimo do próprio Omarchy. Escolha sua câmera e seu microfone uma vez, depois aperte `Space` para gravar, e de novo para pausar e retomar a mesma tomada. Ele sempre grava na resolução mais alta da sua câmera, com um medidor de microfone ao vivo para você verificar seus níveis antes de começar.

Pare a tomada e ela abre na hora em um editor integrado. Clique duas vezes em um clipe para dividi-lo, arraste as alças para cortar cada trecho e remova as partes que você não quer. Depois salve como um MP4. Sua gravação original é mantida até você descartá-la, então você sempre pode voltar e cortar de outro jeito.

Você abre o Monologue pelo iniciador de aplicativos (`Super + Space`).
