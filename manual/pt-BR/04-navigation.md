# Navegação

Tudo no Omarchy acontece pelo teclado — _TUDO!_ Quando o sistema inicia pela primeira vez, você literalmente não consegue fazer nada só com o mouse. Mas você pode apertar `Super + Space` para revelar o Menu do Omarchy e, a partir daqui, você pode fazer praticamente tudo.

Mas o menu do Omarchy nem sequer foi feito para ser a principal maneira de operar o sistema na maior parte do tempo. Dá para ser mais rápido que isso! Todos os aplicativos mais importantes estão vinculados diretamente a teclas de atalho individuais. Você inicia o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Tente fazer um depois do outro, e você verá a mágica do tiling do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Você pode então apertar `Super + J` para empilhá-las uma sobre a outra em vez de lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Aperte `Super + J` novamente para retorná-las às suas posições lado a lado. Depois tente `Super + Shift + Arrow Right` enquanto estiver no navegador para trocar as janelas.

Agora tente `Super + Shift + T` para iniciar o monitor de Atividade. Isso aparecerá como uma janela flutuante. Você pode colocá-la em mosaico usando `Super + T` (e aperte isso novamente para torná-la flutuante de novo). Agora pressione `Super + Shift + F` para abrir o gerenciador de arquivos. Você terá uma bela configuração com quatro janelas:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Você navega entre a janela que quer tornar ativa com `Super + Arrow`. Isso mudará o foco e moverá o cursor para o centro do novo aplicativo. Na borda de uma tela, continua para o monitor daquele lado.

Se você apertar `Super + Shift + 2`, você moverá o aplicativo atualmente em foco para o segundo espaço de trabalho. `Super + Shift + 1` o move de volta. (E `Super + Shift + Alt + 2` moverá o aplicativo atualmente em foco para o segundo espaço de trabalho sem mudar para ele).

Com mais de um monitor, cada monitor tem seus próprios espaços de trabalho de 1 a 10. `Super + 2` vai para o segundo espaço de trabalho do monitor em que você está, e a barra superior de cada monitor mostra seus próprios espaços de trabalho e aquele que está exibindo. `Super + Tab` alterna entre os espaços de trabalho no monitor em que você está. `Super + Shift + Ctrl + Arrows` move a janela em que você está para o monitor naquela direção, para o espaço de trabalho que ele está exibindo, e `Super + Shift + Alt + Arrows` move o espaço de trabalho em que você está para o monitor naquela direção, onde ele assume o mesmo número se estiver livre. Um monitor mantém seus espaços de trabalho quando você o desconecta: eles se juntam aos de outra tela, numerados depois daqueles que ela já tem, e voltam aos seus números antigos quando o monitor retorna.

Se você segurar `Super` e usar o mouse para clicar em uma janela, você poderá reorganizar onde ela fica. Se você segurar `Super` e usar o botão direito do mouse, você pode redimensionar livremente a janela.

Você fecha uma janela com `Super + W` ou `Super + Q` (e fecha todas as janelas com `Ctrl + Alt + Delete`).

Você também pode entrar em tela cheia com `Super + F` ou até mesmo apenas em largura total (mantendo a barra superior) com `Super + Alt + F` ou em tela cheia dentro de uma janela com `Super + Ctrl + F` (ótimo para o YouTube!).

### Dwindle vs scrolling layout

O layout padrão do Omarchy se chama dwindle. Ele mantém todas as janelas que você abre em um único espaço de trabalho visíveis o tempo todo, mesmo que tenha que encolhê-las.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas você também pode optar por transformar um espaço de trabalho no layout de rolagem, onde as janelas são alinhadas lado a lado, além da borda visível da tela. Você transforma um único espaço de trabalho nesse layout via `Super + L`.

Apertar `Super + L` novamente torna o espaço de trabalho flutuante, onde as janelas se sobrepõem livremente e você as posiciona por conta própria, e um terceiro toque retorna ao dwindle. `Super + Alt + L` percorre eles na direção contrária. Uma janela que já é flutuante de qualquer forma — uma que você destacou com `Super + T`, ou um aplicativo que sempre abre flutuante — continua flutuante quando o espaço de trabalho volta ao modo em mosaico. A barra superior marca o espaço de trabalho em que você está com seu layout: um quadrado para dwindle, um círculo para rolagem, e um triângulo para flutuante. Clicar nessa marca também alterna o layout.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por espaço de trabalho, e ela permanece. Então você pode manter o espaço de trabalho 1 em dwindle para navegar e o espaço de trabalho 2 em rolagem para programar, e eles voltarão assim depois de uma reinicialização.

Se você quiser usar o layout de rolagem como padrão, você pode definir isso em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Floating workspaces

Um espaço de trabalho flutuante funciona como uma área de trabalho tradicional: as janelas se sobrepõem, e você as move e dimensiona por conta própria. Cada janela ganha uma barra de título nas cores do seu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela em foco. Uma janela minimizada espera no dock; clique no seu aplicativo para trazê-la de volta. Clique em uma janela para trazê-la para a frente. Redimensione-a a partir de qualquer borda ou canto. Clique duas vezes em uma barra de título para maximizar a janela mantendo a barra superior à vista, e de novo para recuperar seu tamanho antigo. O Chrome e outros navegadores baseados no Chromium, o Disks e o Document Viewer pulam a barra de título e usam seu próprio cabeçalho em vez disso; `Super + Alt + F` os maximiza, e `Super + M` os minimiza.

Um espaço de trabalho flutuante também mostra um dock, com seus aplicativos fixados, tudo o que está em execução, e uma grade de todos os aplicativos atrás do botão de aplicativos, que `Super + Alt + Space` e _Apps_ no menu do Omarchy também abrem. Clique com o botão direito em um aplicativo na grade, ou pressione `Delete`, para desinstalá-lo. Clique em um aplicativo para abri-lo, ou para trazer sua janela para a frente; clique de novo para alternar entre suas janelas. O Files só traz de volta uma janela do espaço de trabalho em que você está e, caso contrário, abre uma nova, e o Terminal e o Agent sempre iniciam outro, embora uma janela minimizada volte primeiro. Clicar com o botão do meio abre uma nova janela. Arraste um ícone ao longo do dock para movê-lo; arrastar um aplicativo em execução para entre os outros o mantém lá. Clique com o botão direito para manter um aplicativo no dock, tirá-lo de lá, ou encerrá-lo. O dock sai do caminho de uma janela em tela cheia. Clique com o botão direito no botão de aplicativos para mover o dock para outra borda ou fazer com que ele se oculte até o ponteiro alcançar sua borda. A posição também está em _Appearance > Dock > Dock Position_, e `omarchy dock position left` e `omarchy dock autohide on` definem ambos a partir de um terminal. Os aplicativos que você mantém no dock ficam esmaecidos enquanto não estão em execução.

Novos espaços de trabalho, e qualquer um ao qual você não tenha dado um layout próprio com `Super + L`, usam o layout padrão. Mudar o padrão redefine todos os espaços de trabalho sem janelas para ele, enquanto um com janelas mantém o layout que tem. Uma janela minimizada para o dock ainda conta como uma janela no espaço de trabalho que deixou. Escolha-o em _Appearance > Workspace Layout_: Tiling, Scrolling, ou Floating. `omarchy-hyprland-workspace-layout-default scrolling` define isso a partir de um terminal.

### Grouping windows

As janelas podem ser agrupadas usando `Super + G`. Uma vez que você esteja em um grupo, toda janela que você iniciar enquanto ele estiver ativo pertencerá ao grupo. Você pode se mover entre essas janelas agrupadas usando `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` para ir diretamente às janelas agrupadas em ordem.

Você pode mover uma janela para fora do grupo com `Super + Alt + G` ou desmontar o grupo inteiro apertando `Super + G` novamente. Por fim, você pode mover janelas de fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Popping windows

Você pode destacar uma janela da sua alocação de espaço de trabalho com `Super + O`. Isso a fixará como uma janela flutuante que acompanha você em qualquer espaço de trabalho para onde você for. Ótimo para reprodutores de vídeo e similares.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

Há um espaço de trabalho scratchpad especial em tamanho total que se sobrepõe a qualquer espaço de trabalho em que você esteja no momento. Você acessa o que está nele usando `Super + S`, e você coloca janelas lá usando `Super + Alt + S`.

Ele funciona bem para controles ou um terminal com o qual você quer interagir rapidamente sem sair do espaço de trabalho atual.

### Quake console

Por fim, há um console Quake de meia altura que desce sobre qualquer espaço de trabalho em que você esteja no momento. Alterne-o com `Super + Grave`, e coloque uma janela lá usando `Super + Shift + Grave`.

Ele abre com seu agente padrão pronto para uso. Enquanto o console contém uma única janela, ele desce como um painel centralizado em vez de abranger a tela. Coloque um segundo aplicativo nele e ele volta à largura total, para que os dois tenham espaço para ficar lado a lado.

Para mover uma janela para fora do scratchpad ou do console, envie-a diretamente para outro espaço de trabalho com algo como `Super + Shift + 1`.

### It takes some getting used to!

Leva um tempinho para se acostumar a navegar pela sua área de trabalho assim, mas, uma vez que você se acostuma, vai ser difícil voltar a uma experiência tradicional de área de trabalho guiada pelo mouse!
