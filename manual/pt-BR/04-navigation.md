# Navegação

Tudo no Omarchy acontece pelo teclado — _TUDO!_ Quando o sistema inicia pela primeira vez, você literalmente não consegue fazer nada só com o mouse. Mas você pode pressionar `Super + Space` para revelar o Menu do Omarchy e, a partir daí, fazer praticamente tudo.

Mas o menu do Omarchy nem sequer foi pensado para ser a principal forma de operar o sistema na maior parte do tempo. Dá para ser mais rápido que isso! Todos os aplicativos mais importantes estão vinculados diretamente a teclas de atalho individuais. Você inicia o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Tente fazer um depois do outro e você verá a magia do tiling do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Depois, você pode pressionar `Super + J` para empilhá-los um sobre o outro, em vez de lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Pressione `Super + J` novamente para devolvê-los às suas posições lado a lado. Depois tente `Super + Shift + Arrow Right` enquanto estiver no navegador para trocar as janelas de lugar.

Agora tente `Super + Ctrl + T` para iniciar o monitor de Atividade. Ele vai aparecer como uma janela flutuante. Você pode colocá-lo em tiling usando `Super + T` (e pressionar isso novamente para torná-lo flutuante de novo). Agora pressione `Super + Shift + F` para abrir o gerenciador de arquivos. Você terá uma bela configuração com quatro janelas:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Você navega entre as janelas para escolher qual quer que fique ativa com `Super + Arrow`. Isso vai mudar o foco e mover o cursor para o centro do novo aplicativo.

Se você pressionar `Super + Shift + 2`, você vai mover o aplicativo em foco no momento para a segunda área de trabalho. `Super + Shift + 1` move ele de volta. (E `Super + Shift + Alt + 2` vai mover o aplicativo em foco no momento para a segunda área de trabalho sem mudar para ela).

Se você segurar `Super` e usar o mouse para clicar em uma janela, você poderá reorganizar onde ela fica. Se você segurar `Super` e usar o botão direito do mouse, você pode redimensionar a janela livremente.

Você fecha uma janela com `Super + W` ou `Super + Q` (e fecha todas as janelas com `Ctrl + Alt + Delete`).

Você também pode entrar em tela cheia com `Super + F`, ou até apenas em largura total (mantendo a barra superior) com `Super + Alt + F`, ou em tela cheia dentro de uma janela com `Super + Ctrl + F` (ótimo para o YouTube!).

### Dwindle vs layout scrolling

O layout padrão do Omarchy se chama dwindle. Ele mantém todas as janelas que você abre em uma única área de trabalho visíveis o tempo todo, mesmo que precise encolhê-las.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas você também pode optar por transformar uma área de trabalho no layout scrolling, em que as janelas ficam enfileiradas lado a lado, além da borda visível da tela. Você transforma uma única área de trabalho nesse layout com `Super + L`.

Pressionar `Super + L` novamente torna a área de trabalho flutuante, em que as janelas se sobrepõem livremente e você as posiciona por conta própria, e uma terceira pressão devolve ela ao dwindle. `Super + Alt + L` percorre eles no sentido contrário. Uma janela que já flutua de qualquer forma — uma que você destacou com `Super + T`, ou um aplicativo que sempre abre flutuante — continua flutuando quando a área de trabalho volta ao tiling. A barra superior marca a área de trabalho em que você está com o layout dela: um quadrado para dwindle, um círculo para scrolling e um triângulo para flutuante. Clicar nessa marca também alterna o layout em ciclo.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por área de trabalho, e ela persiste. Assim, você pode manter a área de trabalho 1 no dwindle para navegar na web e a área de trabalho 2 no scrolling para código, e elas voltarão assim depois de uma reinicialização.

Se você quiser usar o layout scrolling como padrão, você pode definir isso em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Áreas de trabalho flutuantes

Uma área de trabalho flutuante funciona como uma área de trabalho tradicional: as janelas se sobrepõem, e você move e dimensiona elas por conta própria. Cada janela ganha uma barra de título nas cores do seu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela em foco. Uma janela minimizada aguarda no dock; clique no aplicativo dela para trazê-la de volta. Clique em uma janela para trazê-la para a frente. Redimensione ela a partir de qualquer borda ou canto. Clique duas vezes em uma barra de título para maximizar a janela mantendo a barra superior à vista, e de novo para recuperar o tamanho antigo dela.

Uma área de trabalho flutuante também mostra um dock, com seus aplicativos fixados, tudo o que está em execução, e uma grade com todos os aplicativos atrás do botão de aplicativos, que `Super + Alt + Space` e _Apps_ no menu do Omarchy também abrem. Clique com o botão direito em um aplicativo na grade, ou pressione `Delete`, para desinstalá-lo. Clique em um aplicativo para abri-lo, ou para trazer a janela dele para a frente; clique novamente para alternar entre as janelas dele em ciclo. O clique com o botão do meio abre uma nova janela. Arraste um ícone ao longo do dock para movê-lo; arrastar um aplicativo em execução para o meio dos outros mantém ele ali. Clique com o botão direito para manter um aplicativo no dock, tirá-lo de lá ou encerrá-lo. O dock sai do caminho de uma janela em tela cheia. Clique com o botão direito no botão de aplicativos para mover o dock para outra borda ou fazer ele se esconder até que o ponteiro alcance a borda dele. A posição também fica em _Trigger > Appearance > Dock > Dock Position_, e `omarchy dock position left` e `omarchy dock autohide on` definem as duas coisas a partir de um terminal. Os aplicativos que você mantém no dock ficam esmaecidos enquanto não estão em execução.

Novas áreas de trabalho, e qualquer uma à qual você não tenha dado um layout próprio com `Super + L`, usam o layout padrão. Mudar o padrão redefine para ele todas as áreas de trabalho sem janelas, enquanto uma com janelas mantém o layout que ela tem. Uma janela minimizada para o dock ainda conta como uma janela na área de trabalho de onde ela saiu. Escolha ele em _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling ou Floating. `omarchy-hyprland-workspace-layout-default scrolling` define isso a partir de um terminal.

### Agrupando janelas

As janelas podem ser agrupadas usando `Super + G`. Quando você estiver em um grupo, todas as janelas que você iniciar enquanto ele estiver ativo pertencerão ao grupo. Você pode se mover entre essas janelas agrupadas usando `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` para ir diretamente para a janela agrupada na ordem.

Você pode mover uma janela para fora do agrupamento com `Super + Alt + G` ou desfazer o grupo inteiro pressionando `Super + G` novamente. Por fim, você pode mover janelas de fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Destacando janelas

Você pode destacar uma janela da alocação dela na área de trabalho com `Super + O`. Isso vai fixá-la como uma janela flutuante que segue você para qualquer área de trabalho aonde você for. Ótimo para players de vídeo e coisas do tipo.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Área de trabalho scratchpad

Por fim, existe uma área de trabalho scratchpad especial que desce sobre a área de trabalho em que você estiver no momento, muito parecida com um console do Quake. Alterne ela com `Super + Grave` ou `Super + S`, e coloque uma janela nela usando `Super + Shift + Grave` ou `Super + Alt + S`.

Ela funciona especialmente bem para um terminal executando um agent, ou para controles com os quais você quer interagir rapidamente sem sair da área de trabalho atual. Para tirar uma janela do scratchpad, envie ela diretamente para outra área de trabalho com algo como `Super + Shift + 1`.

Enquanto o scratchpad mantém uma única janela, ele desce como um painel centralizado, em vez de ocupar toda a largura da tela. Coloque um segundo aplicativo nele e ele volta à largura total, para que os dois tenham espaço para ficar lado a lado.

### É preciso se acostumar!

Leva um tempinho para se acostumar a navegar pela sua área de trabalho desse jeito, mas, quando você se acostumar, vai ser difícil voltar a uma experiência tradicional de área de trabalho movida a mouse!
