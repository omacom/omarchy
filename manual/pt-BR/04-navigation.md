# Navegação

Tudo no Omarchy acontece pelo teclado — _TUDO!_ Quando o sistema inicia pela primeira vez, você literalmente não consegue fazer nada só com o mouse. Mas você pode pressionar `Super + Space` para revelar o Menu do Omarchy e, a partir daí, pode fazer praticamente tudo.

Mas o menu do Omarchy nem sequer foi pensado para ser a principal forma de operar o sistema na maior parte do tempo. Dá para sermos mais rápidos do que isso! Todos os aplicativos mais importantes estão vinculados diretamente a atalhos individuais. Você abre o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Tente fazer um depois do outro, e você verá a mágica do mosaico do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Você pode então pressionar `Super + J` para empilhá-los um sobre o outro, em vez de lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Pressione `Super + J` novamente para devolvê-los às posições lado a lado. Depois experimente `Super + Shift + Arrow Right` enquanto estiver no navegador para trocar as janelas.

Agora experimente `Super + Shift + T` para abrir o monitor Activity. Ele aparecerá como uma janela flutuante. Você pode colocá-lo em mosaico usando `Super + T` (e pressionar isso de novo para fazê-lo flutuar novamente). Agora pressione `Super + Shift + F` para abrir o gerenciador de arquivos. Você terá uma bela configuração em quatro partes:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Você navega entre as janelas que quer ativar com `Super + Arrow`. Isso muda o foco e move o cursor para o centro do novo aplicativo. Na borda de uma tela, ele continua para o monitor daquele lado.

Se você pressionar `Super + Shift + 2`, moverá o aplicativo em foco no momento para o segundo espaço de trabalho. `Super + Shift + 1` o traz de volta. (E `Super + Shift + Alt + 2` moverá o aplicativo em foco no momento para o segundo espaço de trabalho sem mudar para ele).

Com mais de um monitor, cada monitor tem seus próprios espaços de trabalho de 1 a 10. `Super + 2` vai para o segundo espaço de trabalho do monitor em que você está, e a barra superior de cada monitor mostra seus próprios espaços de trabalho e aquele que ele está exibindo. `Super + Tab` percorre os espaços de trabalho do monitor em que você está. `Super + Shift + Ctrl + Arrows` move a janela em que você está para o monitor naquela direção, para o espaço de trabalho que ele está exibindo, e `Super + Shift + Alt + Arrows` move o espaço de trabalho em que você está para o monitor naquela direção, onde ele assume o mesmo número, se estiver livre. Um monitor mantém seus espaços de trabalho quando você o desconecta: eles se juntam aos de outra tela, numerados depois daqueles que ela já tem, e voltam aos números antigos quando o monitor retorna.

Se você segurar `Super` e usar o mouse para clicar em uma janela, poderá reorganizar onde ela fica. Se você segurar `Super` e usar o botão direito do mouse, poderá redimensionar a janela livremente.

Você fecha uma janela com `Super + W` ou `Super + Q` (e fecha todas as janelas com `Ctrl + Alt + Delete`).

Você também pode entrar em tela cheia com `Super + F` ou até mesmo apenas em largura total (mantendo a barra superior) com `Super + Alt + F`, ou em tela cheia dentro de uma janela com `Super + Ctrl + F` (ótimo para o YouTube!).

### Layout dwindle vs. layout com rolagem

O layout padrão do Omarchy se chama dwindle. Ele mantém todas as janelas que você abre em um único espaço de trabalho visíveis o tempo todo, mesmo que tenha que encolhê-las.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas você também pode optar por transformar um espaço de trabalho no layout com rolagem, onde as janelas são alinhadas lado a lado, além da borda visível da tela. Você transforma um único espaço de trabalho nesse layout com `Super + L`.

Pressionar `Super + L` novamente torna o espaço de trabalho flutuante, onde as janelas se sobrepõem livremente e você as posiciona por conta própria, e uma terceira pressão o devolve ao dwindle. `Super + Alt + L` percorre os layouts na direção contrária. Uma janela que já flutua de qualquer forma — uma que você retirou com `Super + T`, ou um aplicativo que sempre abre flutuante — continua flutuando quando o espaço de trabalho volta ao mosaico. A barra superior marca o espaço de trabalho em que você está com seu layout: um quadrado para dwindle, um círculo para rolagem e um triângulo para flutuante. Clicar nessa marca também alterna o layout, assim como a tecla de exibição em laptops que têm uma.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por espaço de trabalho, e ela permanece. Assim, você pode manter o espaço de trabalho 1 em dwindle para navegar e o espaço de trabalho 2 em rolagem para programar, e eles voltarão desse jeito depois de uma reinicialização.

Se você quiser usar o layout com rolagem como padrão, pode definir isso em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espaços de trabalho flutuantes

Um espaço de trabalho flutuante funciona como uma área de trabalho tradicional: as janelas se sobrepõem, e você as move e dimensiona por conta própria. Cada janela ganha uma barra de título nas cores do seu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela em foco. Uma janela minimizada espera no dock; clique no aplicativo dela para trazê-la de volta. Clique em uma janela para trazê-la para frente. Redimensione-a a partir de qualquer borda ou canto. Clique duas vezes em uma barra de título para maximizar a janela mantendo a barra superior à vista, e novamente para recuperar o tamanho antigo. Chrome e outros navegadores baseados em Chromium, Disks e Document Viewer ignoram a barra de título e usam seu próprio cabeçalho; `Super + Alt + F` os maximiza, e `Super + M` os minimiza.

Um espaço de trabalho flutuante também mostra um dock, com seus aplicativos fixados, tudo o que está em execução, e uma grade com todos os aplicativos atrás do botão de aplicativos, que `Super + Alt + Space` e _Apps_ no menu do Omarchy também abrem. Clique com o botão direito em um aplicativo na grade, ou pressione `Delete`, para desinstalá-lo. Clique em um aplicativo para abri-lo, ou para trazer sua janela para frente; clique novamente para percorrer suas janelas. O Files só traz de volta uma janela do espaço de trabalho em que você está e, caso contrário, abre uma nova, e Terminal e Agent sempre iniciam outra, embora uma janela minimizada volte primeiro. Um clique com o botão do meio abre uma nova janela. Arraste um ícone pelo dock para movê-lo; arrastar um aplicativo em execução para entre os outros o mantém ali. Clique com o botão direito para manter um aplicativo no dock, retirá-lo dele ou encerrá-lo. O dock sai do caminho de uma janela em tela cheia. Clique com o botão direito no botão de aplicativos para mover o dock para outra borda ou fazê-lo se ocultar até o ponteiro alcançar sua borda. A posição também está em _Appearance > Dock > Dock Position_, e `omarchy dock position left` e `omarchy dock autohide on` definem ambas a partir de um terminal. Os aplicativos que você mantém no dock ficam esmaecidos enquanto não estão em execução.

Espaços de trabalho novos, e qualquer um ao qual você não tenha dado um layout próprio com `Super + L`, usam o layout padrão. Alterar o padrão redefine para ele todos os espaços de trabalho sem janelas, enquanto um que tenha janelas mantém o layout que tem. Uma janela minimizada para o dock ainda conta como uma janela no espaço de trabalho de onde ela saiu. Escolha-o em _Appearance > Workspace Layout_: Tiling, Scrolling ou Floating. `omarchy hyprland workspace layout default scrolling` o define a partir de um terminal.

### Agrupando janelas

As janelas podem ser agrupadas usando `Super + G`. Uma vez dentro de um grupo, todas as janelas que você iniciar enquanto ele estiver ativo pertencerão ao grupo. Você pode se mover entre essas janelas agrupadas usando `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` para ir diretamente às janelas agrupadas em ordem.

Você pode mover uma janela para fora do grupo com `Super + Alt + G` ou desmontar o grupo inteiro pressionando `Super + G` novamente. Por fim, você pode mover janelas de fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Retirando janelas

Você pode retirar uma janela de sua alocação no espaço de trabalho com `Super + O`. Isso a fixará como uma janela flutuante que acompanha você em qualquer espaço de trabalho para onde você for. Ótimo para reprodutores de vídeo e coisas assim.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espaço de trabalho scratchpad

Há um espaço de trabalho scratchpad especial, de tamanho completo, que se sobrepõe ao espaço de trabalho em que você está no momento. Você acessa o que está nele usando `Super + S`, e coloca janelas lá usando `Super + Alt + S`.

Ele funciona bem para controles ou um terminal com os quais você quer interagir rapidamente sem sair do espaço de trabalho atual.

### Console Quake

Por fim, há um console Quake de meia altura que desce sobre o espaço de trabalho em que você está no momento. Alterne-o com `Super + Grave`, e coloque uma janela lá usando `Super + Shift + Grave`.

Na primeira vez que ele abre, inicia seu agente padrão, ou pede que você escolha um, se você ainda não tiver escolhido nenhum. Enquanto o console contém uma única janela, ele desce como um painel centralizado, em vez de abranger a tela inteira. Coloque um segundo aplicativo nele e ele volta à largura total, para que os dois tenham espaço para ficar lado a lado.

Para mover uma janela para fora do scratchpad ou do console, envie-a diretamente para outro espaço de trabalho com algo como `Super + Shift + 1`.

### Leva um tempo para se acostumar!

Leva um tempinho para se acostumar a navegar pela sua área de trabalho dessa forma, mas, uma vez que você se acostume, será difícil voltar a uma experiência tradicional de área de trabalho guiada pelo mouse!
