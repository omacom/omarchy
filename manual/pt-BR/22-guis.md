# GUIs

## Arquivos

Files (Nautilus) é o gerenciador de arquivos gráfico. `Super + Shift + F` abre ele, e `Super + Shift + Alt + F` abre ele no diretório em que o seu terminal está, o que economiza um monte de cliques. `Ctrl + L` permite digitar um caminho, e apertar `Space` em qualquer arquivo oferece uma prévia rápida sem abrir nada.

Conecte um pendrive USB ou um cartão SD e ele é montado automaticamente, então simplesmente aparece na barra lateral. Para qualquer coisa mais envolvida — formatar uma unidade, verificar a saúde SMART, criar partições — inicie o _Disks_ a partir do inicializador de aplicativos (`Super + Space`).

Clicar duas vezes segue padrões sensatos: imagens abrem no imv, vídeos no mpv, PDFs no Document Viewer e texto simples no Neovim.

## Disktree

Quando a unidade encher e você não tiver ideia do que está consumindo ela, inicie o [Disktree](https://github.com/tobi/disktree) a partir do inicializador de aplicativos (`Super + Space`). Ele mostra um treemap gráfico do seu diretório home. Blocos maiores ocupam mais espaço; entre nos diretórios com o teclado ou o mouse, marque o que deve sair e revise suas seleções antes de remover qualquer coisa. Execute `disktree --disk` para escanear o disco inteiro.

## Obsidian

[Obsidian](https://obsidian.md/) é um aplicativo de anotações gratuito e altamente extensível que usa arquivos Markdown simples para armazenamento.

Obsidian é gratuito para todos os fins, incluindo uso pessoal, comercial e sem fins lucrativos.

Obsidian também oferece um [complemento comercial para sincronização](https://obsidian.md/sync) com aplicativos móveis no iOS e Android. (https://obsidian.md/pricing).

Você inicia o Obsidian com `Super + Shift + O`. Para usar a sincronização de tema, você precisa selecionar o tema `Omarchy` nas configurações.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) é o aplicativo de escrita Markdown simplíssimo do próprio Omarchy. Sem cofres, sem plugins, só você e as palavras.

Você inicia o Omawrite com `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagens que é ótima para cortar, redimensionar e outras manipulações básicas. Só não espere uma alternativa ao Photoshop. Mas ela ainda tem Varinha Mágica e camadas!

Você inicia o Pinta pelo inicializador de aplicativos (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) é um aplicativo de temas que pode extrair cores de uma imagem de fundo e transformá-las em um tema completo e coeso. É o jeito mais fácil de [criar seu próprio tema](43-making-your-own-theme.md).

Você inicia o Aether pelo inicializador de aplicativos (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) permite enviar arquivos para outros dispositivos na mesma rede que estejam executando o aplicativo, como o AirDrop da Apple. Mas ele é multiplataforma, então você pode enviar arquivos de e para Windows, macOS, Android, iOS e, claro, Linux.

Você pode abrir o menu Share em `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Ele oferece quatro opções:

- **Clipboard** envia o que quer que você tenha copiado como um arquivo de texto. Ótimo para colocar um link ou um trecho no seu celular sem enviar um e-mail para si mesmo.
- **File** abre um seletor de arquivos onde você pode selecionar vários de uma vez.
- **Folder** envia um diretório inteiro.
- **Receive** abre o LocalSend propriamente dito para que outro dispositivo possa enviar algo para você.

A mesma coisa funciona a partir do terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Deixe o caminho de fora e você recebe o seletor.

Você também pode enviar direto do gerenciador de arquivos: clique com o botão direito em qualquer seleção no Nautilus e escolha _Send via LocalSend_.

O firewall do Omarchy é fechado por padrão, exceto pela porta do LocalSend, então isso funciona de cara em uma instalação nova. Veja [segurança](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo com processador de texto, planilha, apresentações, aplicativo de desenho e muito mais. Ele é compatível com arquivos do Microsoft Office, então é um ótimo jeito de conseguir abrir aqueles documentos do Word.

Você inicia o LibreOffice pelo inicializador de aplicativos (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) é o aplicativo de apresentações simplíssimo do próprio Omarchy. Seu deck é um único arquivo Markdown com as imagens e os vídeos ao lado dele: escreva cada slide abaixo de uma prévia ao vivo, arraste os slides para ordenar, depois apresente em tela cheia ou exporte para PDF e PowerPoint. Ele até capta o seu tema do Omarchy.

Você inicia o Hype pelo inicializador de aplicativos (`Super + Space`). Aperte `?` dentro dele para ver todos os atalhos.

## Signed

[Signed](https://github.com/omacom/signed) é o jeito simplíssimo do próprio Omarchy de assinar PDFs e preenchê-los. Coloque sua assinatura salva, texto e a data de hoje em qualquer lugar de uma página, depois salve uma cópia assinada ao lado do original. Veja [Preenchendo PDFs](27-filling-out-pdfs.md) para saber como.

Você inicia o Signed pelo inicializador de aplicativos (`Super + Space`), ou abre um PDF com ele a partir do gerenciador de arquivos.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) é a calculadora simplíssima do próprio Omarchy, que abre em uma janela flutuante.

Você inicia o Omacalc com `Super + Shift + Q` (ou a tecla de calculadora, se o seu teclado tiver uma).

## Signal

[Signal](https://signal.org/) é o pioneiro das mensagens com criptografia E2E, e uma ótima opção de comunicação para quem prefere não passar por um dos grandes conglomerados de tecnologia.

Você inicia o Signal com `Super + Shift + G`. Ele não faz parte da instalação básica, então na primeira vez que você apertar isso, o Omarchy vai oferecer instalá-lo para você (ele também fica em _Install > Service_ no menu do Omarchy).

## mpv

[mpv](https://mpv.io/) é um reprodutor de mídia simples e rápido que reproduz quase qualquer coisa de qualquer fonte. Ótimo para assistir a vídeos.

Você inicia o mpv pelo inicializador de aplicativos (`Super + Space`) ou simplesmente clica duas vezes em um vídeo no gerenciador de arquivos.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) é o cortador de vídeo simplíssimo do próprio Omarchy. Quando tudo o que você precisa é cortar o começo e o fim de um clipe, ele supera abrir um editor de vídeo completo.

Você inicia o Omacut pelo inicializador de aplicativos (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) é o gravador de webcam simplíssimo do próprio Omarchy. Escolha sua câmera e seu microfone uma vez, depois aperte `Space` para gravar, e de novo para pausar e retomar a mesma tomada. Ele sempre grava na resolução mais alta da sua câmera, com um medidor de microfone ao vivo para você verificar seus níveis antes de começar.

Pare a tomada e ela abre na hora em um editor integrado. Clique duas vezes em um clipe para dividi-lo, arraste as alças para cortar cada pedaço e remova as partes que você não quer. Depois salve como um MP4. Sua gravação original é mantida até você descartá-la, então você sempre pode voltar e cortá-la de outro jeito.

Você inicia o Monologue pelo inicializador de aplicativos (`Super + Space`).
