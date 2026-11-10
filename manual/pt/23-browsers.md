# Navegadores

O Omarchy vem com o [Chromium](https://www.chromium.org/) como navegador predefinido. É a compilação open source simples, com tema a condizer com o resto do teu sistema, e é o que `Super + Shift + Return` abre e aquilo dentro do qual corre cada [aplicação web](25-web-apps.md).

Se o Chromium não for do teu agrado, não ficas preso a ele. Em _Instalar > Navegador_ no menu Omarchy encontras o Chrome, o Edge, o Brave, o Brave Origin, o Firefox e o [Zen](https://zen-browser.app/). Escolhe um e o Omarchy instala-o, configura o seu diretório de políticas e aplica-lhe o teu tema atual.

## Tornar um deles o predefinido

Instalar um navegador não o promove. Depois de ele estar na máquina, vai a _Configurar > Predefinições > Navegador_ e escolhe-o — o menu só lista os navegadores que realmente tens instalados e marca o predefinido atual com um visto.

A partir do terminal, é:

```bash
omarchy default browser firefox
```

Executa-o sem argumento e ele diz-te qual é o predefinido atual. Isto define o processador XDG, por isso não são só os atalhos do Omarchy que acompanham — tudo o que abre uma ligação, de uma aplicação de chat a um comando de terminal, vai para o navegador que escolheste.

## Copiar URL e Transferir Vídeo

Os navegadores da família Chromium (o próprio Chromium, o Chrome, o Edge e o Brave) trazem duas extensões do Omarchy que saem do navegador e entram no resto do teu sistema.

**Copiar URL** coloca o endereço do separador atual na tua área de transferência com `Alt + Shift + L`. É mais rápido do que clicar na barra de endereços e copiar e, como passa pela área de transferência do sistema em vez da do navegador, recebes uma notificação do Omarchy a confirmá-lo e o URL fica imediatamente disponível no [histórico da área de transferência](08-unified-clipboard-history.md) e em todas as outras aplicações. Também há um botão na barra de ferramentas, se preferires clicar.

**Transferir Vídeo** obtém o vídeo que está a ser reproduzido na página que estás a ver com `Alt + Shift + D`. Entrega o URL ao [yt-dlp](https://github.com/yt-dlp/yt-dlp), por isso funciona em muito mais do que o YouTube, e a transferência vai parar a `~/Videos`. O progresso aparece na mesma apresentação no ecrã que o volume e o brilho usam, atualizando-se no local em vez de acumular notificações. Define `OMARCHY_YTDLP_DIR` se preferires que os ficheiros vão para outro sítio — vê as [Perguntas frequentes](46-faq.md) para saberes onde colocar as variáveis de ambiente.

Ambas as extensões falam com o Omarchy através de um pequeno anfitrião de mensagens nativas, que é instalado por ti juntamente com o navegador. É essa peça que permite que o vídeo de uma página web acabe no teu diretório pessoal e que um URL acabe no teu gestor da área de transferência, algo que uma extensão normal não consegue fazer sozinha.

Estas são exclusivas da família Chromium. O Firefox e o Zen não as recebem.

## Firefox e Zen

O Firefox e o Zen são de uma família diferente, por isso recebem um tratamento diferente: o Omarchy instala um ficheiro de políticas para predefinições sensatas e coloca-os em modo Wayland nativo, que é o que queres para escalonamento fracionário e deslocamento suave com o painel tátil.

Não recebem as extensões Chromium acima, nem são tematizados pelo Omarchy, por isso essas partes da experiência ficam por tua conta.

## Remover um deles outra vez

Tudo o que instalaste aqui pode ser retirado outra vez em _Remover > Navegador_. O Chromium não está nessa lista — faz parte do sistema base.
