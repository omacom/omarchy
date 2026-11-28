# Navegadores

O Omarchy vem com o [Google Chrome](https://www.google.com/chrome/) como navegador predefinido. Tem um tema a condizer com o resto do sistema e é o que `Super + Shift + Return` (ou `Super + Shift + B`) abre, com `Super + Shift + Alt + B` para uma janela privada, e onde corre cada [aplicação web](25-web-apps.md). Abre diretamente numa janela do navegador: não há ecrã de boas-vindas nem pedido de início de sessão, as estatísticas de utilização e os relatórios de falhas não são enviados para a Google e os pedidos de privacidade relativos a anúncios estão desativados. Continua a poder iniciar sessão na sua conta Google a partir do botão de perfil sempre que quiser sincronização.

Se o Chrome não for do seu gosto, não está preso a ele. Em _Install > Browser_, no menu do Omarchy, encontra o [Chromium](https://www.chromium.org/) (a versão simples de código aberto a partir da qual o Chrome é feito), o Edge, o Brave, o Brave Origin, o Firefox, o [Zen](https://zen-browser.app/) e o [Ladybird](https://ladybird.org/) (o Edge apenas em máquinas x86). Escolha um e o Omarchy instala-o, configura o respetivo diretório de políticas e aplica-lhe o seu tema atual.

## Tornar um deles o predefinido

Instalar um navegador não o promove. Para mudar, vá a _Setup > Defaults > Browser_ e escolha um. O predefinido atual está assinalado com um visto, e escolher um navegador que ainda não tem instala-o primeiro.

A partir do terminal, é:

```bash
omarchy default browser firefox
```

Execute-o sem qualquer argumento e ele indica-lhe o predefinido atual. Isto define o gestor XDG, por isso não são apenas as teclas de atalho do Omarchy a acompanhar — tudo o que abre uma ligação, de uma aplicação de conversa a um comando no terminal, vai para o navegador que escolheu.

## Copiar URL e transferir vídeo

Os navegadores da família Chromium (o próprio Chromium, o Chrome, o Edge, o Brave e o Brave Origin) vêm com três extensões do Omarchy: duas que saem do navegador e chegam ao resto do sistema, e uma que arruma o WhatsApp.

**Copy URL** coloca o endereço do separador atual na área de transferência com `Alt + Shift + L`. É mais rápido do que clicar na barra de endereços e copiar, e como passa pela área de transferência do sistema em vez da do navegador, recebe uma notificação do Omarchy a confirmar e o URL fica imediatamente disponível no [histórico da área de transferência](08-unified-clipboard-history.md) e em todas as outras aplicações. Há também um botão na barra de ferramentas, se preferir clicar.

**Download Video** obtém o vídeo que está a ser reproduzido na página que está a ver com `Alt + Shift + D`. Entrega o URL ao [yt-dlp](https://github.com/yt-dlp/yt-dlp), por isso funciona em muito mais do que o YouTube, e a transferência vai parar a `~/Videos`. O progresso aparece no mesmo indicador no ecrã que o volume e o brilho utilizam, a atualizar no local em vez de acumular notificações. Defina `OMARCHY_YTDLP_DIR` se preferir que os ficheiros vão para outro lado — veja as [FAQ](46-faq.md) para saber onde colocar as variáveis de ambiente.

Ambas as extensões falam com o Omarchy através de um pequeno anfitrião de mensagens nativas, que lhe é instalado juntamente com o navegador. É essa a peça que permite que um vídeo de uma página web acabe no seu diretório pessoal e que um URL acabe no seu gestor da área de transferência, o que uma extensão normal não consegue fazer sozinha.

**WhatsApp Slim** faz com que o WhatsApp Web siga o tema do seu sistema e recolhe a respetiva lista de conversas quando a janela é estreita.

Estas são apenas para a família Chromium. O Firefox e o Zen não as recebem.

## Firefox e Zen

O Firefox e o Zen são de uma família diferente, por isso recebem um tratamento diferente: o Omarchy instala um ficheiro de políticas para predefinições sensatas e coloca-os em modo Wayland nativo, que é o que quer para o escalonamento fracionário e para um deslocamento suave no trackpad.

Não recebem as extensões Chromium acima e não têm um tema aplicado pelo Omarchy, por isso essas partes da experiência ficam por sua conta.

## Ladybird

O Ladybird é um navegador escrito de raiz, com o seu próprio motor em vez do motor do Chromium ou do Firefox. Ainda está em alfa, por isso conte com sites que ainda não funcionam, e o Omarchy instala-o tal como vem: sem extensões, sem tema, sem políticas. Também não tem janela privada, por isso `Super + Shift + Alt + B` abre-o com um perfil temporário que é eliminado quando o fecha. As [aplicações web](25-web-apps.md) continuam a correr no Chrome ou no Chromium.

## Remover um deles outra vez

Qualquer um destes navegadores, incluindo o Chrome, pode ser removido em _Remove > Browser_. As ligações passam então para o Chrome ou para o Chromium, se o outro ainda estiver instalado.
