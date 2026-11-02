# Navegação

Tudo no Omarchy acontece pelo teclado — _TUDO!_ Quando o sistema inicia pela primeira vez, você literalmente não consegue fazer nada só com o mouse. Mas você pode pressionar `Super + Space` para revelar o Menu do Omarchy e, a partir daí, pode fazer praticamente tudo.

Mas o menu do Omarchy nem sequer foi pensado para ser a principal forma de operar o sistema na maior parte do tempo. Dá para ser mais rápido que isso! Todos os aplicativos mais importantes estão vinculados diretamente a teclas de atalho individuais. Você abre o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Experimente fazer um depois do outro e você verá a mágica do tiling do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Você pode então pressionar `Super + J` para empilhá-los um sobre o outro em vez de lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Pressione `Super + J` novamente para retorná-los às suas posições lado a lado. Depois experimente `Super + Shift + Arrow Right` enquanto estiver no navegador para trocar as janelas.

Agora experimente `Super + Shift + T` para abrir o monitor de atividades. Ele aparecerá como uma janela flutuante. Você pode colocá-lo em mosaico usando `Super + T` (e pressionar isso novamente para torná-lo flutuante de novo). Agora pressione `Super + Shift + F` para abrir o gerenciador de arquivos. Você terá uma bela configuração em quatro partes:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Você navega entre a janela que quer ativar com `Super + Arrow`. Isso mudará o foco e moverá o cursor para o centro do novo aplicativo. Na borda de uma tela, ele continua para o monitor daquele lado.

Se você pressionar `Super + Shift + 2`, moverá o aplicativo atualmente em foco para a segunda área de trabalho. `Super + Shift + 1` o move de volta. (E `Super + Shift + Alt + 2` moverá o aplicativo atualmente em foco para a segunda área de trabalho sem mudar para ela.)

Com mais de um monitor, cada monitor tem suas próprias áreas de trabalho de 1 a 10. `Super + 2` vai para a segunda área de trabalho do monitor em que você está, e a barra superior de cada monitor mostra suas próprias áreas de trabalho e aquela que ele está exibindo. `Super + Tab` alterna entre as áreas de trabalho do monitor em que você está. `Super + Shift + Ctrl + Arrows` move a janela em que você está para o monitor naquela direção, para a área de trabalho que ele está exibindo, e `Super + Shift + Alt + Arrows` move a área de trabalho em que você está para o monitor naquela direção, onde ela assume o mesmo número se estiver livre. Um monitor mantém suas áreas de trabalho quando você o desconecta: elas se juntam às de outra tela, numeradas depois das que ela já tem, e voltam aos seus números antigos quando o monitor retorna.

Se você mantiver `Super` pressionado e usar o mouse para clicar em uma janela, poderá reorganizar onde ela fica. Se você mantiver `Super` pressionado e usar o botão direito do mouse, poderá redimensionar a janela livremente.

Você fecha uma janela com `Super + W` ou `Super + Q` (e fecha todas as janelas com `Ctrl + Alt + Delete`).

Você também pode entrar em tela cheia com `Super + F` ou até mesmo apenas em largura total (mantendo a barra superior) com `Super + Alt + F` ou em tela cheia dentro de uma janela com `Super + Ctrl + F` (ótimo para o YouTube!).

### Layout dwindle vs. de rolagem

O layout padrão do Omarchy é chamado de dwindle. Ele mantém todas as janelas que você abre em uma única área de trabalho visíveis o tempo todo, mesmo que precise encolhê-las.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas você também pode optar por transformar uma área de trabalho no layout de rolagem, onde as janelas são alinhadas lado a lado, além da borda visível da tela. Você transforma uma única área de trabalho nesse layout via `Super + L`.

Pressionar `Super + L` novamente torna a área de trabalho flutuante, onde as janelas se sobrepõem livremente e você as posiciona por conta própria, e uma terceira pressão retorna ao dwindle. `Super + Alt + L` percorre os layouts na direção oposta. Uma janela que já é flutuante de qualquer forma — uma que você destacou com `Super + T`, ou um aplicativo que sempre abre flutuante — continua flutuante quando a área de trabalho volta ao mosaico. A barra superior marca a área de trabalho em que você está com seu layout: um quadrado para dwindle, um círculo para rolagem e um triângulo para flutuante. Clicar nessa marca também alterna o layout.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por área de trabalho e ela persiste. Assim, você pode manter a área de trabalho 1 em dwindle para navegação e a área de trabalho 2 em rolagem para código, e elas voltarão dessa forma após uma reinicialização.

Se você quiser usar o layout de rolagem como padrão, pode definir isso em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Áreas de trabalho flutuantes

Uma área de trabalho flutuante funciona como uma área de trabalho tradicional: as janelas se sobrepõem, e você as move e dimensiona por conta própria. Cada janela recebe uma barra de título nas cores do seu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela em foco. Uma janela minimizada aguarda no dock; clique em seu aplicativo para trazê-la de volta. Clique em uma janela para trazê-la para frente. Redimensione-a a partir de qualquer borda ou canto. Clique duas vezes em uma barra de título para maximizar a janela mantendo a barra superior visível, e novamente para recuperar seu tamanho antigo.

Uma área de trabalho flutuante também mostra um dock, com seus aplicativos fixados, tudo o que está em execução e uma grade de todos os aplicativos atrás do botão de aplicativos, que `Super + Alt + Space` e _Aplicativos_ no menu do Omarchy também abrem. Clique com o botão direito em um aplicativo na grade, ou pressione `Delete`, para desinstalá-lo. Clique em um aplicativo para abri-lo, ou para trazer sua janela para frente; clique novamente para alternar entre suas janelas. Clique com o botão do meio para abrir uma nova janela. Arraste um ícone ao longo do dock para movê-lo; arrastar um aplicativo em execução para entre os outros o mantém ali. Clique com o botão direito para manter um aplicativo no dock, removê-lo dele ou encerrá-lo. O dock sai do caminho de uma janela em tela cheia. Clique com o botão direito no botão de aplicativos para mover o dock para outra borda ou fazê-lo se esconder até que o ponteiro alcance sua borda. A posição também está em _Aparência > Dock > Posição do Dock_, e `omarchy dock position left` e `omarchy dock autohide on` definem ambos a partir de um terminal. Os aplicativos que você mantém no dock ficam esmaecidos enquanto não estão em execução.

Novas áreas de trabalho, e qualquer uma à qual você não tenha dado um layout próprio com `Super + L`, usam o layout padrão. Alterar o padrão redefine para ele todas as áreas de trabalho sem janelas, enquanto uma com janelas mantém o layout que tem. Uma janela minimizada para o dock ainda conta como uma janela na área de trabalho de onde saiu. Escolha-o em _Aparência > Layout da Área de Trabalho_: Mosaico, Rolagem ou Flutuante. `omarchy-hyprland-workspace-layout-default scrolling` define isso a partir de um terminal.

### Agrupando janelas

As janelas podem ser agrupadas usando `Super + G`. Depois que você estiver em um grupo, todas as janelas que abrir enquanto ele estiver ativo pertencerão ao grupo. Você pode se mover entre essas janelas agrupadas usando `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` para ir diretamente às janelas agrupadas em ordem.

Você pode mover uma janela para fora do agrupamento com `Super + Alt + G` ou desmontar todo o grupo pressionando `Super + G` novamente. Por fim, você pode mover janelas de fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Destacando janelas

Você pode destacar uma janela de sua alocação na área de trabalho com `Super + O`. Isso a fixará como uma janela flutuante que acompanha você em qualquer área de trabalho para onde você for. Ótimo para players de vídeo e afins.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Área de trabalho scratchpad

Há uma área de trabalho scratchpad especial em tamanho total que se sobrepõe a qualquer área de trabalho em que você esteja no momento. Você acessa o que está nela usando `Super + S`, e coloca janelas lá usando `Super + Alt + S`.

Ela funciona bem para controles ou um terminal com o qual você queira interagir rapidamente sem sair da área de trabalho atual.

### Console Quake

Por fim, há um console Quake de meia altura que desce sobre qualquer área de trabalho em que você esteja no momento. Alterne-o com `Super + Grave`, e coloque uma janela lá usando `Super + Shift + Grave`.

Ele abre com seu agente padrão pronto para usar. Enquanto o console contém uma única janela, ele desce como um painel centralizado em vez de ocupar toda a tela. Coloque um segundo aplicativo nele e ele volta à largura total, para que os dois tenham espaço para ficar lado a lado.

Para mover uma janela para fora do scratchpad ou do console, envie-a diretamente para outra área de trabalho com algo como `Super + Shift + 1`.

### Leva um tempo para se acostumar!

Leva um pouco de tempo para se acostumar a navegar pela sua área de trabalho dessa forma, mas depois que você se acostumar, será difícil voltar a uma experiência tradicional de área de trabalho orientada pelo mouse!
