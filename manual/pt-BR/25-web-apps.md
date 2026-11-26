# Aplicativos Web

Você pode adicionar seus próprios aplicativos web usando _Install > Web App_ no menu do Omarchy (`Super + Space`). Ele vai pedir o nome do aplicativo, a URL do aplicativo e a URL do ícone, se não conseguir obtê-la via favicon. Você pode conseguir ótimos ícones PNG para muitos aplicativos web populares no [Dashboard Icons](https://dashboardicons.com).

Eles ficarão então acessíveis pelo lançador de aplicativos (`Super + Space`) e usarão a bela janela de aplicativo web sem moldura.

Se quiser remover um aplicativo web, basta ir em _Remove > Web App_ no menu do Omarchy.

O melhor é entrar em todas as suas contas usando um navegador comum antes de usar os atalhos dos aplicativos web. O fino frame wrapper não funciona bem com o 1password, então é simplesmente mais fácil já estar logado diretamente antes.

Todas as teclas de atalho do teclado para esses aplicativos web podem ser alteradas em `~/.config/hypr/bindings.lua`.

Quando estiver em um aplicativo web, você pode copiar a URL atual para a área de transferência usando `Shift + Alt + L`.

Por padrão, o Omarchy já vem com uma variedade de aplicativos padrão:

## HEY

O [HEY](https://www.hey.com/) é um serviço de e-mail e calendário que serve como uma ótima alternativa para quem está cansado do Gmail, Outlook ou Apple Mail. Ele é feito pela [37signals](https://37signals.com/), onde o Omarchy se originou.

Você pode iniciar o HEY Email usando `Super + Shift + E`, ir direto para escrever um novo e-mail usando `Super + Shift + Alt + E` e iniciar o HEY Calendar usando `Super + Shift + C`.

## Basecamp

O [Basecamp](https://basecamp.com/) é um serviço de gerenciamento de projetos que ajuda equipes pequenas a avançar mais rápido e progredir mais. Em vez de remendar uma mistura de Trello, Slack, Asana, Notion ou seja lá o que for, você pode ter tudo em um só lugar com o Basecamp. Ele é feito pela [37signals](https://37signals.com/), onde o Omarchy se originou.

Você pode iniciar o Basecamp usando o lançador de aplicativos (`Super + Space`)

## ChatGPT

O [ChatGPT](https://chatgpt.com) é o chatbot de IA mais popular do mundo.

Você pode iniciar o ChatGPT usando `Super + Shift + A`.

## Grok

O [Grok](https://grok.com) é o chatbot da xAI.

Você pode iniciar o Grok usando `Super + Shift + Alt + A`.

## WhatsApp

O [WhatsApp](https://www.whatsapp.com/) é um dos serviços de mensagens mais populares do mundo, e a versão web é uma ótima opção para Linux.

Você pode iniciar o WhatsApp usando `Super + Shift + Alt + G`. Ele abre com a extensão WhatsApp Slim do Omarchy, que faz ele seguir o seu tema e recolhe a lista de conversas quando a janela é estreita.

## Aplicativos Google

Google Messages, Google Photos, Google Maps e Google Contacts também estão incluídos como aplicativos web.

Você pode iniciar o Google Messages usando `Super + Shift + Ctrl + G`, o Google Photos usando `Super + Shift + P` e o Google Maps usando `Super + Shift + S`. O Google Contacts está disponível pelo lançador de aplicativos (`Super + Space`).

## X

É no X que as notícias surgem.

Você pode iniciar o X usando `Super + Shift + X` e ir direto para escrever uma nova publicação com `Super + Shift + Alt + X`.

## YouTube

O [YouTube](https://youtube.com/) é a plataforma de vídeos mais popular do mundo.

Você pode iniciar o YouTube usando `Super + Shift + Y`.

## Netflix

A [Netflix](https://www.netflix.com/) está incluída como aplicativo web em novas instalações.

Você inicia a Netflix usando o lançador de aplicativos (`Super + Space`).

## Zoom

O [Zoom](https://zoom.us/) é o sistema de videochamadas mais popular usado nos EUA. Ótimas conexões no mundo todo. E reuniões de 40 minutos podem ser feitas sem uma conta paga. O Omarchy encapsula o cliente web do Zoom, e os links de reunião do zoom vão abrir direto nele.

Você inicia o Zoom usando o lançador de aplicativos (`Super + Space`).

## Discord

O [Discord](https://discord.com/) é onde a maioria das comunidades de games e de código aberto se reúne, incluindo [a própria do Omarchy](https://discord.gg/tXFUdasqhY).

Você inicia o Discord usando o lançador de aplicativos (`Super + Space`).

## Aplicativos Microsoft

Selecione _Install > Service > Microsoft_ para adicionar Outlook, Word, Excel, PowerPoint, Teams e OneDrive como aplicativos web. Cada aplicativo tem seu próprio lançador e abre diretamente, usando as URLs comerciais do Microsoft 365 e o seu perfil de navegador existente. Eles abrem nas mesmas janelas de aplicativo do navegador que os outros aplicativos web do Omarchy; eles não instalam o cliente separado Teams for Linux.

Remova o pacote com _Remove > Services > Microsoft_, ou remova aplicativos individuais com _Remove > Web App_. Você também pode instalar só os aplicativos que quiser por meio de _Install > Web App_.

Para uma nuvem governamental ou soberana, edite a URL na linha `Exec=` no lançador relevante em `~/.local/share/applications/`, como `Microsoft Teams.desktop`, usando a URL fornecida pela sua organização. Escreva qualquer `%` literal nessa linha como `%%`. As alterações se aplicam na próxima inicialização. Executar o instalador do pacote novamente substitui seus lançadores pelas URLs padrão.

Para manter os logins de trabalho separados, acrescente um diretório de dados do navegador à linha `Exec=` de cada lançador:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Substitua o diretório de exemplo por um caminho absoluto de sua escolha e use o mesmo caminho para todos os seis lançadores para compartilhar os logins de trabalho entre eles. Os aplicativos web usam o navegador compatível selecionado do Omarchy, recorrendo ao Chrome quando o navegador padrão não é compatível.
