# Navegadores

O Omarchy vem com o [Chromium](https://www.chromium.org/) como navegador padrão. É a compilação simples de código aberto, tematizada para combinar com o restante do seu sistema, e é o que `Super + Shift + Return` abre e dentro do qual todos os [aplicativos web](25-web-apps.md) são executados.

Se o Chromium não for do seu gosto, você não está preso a ele. Em _Instalar > Navegador_ no menu do Omarchy, você encontrará Chrome, Edge, Brave, Brave Origin, Firefox e [Zen](https://zen-browser.app/). Escolha um e o Omarchy o instala, configura seu diretório de políticas e aplica seu tema atual a ele.

## Tornando um deles o padrão

Instalar um navegador não o promove. Depois que ele estiver na máquina, vá a _Setup > Defaults > Browser_ e escolha-o — o menu só lista os navegadores que você realmente tem instalados e marca o padrão atual com uma marca de seleção.

Pelo terminal, é:

```bash
omarchy default browser firefox
```

Execute-o sem argumento e ele informa o padrão atual. Isso define o manipulador XDG, então não são apenas os atalhos do Omarchy que acompanham — qualquer coisa que abra um link, de um aplicativo de chat a um comando de terminal, vai para o navegador que você escolheu.

## Copiar URL e baixar vídeo

Os navegadores da família Chromium (o próprio Chromium, Chrome, Edge e Brave) vêm com duas extensões do Omarchy que saem do navegador e alcançam o resto do seu sistema.

**Copy URL** coloca o endereço da guia atual na sua área de transferência com `Alt + Shift + L`. Isso é mais rápido do que clicar na barra de endereço e copiar e, como ele passa pela área de transferência do sistema em vez da do navegador, você recebe uma notificação do Omarchy confirmando e a URL fica imediatamente disponível no [histórico da área de transferência](08-unified-clipboard-history.md) e em todos os outros aplicativos. Há também um botão na barra de ferramentas, se você preferir clicar.

**Download Video** captura o vídeo em reprodução na página que você está vendo com `Alt + Shift + D`. Ele entrega a URL ao [yt-dlp](https://github.com/yt-dlp/yt-dlp), então funciona em muito mais do que o YouTube, e o download vai para `~/Videos`. O progresso aparece na mesma exibição na tela que volume e brilho usam, atualizando no local em vez de empilhar notificações. Defina `OMARCHY_YTDLP_DIR` se você preferir que os arquivos vão para outro lugar — consulte as [perguntas frequentes](46-faq.md) para saber onde colocar as variáveis de ambiente.

As duas extensões conversam com o Omarchy por meio de um pequeno host de mensagens nativas, que é instalado para você junto com o navegador. É essa a peça que permite que o vídeo de uma página web acabe no seu diretório inicial e uma URL acabe no seu gerenciador de área de transferência, algo que uma extensão normal não consegue fazer sozinha.

Esses recursos são só para a família Chromium. Firefox e Zen não os recebem.

## Firefox e Zen

Firefox e Zen são de outra família, então recebem um tratamento diferente: o Omarchy instala um arquivo de políticas para padrões sensatos e os coloca em modo Wayland nativo, que é o que você quer para dimensionamento fracionário e rolagem suave no trackpad.

Eles não recebem as extensões do Chromium acima, nem são tematizados pelo Omarchy, então essas partes da experiência ficam por sua conta configurar.

## Removendo um deles de novo

Qualquer coisa que você instalou aqui pode ser removida de volta em _Remover > Navegador_. O Chromium não está nessa lista — ele faz parte do sistema base.
