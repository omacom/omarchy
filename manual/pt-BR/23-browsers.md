# Navegadores

O Omarchy vem com o [Google Chrome](https://www.google.com/chrome/) como navegador padrão. Ele é tematizado para combinar com o resto do seu sistema, e é o que `Super + Shift + Return` (ou `Super + Shift + B`) abre, com `Super + Shift + Alt + B` para uma janela privada, e é dentro dele que todo [aplicativo web](25-web-apps.md) roda. Ele abre direto em uma janela do navegador: não há tela de boas-vindas nem solicitação de login, estatísticas de uso e relatórios de falhas não são enviados ao Google, e os avisos de privacidade de anúncios estão desativados. Você ainda pode entrar na sua conta do Google pelo botão de perfil sempre que quiser sincronização.

Se o Chrome não é do seu gosto, você não está preso a ele. Em _Install > Browser_ no menu do Omarchy você encontrará o [Chromium](https://www.chromium.org/) (a versão pura de código aberto da qual o Chrome é feito), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) e [Ladybird](https://ladybird.org/) (Edge apenas em máquinas x86). Escolha um e o Omarchy o instala, configura seu diretório de políticas e aplica seu tema atual a ele.

## Definindo um como padrão

Instalar um navegador não o promove. Para trocar, vá para _Setup > Defaults > Browser_ e escolha um. O padrão atual é marcado com uma marca de seleção, e escolher um navegador que você ainda não tem o instala primeiro.

Pelo terminal, é assim:

```bash
omarchy default browser firefox
```

Execute-o sem nenhum argumento e ele informa o padrão atual. Isso define o manipulador XDG, então não são apenas as teclas de atalho do Omarchy que acompanham — qualquer coisa que abra um link, de um aplicativo de bate-papo a um comando no terminal, vai para o navegador que você escolheu.

## Copy URL e Download Video

Os navegadores da família Chromium (o próprio Chromium, Chrome, Edge, Brave e Brave Origin) vêm com três extensões do Omarchy: duas que saem do navegador e alcançam o resto do seu sistema, e uma que organiza o WhatsApp.

**Copy URL** coloca o endereço da guia atual na sua área de transferência com `Alt + Shift + L`. Isso é mais rápido do que clicar na barra de endereços e copiar, e como passa pela área de transferência do sistema, e não pela do navegador, você recebe uma notificação do Omarchy confirmando e a URL fica imediatamente disponível no [histórico da área de transferência](08-unified-clipboard-history.md) e em todos os outros aplicativos. Há também um botão na barra de ferramentas, se você preferir clicar.

**Download Video** captura o vídeo em reprodução na página que você está vendo com `Alt + Shift + D`. Ele entrega a URL ao [yt-dlp](https://github.com/yt-dlp/yt-dlp), então funciona em muito mais do que apenas no YouTube, e o download vai parar em `~/Videos`. O progresso aparece na mesma exibição na tela que o volume e o brilho usam, atualizando no lugar em vez de empilhar notificações. Defina `OMARCHY_YTDLP_DIR` se preferir que os arquivos vão para outro lugar — veja o [FAQ](46-faq.md) para saber onde colocar variáveis de ambiente.

Ambas as extensões conversam com o Omarchy por meio de um pequeno host de mensagens nativo, que é instalado para você junto com o navegador. É essa peça que permite que o vídeo de uma página web acabe no seu diretório pessoal e que uma URL acabe no seu gerenciador de área de transferência, o que uma extensão normal não consegue fazer sozinha.

**WhatsApp Slim** faz o WhatsApp Web seguir o tema do seu sistema e recolhe sua lista de conversas quando a janela está estreita.

Essas são exclusivas da família Chromium. Firefox e Zen não as recebem.

## Firefox e Zen

Firefox e Zen são de uma família diferente, então recebem um tratamento diferente: o Omarchy instala um arquivo de políticas com padrões sensatos e os coloca no modo Wayland nativo, que você quer para escala fracionária e rolagem suave no trackpad.

Eles não recebem as extensões Chromium acima, e não são tematizados pelo Omarchy, então essas partes da experiência ficam por sua conta configurar.

## Ladybird

O Ladybird é um navegador escrito do zero, com seu próprio mecanismo em vez do do Chromium ou do Firefox. Ele ainda está em alfa, então espere sites que ainda não funcionam, e o Omarchy o instala como ele vem: sem extensões, sem tema, sem políticas. Ele também não tem janela privada, então `Super + Shift + Alt + B` o abre com um perfil temporário que é excluído quando você o fecha. Os [aplicativos web](25-web-apps.md) continuam rodando no Chrome ou no Chromium.

## Removendo um novamente

Qualquer um desses navegadores, incluindo o Chrome, pode ser removido novamente em _Remove > Browser_. Os links então vão para o Chrome ou o Chromium, se o outro ainda estiver instalado.
