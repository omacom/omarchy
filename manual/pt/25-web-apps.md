# Aplicações Web

Pode adicionar as suas próprias aplicações web através de _Install > Web App_ no menu Omarchy (`Super + Space`). Vai pedir-lhe o nome da aplicação, o URL da aplicação e o URL do ícone, caso não consiga obtê-lo através do favicon. Pode obter excelentes ícones PNG para muitas aplicações web populares em [Dashboard Icons](https://dashboardicons.com).

Ficarão depois acessíveis através do lançador de aplicações (`Super + Space`) e utilizam a bonita janela de aplicação web sem moldura.

Se quiser remover uma aplicação web, basta ir a _Remove > Web App_ no menu Omarchy.

O melhor é iniciar sessão em todas as suas contas com um navegador normal antes de utilizar os atalhos das aplicações web. A fina moldura envolvente não funciona bem com o 1password, por isso é simplesmente mais fácil ter a sessão iniciada diretamente primeiro.

Todos os atalhos de teclado destas aplicações web podem ser alterados em `~/.config/hypr/bindings.lua`.

Quando estiver numa aplicação web, pode copiar o URL atual para a área de transferência com `Shift + Alt + L`.

Por predefinição, o Omarchy já inclui um conjunto de aplicações predefinidas:

## HEY

O [HEY](https://www.hey.com/) é um serviço de e-mail e calendário que funciona como uma excelente alternativa para quem está farto do Gmail, do Outlook ou do Apple Mail. É desenvolvido pela [37signals](https://37signals.com/) onde o Omarchy teve origem.

Pode iniciar o HEY Email com `Super + Shift + E`, ir diretamente para a composição de um novo e-mail com `Super + Shift + Alt + E` e iniciar o HEY Calendar com `Super + Shift + C`.

## Basecamp

O [Basecamp](https://basecamp.com/) é um serviço de gestão de projetos que ajuda pequenas equipas a avançar mais depressa e a fazer mais progressos. Em vez de remendar uma mistura de Trello, Slack, Asana, Notion ou o que for, pode ter tudo num só lugar com o Basecamp. É desenvolvido pela [37signals](https://37signals.com/) onde o Omarchy teve origem.

Pode iniciar o Basecamp através do lançador de aplicações (`Super + Space`)

## ChatGPT

O [ChatGPT](https://chatgpt.com) é o chatbot de IA mais popular do mundo.

Pode iniciar o ChatGPT com `Super + Shift + A`.

## Grok

O [Grok](https://grok.com) é o chatbot da xAI.

Pode iniciar o Grok com `Super + Shift + Alt + A`.

## WhatsApp

O [WhatsApp](https://www.whatsapp.com/) é um dos serviços de mensagens mais populares do mundo, e a versão web é uma excelente opção para Linux.

Pode iniciar o WhatsApp com `Super + Shift + Alt + G`.

## Aplicações Google

O Google Messages, o Google Photos, o Google Maps e o Google Contacts também estão incluídos como aplicações web.

Pode iniciar o Google Messages com `Super + Shift + Ctrl + G`, o Google Photos com `Super + Shift + P` e o Google Maps com `Super + Shift + S`. O Google Contacts está disponível através do lançador de aplicações (`Super + Space`).

## X

É no X que surgem as notícias.

Pode iniciar o X com `Super + Shift + X` e ir diretamente escrever uma nova publicação com `Super + Shift + Alt + X`.

## YouTube

O [YouTube](https://youtube.com/) é a plataforma de vídeo mais popular do mundo.

Pode iniciar o YouTube com `Super + Shift + Y`.

## Zoom

O [Zoom](https://zoom.us/) é o sistema de videochamada mais popular utilizado nos EUA. Excelentes ligações em todo o mundo. E é possível realizar reuniões de 40 minutos sem uma conta paga. O Omarchy envolve o cliente web do Zoom, e as ligações para reuniões do Zoom abrem diretamente nele.

Inicia o Zoom através do lançador de aplicações (`Super + Space`).

## Discord

O [Discord](https://discord.com/) é onde se reúne a maioria das comunidades de gaming e de open source, incluindo [a do próprio Omarchy](https://discord.gg/tXFUdasqhY).

Inicia o Discord através do lançador de aplicações (`Super + Space`).

## Aplicações Microsoft

Selecione _Install > Service > Microsoft_ para adicionar o Outlook, o Word, o Excel, o PowerPoint, o Teams e o OneDrive como aplicações web. Cada aplicação tem o seu próprio lançador e abre diretamente, com os URL comerciais do Microsoft 365 e o seu perfil de navegador existente. Abrem nas mesmas janelas de aplicação de navegador que as outras aplicações web do Omarchy; não instalam o cliente separado Teams for Linux.

Remova o conjunto com _Remove > Service > Microsoft_, ou remova aplicações individuais com _Remove > Web App_. Também pode instalar apenas as aplicações que quiser através de _Install > Web App_.

Para uma cloud governamental ou soberana, edite o URL na linha `Exec=` no lançador relevante em `~/.local/share/applications/`, como `Microsoft Teams.desktop`, com o URL fornecido pela sua organização. Escreva qualquer `%` literal nessa linha como `%%`. As alterações aplicam-se no próximo arranque. Executar novamente o instalador do conjunto substitui os respetivos lançadores pelos URL predefinidos.

Para manter as sessões de trabalho separadas, acrescente um diretório de dados do navegador à linha `Exec=` de cada lançador:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Substitua o diretório de exemplo por um caminho absoluto à sua escolha e utilize o mesmo caminho para os seis lançadores, para partilhar as sessões de trabalho entre eles. As aplicações web utilizam o navegador suportado selecionado do Omarchy, com recurso ao Chrome quando o navegador predefinido não é suportado.
