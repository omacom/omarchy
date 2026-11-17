# Navegadores

O Omarchy vem com o [Google Chrome](https://www.google.com/chrome/) como navegador predefinido. Tem um tema a condizer com o resto do sistema, e é o que `Super + Shift + Return` abre e dentro do qual é executada cada [aplicação web](25-web-apps.md). Abre diretamente numa janela do navegador: não há ecrã de boas-vindas nem pedido para iniciar sessão, as estatísticas de utilização e os relatórios de falhas não são enviados para a Google, e os pedidos de privacidade publicitária estão desligados. Continua a poder iniciar sessão na sua conta Google a partir do botão de perfil sempre que quiser sincronização.

Se o Chrome não é do seu gosto, não está preso a ele. Em _Install > Browser_ no menu do Omarchy vai encontrar o [Chromium](https://www.chromium.org/) (a versão simples e de código aberto a partir da qual o Chrome é feito), Edge, Brave, Brave Origin, Firefox, e [Zen](https://zen-browser.app/). Escolha um e o Omarchy instala-o, configura o respetivo diretório de políticas, e aplica-lhe o seu tema atual.

## Tornar um deles o predefinido

Instalar um navegador não o promove. Depois de ele estar na máquina, vá a _Setup > Defaults > Browser_ e escolha-o — o menu só lista os navegadores que tem efetivamente instalados, e marca o predefinido atual com um visto.

A partir do terminal é:

```bash
omarchy default browser firefox
```

Execute-o sem argumento e ele indica-lhe o predefinido atual. Isto define o gestor XDG, por isso não são só os atalhos de teclado do Omarchy a acompanhar — tudo o que abrir uma ligação, de uma aplicação de conversa a um comando no terminal, vai para o navegador que escolheu.

## Copy URL e Download Video

Os navegadores da família Chromium (o próprio Chromium, Chrome, Edge, e Brave) vêm com duas extensões do Omarchy que vão para lá do navegador e chegam ao resto do sistema.

**Copy URL** coloca o endereço do separador atual na sua área de transferência com `Alt + Shift + L`. É mais rápido do que clicar na barra de endereços e copiar, e como passa pela área de transferência do sistema em vez de pela do navegador, recebe uma notificação do Omarchy a confirmá-lo e o URL fica imediatamente disponível no [histórico da área de transferência](08-unified-clipboard-history.md) e em todas as outras aplicações. Também há um botão na barra de ferramentas, se preferir clicar.

**Download Video** obtém o vídeo que está a ser reproduzido na página que está a ver com `Alt + Shift + D`. Passa o URL ao [yt-dlp](https://github.com/yt-dlp/yt-dlp), por isso funciona em muito mais do que o YouTube, e a transferência vai parar a `~/Videos`. O progresso aparece no mesmo indicador no ecrã que o volume e a luminosidade usam, a atualizar no local em vez de acumular notificações. Defina `OMARCHY_YTDLP_DIR` se preferir que os ficheiros vão para outro sítio — consulte as [FAQ](46-faq.md) para saber onde colocar as variáveis de ambiente.

Ambas as extensões comunicam com o Omarchy através de um pequeno anfitrião de mensagens nativo, que é instalado por si juntamente com o navegador. É essa a peça que permite que o vídeo de uma página web acabe no seu diretório pessoal e que um URL acabe no seu gestor da área de transferência, algo que uma extensão normal não consegue fazer sozinha.

Estas são exclusivas da família Chromium. O Firefox e o Zen não as recebem.

## Firefox e Zen

O Firefox e o Zen são de uma família diferente, por isso recebem um tratamento diferente: o Omarchy instala um ficheiro de políticas para predefinições sensatas e coloca-os em modo Wayland nativo, que é o que quer para escala fracionária e para um deslocamento suave no trackpad.

Não recebem as extensões Chromium acima, e não têm um tema aplicado pelo Omarchy, por isso essas partes da experiência ficam por sua conta para configurar.

## Voltar a remover um

Qualquer um destes navegadores, incluindo o Chrome, pode voltar a ser retirado em _Remove > Browser_. As ligações passam então para o Chrome ou para o Chromium, se o outro ainda estiver instalado.
