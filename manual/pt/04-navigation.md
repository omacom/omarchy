# Navegação

Tudo no Omarchy acontece através do teclado — _TUDO!_ Quando o sistema arranca pela primeira vez, literalmente não consegues fazer nada só com o rato. Mas podes premir `Super + Space` para revelar o Menu Omarchy e, a partir daqui, podes fazer praticamente tudo.

Mas o menu Omarchy nem sequer foi pensado para ser a forma principal de operar o sistema a maior parte do tempo. Conseguimos ser mais rápidos do que isso! Todas as aplicações mais importantes estão associadas diretamente a teclas de atalho individuais. Arrancas o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Experimenta fazer um a seguir ao outro e vais ver a magia do tiling do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Depois podes premir `Super + J` para as empilhar uma em cima da outra em vez de lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Prime `Super + J` outra vez para as devolver às suas posições lado a lado. Depois experimenta `Super + Shift + Arrow Right` enquanto estás no navegador para trocar as janelas.

Agora experimenta `Super + Shift + T` para iniciar o monitor de atividade. Este vai aparecer como uma janela flutuante. Podes colocá-lo em mosaico com `Super + T` (e premir isso outra vez para o tornar flutuante novamente). Agora prime `Super + Shift + F` para abrir o gestor de ficheiros. Ficas com uma configuração impecável em quatro partes:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegas entre as janelas para escolheres a que queres que esteja ativa com `Super + Arrow`. Isto muda o foco e move o cursor para o centro da nova aplicação. No limite de um ecrã, continua para o monitor desse lado.

Se premires `Super + Shift + 2`, moves a aplicação atualmente em foco para o segundo espaço de trabalho. `Super + Shift + 1` volta a colocá-la no primeiro. (E `Super + Shift + Alt + 2` move a aplicação atualmente em foco para o segundo espaço de trabalho sem mudar para ele).

Com mais do que um monitor, cada monitor tem os seus próprios espaços de trabalho de 1 a 10. `Super + 2` vai para o segundo espaço de trabalho do monitor onde estás, e a barra superior de cada monitor mostra os seus próprios espaços de trabalho e aquele que está a mostrar. `Super + Tab` percorre ciclicamente os espaços de trabalho do monitor onde estás. `Super + Shift + Ctrl + Arrows` move a janela onde estás para o monitor nessa direção, para o espaço de trabalho que este está a mostrar, e `Super + Shift + Alt + Arrows` move o espaço de trabalho onde estás para o monitor nessa direção, onde assume o mesmo número se este estiver livre. Um monitor mantém os seus espaços de trabalho quando o desligas: juntam-se aos de outro ecrã, numerados a seguir aos que este já tem, e voltam aos seus números antigos quando o monitor regressa.

Se mantiveres `Super` premido e usares o rato para clicar numa janela, vais conseguir reorganizar onde ela fica. Se mantiveres `Super` premido e usares o botão direito do rato, podes redimensionar a janela livremente.

Fechas uma janela com `Super + W` ou `Super + Q` (e fechas todas as janelas com `Ctrl + Alt + Delete`).

Também podes passar para ecrã inteiro com `Super + F`, ou apenas para largura total (mantendo a barra superior) com `Super + Alt + F`, ou para ecrã inteiro dentro de uma janela com `Super + Ctrl + F` (ótimo para o YouTube!).

### Layout dwindle vs scrolling

O layout predefinido do Omarchy chama-se dwindle. Mantém todas as janelas que abres num único espaço de trabalho visíveis a todo o momento, mesmo que tenha de as encolher.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas também podes optar por transformar um espaço de trabalho no layout scrolling, em que as janelas ficam alinhadas lado a lado, para lá do limite visível do ecrã. Transformas um único espaço de trabalho neste layout através de `Super + L`.

Premir `Super + L` outra vez torna o espaço de trabalho flutuante, em que as janelas se sobrepõem livremente e és tu a colocá-las, e uma terceira pressão devolve-o a dwindle. `Super + Alt + L` percorre-os no sentido inverso. Uma janela que já é flutuante de qualquer forma — uma que destacaste com `Super + T`, ou uma aplicação que abre sempre em modo flutuante — continua flutuante quando o espaço de trabalho volta ao modo em mosaico. A barra superior assinala o espaço de trabalho onde estás com o respetivo layout: um quadrado para dwindle, um círculo para scrolling e um triângulo para flutuante. Clicar nessa marca também percorre ciclicamente os layouts.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por espaço de trabalho e mantém-se. Por isso, podes manter o espaço de trabalho 1 em dwindle para navegar e o espaço de trabalho 2 em scrolling para programar, e eles voltam assim depois de um reinício.

Se quiseres usar o layout scrolling como predefinição, podes defini-lo em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espaços de trabalho flutuantes

Um espaço de trabalho flutuante funciona como um ambiente de trabalho tradicional: as janelas sobrepõem-se e és tu a movê-las e a dimensioná-las. Cada janela recebe uma barra de título com as cores do teu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela em foco. Uma janela minimizada fica à espera na dock; clica na respetiva aplicação para a trazer de volta. Clica numa janela para a trazer para a frente. Redimensiona-a a partir de qualquer extremidade ou canto. Faz duplo clique numa barra de título para maximizar a janela mantendo a barra superior visível, e outra vez para recuperar o tamanho antigo.

Um espaço de trabalho flutuante também mostra uma dock, com as tuas aplicações fixadas, tudo o que está a ser executado e uma grelha de todas as aplicações por detrás do botão de aplicações, que `Super + Alt + Space` e _Apps_ no menu Omarchy também abrem. Clica com o botão direito numa aplicação na grelha, ou prime `Delete`, para a desinstalar. Clica numa aplicação para a abrir, ou para trazer a respetiva janela para a frente; clica outra vez para percorrer ciclicamente as suas janelas. Um clique com o botão do meio abre uma nova janela. Arrasta um ícone ao longo da dock para o mover; arrastar uma aplicação em execução para entre as outras mantém-na lá. Clica com o botão direito para manter uma aplicação na dock, retirá-la de lá ou sair dela. A dock sai do caminho de uma janela em ecrã inteiro. Clica com o botão direito no botão de aplicações para mover a dock para outra extremidade ou para fazer com que se oculte até o ponteiro chegar à respetiva extremidade. A posição também está em _Appearance > Dock > Dock Position_, e `omarchy dock position left` e `omarchy dock autohide on` definem ambas a partir de um terminal. As aplicações que manténs na dock ficam esbatidas enquanto não estiverem a ser executadas.

Os novos espaços de trabalho, e qualquer um a que não tenhas dado um layout próprio com `Super + L`, usam o layout predefinido. Alterar a predefinição repõe nela todos os espaços de trabalho sem janelas, enquanto um com janelas mantém o layout que tem. Uma janela minimizada para a dock continua a contar como uma janela no espaço de trabalho que deixou. Escolhe-o em _Appearance > Workspace Layout_: Tiling, Scrolling ou Floating. `omarchy-hyprland-workspace-layout-default scrolling` define-o a partir de um terminal.

### Agrupar janelas

As janelas podem ser agrupadas com `Super + G`. Assim que estiveres num grupo, todas as janelas que iniciares enquanto este estiver ativo pertencem ao grupo. Podes mover-te entre estas janelas agrupadas com `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` para ires diretamente para as janelas agrupadas por ordem.

Podes mover uma janela para fora do agrupamento com `Super + Alt + G` ou desmontar o grupo inteiro premindo `Super + G` outra vez. Por fim, podes mover janelas de fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Destacar janelas

Podes destacar uma janela da sua atribuição ao espaço de trabalho com `Super + O`. Isso fixa-a como uma janela flutuante que te segue para qualquer espaço de trabalho a que vás. Ótimo para leitores de vídeo e coisas do género.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espaço de trabalho scratchpad

Existe um espaço de trabalho scratchpad especial, de tamanho completo, que se sobrepõe ao espaço de trabalho onde estás no momento. Acedes ao que está nele com `Super + S`, e colocas janelas lá com `Super + Alt + S`.

Funciona bem para controlos ou um terminal com que queres interagir rapidamente sem sair do espaço de trabalho atual.

### Consola Quake

Por fim, existe uma consola Quake de meia altura que desce sobre o espaço de trabalho onde estás no momento. Alterna-a com `Super + Grave`, e coloca uma janela lá com `Super + Shift + Grave`.

Abre com o teu agente predefinido pronto a arrancar. Enquanto a consola tiver uma única janela, desce como um painel centrado em vez de ocupar toda a largura do ecrã. Coloca uma segunda aplicação nela e volta à largura total, para as duas terem espaço para ficar lado a lado.

Para mover uma janela para fora do scratchpad ou da consola, envia-a diretamente para outro espaço de trabalho com algo como `Super + Shift + 1`.

### É preciso algum tempo para te habituares!

Demora um pouco a habituares-te a navegar no teu ambiente de trabalho desta forma, mas, assim que te habituares, vai ser difícil voltar a uma experiência de ambiente de trabalho tradicional orientada pelo rato!
