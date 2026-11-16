# GUIs

## Arquivos

O Arquivos (Nautilus) é o gerenciador gráfico de arquivos. `Super + Shift + F` o abre, e `Super + Shift + Alt + F` o abre no diretório em que o seu terminal está, o que economiza muitos cliques. `Ctrl + L` permite digitar um caminho, e apertar `Space` em qualquer arquivo oferece uma prévia rápida sem abrir nada.

Conecte um pendrive USB ou um cartão SD e ele é montado automaticamente, então simplesmente aparece na barra lateral. Para qualquer coisa mais envolvida — formatar uma unidade, verificar a saúde SMART, criar partições — inicie o _Disks_ pelo lançador de aplicativos (`Super + Space`).

O clique duplo segue padrões sensatos: imagens, vídeos e músicas abrem no Omaview, PDFs no Document Viewer, Markdown no Omawrite e texto puro no editor escolhido em _Setup > Default > Editor_.

## Disktree

Quando a unidade lotar e você não tiver ideia do que está consumindo esse espaço, inicie o [Disktree](https://github.com/tobi/disktree) pelo lançador de aplicativos (`Super + Space`). Ele mostra um treemap gráfico do seu diretório home. Blocos maiores ocupam mais espaço; navegue pelos diretórios com o teclado ou o mouse, marque o que deve sair e revise suas seleções antes de remover qualquer coisa. Execute `disktree --disk` para escanear o disco inteiro.

## Obsidian

O [Obsidian](https://obsidian.md/) é um aplicativo de anotações gratuito e altamente extensível que usa arquivos Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, incluindo uso pessoal, comercial e sem fins lucrativos.

O Obsidian também oferece um [complemento comercial para sincronização](https://obsidian.md/sync) com aplicativos móveis no iOS e Android. (https://obsidian.md/pricing).

Você inicia o Obsidian com `Super + Shift + O`. Para usar a sincronização de tema, você deve selecionar o tema `Omarchy` nas configurações.

## Omawrite

O [Omawrite](https://github.com/omacom-io/omawrite) é o aplicativo de escrita em Markdown extremamente simples do próprio Omarchy. Sem cofres, sem plugins, só você e as palavras.

Você inicia o Omawrite com `Super + Shift + W`.

## Pinta

O [Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagens ótima para recortar, redimensionar e outras manipulações básicas. Só não espere uma alternativa ao Photoshop. Mas ele ainda tem Magic Wand e camadas!

Você inicia o Pinta pelo lançador de aplicativos (`Super + Space`).

## Aether

O [Aether](https://github.com/bjarneo/aether) é um aplicativo de temas que consegue extrair cores de uma imagem de fundo e transformá-las em um tema completo e coeso. É a maneira mais fácil de [criar seu próprio tema](43-making-your-own-theme.md).

Você inicia o Aether pelo lançador de aplicativos (`Super + Space`).

## LocalSend

O [LocalSend](https://localsend.org/) permite enviar arquivos para outros dispositivos na mesma rede que estejam executando o aplicativo, como o AirDrop da Apple. Ele é multiplataforma, porém, então você pode enviar arquivos de e para Windows, macOS, Android, iOS e, claro, Linux.

Você pode abrir o menu Compartilhar com `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Ele oferece quatro opções:

- **Clipboard** envia o que você copiou como um arquivo de texto. Ótimo para colocar um link ou um trecho no seu celular sem precisar enviar um e-mail para si mesmo.
- **File** abre um seletor de arquivos no qual você pode selecionar vários de uma vez.
- **Folder** envia um diretório inteiro.
- **Receive** abre o LocalSend propriamente dito para que outro dispositivo possa enviar algo para você.

A mesma coisa funciona pelo terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Deixe o caminho de fora e você terá o seletor.

Você também pode enviar direto do gerenciador de arquivos: clique com o botão direito em qualquer seleção no Nautilus e escolha _Send via LocalSend_.

O firewall do Omarchy fica fechado por padrão, exceto pela porta do LocalSend, então isso funciona de fábrica em uma instalação nova. Veja [segurança](48-security.md).

## LibreOffice

O [LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, planilha, apresentações, aplicativo de desenho e muito mais. Ele é compatível com arquivos do Microsoft Office, então é uma ótima maneira de conseguir abrir aqueles documentos do Word.

Você inicia o LibreOffice pelo lançador de aplicativos (`Super + Space`).

## Hype

O [Hype](https://github.com/omacom/hype) é o aplicativo de apresentações extremamente simples do próprio Omarchy. Sua apresentação é um único arquivo Markdown com as imagens e os vídeos ao lado dele: escreva cada slide abaixo de uma prévia ao vivo, arraste os slides para colocá-los em ordem e depois apresente em tela cheia ou exporte para PDF e PowerPoint. Ele ainda adota o seu tema do Omarchy.

Você inicia o Hype pelo lançador de aplicativos (`Super + Space`). Pressione `?` dentro dele para ver todos os atalhos.

## Signed

O [Signed](https://github.com/omacom/signed) é a forma extremamente simples do próprio Omarchy de assinar PDFs e preenchê-los. Coloque sua assinatura salva, texto e a data de hoje em qualquer lugar de uma página e depois salve uma cópia assinada ao lado do original. Veja [Preenchendo PDFs](27-filling-out-pdfs.md) para saber como.

Você inicia o Signed pelo lançador de aplicativos (`Super + Space`), ou abre um PDF com ele a partir do gerenciador de arquivos.

## Checkmate

O [Checkmate](https://github.com/omacom/checkmate) é o jogo de xadrez 3D do próprio Omarchy. Jogue com um amigo no mesmo computador ou contra o adversário integrado em três níveis, em quatro conjuntos esculpidos que se movem cada um à sua maneira: naves orbitais, madeira entalhada e marfim, criaturas da floresta e doces. As partidas não têm relógio e são salvas após cada movimento.

Você inicia o Checkmate pelo lançador de aplicativos (`Super + Space`), onde ele aparece listado como Chess. Pressione `?` dentro dele para ver todos os atalhos.

## Omacalc

O [Omacalc](https://github.com/omacom-io/omacalc) é a calculadora extremamente simples do próprio Omarchy, que abre em uma janela flutuante.

Você inicia o Omacalc com `Super + Shift + Q` (ou com a tecla de calculadora, se o seu teclado tiver uma).

## Signal

O [Signal](https://signal.org/) é o pioneiro das mensagens com criptografia E2E, e uma ótima opção de comunicação para qualquer pessoa que prefira não passar por um dos grandes conglomerados de tecnologia.

Você inicia o Signal com `Super + Shift + G`. Ele não faz parte da instalação básica, então na primeira vez que você apertar isso, o Omarchy oferecerá instalá-lo para você (ele também está em _Install > Service_ no menu do Omarchy).

## Omaview

O [Omaview](https://github.com/omacom/omaview) é o visualizador de imagens e reprodutor de mídia extremamente simples do próprio Omarchy: uma janela para suas fotos, vídeos e músicas. Abra uma foto e as teclas de seta percorrem o restante da pasta dela, `N` e `P` fazem isso com qualquer coisa, e `Ctrl + M` mostra a pasta inteira como uma grade. Ele também mostra fotos HEIC, AVIF e JPEG XL, e continua de onde você parou em qualquer coisa longa.

Pressione `F` para tela cheia, `E` para editar uma imagem no Omasnap ou cortar um vídeo no Omacut, `Ctrl + P` para imprimir uma imagem e `Delete` para mover um arquivo para a Lixeira (`Ctrl + Z` o traz de volta). Pressione `?` dentro dele para ver todos os atalhos.

Você inicia o Omaview como _Media Viewer_ pelo lançador de aplicativos (`Super + Space`), ou apenas clica duas vezes em uma imagem, vídeo ou música no gerenciador de arquivos.

## Omacut

O [Omacut](https://github.com/omacom-io/omacut) é o cortador de vídeos extremamente simples do próprio Omarchy. Quando tudo o que você precisa é cortar o início e o fim de um clipe, ele supera abrir um editor de vídeos completo.

Você inicia o Omacut pelo lançador de aplicativos (`Super + Space`).

## Monologue

O [Monologue](https://github.com/omacom/monologue) é o gravador de webcam extremamente simples do próprio Omarchy. Escolha sua câmera e seu microfone uma vez, depois pressione `Space` para gravar, e novamente para pausar e retomar a mesma tomada. Ele sempre grava na resolução mais alta da sua câmera, com um medidor de microfone ao vivo para você verificar seus níveis antes de começar.

Pare a tomada e ela abre imediatamente em um editor integrado. Clique duas vezes em um clipe para dividi-lo, arraste as alças para cortar cada trecho e remova as partes que você não quer. Depois salve-o como MP4. Sua gravação original é mantida até você descartá-la, então você sempre pode voltar e cortá-la de outra maneira.

Você inicia o Monologue pelo lançador de aplicativos (`Super + Space`).
