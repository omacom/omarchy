# GUIs

## Files

O Files (Nautilus) é o gerenciador de arquivos gráfico. `Super + Shift + F` abre ele, e `Super + Shift + Alt + F` abre ele no diretório em que o seu terminal está, o que economiza um monte de cliques. `Ctrl + L` permite que você digite um caminho, e apertar `Space` em qualquer arquivo mostra uma prévia rápida sem abrir nada.

Conecte um pendrive USB ou um cartão SD e ele é montado automaticamente, então simplesmente aparece na barra lateral. Para qualquer coisa mais complexa — formatar um disco, verificar a saúde SMART, criar partições — abra o _Disks_ pelo lançador de aplicativos (`Super + Space`).

O clique duplo segue padrões sensatos: imagens, vídeos e músicas abrem no Omaview, PDFs no Document Viewer, Markdown no Omawrite, e texto puro no editor escolhido em _Setup > Default > Editor_.

## Disktree

Quando o disco enche e você não tem ideia do que está devorando ele, abra o [Disktree](https://github.com/tobi/disktree) pelo lançador de aplicativos (`Super + Space`). Ele mostra um treemap gráfico do seu diretório home. Blocos maiores ocupam mais espaço; navegue pelos diretórios com o teclado ou o mouse, marque o que deve sair, e revise suas seleções antes de remover qualquer coisa. Execute `disktree --disk` para escanear o disco inteiro.

## Obsidian

O [Obsidian](https://obsidian.md/) é um aplicativo de anotações gratuito e altamente extensível que usa arquivos Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, incluindo uso pessoal, comercial e sem fins lucrativos.

O Obsidian também oferece um [complemento comercial para sincronização](https://obsidian.md/sync) com aplicativos móveis no iOS e Android. (https://obsidian.md/pricing).

Você inicia o Obsidian com `Super + Shift + O`. Para usar a sincronização de tema, você precisa selecionar o tema `Omarchy` nas configurações.

## Omawrite

O [Omawrite](https://github.com/omacom-io/omawrite) é o aplicativo de escrita em Markdown absurdamente simples do próprio Omarchy. Sem cofres, sem plugins, só você e as palavras.

Você inicia o Omawrite com `Super + Shift + W`.

## Pinta

O [Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagens que é ótima para cortar, redimensionar e outras manipulações básicas. Só não espere uma alternativa ao Photoshop. Mas ele ainda tem Magic Wand e camadas!

Você inicia o Pinta pelo lançador de aplicativos (`Super + Space`).

## Aether

O [Aether](https://github.com/bjarneo/aether) é um aplicativo de temas que pode extrair cores de uma imagem de fundo e transformá-las em um tema completo e coeso. É a maneira mais fácil de [criar seu próprio tema](43-making-your-own-theme.md).

Você inicia o Aether pelo lançador de aplicativos (`Super + Space`).

## LocalSend

O [LocalSend](https://localsend.org/) permite que você envie arquivos para outros dispositivos na mesma rede que estejam executando o aplicativo, como o AirDrop da Apple. Mas ele é multiplataforma, então você pode enviar arquivos de e para Windows, macOS, Android, iOS e, claro, Linux.

Você pode abrir o menu Share com `Super + Ctrl + S` ou em _Trigger > Share_ no menu do Omarchy. Ele oferece quatro opções:

- **Clipboard** envia o que você copiou como um arquivo de texto. Ótimo para colocar um link ou um trecho no seu celular sem enviar um e-mail para si mesmo.
- **File** abre um seletor de arquivos onde você pode selecionar vários de uma vez.
- **Folder** envia um diretório inteiro.
- **Receive** abre o LocalSend propriamente dito para que outro dispositivo possa enviar algo para você.

A mesma coisa funciona pelo terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Deixe o caminho de fora e você ganha o seletor.

Você também pode enviar direto do gerenciador de arquivos: clique com o botão direito em qualquer seleção no Nautilus e escolha _Send via LocalSend_.

O firewall do Omarchy é fechado por padrão, exceto pela porta do LocalSend, então isso funciona de fábrica em uma instalação nova. Veja [segurança](48-security.md).

## LibreOffice

O [LibreOffice](https://www.libreoffice.org/) é um pacote office completo com processador de texto, planilha, apresentações, aplicativo de desenho e muito mais. Ele é compatível com arquivos do Microsoft Office, então essa é uma ótima maneira de conseguir abrir aqueles documentos do Word.

Você inicia o LibreOffice pelo lançador de aplicativos (`Super + Space`).

## Hype

O [Hype](https://github.com/omacom/hype) é o aplicativo de apresentações absurdamente simples do próprio Omarchy. Sua apresentação é um único arquivo Markdown com suas imagens e vídeos ao lado dele: escreva cada slide abaixo de uma prévia ao vivo, arraste os slides para colocá-los em ordem, depois apresente em tela cheia ou exporte para PDF e PowerPoint. Ele até adota o seu tema do Omarchy.

Você inicia o Hype pelo lançador de aplicativos (`Super + Space`). Aperte `?` dentro dele para ver todos os atalhos.

## Signed

O [Signed](https://github.com/omacom/signed) é a maneira absurdamente simples do próprio Omarchy de assinar PDFs e preenchê-los. Coloque sua assinatura salva, texto e a data de hoje em qualquer lugar de uma página, depois salve uma cópia assinada ao lado do original. Veja [Preenchendo PDFs](27-filling-out-pdfs.md) para saber como.

Você inicia o Signed pelo lançador de aplicativos (`Super + Space`), ou abre um PDF com ele a partir do gerenciador de arquivos.

## Omacalc

O [Omacalc](https://github.com/omacom-io/omacalc) é a calculadora absurdamente simples do próprio Omarchy, que abre em uma janela flutuante.

Você inicia o Omacalc com `Super + Shift + Q` (ou a tecla de calculadora, se o seu teclado tiver uma).

## Signal

O [Signal](https://signal.org/) é o pioneiro das mensagens com criptografia E2E, e uma ótima opção de comunicação para quem prefere não passar por um dos grandes conglomerados de tecnologia.

Você inicia o Signal com `Super + Shift + G`. Ele não faz parte da instalação base, então na primeira vez que você apertar isso, o Omarchy vai oferecer instalá-lo para você (ele também está em _Install > Service_ no menu do Omarchy).

## Omaview

O [Omaview](https://github.com/omacom/omaview) é o visualizador de imagens e reprodutor de mídia absurdamente simples do próprio Omarchy: uma janela para suas fotos, vídeos e músicas. Abra uma foto e as teclas de seta percorrem o resto da pasta dela, `N` e `P` fazem isso para qualquer coisa, e `Ctrl + M` mostra a pasta inteira como uma grade. Ele também mostra fotos HEIC, AVIF e JPEG XL, e continua de onde você parou em qualquer coisa longa.

Aperte `F` para tela cheia, `E` para editar uma imagem no Omasnap ou cortar um vídeo no Omacut, `Ctrl + P` para imprimir uma imagem, e `Delete` para mover um arquivo para a Lixeira (`Ctrl + Z` traz ele de volta). Aperte `?` dentro dele para ver todos os atalhos.

Você inicia o Omaview como _Media Viewer_ pelo lançador de aplicativos (`Super + Space`), ou simplesmente dá um clique duplo em uma imagem, vídeo ou música no gerenciador de arquivos.

## Omacut

O [Omacut](https://github.com/omacom-io/omacut) é o cortador de vídeo absurdamente simples do próprio Omarchy. Quando tudo que você precisa é cortar o início e o fim de um clipe, ele ganha de abrir um editor de vídeo completo.

Você inicia o Omacut pelo lançador de aplicativos (`Super + Space`).

## Monologue

O [Monologue](https://github.com/omacom/monologue) é o gravador de webcam absurdamente simples do próprio Omarchy. Escolha sua câmera e seu microfone uma vez, depois aperte `Space` para gravar, e de novo para pausar e retomar a mesma tomada. Ele sempre grava na resolução mais alta da sua câmera, com um medidor de microfone ao vivo para você verificar seus níveis antes de começar.

Pare a tomada e ela abre na hora em um editor embutido. Dê um clique duplo em um clipe para dividi-lo, arraste as alças para cortar cada pedaço, e remova as partes que você não quer. Depois salve ele como um MP4. Sua gravação original é mantida até você descartá-la, então você sempre pode voltar e cortá-la de outro jeito.

Você inicia o Monologue pelo lançador de aplicativos (`Super + Space`).
