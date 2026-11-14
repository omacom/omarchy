# Navegadores

O Omarchy vem com o [Google Chrome](https://www.google.com/chrome/) como navegador padrão. Ele recebe um tema que combina com o resto do sistema, é o que `Super + Shift + Return` abre e é dentro dele que todo [aplicativo web](25-web-apps.md) roda. Ele abre direto em uma janela do navegador: não há tela de boas-vindas nem solicitação de login, as estatísticas de uso e os relatórios de falhas não são enviados ao Google e os avisos de privacidade de anúncios ficam desativados. Você ainda pode entrar na sua conta do Google pelo botão de perfil sempre que quiser sincronizar.

Se o Chrome não for do seu gosto, você não está preso a ele. Em _Instalar > Navegador_, no menu do Omarchy, você encontra o [Chromium](https://www.chromium.org/) (a versão pura e de código aberto a partir da qual o Chrome é feito), o Edge, o Brave, o Brave Origin, o Firefox e o [Zen](https://zen-browser.app/). Escolha um e o Omarchy o instala, configura seu diretório de políticas e aplica seu tema atual a ele.

## Tornando um deles o padrão

Instalar um navegador não o promove. Depois que ele estiver na máquina, vá para _Configuração > Padrões > Navegador_ e escolha-o — o menu só lista os navegadores que você realmente tem instalados e marca o padrão atual com uma marca de seleção.

Pelo terminal, é assim:

```bash
omarchy default browser firefox
```

Execute-o sem nenhum argumento e ele informa o padrão atual. Isso define o manipulador XDG, então não são só os atalhos do Omarchy que acompanham — qualquer coisa que abra um link, de um aplicativo de bate-papo a um comando no terminal, vai para o navegador que você escolheu.

## Copiar URL e Baixar Vídeo

Os navegadores da família Chromium (o próprio Chromium, o Chrome, o Edge e o Brave) vêm com duas extensões do Omarchy que alcançam além do navegador e chegam ao resto do sistema.

**Copiar URL** coloca o endereço da guia atual na sua área de transferência com `Alt + Shift + L`. Isso é mais rápido do que clicar na barra de endereços e copiar e, como passa pela área de transferência do sistema e não pela do navegador, você recebe uma notificação do Omarchy confirmando e a URL fica imediatamente disponível no [histórico da área de transferência](08-unified-clipboard-history.md) e em todos os outros aplicativos. Também há um botão na barra de ferramentas, se você preferir clicar.

**Baixar Vídeo** pega o vídeo em reprodução na página que você está vendo com `Alt + Shift + D`. Ele entrega a URL ao [yt-dlp](https://github.com/yt-dlp/yt-dlp), então funciona em muito mais lugares além do YouTube, e o download vai para `~/Videos`. O progresso aparece no mesmo indicador na tela que o volume e o brilho usam, atualizando no lugar em vez de empilhar notificações. Defina `OMARCHY_YTDLP_DIR` se preferir que os arquivos vão para outro lugar — veja o [FAQ](46-faq.md) para saber onde colocar variáveis de ambiente.

As duas extensões se comunicam com o Omarchy por meio de um pequeno host de mensagens nativo, que é instalado para você junto com o navegador. É essa peça que permite que o vídeo de uma página web acabe no seu diretório pessoal e que uma URL acabe no seu gerenciador de área de transferência, algo que uma extensão normal não consegue fazer sozinha.

Elas são exclusivas da família Chromium. O Firefox e o Zen não as recebem.

## Firefox e Zen

O Firefox e o Zen são de outra família, então recebem um tratamento diferente: o Omarchy instala um arquivo de políticas com padrões sensatos e os coloca no modo Wayland nativo, que é o que você quer para escala fracionária e rolagem suave no trackpad.

Eles não recebem as extensões do Chromium acima e não recebem tema do Omarchy, então essas partes da experiência ficam por sua conta para configurar.

## Removendo um deles novamente

Qualquer um desses navegadores, incluindo o Chrome, pode ser removido em _Remover > Navegador_. Os links então vão para o Chrome ou o Chromium, se o outro ainda estiver instalado.
