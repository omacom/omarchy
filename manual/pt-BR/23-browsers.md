# Navegadores

O Omarchy vem com o [Google Chrome](https://www.google.com/chrome/) como navegador padrão. Ele é tematizado para combinar com o resto do seu sistema, e é ele que `Super + Shift + Return` (ou `Super + Shift + B`) abre, com `Super + Shift + Alt + B` para uma janela privativa, e é dentro dele que roda cada [aplicativo web](25-web-apps.md). Ele abre direto em uma janela do navegador: não há tela de boas-vindas nem pedido de login, as estatísticas de uso e os relatórios de falha não são enviados ao Google, e os avisos de privacidade de anúncios estão desligados. Você ainda pode entrar na sua conta do Google pelo botão de perfil quando quiser a sincronização.

Se o Chrome não for do seu gosto, você não está preso a ele. Em _Install > Browser_ no menu do Omarchy, você encontra o [Chromium](https://www.chromium.org/) (a versão simples e de código aberto a partir da qual o Chrome é feito), Edge, Brave, Brave Origin, Firefox e [Zen](https://zen-browser.app/) (Edge somente em máquinas x86). Escolha um e o Omarchy o instala, configura o diretório de políticas dele e aplica o seu tema atual a ele.

## Tornando um deles o padrão

Instalar um navegador não o promove. Para trocar, vá até _Setup > Defaults > Browser_ e escolha um. O padrão atual é marcado com um sinal de verificação, e escolher um navegador que você ainda não tem o instala primeiro.

Pelo terminal, é:

```bash
omarchy default browser firefox
```

Execute-o sem nenhum argumento e ele informa o padrão atual. Isso define o manipulador XDG, então não são só os atalhos do Omarchy que acompanham — qualquer coisa que abra um link, de um aplicativo de chat a um comando no terminal, vai para o navegador que você escolheu.

## Copy URL e Download Video

Os navegadores da família Chromium (o próprio Chromium, Chrome, Edge, Brave e Brave Origin) vêm com três extensões do Omarchy: duas que saem do navegador e alcançam o resto do seu sistema, e uma que organiza o WhatsApp.

**Copy URL** coloca o endereço da aba atual na sua área de transferência com `Alt + Shift + L`. Isso é mais rápido do que clicar na barra de endereços e copiar, e, como passa pela área de transferência do sistema em vez da do navegador, você recebe uma notificação do Omarchy confirmando, e o URL fica imediatamente disponível no [histórico unificado da área de transferência](08-unified-clipboard-history.md) e em todos os outros aplicativos. Há também um botão na barra de ferramentas, se você preferir clicar.

**Download Video** pega o vídeo em reprodução na página que você está vendo com `Alt + Shift + D`. Ele entrega o URL ao [yt-dlp](https://github.com/yt-dlp/yt-dlp), então funciona em muito mais lugares do que só no YouTube, e o download vai parar em `~/Videos`. O progresso aparece na mesma exibição na tela que o volume e o brilho usam, atualizando no lugar em vez de acumular notificações. Defina `OMARCHY_YTDLP_DIR` se preferir que os arquivos vão para outro lugar — veja o [FAQ](46-faq.md) para saber onde colocar variáveis de ambiente.

As duas extensões conversam com o Omarchy por meio de um pequeno host de mensagens nativas, que é instalado para você junto com o navegador. É essa peça que permite que o vídeo de uma página web acabe no seu diretório pessoal e que um URL acabe no seu gerenciador de área de transferência, algo que uma extensão normal não consegue fazer sozinha.

**WhatsApp Slim** faz o WhatsApp Web seguir o tema do seu sistema e recolhe a lista de conversas dele quando a janela é estreita.

Essas são exclusivas da família Chromium. Firefox e Zen não as recebem.

## Firefox e Zen

Firefox e Zen são de outra família, então recebem um tratamento diferente: o Omarchy instala um arquivo de políticas com padrões sensatos e os coloca no modo Wayland nativo, que é o que você quer para escala fracionária e rolagem suave no trackpad.

Eles não recebem as extensões Chromium acima e não são tematizados pelo Omarchy, então essas partes da experiência ficam por sua conta para configurar.

## Removendo um de novo

Qualquer um desses navegadores, incluindo o Chrome, pode ser removido de novo em _Remove > Browser_. Os links então vão para o Chrome ou o Chromium, se o outro ainda estiver instalado.
