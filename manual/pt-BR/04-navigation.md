# Navegação

Tudo no Omarchy acontece pelo teclado — _TUDO!_ Quando o sistema inicia pela primeira vez, você literalmente não consegue fazer nada só com o mouse. Mas você pode apertar `Super + Space` para revelar o Menu do Omarchy e, a partir daqui, você pode fazer praticamente tudo.

Mas o menu do Omarchy nem sequer foi pensado para ser a principal forma de operar o sistema na maior parte do tempo. Dá para ser mais rápido que isso! Todos os aplicativos mais importantes estão vinculados diretamente a teclas de atalho individuais. Você inicia o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Tente fazer um depois do outro, e você verá a mágica do tiling do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Você pode então apertar `Super + J` para empilhá-los um em cima do outro, em vez de lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Aperte `Super + J` novamente para retorná-los às suas posições lado a lado. Depois tente `Super + Shift + Arrow Right` enquanto estiver no navegador para trocar as janelas.

Agora tente `Super + Shift + T` para iniciar o monitor de Atividade. Ele aparecerá como uma janela flutuante. Você pode colocá-lo em tiling usando `Super + T` (e apertar isso novamente para torná-lo flutuante de novo). Agora pressione `Super + Shift + F` para abrir o gerenciador de arquivos. Você terá uma configuração bacana em quatro vias:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Você navega entre a janela que quer tornar ativa com `Super + Arrow`. Isso mudará o foco e moverá o cursor para o centro do novo aplicativo. Na borda de uma tela, ele continua para o monitor daquele lado.

Se você apertar `Super + Shift + 2`, você moverá o aplicativo atualmente em foco para o segundo workspace. `Super + Shift + 1` move ele de volta. (E `Super + Shift + Alt + 2` moverá o aplicativo atualmente em foco para o segundo workspace sem mudar para ele).

Com mais de um monitor, cada monitor tem seus próprios workspaces de 1 a 10. `Super + 2` vai para o segundo workspace do monitor em que você está, e a barra superior de cada monitor mostra seus próprios workspaces e aquele que ele está exibindo. `Super + Tab` alterna entre os workspaces no monitor em que você está. `Super + Shift + Ctrl + Arrows` move a janela em que você está para o monitor naquela direção, para o workspace que ele está exibindo, e `Super + Shift + Alt + Arrows` move o workspace em que você está para o monitor naquela direção, onde ele assume o mesmo número se estiver livre. Um monitor mantém seus workspaces quando você o desconecta: eles se juntam aos de outra tela, numerados depois daqueles que ela já tem, e voltam aos seus números antigos quando o monitor retorna.

Se você segurar `Super` e usar o mouse para clicar em uma janela, você poderá reorganizar onde ela fica. Se você segurar `Super` e usar o botão direito do mouse, você pode redimensionar a janela livremente.

Você fecha uma janela com `Super + W` ou `Super + Q` (e fecha todas as janelas com `Ctrl + Alt + Delete`).

Você também pode entrar em tela cheia com `Super + F` ou até mesmo apenas em largura total (mantendo a barra superior) com `Super + Alt + F` ou em tela cheia dentro de uma janela com `Super + Ctrl + F` (ótimo para o YouTube!).

### Layout dwindle vs scrolling

O layout padrão do Omarchy se chama dwindle. Ele mantém todas as janelas que você abre em um único workspace visíveis o tempo todo, mesmo que tenha que encolhê-las.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas você também pode escolher transformar um workspace no layout scrolling, onde as janelas são alinhadas lado a lado, além da borda visível da tela. Você transforma um único workspace neste layout via `Super + L`.

Pressionar `Super + L` novamente torna o workspace flutuante, onde as janelas se sobrepõem livremente e você as posiciona por conta própria, e uma terceira pressionada retorna ele para dwindle. `Super + Alt + L` percorre eles na outra direção. Uma janela que já flutua de qualquer forma — uma que você retirou com `Super + T`, ou um aplicativo que sempre abre flutuante — continua flutuando quando o workspace volta para tiling. A barra superior marca o workspace em que você está com seu layout: um quadrado para dwindle, um círculo para scrolling, e um triângulo para flutuante. Clicar nessa marca também alterna o layout.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por workspace, e ela persiste. Assim você pode manter o workspace 1 em dwindle para navegação e o workspace 2 em scrolling para código, e eles voltarão desse jeito depois de uma reinicialização.

Se você desejar usar o layout scrolling como padrão, você pode definir isso em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspaces flutuantes

Um workspace flutuante funciona como uma área de trabalho tradicional: as janelas se sobrepõem, e você as move e dimensiona por conta própria. Cada janela recebe uma barra de título nas cores do seu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela em foco. Uma janela minimizada aguarda no dock; clique no aplicativo dela para trazê-la de volta. Clique em uma janela para trazê-la para frente. Redimensione-a a partir de qualquer borda ou canto. Clique duas vezes em uma barra de título para maximizar a janela mantendo a barra superior visível, e novamente para recuperar seu tamanho antigo.

Um workspace flutuante também mostra um dock, com seus aplicativos fixados, tudo o que está em execução, e uma grade de todos os aplicativos atrás do botão de aplicativos, que `Super + Alt + Space` e _Apps_ no menu do Omarchy também abrem. Clique com o botão direito em um aplicativo na grade, ou pressione `Delete`, para desinstalá-lo. Clique em um aplicativo para abri-lo, ou para trazer sua janela para frente; clique novamente para alternar entre suas janelas. O clique do meio abre uma nova janela. Arraste um ícone ao longo do dock para movê-lo; arrastar um aplicativo em execução para entre os outros o mantém lá. Clique com o botão direito para manter um aplicativo no dock, tirá-lo dele, ou encerrá-lo. O dock sai do caminho de uma janela em tela cheia. Clique com o botão direito no botão de aplicativos para mover o dock para outra borda ou fazer com que ele se oculte até que o ponteiro alcance sua borda. A posição também está em _Appearance > Dock > Dock Position_, e `omarchy dock position left` e `omarchy dock autohide on` definem ambos a partir de um terminal. Aplicativos que você mantém no dock ficam esmaecidos enquanto não estão em execução.

Novos workspaces, e qualquer um ao qual você não tenha dado um layout próprio com `Super + L`, usam o layout padrão. Alterar o padrão redefine para ele todo workspace sem janelas, enquanto um com janelas mantém o layout que tem. Uma janela minimizada para o dock ainda conta como uma janela no workspace que ela deixou. Escolha-o em _Appearance > Workspace Layout_: Tiling, Scrolling, ou Floating. `omarchy-hyprland-workspace-layout-default scrolling` define isso a partir de um terminal.

### Agrupando janelas

As janelas podem ser agrupadas usando `Super + G`. Depois que você está em um grupo, toda janela que você iniciar enquanto ele estiver ativo pertencerá ao grupo. Você pode se mover entre essas janelas agrupadas usando `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` para ir diretamente para a janela agrupada em ordem.

Você pode mover uma janela para fora do agrupamento com `Super + Alt + G` ou desmontar o grupo inteiro apertando `Super + G` novamente. Por fim, você pode mover janelas de fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Destacando janelas

Você pode destacar uma janela de sua alocação de workspace com `Super + O`. Isso a fixará como uma janela flutuante que acompanha você em qualquer workspace para o qual você vá. Ótimo para reprodutores de vídeo e coisas do tipo.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Existe um workspace scratchpad especial em tamanho cheio que se sobrepõe a qualquer workspace em que você esteja atualmente. Você acessa o que está nele usando `Super + S`, e você coloca janelas lá usando `Super + Alt + S`.

Ele funciona bem para controles ou um terminal com o qual você quer interagir rapidamente sem sair do workspace atual.

### Console Quake

Por fim, existe um console Quake de meia altura que desce sobre qualquer workspace em que você esteja atualmente. Alterne-o com `Super + Grave`, e coloque uma janela lá usando `Super + Shift + Grave`.

Ele abre com seu agent padrão pronto para uso. Enquanto o console contém uma única janela, ele desce como um painel centralizado, em vez de se estender por toda a tela. Coloque um segundo aplicativo nele e ele volta à largura total, para que os dois tenham espaço para ficar lado a lado.

Para mover uma janela para fora do scratchpad ou do console, envie-a diretamente para outro workspace com algo como `Super + Shift + 1`.

### Leva um tempo para se acostumar!

Leva um tempinho para se acostumar a navegar pela sua área de trabalho assim, mas, depois que você se acostumar, vai ser difícil voltar a uma experiência de área de trabalho tradicional guiada pelo mouse!
