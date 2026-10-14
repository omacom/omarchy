# Navegação

Tudo no Omarchy acontece através do teclado — _TUDO!_ Quando o sistema arranca pela primeira vez, literalmente não consegues fazer nada só com o rato. Mas podes carregar em `Super + Space` para revelar o Menu Omarchy e, a partir daqui, fazer praticamente tudo.

Mas o menu Omarchy nem sequer foi pensado para ser a forma principal de operar o sistema na maior parte do tempo. Conseguimos ser mais rápidos do que isso! Todas as aplicações mais importantes estão associadas diretamente a atalhos individuais. Arrancas o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Experimenta fazer um a seguir ao outro e vais ver a magia do tiling do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Podes depois carregar em `Super + J` para as empilhar uma em cima da outra em vez de lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Carrega outra vez em `Super + J` para as devolver às suas posições lado a lado. Depois experimenta `Super + Shift + Arrow Right` enquanto estás no navegador para trocar as janelas.

Agora experimenta `Super + Ctrl + T` para arrancar o monitor Activity. Esse vai aparecer como uma janela flutuante. Podes colocá-lo em tiling com `Super + T` (e carregar outra vez nisso para o tornar flutuante outra vez). Agora carrega em `Super + Shift + F` para abrir o gestor de ficheiros. Vais ficar com uma arrumação impecável em quatro:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegas entre as janelas para escolheres a que queres ativa com `Super + Arrow`. Isto muda o foco e move o cursor para o centro da nova aplicação.

Se carregares em `Super + Shift + 2`, moves a aplicação atualmente em foco para o segundo espaço de trabalho. `Super + Shift + 1` move-a de volta. (E `Super + Shift + Alt + 2` move a aplicação atualmente em foco para o segundo espaço de trabalho sem mudar para ele).

Se mantiveres `Super` carregado e usares o rato para clicar numa janela, vais conseguir reorganizar onde ela fica. Se mantiveres `Super` carregado e usares o botão direito do rato, podes redimensionar a janela livremente.

Fechas uma janela com `Super + W` ou `Super + Q` (e fechas todas as janelas com `Ctrl + Alt + Delete`).

Também podes ir para ecrã inteiro com `Super + F` ou até apenas para largura total (mantendo a barra superior) com `Super + Alt + F` ou para ecrã inteiro dentro de uma janela com `Super + Ctrl + F` (ótimo para o YouTube!).

### Esquema dwindle vs scrolling

O esquema predefinido do Omarchy chama-se dwindle. Mantém todas as janelas que abres num único espaço de trabalho sempre visíveis, mesmo que tenha de as encolher.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas também podes escolher transformar um espaço de trabalho no esquema scrolling, onde as janelas ficam alinhadas lado a lado, para além do limite visível do ecrã. Transformas um único espaço de trabalho neste esquema através de `Super + L`.

Carregar outra vez em `Super + L` torna o espaço de trabalho flutuante, onde as janelas se sobrepõem livremente e és tu que as colocas, e um terceiro toque devolve-o ao dwindle. `Super + Alt + L` percorre-os no sentido inverso. Uma janela que já flutua de qualquer forma — uma que destacaste com `Super + T`, ou uma aplicação que abre sempre flutuante — continua a flutuar quando o espaço de trabalho volta ao tiling. A barra superior assinala o espaço de trabalho onde estás com o respetivo esquema: um quadrado para dwindle, um círculo para scrolling e um triângulo para flutuante. Clicar nessa marca também percorre os esquemas.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por espaço de trabalho e mantém-se. Por isso podes manter o espaço de trabalho 1 em dwindle para navegar e o espaço de trabalho 2 em scrolling para código, e eles vão voltar assim depois de um reinício.

Se quiseres usar o esquema scrolling como predefinição, podes defini-lo em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espaços de trabalho flutuantes

Um espaço de trabalho flutuante funciona como um ambiente de trabalho tradicional: as janelas sobrepõem-se e és tu que as moves e dimensionas. Cada janela recebe uma barra de título nas cores do teu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela em foco. Uma janela minimizada fica à espera na dock; clica na sua aplicação para a trazer de volta. Clica numa janela para a trazer para a frente. Redimensiona-a a partir de qualquer margem ou canto. Faz duplo clique numa barra de título para maximizar a janela mantendo a barra superior visível, e outra vez para recuperar o seu tamanho antigo.

Um espaço de trabalho flutuante também mostra uma dock, com as tuas aplicações afixadas, tudo o que está a correr e uma grelha de todas as aplicações atrás do botão de aplicações, que `Super + Alt + Space` e _Apps_ no menu Omarchy também abrem. Clica com o botão direito numa aplicação da grelha, ou carrega em `Delete`, para a desinstalar. Clica numa aplicação para a abrir, ou para trazer a sua janela para a frente; clica outra vez para percorrer as suas janelas. O clique do meio abre uma nova janela. Arrasta um ícone ao longo da dock para o mover; arrastar uma aplicação em execução para o meio das outras mantém-na aí. Clica com o botão direito para manter uma aplicação na dock, retirá-la ou sair dela. A dock sai do caminho de uma janela em ecrã inteiro. Clica com o botão direito no botão de aplicações para mover a dock para outra margem ou fazer com que se esconda até o ponteiro chegar à sua margem. A posição também está em _Trigger > Appearance > Dock > Dock Position_, e `omarchy dock position left` e `omarchy dock autohide on` definem ambas a partir de um terminal. As aplicações que manténs na dock ficam esbatidas enquanto não estão a correr.

Os espaços de trabalho novos, e qualquer um a que não tenhas dado um esquema próprio com `Super + L`, usam o esquema predefinido. Alterar a predefinição repõe nela todos os espaços de trabalho sem janelas, enquanto um que tenha janelas mantém o esquema que tem. Uma janela minimizada para a dock continua a contar como uma janela no espaço de trabalho de onde saiu. Escolhe-o em _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling ou Floating. `omarchy-hyprland-workspace-layout-default scrolling` define-o a partir de um terminal.

### Agrupar janelas

As janelas podem ser agrupadas com `Super + G`. Assim que estiveres num grupo, todas as janelas que arrancares enquanto isso estiver ativo vão pertencer ao grupo. Podes mover-te entre estas janelas agrupadas com `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` para ir diretamente para a janela agrupada por ordem.

Podes mover uma janela para fora do agrupamento com `Super + Alt + G` ou desmontar o grupo inteiro carregando outra vez em `Super + G`. Por fim, podes mover janelas de fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Destacar janelas

Podes destacar uma janela da sua atribuição ao espaço de trabalho com `Super + O`. Isso vai afixá-la como uma janela flutuante que te segue para qualquer espaço de trabalho onde fores. Ótimo para leitores de vídeo e afins.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espaço de trabalho scratchpad

Por fim, existe um espaço de trabalho scratchpad especial que desce sobre qualquer espaço de trabalho onde estejas de momento, muito parecido com uma consola do Quake. Alterna-o com `Super + Grave` ou `Super + S` e coloca lá uma janela com `Super + Shift + Grave` ou `Super + Alt + S`.

Funciona especialmente bem para um terminal que esteja a correr um agente, ou para controlos com que queiras interagir rapidamente sem sair do espaço de trabalho atual. Para retirar uma janela do scratchpad, envia-a diretamente para outro espaço de trabalho com algo como `Super + Shift + 1`.

Enquanto o scratchpad tiver uma única janela, desce como um painel centrado em vez de ocupar todo o ecrã. Coloca lá uma segunda aplicação e ele volta à largura total, para as duas terem espaço para ficarem lado a lado.

### É preciso habituar-se!

É preciso algum tempo para te habituares a navegar no teu ambiente de trabalho assim, mas assim que o fizeres, vai ser difícil voltar a uma experiência tradicional de ambiente de trabalho conduzida pelo rato!
