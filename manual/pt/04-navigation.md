# Navegação

Tudo no Omarchy acontece através do teclado — _TUDO!_ Quando o sistema arranca pela primeira vez, literalmente não consegues fazer nada só com o rato. Mas podes premir `Super + Space` para mostrar o Menu Omarchy e, a partir daqui, podes fazer praticamente tudo.

Mas o menu Omarchy nem sequer foi pensado para ser a principal forma de operar o sistema na maior parte do tempo. Conseguimos ser mais rápidos do que isso! Todas as aplicações mais importantes estão associadas diretamente a teclas de atalho individuais. Arrancas o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Experimenta fazer uma coisa a seguir à outra e vais ver a magia da disposição em mosaico do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Podes depois premir `Super + J` para as empilhar uma por cima da outra, em vez de as colocar lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Volta a premir `Super + J` para as devolveres às posições lado a lado. Depois experimenta `Super + Shift + Arrow Right` enquanto estás no navegador para trocar as janelas de lugar.

Agora experimenta `Super + Shift + T` para iniciar o monitor de atividade. Este vai aparecer como uma janela flutuante, com uma barra de título por onde a podes arrastar e botões para a minimizar, maximizar e fechar. Todas as janelas flutuantes têm uma, estejam onde estiverem. Podes colocá-la em mosaico com `Super + T` (e voltar a premir a mesma combinação para a tornar flutuante outra vez). Agora preme `Super + Shift + F` para abrir o gestor de ficheiros. Vais ficar com uma configuração bem organizada de quatro janelas:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegas entre as janelas para escolheres qual fica ativa com `Super + Arrow`. Isto muda o foco e move o cursor para o centro da nova aplicação. Na extremidade de um ecrã, continua para o monitor desse lado.

Se premires `Super + Shift + 2`, moves a aplicação atualmente focada para a segunda área de trabalho. `Super + Shift + 1` devolve-a. (E `Super + Shift + Alt + 2` move a aplicação atualmente focada para a segunda área de trabalho sem mudar para ela).

Com mais do que um monitor, cada monitor tem as suas próprias áreas de trabalho de 1 a 10. `Super + 2` vai para a segunda área de trabalho do monitor onde estás, e a barra superior de cada monitor mostra as suas próprias áreas de trabalho e aquela que está a mostrar. `Super + Tab` percorre as áreas de trabalho do monitor onde estás. `Super + Shift + Ctrl + Arrows` move a janela onde estás para o monitor nessa direção, para a área de trabalho que este está a mostrar, e `Super + Shift + Alt + Arrows` move a área de trabalho onde estás para o monitor nessa direção, onde assume o mesmo número se estiver livre. Um monitor conserva as suas áreas de trabalho quando o desligas: estas juntam-se às de outro ecrã, numeradas a seguir às que esse já tem, e voltam aos números antigos quando o monitor regressa.

Se mantiveres `Super` premido e usares o rato para clicar numa janela, vais poder reorganizar onde ela fica. Se mantiveres `Super` premido e usares o botão direito do rato, podes redimensionar a janela livremente.

Fechas uma janela com `Super + W` ou `Super + Q` (e fechas todas as janelas com `Ctrl + Alt + Delete`).

Também podes passar para ecrã inteiro com `Super + F`, ou até apenas para a largura total (com a barra superior visível) com `Super + Alt + F`, ou para ecrã inteiro dentro de uma janela com `Super + Ctrl + F` (ótimo para o YouTube!).

### Layout dwindle vs. layout scrolling

O layout predefinido do Omarchy chama-se dwindle. Mantém todas as janelas que abres numa única área de trabalho sempre visíveis, mesmo que tenha de as encolher.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas também podes optar por transformar uma área de trabalho no layout scrolling, onde as janelas ficam alinhadas lado a lado, para lá da extremidade visível do ecrã. Transformas uma única área de trabalho neste layout com `Super + L`.

Premir `Super + L` outra vez torna a área de trabalho flutuante, onde as janelas se sobrepõem livremente e és tu a colocá-las, e premir uma terceira vez devolve-a ao dwindle. `Super + Alt + L` percorre os layouts no sentido inverso. Uma janela que já seja flutuante — uma que tenhas destacado com `Super + T`, ou uma aplicação que abre sempre como flutuante — mantém-se flutuante quando a área de trabalho volta ao mosaico. A barra superior assinala a área de trabalho onde estás com o respetivo layout: um quadrado para dwindle, um círculo para scrolling e um triângulo para flutuante. Clicar nessa marca também percorre os layouts, e a tecla do ecrã também o faz nos portáteis que a tenham.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por área de trabalho e mantém-se. Assim, podes manter a área de trabalho 1 em dwindle para navegar e a área de trabalho 2 em scrolling para programar, e elas vão regressar dessa forma depois de um reinício.

Se queres usar o layout scrolling como predefinido, podes defini-lo em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Áreas de trabalho flutuantes

Uma área de trabalho flutuante funciona como um ambiente de trabalho tradicional: as janelas sobrepõem-se e és tu a movê-las e a dimensioná-las. Cada janela recebe uma barra de título com as cores do teu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela focada. Uma janela minimizada fica à espera na dock; clica na sua aplicação para a trazeres de volta. Clica numa janela para a trazeres para a frente. Redimensiona-a a partir de qualquer extremidade ou canto. Faz duplo clique numa barra de título para maximizares a janela sem deixares de ver a barra superior, e outra vez para recuperares o tamanho antigo. O Chrome e outros navegadores baseados em Chromium, o Disks e o Document Viewer ignoram a barra de título e usam, em vez disso, o seu próprio cabeçalho; `Super + Alt + F` maximiza-os e `Super + M` minimiza-os.

Cada área de trabalho tem uma dock, com as tuas aplicações fixadas, tudo o que está em execução e uma grelha com todas as aplicações atrás do botão de aplicações, que `Super + Alt + Space` e _Apps_ no menu Omarchy também abrem. Clica com o botão direito numa aplicação na grelha, ou preme `Delete`, para a desinstalares. Clica numa aplicação para a abrires, ou para trazeres a sua janela para a frente; volta a clicar para percorreres as suas janelas. O Files só traz de volta uma janela da área de trabalho onde estás e, caso contrário, abre uma nova, e o Terminal e o Agent iniciam sempre outra, embora uma janela minimizada volte primeiro. Um clique com o botão do meio abre uma nova janela. Arrasta um ícone ao longo da dock para o moveres; arrastar uma aplicação em execução para entre as outras mantém-na lá. Clica com o botão direito numa aplicação para a manteres na dock, a retirares de lá ou a fechares. A dock fica visível enquanto uma área de trabalho estiver vazia e, assim que a área de trabalho tiver uma janela, esconde-se até o ponteiro atingir a sua extremidade. Uma janela em ecrã inteiro esconde-a por completo. Arrasta o botão de aplicações em direção a outra extremidade do ecrã para moveres a dock para lá. Clica com o botão direito nele para obteres _Position_, com o qual escolhes uma extremidade, e _Layout_, com o qual defines o layout predefinido, da mesma forma que _Appearance > Workspace Layout_. A posição também está em _Appearance > Dock > Dock Position_, e `omarchy dock position left` define-a a partir de um terminal. As aplicações que manténs na dock ficam esbatidas enquanto não estiverem em execução. Para limitar a dock às áreas de trabalho flutuantes, usa _Appearance > Dock > Dock Only on Floating_ ou `omarchy dock tiling off`.

As áreas de trabalho novas, e todas aquelas a que não tenhas atribuído um layout próprio com `Super + L`, usam o layout predefinido. Alterar o layout predefinido faz com que todas as áreas de trabalho sem janelas passem para ele, ao passo que uma área com janelas mantém o layout que tem. Uma janela minimizada para a dock continua a contar como uma janela na área de trabalho que deixou. Escolhe-o em _Appearance > Workspace Layout_: Tiling, Scrolling ou Floating. `omarchy hyprland workspace layout default scrolling` define-o a partir de um terminal.

### Agrupar janelas

As janelas podem ser agrupadas com `Super + G`. Assim que estiveres num grupo, todas as janelas que iniciares enquanto este estiver ativo vão pertencer ao grupo. Podes mover-te entre estas janelas agrupadas com `Super + Ctrl + Arrow Left/Right` ou com `Super + Alt + 1/2/3/4` para ires diretamente para as janelas agrupadas por ordem.

Podes retirar uma janela do grupo com `Super + Alt + G` ou desfazer o grupo inteiro ao premires `Super + G` outra vez. Por fim, podes mover janelas que estejam fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Destacar janelas

Podes destacar uma janela da sua atribuição à área de trabalho com `Super + O`. Isso vai fixá-la como uma janela flutuante que te acompanha para qualquer área de trabalho para onde vás. Ótimo para leitores de vídeo e afins.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Área de trabalho scratchpad

Existe uma área de trabalho scratchpad especial, de tamanho completo, que se sobrepõe à área de trabalho onde estiveres. Acedes ao que está nela com `Super + S` e colocas janelas lá com `Super + Alt + S`.

Funciona bem para controlos ou para um terminal com o qual queres interagir rapidamente sem saíres da área de trabalho atual.

### Consola Quake

Por fim, há uma consola Quake de meia altura que desce sobre a área de trabalho onde estiveres. Alterna-a com `Super + the key above Tab` (grave nas disposições americanas) e coloca lá uma janela com `Super + Shift + the key above Tab`.

Da primeira vez que abre, inicia o teu agente predefinido, ou pede-te que escolhas um caso ainda não tenhas escolhido nenhum. Enquanto a consola tiver apenas uma janela, desce como um painel centrado, em vez de ocupar todo o ecrã. Coloca lá uma segunda aplicação e ela volta à largura total, para que as duas tenham espaço para ficarem lado a lado.

Para retirares uma janela tanto do scratchpad como da consola, envia-a diretamente para outra área de trabalho com algo como `Super + Shift + 1`.

### É preciso habituar-se!

Leva algum tempo até te habituares a navegar no teu ambiente de trabalho desta forma, mas, assim que o fizeres, vai ser difícil voltar à experiência tradicional de um ambiente de trabalho controlado pelo rato!
