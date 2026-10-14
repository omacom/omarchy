# Aplicações Web

Podes adicionar as tuas próprias aplicações web usando _Instalar > App Web_ no menu Omarchy (`Super + Space`). Ele pede-te o nome da aplicação, o URL da aplicação e o URL do ícone, se não o conseguir obter através do favicon. Podes obter ótimos ícones PNG para muitas aplicações web populares no [Dashboard Icons](https://dashboardicons.com).

Ficam depois acessíveis através do lançador de aplicações (`Super + Space`) e usam a bela janela de aplicação web sem moldura.

Se quiseres remover uma aplicação web, basta ires a _Remover > App Web_ no menu Omarchy.

É melhor iniciares sessão em todas as tuas contas usando um navegador normal antes de usares os atalhos das aplicações web. A moldura fina do invólucro não funciona bem com o 1Password, por isso é mais fácil iniciares sessão diretamente primeiro.

Todos os atalhos de teclado para estas aplicações web podem ser alterados em `~/.config/hypr/bindings.lua`.

Quando estiveres numa aplicação web, podes copiar o URL atual para a área de transferência com `Shift + Alt + L`.

Por predefinição, o Omarchy já vem com um sortido de aplicações predefinidas:

## HEY

O [HEY](https://www.hey.com/) é um serviço de e-mail e calendário que serve como uma ótima alternativa para quem está cansado do Gmail, do Outlook ou do Apple Mail. É feito pela [37signals](https://37signals.com/), onde o Omarchy nasceu.

Podes iniciar o HEY Email com `Super + Shift + E`, saltar diretamente para escreveres um novo e-mail com `Super + Shift + Alt + E` e iniciar o HEY Calendar com `Super + Shift + C`.

## Basecamp

O [Basecamp](https://basecamp.com/) é um serviço de gestão de projetos que ajuda pequenas equipas a avançar mais depressa e a fazer mais progressos. Em vez de juntares uma manta de retalhos de Trello, Slack, Asana, Notion ou o que for, podes ter tudo num só lugar com o Basecamp. É feito pela [37signals](https://37signals.com/), onde o Omarchy nasceu.

Podes iniciar o Basecamp usando o lançador de aplicações (`Super + Space`)

## ChatGPT

O [ChatGPT](https://chatgpt.com) é o chatbot de IA mais popular do mundo.

Podes iniciar o ChatGPT com `Super + Shift + A`.

## Grok

O [Grok](https://grok.com) é o chatbot da xAI.

Podes iniciar o Grok com `Super + Shift + Alt + A`.

## WhatsApp

O [WhatsApp](https://www.whatsapp.com/) é um dos serviços de mensagens mais populares do mundo, e a versão web é uma ótima opção para Linux.

Podes iniciar o WhatsApp com `Super + Shift + Alt + G`.

## Aplicações Google

O Google Messages, o Google Photos, o Google Maps e o Google Contacts também estão todos incluídos como aplicações web.

Podes iniciar o Google Messages com `Super + Shift + Ctrl + G`, o Google Photos com `Super + Shift + P` e o Google Maps com `Super + Shift + S`. O Google Contacts está disponível através do lançador de aplicações (`Super + Space`).

## X

O X é onde as notícias surgem.

Podes iniciar o X com `Super + Shift + X` e ires diretamente escrever uma nova publicação com `Super + Shift + Alt + X`.

## YouTube

O [YouTube](https://youtube.com/) é a plataforma de vídeo mais popular do mundo.

Podes iniciar o YouTube com `Super + Shift + Y`.

## Zoom

O [Zoom](https://zoom.us/) é o sistema de videochamada mais popular nos EUA. Ótimas ligações em todo o mundo. E podem fazer-se reuniões de 40 minutos sem uma conta paga. O Omarchy envolve o cliente web do Zoom, e as ligações de reuniões do Zoom abrem diretamente nele.

Inicias o Zoom usando o lançador de aplicações (`Super + Space`).

## Discord

O [Discord](https://discord.com/) é onde se juntam a maioria das comunidades de jogos e de open source, incluindo [a do próprio Omarchy](https://discord.gg/tXFUdasqhY).

Inicias o Discord usando o lançador de aplicações (`Super + Space`).

## Aplicações Microsoft

Seleciona _Instalar > Serviço > Microsoft_ para adicionares o Outlook, o Word, o Excel, o PowerPoint, o Teams e o OneDrive como aplicações web. Cada aplicação tem o seu próprio lançador e abre diretamente, usando os URL comerciais do Microsoft 365 e o teu perfil de navegador existente. Abrem nas mesmas janelas de aplicação de navegador que as outras aplicações web do Omarchy; não instalam o cliente Teams para Linux separado.

Remove o conjunto com _Remover > Serviço > Microsoft_, ou remove aplicações individuais com _Remover > App Web_. Também podes instalar apenas as aplicações que queres através de _Instalar > App Web_.

Para uma nuvem governamental ou soberana, edita o URL na linha `Exec=` no lançador relevante em `~/.local/share/applications/`, como `Microsoft Teams.desktop`, usando o URL fornecido pela tua organização. Escreve qualquer `%` literal nessa linha como `%%`. As alterações aplicam-se no próximo arranque. Executar outra vez o instalador do conjunto substitui os seus lançadores pelos URL predefinidos.

Para manteres os inícios de sessão de trabalho separados, acrescenta um diretório de dados do navegador à linha `Exec=` de cada lançador:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Substitui o diretório de exemplo por um caminho absoluto à tua escolha e usa o mesmo caminho para os seis lançadores, para partilhares os inícios de sessão de trabalho entre eles. As aplicações web usam o navegador suportado selecionado pelo Omarchy, recorrendo ao Chromium quando o navegador predefinido não é suportado.
