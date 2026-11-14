# Navegação

Tudo no Omarchy acontece pelo teclado — _TUDO!_ Quando o sistema inicia pela primeira vez, você literalmente não consegue fazer nada só com o mouse. Mas você pode pressionar `Super + Space` para revelar o Menu do Omarchy e, a partir daí, pode fazer praticamente tudo.

Mas o menu do Omarchy nem sequer foi pensado para ser a forma principal de operar o sistema na maior parte do tempo. Dá para ser mais rápido que isso! Todos os aplicativos mais importantes estão vinculados diretamente a teclas de atalho individuais. Você abre o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Tente fazer um depois do outro e você verá a mágica do tiling do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Você pode então pressionar `Super + J` para empilhá-las uma sobre a outra, em vez de lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Pressione `Super + J` novamente para retorná-las às suas posições lado a lado. Depois, tente `Super + Shift + Arrow Right` enquanto estiver no navegador para trocar as janelas de lugar.

Agora tente `Super + Shift + T` para abrir o monitor de atividade. Ele aparecerá como uma janela flutuante. Você pode colocá-lo em tiling usando `Super + T` (e pressionar isso novamente para torná-lo flutuante de novo). Agora pressione `Super + Shift + F` para abrir o gerenciador de arquivos. Você terá uma bela divisão em quatro:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Você navega entre as janelas para ativar a que quiser com `Super + Arrow`. Isso mudará o foco e moverá o cursor para o centro do novo aplicativo. Na borda de uma tela, ele continua para o monitor daquele lado.

Se você pressionar `Super + Shift + 2`, moverá o aplicativo atualmente em foco para a segunda área de trabalho. `Super + Shift + 1` o traz de volta. (E `Super + Shift + Alt + 2` moverá o aplicativo atualmente em foco para a segunda área de trabalho sem mudar para ela.)

Com mais de um monitor, cada monitor tem suas próprias áreas de trabalho de 1 a 10. `Super + 2` vai para a segunda área de trabalho do monitor em que você está, e a barra superior de cada monitor mostra suas próprias áreas de trabalho e aquela que ele está exibindo. `Super + Tab` percorre as áreas de trabalho do monitor em que você está. `Super + Shift + Ctrl + Arrows` move a janela em que você está para o monitor naquela direção, para a área de trabalho que ele está exibindo, e `Super + Shift + Alt + Arrows` move a área de trabalho em que você está para o monitor naquela direção, onde ela assume o mesmo número, se estiver livre. Um monitor mantém suas áreas de trabalho quando você o desconecta: elas se juntam às de outra tela, numeradas depois das que ela já tem, e voltam aos seus números antigos quando o monitor retorna.

Se você segurar `Super` e usar o mouse para clicar em uma janela, poderá reorganizar onde ela fica. Se você segurar `Super` e usar o botão direito do mouse, poderá redimensionar a janela livremente.

Você fecha uma janela com `Super + W` ou `Super + Q` (e fecha todas as janelas com `Ctrl + Alt + Delete`).

Você também pode entrar em tela cheia com `Super + F` ou até apenas em largura total (mantendo a barra superior) com `Super + Alt + F`, ou em tela cheia dentro de uma janela com `Super + Ctrl + F` (ótimo para o YouTube!).

### Layout dwindle vs. de rolagem

O layout padrão do Omarchy se chama dwindle. Ele mantém todas as janelas que você abre em uma única área de trabalho visíveis o tempo todo, mesmo que precise encolhê-las.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas você também pode optar por transformar uma área de trabalho no layout de rolagem, em que as janelas são enfileiradas lado a lado, além da borda visível da tela. Você transforma uma única área de trabalho nesse layout com `Super + L`.

Pressionar `Super + L` novamente transforma a área de trabalho em flutuante, em que as janelas se sobrepõem livremente e você as posiciona por conta própria, e uma terceira pressão a retorna ao dwindle. `Super + Alt + L` percorre os layouts na direção oposta. Uma janela que já flutua de qualquer forma — uma que você destacou com `Super + T`, ou um aplicativo que sempre abre flutuante — continua flutuando quando a área de trabalho volta ao tiling. A barra superior marca a área de trabalho em que você está com o seu layout: um quadrado para dwindle, um círculo para rolagem e um triângulo para flutuante. Clicar nessa marca também alterna o layout em ciclo.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por área de trabalho e ela é mantida. Então você pode manter a área de trabalho 1 em dwindle para navegar e a área de trabalho 2 em rolagem para programar, e elas voltarão assim depois de uma reinicialização.

Se você quiser usar o layout de rolagem como padrão, pode definir isso em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Áreas de trabalho flutuantes

Uma área de trabalho flutuante funciona como uma área de trabalho tradicional: as janelas se sobrepõem, e você as move e dimensiona por conta própria. Cada janela recebe uma barra de título nas cores do seu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela em foco. Uma janela minimizada aguarda no dock; clique no aplicativo dela para trazê-la de volta. Clique em uma janela para trazê-la para a frente. Redimensione-a a partir de qualquer borda ou canto. Dê um clique duplo em uma barra de título para maximizar a janela mantendo a barra superior visível, e novamente para recuperar seu tamanho antigo. O Chrome e outros navegadores baseados no Chromium, o Disks e o Document Viewer pulam a barra de título e usam seu próprio cabeçalho; `Super + Alt + F` os maximiza, e `Super + M` os minimiza.

Uma área de trabalho flutuante também mostra um dock, com seus aplicativos fixados, tudo o que está em execução e uma grade de todos os aplicativos atrás do botão de aplicativos, que `Super + Alt + Space` e _Apps_ no menu do Omarchy também abrem. Clique com o botão direito em um aplicativo na grade, ou pressione `Delete`, para desinstalá-lo. Clique em um aplicativo para abri-lo, ou para trazer sua janela para a frente; clique novamente para alternar entre suas janelas. O clique do meio abre uma nova janela. Arraste um ícone ao longo do dock para movê-lo; arrastar um aplicativo em execução para entre os outros o mantém ali. Clique com o botão direito para manter um aplicativo no dock, removê-lo de lá ou encerrá-lo. O dock sai do caminho de uma janela em tela cheia. Clique com o botão direito no botão de aplicativos para mover o dock para outra borda ou fazer com que ele se oculte até o ponteiro alcançar sua borda. A posição também está em _Appearance > Dock > Dock Position_, e `omarchy dock position left` e `omarchy dock autohide on` definem ambas a partir de um terminal. Os aplicativos que você mantém no dock ficam esmaecidos enquanto não estão em execução.

Novas áreas de trabalho, e qualquer uma à qual você não tenha dado um layout próprio com `Super + L`, usam o layout padrão. Alterar o padrão redefine para ele todas as áreas de trabalho sem janelas, enquanto uma que tenha janelas mantém o layout que possui. Uma janela minimizada no dock ainda conta como uma janela na área de trabalho de onde saiu. Escolha-o em _Appearance > Workspace Layout_: Tiling, Scrolling ou Floating. `omarchy-hyprland-workspace-layout-default scrolling` o define a partir de um terminal.

### Agrupando janelas

As janelas podem ser agrupadas usando `Super + G`. Depois que você estiver em um grupo, todas as janelas que você abrir enquanto ele estiver ativo pertencerão ao grupo. Você pode se mover entre essas janelas agrupadas usando `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` para ir diretamente às janelas agrupadas em ordem.

Você pode mover uma janela para fora do agrupamento com `Super + Alt + G` ou desmontar o grupo inteiro pressionando `Super + G` novamente. Por fim, você pode mover janelas de fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Destacando janelas

Você pode destacar uma janela da sua alocação de área de trabalho com `Super + O`. Isso a fixará como uma janela flutuante que acompanha você em qualquer área de trabalho para onde você for. Ótimo para players de vídeo e similares.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Área de trabalho scratchpad

Existe uma área de trabalho scratchpad especial, de tamanho integral, que se sobrepõe à área de trabalho em que você está no momento. Você acessa o que está nela usando `Super + S` e coloca janelas lá usando `Super + Alt + S`.

Ela funciona bem para controles ou um terminal com o qual você quer interagir rapidamente sem sair da área de trabalho atual.

### Console Quake

Por fim, há um console Quake de meia altura que desce sobre a área de trabalho em que você está no momento. Alterne-o com `Super + Grave` e coloque uma janela lá usando `Super + Shift + Grave`.

Ele abre com seu agente padrão pronto para uso. Enquanto o console contém uma única janela, ele desce como um painel centralizado, em vez de abranger a tela inteira. Coloque um segundo aplicativo nele e ele volta à largura total, para que os dois tenham espaço para ficar lado a lado.

Para mover uma janela para fora do scratchpad ou do console, envie-a diretamente para outra área de trabalho com algo como `Super + Shift + 1`.

### É preciso se acostumar!

Leva um tempo para se acostumar a navegar pela sua área de trabalho assim, mas, depois que você se acostuma, vai ser difícil voltar a uma experiência tradicional de área de trabalho guiada pelo mouse!
