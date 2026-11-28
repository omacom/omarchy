# Navegadores

O Omarchy vem com o [Google Chrome](https://www.google.com/chrome/) como navegador predefinido. Tem um tema a condizer com o resto do sistema, e é o que `Super + Shift + Return` (ou `Super + Shift + B`) abre, com `Super + Shift + Alt + B` para uma janela privada, e é dentro dele que corre cada [aplicação web](25-web-apps.md). Abre diretamente numa janela do navegador: não há ecrã de boas-vindas nem pedido para iniciar sessão, as estatísticas de utilização e os relatórios de falhas não são enviados para a Google, e os pedidos relativos à privacidade dos anúncios estão desativados. Ainda pode iniciar sessão na sua conta Google a partir do botão de perfil sempre que quiser sincronização.

Se o Chrome não for do seu agrado, não está preso a ele. Em _Instalar > Navegador_ no menu do Omarchy encontra o [Chromium](https://www.chromium.org/) (a compilação simples de código aberto a partir da qual o Chrome é feito), o Edge, o Brave, o Brave Origin, o Firefox e o [Zen](https://zen-browser.app/) (Edge apenas em máquinas x86). Escolha um e o Omarchy instala-o, configura o respetivo diretório de políticas e aplica-lhe o seu tema atual.

## Definir um como predefinido

Instalar um navegador não o promove a predefinido. Para mudar, vá a _Configuração > Predefinições > Navegador_ e escolha um. O predefinido atual está assinalado com um visto, e escolher um navegador que ainda não tem instala-o primeiro.

A partir do terminal, é:

```bash
omarchy default browser firefox
```

Execute-o sem argumentos e ele indica-lhe o predefinido atual. Isto define o gestor XDG, por isso não são só os atalhos do Omarchy que acompanham a mudança — tudo o que abrir uma ligação, desde uma aplicação de chat a um comando no terminal, vai para o navegador que escolheu.

## Copiar URL e Descarregar Vídeo

Os navegadores da família Chromium (o próprio Chromium, o Chrome, o Edge, o Brave e o Brave Origin) trazem três extensões do Omarchy: duas que saem do navegador e chegam ao resto do sistema, e uma que arruma o WhatsApp.

**Copy URL** coloca o endereço do separador atual na área de transferência com `Alt + Shift + L`. É mais rápido do que clicar na barra de endereços e copiar, e como passa pela área de transferência do sistema e não pela do navegador, recebe uma notificação do Omarchy a confirmar e o URL fica imediatamente disponível no [histórico da área de transferência](08-unified-clipboard-history.md) e em todas as outras aplicações. Também há um botão na barra de ferramentas, se preferir clicar.

**Download Video** capta o vídeo que está a ser reproduzido na página que está a ver com `Alt + Shift + D`. Entrega o URL ao [yt-dlp](https://github.com/yt-dlp/yt-dlp), por isso funciona em muito mais do que o YouTube, e o ficheiro descarregado vai parar a `~/Videos`. O progresso aparece no mesmo indicador no ecrã que o volume e o brilho utilizam, a atualizar-se no local em vez de acumular notificações. Defina `OMARCHY_YTDLP_DIR` se preferir que os ficheiros vão para outro local — consulte as [FAQ](46-faq.md) para saber onde colocar as variáveis de ambiente.

As duas extensões comunicam com o Omarchy através de um pequeno anfitrião nativo de mensagens, que é instalado por si juntamente com o navegador. É essa peça que permite que o vídeo de uma página web acabe no seu diretório pessoal e que um URL acabe no seu gestor da área de transferência, algo que uma extensão normal não consegue fazer sozinha.

**WhatsApp Slim** faz com que o WhatsApp Web siga o tema do sistema e recolhe a lista de conversas quando a janela é estreita.

Estas são exclusivas da família Chromium. O Firefox e o Zen não as recebem.

## Firefox e Zen

O Firefox e o Zen pertencem a outra família, por isso recebem um tratamento diferente: o Omarchy instala um ficheiro de políticas com predefinições sensatas e coloca-os em modo Wayland nativo, que é o que quer para a escala fracionária e para um deslocamento suave no trackpad.

Não recebem as extensões Chromium acima e não recebem um tema do Omarchy, por isso essas partes da experiência ficam por sua conta configurar.

## Voltar a remover um

Qualquer um destes navegadores, incluindo o Chrome, pode voltar a ser removido em _Remover > Navegador_. As ligações passam então para o Chrome ou para o Chromium, se o outro ainda estiver instalado.
