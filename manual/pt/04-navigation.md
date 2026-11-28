# Navegação

Tudo no Omarchy acontece através do teclado — _TUDO!_ Quando o sistema arranca pela primeira vez, literalmente não consegues fazer nada só com o rato. Mas podes premir `Super + Space` para revelar o Menu Omarchy e, a partir daí, podes fazer praticamente tudo.

Mas o menu Omarchy nem sequer foi pensado para ser a forma principal de operar o sistema na maior parte do tempo. Conseguimos ser mais rápidos do que isso! Todas as aplicações mais importantes estão associadas diretamente a teclas de atalho individuais. Arrancas o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Experimenta fazer um a seguir ao outro e vais ver a magia da disposição em mosaico do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Depois podes premir `Super + J` para as empilhar uma em cima da outra em vez de as pôr lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Prime `Super + J` outra vez para as devolveres às suas posições lado a lado. Depois experimenta `Super + Shift + Arrow Right` enquanto estás no navegador para trocares as janelas.

Agora experimenta `Super + Shift + T` para iniciar o monitor Activity. Ele vai aparecer como uma janela flutuante, com uma barra de título por onde a podes arrastar e botões para a minimizar, maximizar e fechar. Todas as janelas flutuantes têm uma, onde quer que estejam. Podes pô-la em mosaico com `Super + T` (e premir isso outra vez para a tornar flutuante novamente). Agora prime `Super + Shift + F` para abrir o gestor de ficheiros. Vais ficar com uma bela disposição em quatro:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegas entre a janela que queres ativar com `Super + Arrow`. Isso muda o foco e move o cursor para o centro da nova aplicação. No limite de um ecrã, continua para o monitor desse lado.

Se premires `Super + Shift + 2`, moves a aplicação focada no momento para o segundo espaço de trabalho. `Super + Shift + 1` traz-la de volta. (E `Super + Shift + Alt + 2` move a aplicação focada no momento para o segundo espaço de trabalho sem mudares para ele).

Com mais do que um monitor, cada monitor tem os seus próprios espaços de trabalho de 1 a 10. `Super + 2` vai para o segundo espaço de trabalho do monitor em que estás, e a barra superior de cada monitor mostra os seus próprios espaços de trabalho e aquele que está a apresentar. `Super + Tab` percorre os espaços de trabalho do monitor em que estás. `Super + Shift + Ctrl + Arrows` move a janela em que estás para o monitor nessa direção, para o espaço de trabalho que ele está a apresentar, e `Super + Shift + Alt + Arrows` move o espaço de trabalho em que estás para o monitor nessa direção, onde ele fica com o mesmo número, se estiver livre. Um monitor mantém os seus espaços de trabalho quando o desligas: eles juntam-se aos de outro ecrã, numerados a seguir aos que ele já tem, e voltam aos seus números antigos quando o monitor regressa.

Se mantiveres `Super` premido e usares o rato para clicar numa janela, vais conseguir reorganizar onde ela fica. Se mantiveres `Super` premido e usares o botão direito do rato, podes redimensionar a janela livremente.

Fechas uma janela com `Super + W` ou `Super + Q` (e fechas todas as janelas com `Ctrl + Alt + Delete`).

Também podes ir para ecrã inteiro com `Super + F`, ou até apenas para largura total (mantendo a barra superior) com `Super + Alt + F`, ou para ecrã inteiro dentro de uma janela com `Super + Ctrl + F` (óptimo para o YouTube!).

### Esquema dwindle vs esquema de deslocamento

O esquema predefinido do Omarchy chama-se dwindle. Mantém todas as janelas que abres num único espaço de trabalho visíveis a todo o momento, mesmo que tenha de as encolher.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas também podes optar por transformar um espaço de trabalho no esquema de deslocamento, onde as janelas ficam alinhadas lado a lado, para lá do limite visível do ecrã. Transformas um único espaço de trabalho neste esquema através de `Super + L`.

Premir `Super + L` outra vez torna o espaço de trabalho flutuante, onde as janelas se sobrepõem livremente e és tu a colocá-las, e uma terceira pressão devolve-o a dwindle. `Super + Alt + L` percorre-os na outra direção. Uma janela que já é flutuante de qualquer forma — uma que tenhas retirado com `Super + T`, ou uma aplicação que abre sempre flutuante — mantém-se flutuante quando o espaço de trabalho volta à disposição em mosaico. A barra superior assinala o espaço de trabalho em que estás com o seu esquema: um quadrado para dwindle, um círculo para deslocamento e um triângulo para flutuante. Clicar nessa marca também percorre o esquema, tal como a tecla de ecrã nos portáteis que a têm.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por espaço de trabalho e mantém-se. Por isso podes manter o espaço de trabalho 1 em dwindle para navegar e o espaço de trabalho 2 em deslocamento para código, e eles vão voltar dessa forma depois de um reinício.

Se quiseres usar o esquema de deslocamento como predefinido, podes defini-lo em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espaços de trabalho flutuantes

Um espaço de trabalho flutuante funciona como um ambiente de trabalho tradicional: as janelas sobrepõem-se e és tu a movê-las e a dimensioná-las. Cada janela recebe uma barra de título nas cores do teu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela focada. Uma janela minimizada fica à espera na dock; clica na sua aplicação para a trazeres de volta. Clica numa janela para a trazeres para a frente. Redimensiona-a a partir de qualquer extremidade ou canto. Faz duplo clique numa barra de título para maximizar a janela mantendo a barra superior visível, e outra vez para recuperares o seu tamanho antigo. O Chrome e outros navegadores baseados em Chromium, o Disks e o Document Viewer ignoram a barra de título e usam antes o seu próprio cabeçalho; `Super + Alt + F` maximiza-os e `Super + M` minimiza-os.

Todos os espaços de trabalho têm uma dock, com as tuas aplicações fixadas, tudo o que está a correr e uma grelha de todas as aplicações por trás do botão de aplicações, que `Super + Alt + Space` e _Apps_ no menu Omarchy também abrem. Clica com o botão direito numa aplicação na grelha, ou prime `Delete`, para a desinstalar. Clica numa aplicação para a abrir, ou para trazeres a sua janela para a frente; clica outra vez para percorreres as suas janelas. O Files só traz de volta uma janela do espaço de trabalho em que estás e, caso contrário, abre uma nova, e o Terminal e o Agent iniciam sempre outra, embora uma janela minimizada volte primeiro. Um clique com o botão do meio abre uma nova janela. Arrasta um ícone ao longo da dock para o moveres; arrastar uma aplicação em execução para junto das outras mantém-na lá. Clica com o botão direito para manteres uma aplicação na dock, a retirares de lá ou a fechares. A dock mantém-se visível enquanto um espaço de trabalho está vazio e, assim que o espaço de trabalho tem uma janela, esconde-se até o ponteiro chegar à sua extremidade. Uma janela em ecrã inteiro esconde-a por completo. Arrasta o botão de aplicações em direção a outra extremidade do ecrã para moveres a dock para lá. Clica nele com o botão direito para _Position_, para escolheres uma extremidade, _Layout_, para definires o esquema predefinido tal como _Appearance > Workspace Layout_ faz, e _Visibility_, para manteres a dock sempre ligada, fazeres com que a primeira aplicação a esconda, ou a manteres sempre escondida. `omarchy dock visibility always` define isso a partir de um terminal. A posição também está em _Appearance > Dock > Dock Position_, e `omarchy dock position left` define-a a partir de um terminal. As aplicações que manténs na dock ficam esbatidas enquanto não estão a correr. Para restringires a dock aos espaços de trabalho flutuantes, usa _Appearance > Dock > Dock Only on Floating_ ou `omarchy dock tiling off`.

Os espaços de trabalho novos, e todos aqueles a que não tenhas dado um esquema próprio com `Super + L`, usam o esquema predefinido. Mudar a predefinição repõe nela todos os espaços de trabalho sem janelas, enquanto um que tenha janelas mantém o esquema que tem. Uma janela minimizada para a dock continua a contar como uma janela no espaço de trabalho de onde saiu. Escolhe-o em _Appearance > Workspace Layout_: Tiling, Scrolling ou Floating. `omarchy hyprland workspace layout default scrolling` define-o a partir de um terminal.

### Agrupar janelas

As janelas podem ser agrupadas com `Super + G`. Assim que estiveres num grupo, todas as janelas que iniciares enquanto ele estiver activo vão pertencer ao grupo. Podes mover-te entre estas janelas agrupadas com `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` para ires diretamente para as janelas agrupadas por ordem.

Podes mover uma janela para fora do agrupamento com `Super + Alt + G` ou desmontar o grupo inteiro premindo `Super + G` outra vez. Por fim, podes mover janelas de fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Retirar janelas

Podes retirar uma janela da sua atribuição de espaço de trabalho com `Super + O`. Isso vai fixá-la como uma janela flutuante que te segue para qualquer espaço de trabalho a que vás. Óptimo para leitores de vídeo e afins.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espaço de trabalho scratchpad

Há um espaço de trabalho scratchpad especial de tamanho completo que se sobrepõe ao espaço de trabalho em que estás no momento. Acedes ao que está nele com `Super + S` e colocas janelas lá com `Super + Alt + S`.

Funciona bem para controlos ou para um terminal com que queres interagir rapidamente sem saíres do espaço de trabalho actual.

### Consola Quake

Por fim, há uma consola Quake de meia altura que desce sobre qualquer espaço de trabalho em que estejas no momento. Activa-a e desactiva-a com `Super + the key above Tab` (grave nos esquemas dos EUA) e coloca uma janela lá com `Super + Shift + the key above Tab`.

Da primeira vez que abre, inicia o teu agente predefinido, ou pede-te para escolheres um, se ainda não tiveres escolhido nenhum. Enquanto a consola tiver uma única janela, desce como um painel centrado em vez de abranger todo o ecrã. Põe uma segunda aplicação nela e ela volta à largura total, para as duas terem espaço para ficarem lado a lado.

Para moveres uma janela para fora do scratchpad ou da consola, envia-a diretamente para outro espaço de trabalho com algo como `Super + Shift + 1`.

### É preciso algum tempo para te habituares!

Demora algum tempo até te habituares a navegar no teu ambiente de trabalho desta forma, mas assim que o fizeres, vai ser difícil voltares a uma experiência tradicional de ambiente de trabalho orientada pelo rato!
