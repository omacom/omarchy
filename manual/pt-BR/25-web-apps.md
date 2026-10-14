# Aplicativos web

Você pode adicionar seus próprios aplicativos web usando _Instalar > Aplicativo web_ no menu do Omarchy (`Super + Space`). Ele pedirá o nome do aplicativo, a URL do aplicativo e a URL do ícone, caso não consiga recuperá-lo pelo favicon. Você pode obter ótimos ícones PNG para muitos aplicativos web populares no [Dashboard Icons](https://dashboardicons.com).

Eles ficarão então acessíveis pelo inicializador de aplicativos (`Super + Space`) e usarão a bela janela de aplicativo web sem moldura.

Se você quiser remover um aplicativo web, basta ir a _Remover > Aplicativo web_ no menu do Omarchy.

É melhor você fazer login em todas as suas contas usando um navegador comum antes de usar os atalhos de aplicativos web. A moldura fina do invólucro não funciona bem com o 1password, então é mais fácil estar conectado diretamente primeiro.

Todos os atalhos de teclado desses aplicativos web podem ser alterados em `~/.config/hypr/bindings.lua`.

Quando você estiver em um aplicativo web, pode copiar a URL atual para a área de transferência usando `Shift + Alt + L`.

Por padrão, o Omarchy já vem com uma variedade de aplicativos padrão:

## HEY

O [HEY](https://www.hey.com/) é um serviço de e-mail e calendário que serve como uma ótima alternativa para quem está cansado do Gmail, do Outlook ou do Apple Mail. Ele é feito pela [37signals](https://37signals.com/), onde o Omarchy se originou.

Você pode iniciar o HEY Email usando `Super + Shift + E`, pular direto para escrever um novo e-mail usando `Super + Shift + Alt + E` e iniciar o HEY Calendar usando `Super + Shift + C`.

## Basecamp

O [Basecamp](https://basecamp.com/) é um serviço de gerenciamento de projetos que ajuda pequenas equipes a se moverem mais rápido e a progredirem mais. Em vez de juntar uma miscelânea de Trello, Slack, Asana, Notion ou qualquer outra coisa, você pode ter tudo em um só lugar com o Basecamp. Ele é feito pela [37signals](https://37signals.com/), onde o Omarchy se originou.

Você pode iniciar o Basecamp usando o inicializador de aplicativos (`Super + Space`)

## ChatGPT

O [ChatGPT](https://chatgpt.com) é o chatbot de IA mais popular do mundo.

Você pode iniciar o ChatGPT usando `Super + Shift + A`.

## Grok

O [Grok](https://grok.com) é o chatbot da xAI.

Você pode iniciar o Grok usando `Super + Shift + Alt + A`.

## WhatsApp

O [WhatsApp](https://www.whatsapp.com/) é um dos serviços de mensagens mais populares do mundo, e a versão web é uma ótima opção para o Linux.

Você pode iniciar o WhatsApp usando `Super + Shift + Alt + G`.

## Aplicativos do Google

Google Mensagens, Google Fotos, Google Maps e Google Contatos também estão incluídos como aplicativos web.

Você pode iniciar o Google Mensagens usando `Super + Shift + Ctrl + G`, o Google Fotos usando `Super + Shift + P` e o Google Maps usando `Super + Shift + S`. O Google Contatos está disponível pelo inicializador de aplicativos (`Super + Space`).

## X

O X é onde as notícias acontecem.

Você pode iniciar o X usando `Super + Shift + X` e ir direto para escrever uma nova publicação com `Super + Shift + Alt + X`.

## YouTube

O [YouTube](https://youtube.com/) é a plataforma de vídeos mais popular do mundo.

Você pode iniciar o YouTube usando `Super + Shift + Y`.

## Zoom

O [Zoom](https://zoom.us/) é o sistema de videochamada mais popular usado nos Estados Unidos. Ótimas conexões em todo o mundo. E reuniões de 40 minutos podem ser realizadas sem uma conta paga. O Omarchy envolve o cliente web do Zoom, e links de reuniões do Zoom abrirão direto nele.

Você inicia o Zoom usando o inicializador de aplicativos (`Super + Space`).

## Discord

O [Discord](https://discord.com/) é onde a maioria das comunidades de jogos e de código aberto se reúne, incluindo a [própria do Omarchy](https://discord.gg/tXFUdasqhY).

Você inicia o Discord usando o inicializador de aplicativos (`Super + Space`).

## Aplicativos da Microsoft

Selecione _Instalar > Serviço > Microsoft_ para adicionar Outlook, Word, Excel, PowerPoint, Teams e OneDrive como aplicativos web. Cada aplicativo tem seu próprio inicializador e abre diretamente, usando as URLs comerciais do Microsoft 365 e seu perfil de navegador existente. Eles abrem nas mesmas janelas de aplicativo de navegador que os outros aplicativos web do Omarchy; eles não instalam o cliente separado do Teams para Linux.

Remova o pacote com _Remover > Serviço > Microsoft_, ou remova aplicativos individuais com _Remover > Aplicativo web_. Você também pode instalar só os aplicativos que quer por _Instalar > Aplicativo web_.

Para uma nuvem governamental ou soberana, edite a URL na linha `Exec=` no inicializador relevante em `~/.local/share/applications/`, como `Microsoft Teams.desktop`, usando a URL fornecida pela sua organização. Escreva qualquer `%` literal nessa linha como `%%`. As alterações vigoram no próximo lançamento. Executar o instalador do pacote de novo substitui seus inicializadores pelas URLs padrão.

Para manter os logins de trabalho separados, acrescente um diretório de dados do navegador à linha `Exec=` de cada inicializador:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Substitua o diretório de exemplo por um caminho absoluto de sua escolha e use o mesmo caminho para os seis inicializadores para compartilhar os logins de trabalho entre eles. Os aplicativos web usam o navegador compatível selecionado no Omarchy, recorrendo ao Chromium quando o navegador padrão não é compatível.
