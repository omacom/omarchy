# Navegação

Tudo no Omarchy acontece através do teclado — _TUDO!_ Quando o sistema arranca pela primeira vez, literalmente não consegue fazer nada só com o rato. Mas pode carregar em `Super + Space` para mostrar o Menu Omarchy e, a partir daí, pode fazer praticamente tudo.

Mas o menu Omarchy nem sequer foi pensado para ser a forma principal de operar o sistema na maior parte do tempo. Conseguimos ser mais rápidos do que isso! Todas as aplicações mais importantes estão associadas diretamente a teclas de atalho individuais. Arranca o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Experimente fazer uma coisa a seguir à outra e vai ver a magia da disposição em mosaico do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Depois pode carregar em `Super + J` para as empilhar uma por cima da outra em vez de as pôr lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Carregue novamente em `Super + J` para as voltar a pôr lado a lado. Depois experimente `Super + Shift + Arrow Right` no navegador para trocar as janelas.

Experimente agora `Super + Shift + T` para arrancar o Activity monitor. Vai aparecer como uma janela flutuante. Pode colocá-la em mosaico com `Super + T` (e carregar novamente na mesma tecla para a tornar flutuante outra vez). Agora carregue em `Super + Shift + F` para abrir o gestor de ficheiros. Fica com uma disposição em quatro partes muito arrumada:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navega entre janelas para ativar a que pretende com `Super + Arrow`. Isto muda o foco e move o cursor para o centro da nova aplicação. No limite de um ecrã, continua para o monitor desse lado.

Se carregar em `Super + Shift + 2`, move a aplicação focada atualmente para a segunda área de trabalho. `Super + Shift + 1` volta a trazê-la. (E `Super + Shift + Alt + 2` move a aplicação focada atualmente para a segunda área de trabalho sem mudar para ela).

Com mais do que um monitor, cada monitor tem as suas próprias áreas de trabalho de 1 a 10. `Super + 2` vai para a segunda área de trabalho do monitor onde está, e a barra superior de cada monitor mostra as suas próprias áreas de trabalho e aquela que está a apresentar. `Super + Tab` percorre ciclicamente as áreas de trabalho do monitor onde está. `Super + Shift + Ctrl + Arrows` move a janela onde está para o monitor nessa direção, para a área de trabalho que ele está a apresentar, e `Super + Shift + Alt + Arrows` move a área de trabalho onde está para o monitor nessa direção, onde ela assume o mesmo número, se estiver livre. Um monitor mantém as suas áreas de trabalho quando é desligado: juntam-se às de outro ecrã, numeradas a seguir às que ele já tem, e voltam aos números antigos quando o monitor regressa.

Se mantiver `Super` premido e usar o rato para clicar numa janela, consegue reorganizar onde ela fica. Se mantiver `Super` premido e usar o botão direito do rato, pode redimensionar a janela livremente.

Fecha uma janela com `Super + W` ou `Super + Q` (e fecha todas as janelas com `Ctrl + Alt + Delete`).

Também pode passar para ecrã inteiro com `Super + F`, ou até apenas para largura total (mantendo a barra superior) com `Super + Alt + F`, ou para ecrã inteiro dentro de uma janela com `Super + Ctrl + F` (ótimo para o YouTube!).

### Disposição dwindle vs. disposição de deslocamento

A disposição predefinida do Omarchy chama-se dwindle. Mantém todas as janelas que abre numa única área de trabalho sempre visíveis, mesmo que tenha de as encolher.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas também pode optar por transformar uma área de trabalho na disposição de deslocamento, em que as janelas estão alinhadas lado a lado, para lá do limite visível do ecrã. Transforma uma única área de trabalho nesta disposição através de `Super + L`.

Carregar novamente em `Super + L` torna a área de trabalho flutuante, em que as janelas se sobrepõem livremente e é o utilizador a colocá-las, e um terceiro toque devolve-a a dwindle. `Super + Alt + L` percorre-as na direção oposta. Uma janela que já é flutuante de qualquer forma — uma que tenha destacado com `Super + T`, ou uma aplicação que abre sempre como flutuante — continua flutuante quando a área de trabalho volta à disposição em mosaico. A barra superior assinala a área de trabalho onde está com a sua disposição: um quadrado para dwindle, um círculo para deslocamento e um triângulo para flutuante. Clicar nessa marca também percorre ciclicamente a disposição, tal como a tecla de ecrã nos computadores portáteis que a têm.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é feita por área de trabalho e mantém-se. Por isso, pode manter a área de trabalho 1 em dwindle para navegar na web e a área de trabalho 2 em deslocamento para programar, e elas voltam assim depois de um reinício.

Se quiser usar a disposição de deslocamento como predefinição, pode defini-lo em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Áreas de trabalho flutuantes

Uma área de trabalho flutuante funciona como um ambiente de trabalho tradicional: as janelas sobrepõem-se e é o utilizador a movê-las e a dimensioná-las. Cada janela recebe uma barra de título nas cores do seu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela focada. Uma janela minimizada fica à espera na dock; clique na sua aplicação para a trazer de volta. Clique numa janela para a trazer para a frente. Redimensione-a a partir de qualquer extremidade ou canto. Clique duas vezes numa barra de título para maximizar a janela mantendo a barra superior visível, e outra vez para recuperar o tamanho antigo. O Chrome e outros navegadores baseados em Chromium, o Disks e o Document Viewer ignoram a barra de título e usam, em vez disso, o seu próprio cabeçalho; `Super + Alt + F` maximiza-os e `Super + M` minimiza-os.

Uma área de trabalho flutuante também mostra uma dock, com as suas aplicações fixadas, tudo o que está a ser executado e uma grelha com todas as aplicações por trás do botão de aplicações, que `Super + Alt + Space` e _Apps_ no menu Omarchy também abrem. Clique com o botão direito numa aplicação da grelha, ou carregue em `Delete`, para a desinstalar. Clique numa aplicação para a abrir, ou para trazer a sua janela para a frente; clique outra vez para percorrer ciclicamente as suas janelas. O Files só traz de volta uma janela da área de trabalho onde está e, caso contrário, abre uma nova, e o Terminal e o Agent iniciam sempre outra janela, embora uma janela minimizada regresse primeiro. Um clique com o botão do meio abre uma nova janela. Arraste um ícone ao longo da dock para o mover; arrastar uma aplicação em execução para junto das outras mantém-na lá. Clique com o botão direito para manter uma aplicação na dock, retirá-la de lá ou sair dela. A dock sai do caminho de uma janela em ecrã inteiro. Clique com o botão direito no botão de aplicações para mover a dock para outra extremidade ou para fazer com que se oculte até o ponteiro chegar à sua extremidade. A posição também se encontra em _Appearance > Dock > Dock Position_, e `omarchy dock position left` e `omarchy dock autohide on` definem ambas a partir de um terminal. As aplicações que mantém na dock ficam esbatidas enquanto não estiverem em execução.

As áreas de trabalho novas, e todas aquelas a que não tenha dado uma disposição própria com `Super + L`, usam a disposição predefinida. Alterar a predefinição repõe todas as áreas de trabalho sem janelas para essa disposição, enquanto uma área com janelas mantém a disposição que tem. Uma janela minimizada para a dock continua a contar como uma janela na área de trabalho que deixou. Escolha-a em _Appearance > Workspace Layout_: Mosaico, Deslocamento ou Flutuante. `omarchy hyprland workspace layout default scrolling` define-a a partir de um terminal.

### Agrupar janelas

As janelas podem ser agrupadas com `Super + G`. Assim que estiver num grupo, todas as janelas que iniciar enquanto este estiver ativo vão pertencer ao grupo. Pode mover-se entre estas janelas agrupadas com `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` para ir diretamente para as janelas agrupadas por ordem.

Pode mover uma janela para fora do grupo com `Super + Alt + G` ou desmontar o grupo inteiro carregando novamente em `Super + G`. Por fim, pode mover janelas que estão fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Destacar janelas

Pode retirar uma janela da sua atribuição de área de trabalho com `Super + O`. Isso fixa-a como uma janela flutuante que o acompanha para qualquer área de trabalho a que vá. Ótimo para leitores de vídeo e afins.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Área de trabalho scratchpad

Existe uma área de trabalho scratchpad especial, de tamanho total, que se sobrepõe à área de trabalho onde está atualmente. Acede ao que lá está com `Super + S` e coloca janelas lá com `Super + Alt + S`.

Funciona bem para controlos ou para um terminal com que pretende interagir rapidamente sem sair da área de trabalho atual.

### Consola Quake

Por fim, existe uma consola Quake com metade da altura que desce sobre a área de trabalho onde está atualmente. Alterne-a com `Super + the key above Tab` (acento grave nas disposições de teclado dos EUA) e coloque uma janela lá com `Super + Shift + the key above Tab`.

Da primeira vez que abre, inicia o seu agente predefinido, ou pede-lhe para escolher um se ainda não tiver escolhido nenhum. Enquanto a consola tiver uma única janela, desce como um painel centrado em vez de ocupar toda a largura do ecrã. Coloque uma segunda aplicação nela e ela volta à largura total, para as duas terem espaço para ficarem lado a lado.

Para mover uma janela para fora do scratchpad ou da consola, envie-a diretamente para outra área de trabalho com algo como `Super + Shift + 1`.

### É preciso habituar-se!

Leva algum tempo a habituar-se a navegar no seu ambiente de trabalho desta forma, mas, assim que se habituar, vai ser difícil voltar a uma experiência de ambiente de trabalho tradicional, controlada pelo rato!
