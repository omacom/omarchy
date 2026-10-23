# GUIs

## Arquivos

O Arquivos (Nautilus) é o gerenciador de arquivos gráfico. `Super + Shift + F` o abre, e `Super + Shift + Alt + F` o abre no diretório em que seu terminal está, o que economiza muitos cliques. `Ctrl + L` permite digitar um caminho, e pressionar `Space` em qualquer arquivo oferece uma pré-visualização rápida sem abrir nada.

Conecte um pendrive USB ou um cartão SD e ele é montado automaticamente, então simplesmente aparece na barra lateral. Para qualquer coisa mais envolvida — formatar uma unidade, verificar a integridade SMART, criar partições — inicie _Discos_ pelo inicializador de aplicativos (`Super + Space`).

Um clique duplo segue padrões sensatos: imagens abrem no imv, vídeos no mpv, PDFs no Visualizador de Documentos e texto simples no Neovim.

## Disktree

Quando o disco enche e você não faz ideia do que o está devorando, inicie o [Disktree](https://github.com/tobi/disktree) pelo inicializador de aplicativos (`Super + Space`). Ele mostra um mapa de árvore gráfico do seu diretório inicial. Blocos maiores ocupam mais espaço; navegue pelos diretórios com o teclado ou o mouse, marque o que deve sair e revise suas seleções antes de remover qualquer coisa. Execute `disktree --disk` para escanear o disco inteiro.

## Obsidian

O [Obsidian](https://obsidian.md/) é um aplicativo de anotações gratuito e altamente extensível que usa arquivos Markdown simples para armazenamento.

O Obsidian é gratuito para todos os fins, incluindo uso pessoal, comercial e sem fins lucrativos.

O Obsidian também oferece um [complemento comercial para sincronização](https://obsidian.md/sync) com aplicativos móveis no iOS e no Android. (https://obsidian.md/pricing).

Você inicia o Obsidian com `Super + Shift + O`. Para usar a sincronização de tema, você deve selecionar o tema `Omarchy` nas configurações.

## Omawrite

O [Omawrite](https://github.com/omacom-io/omawrite) é o aplicativo de escrita em Markdown absolutamente simples do próprio Omarchy. Sem cofres, sem plug-ins, só você e as palavras.

Você inicia o Omawrite com `Super + Shift + W`.

## Pinta

O [Pinta](https://www.pinta-project.com/) é uma ferramenta básica de edição de imagens, ótima para recortar, redimensionar e outras manipulações básicas. Só não espere uma alternativa ao Photoshop. Mas ele ainda tem uma Varinha Mágica e camadas!

Você inicia o Pinta pelo inicializador de aplicativos (`Super + Space`).

## Aether

O [Aether](https://github.com/bjarneo/aether) é um aplicativo de tematização que pode extrair cores de uma imagem de fundo e transformá-las em um tema completo e coeso. É a maneira mais fácil de [criar seu próprio tema](43-making-your-own-theme.md).

Você inicia o Aether pelo inicializador de aplicativos (`Super + Space`).

## LocalSend

O [LocalSend](https://localsend.org/) permite enviar arquivos para outros dispositivos na mesma rede que estejam executando o aplicativo, como o AirDrop da Apple. Ele é multiplataforma, porém, então você pode enviar arquivos de e para Windows, macOS, Android, iOS e, é claro, Linux.

Você pode abrir o menu Compartilhar com `Super + Ctrl + S` ou em _Acionar > Compartilhar_ no menu do Omarchy. Ele oferece quatro opções:

- **Área de transferência** envia o que você tiver copiado como um arquivo de texto. Ótimo para colocar um link ou um trecho no seu celular sem enviar um e-mail para si mesmo.
- **Arquivo** abre um seletor de arquivos onde você pode selecionar vários de uma vez.
- **Pasta** envia um diretório inteiro.
- **Receber** abre o próprio LocalSend para que outro dispositivo possa enviar algo para você.

A mesma coisa funciona pelo terminal com `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Omita o caminho e você obtém o seletor.

Você também pode enviar direto do gerenciador de arquivos: clique com o botão direito em qualquer seleção no Nautilus e escolha _Enviar via LocalSend_.

O firewall do Omarchy é fechado por padrão, exceto pela porta do LocalSend, então isso funciona por padrão em uma instalação nova. Consulte [segurança](48-security.md).

## LibreOffice

O [LibreOffice](https://www.libreoffice.org/) é um pacote de escritório completo, com processador de texto, planilha, apresentações, aplicativo de desenho e mais. Ele é compatível com arquivos do Microsoft Office, então essa é uma ótima maneira de conseguir abrir aqueles documentos do Word.

Você inicia o LibreOffice pelo inicializador de aplicativos (`Super + Space`).

## Hype

O [Hype](https://github.com/omacom/hype) é o aplicativo de apresentações absolutamente simples do próprio Omarchy. Sua apresentação é um único arquivo Markdown com suas imagens e vídeos ao lado: escreva cada slide abaixo de uma pré-visualização ao vivo, arraste os slides para ordená-los e depois apresente em tela cheia ou exporte para PDF e PowerPoint. Ele até adota seu tema do Omarchy.

Você inicia o Hype pelo inicializador de aplicativos (`Super + Space`). Pressione `?` dentro dele para ver todos os atalhos.

## Signed

O [Signed](https://github.com/omacom/signed) é a maneira absolutamente simples do próprio Omarchy de assinar PDFs e preenchê-los. Coloque sua assinatura salva, texto e a data de hoje em qualquer lugar de uma página e depois salve uma cópia assinada ao lado do original. Consulte [Preenchendo PDFs](27-filling-out-pdfs.md) para saber como.

Você inicia o Signed pelo inicializador de aplicativos (`Super + Space`), ou abre um PDF com ele pelo gerenciador de arquivos.

## Omacalc

O [Omacalc](https://github.com/omacom-io/omacalc) é a calculadora absolutamente simples do próprio Omarchy, que abre em uma janela flutuante.

Você inicia o Omacalc com `Super + Ctrl + Q` (ou a tecla de calculadora, se o seu teclado tiver uma).

## Signal

O [Signal](https://signal.org/) é o pioneiro das mensagens com criptografia de ponta a ponta, e uma ótima opção de comunicação para quem preferir não passar por um dos grandes conglomerados de tecnologia.

Você inicia o Signal com `Super + Shift + G`. Ele não faz parte da instalação base, então na primeira vez que você pressionar isso, o Omarchy oferecerá instalá-lo para você (ele também está em _Instalar > Serviço_ no menu do Omarchy).

## mpv

O [mpv](https://mpv.io/) é um reprodutor de mídia simples e rápido que reproduz quase qualquer coisa de qualquer fonte. Ótimo para assistir a vídeos.

Você inicia o mpv pelo inicializador de aplicativos (`Super + Space`) ou simplesmente clicando duas vezes em um vídeo no gerenciador de arquivos.

## Omacut

O [Omacut](https://github.com/omacom-io/omacut) é o cortador de vídeo absolutamente simples do próprio Omarchy. Quando tudo o que você precisa é cortar o começo e o fim de um clipe, ele supera abrir um editor de vídeo completo.

Você inicia o Omacut pelo inicializador de aplicativos (`Super + Space`).

## Monologue

O [Monologue](https://github.com/omacom/monologue) é o gravador de webcam absolutamente simples do próprio Omarchy. Escolha sua câmera e seu microfone uma vez, depois pressione `Space` para gravar, e novamente para pausar e retomar a mesma tomada. Ele sempre grava na resolução mais alta da sua câmera, com um medidor de microfone ao vivo para você conferir seus níveis antes de começar.

Pare a tomada e ela abre imediatamente em um editor integrado. Clique duas vezes em um clipe para dividi-lo, arraste as alças para aparar cada pedaço e remova as partes que você não quer. Depois salve como MP4. Sua gravação original é mantida até você descartá-la, então você sempre pode voltar e cortá-la de outro jeito.

Você inicia o Monologue pelo inicializador de aplicativos (`Super + Space`).
