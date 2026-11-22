# Navegação

Tudo no Omarchy acontece através do teclado — _TUDO!_ Quando o sistema arranca pela primeira vez, literalmente não consegues fazer nada só com o rato. Mas podes carregar em `Super + Space` para revelar o Menu Omarchy e, a partir daqui, podes fazer praticamente tudo.

Mas o menu Omarchy nem sequer foi pensado para ser a forma principal de operar o sistema na maior parte do tempo. Conseguimos ser mais rápidos do que isso! Todas as aplicações mais importantes estão associadas diretamente a teclas de atalho individuais. Arrancas o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Experimenta fazer um a seguir ao outro e vais ver a magia do tiling do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Podes depois carregar em `Super + J` para as empilhar uma em cima da outra em vez de ficarem lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Carrega outra vez em `Super + J` para as devolver às suas posições lado a lado. Depois experimenta `Super + Shift + Arrow Right` enquanto estás no navegador para trocar as janelas.

Agora experimenta `Super + Shift + T` para arrancar o monitor de Atividade. Isso vai aparecer como uma janela flutuante. Podes colocá-la em mosaico com `Super + T` (e carregar outra vez nessa combinação para a tornar flutuante de novo). Agora carrega em `Super + Shift + F` para abrir o gestor de ficheiros. Vais ficar com uma bela configuração de quatro janelas:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegas entre a janela que queres que esteja ativa com `Super + Arrow`. Isto muda o foco e move o cursor para o centro da nova aplicação. No limite de um ecrã, continua para o monitor desse lado.

Se carregares em `Super + Shift + 2`, moves a aplicação focada no momento para o segundo espaço de trabalho. `Super + Shift + 1` move-a de volta. (E `Super + Shift + Alt + 2` move a aplicação focada no momento para o segundo espaço de trabalho sem mudar para ele.)

Com mais do que um monitor, cada monitor tem os seus próprios espaços de trabalho de 1 a 10. `Super + 2` vai para o segundo espaço de trabalho do monitor onde estás, e a barra superior de cada monitor mostra os seus próprios espaços de trabalho e aquele que está a mostrar. `Super + Tab` percorre os espaços de trabalho do monitor onde estás. `Super + Shift + Ctrl + Arrows` move a janela onde estás para o monitor nessa direção, para o espaço de trabalho que ele está a mostrar, e `Super + Shift + Alt + Arrows` move o espaço de trabalho onde estás para o monitor nessa direção, onde ele fica com o mesmo número se estiver livre. Um monitor mantém os seus espaços de trabalho quando o desligas: eles juntam-se aos de outro ecrã, numerados a seguir aos que ele já tem, e voltam aos seus números antigos quando o monitor regressa.

Se mantiveres premida a tecla `Super` e usares o rato para clicar numa janela, vais conseguir reorganizar onde ela fica. Se mantiveres premida a tecla `Super` e usares o botão direito do rato, podes redimensionar a janela livremente.

Fechas uma janela com `Super + W` ou `Super + Q` (e fechas todas as janelas com `Ctrl + Alt + Delete`).

Também podes passar para ecrã inteiro com `Super + F`, ou até apenas para a largura total (a manter a barra superior) com `Super + Alt + F`, ou para ecrã inteiro dentro de uma janela com `Super + Ctrl + F` (bom para o YouTube!).

### Dwindle vs. layout scrolling

O layout predefinido do Omarchy chama-se dwindle. Mantém todas as janelas que abres num único espaço de trabalho visíveis a todo o momento, mesmo que tenha de as encolher.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas também podes optar por transformar um espaço de trabalho no layout scrolling, onde as janelas ficam alinhadas lado a lado, para lá do limite visível do ecrã. Transformas um único espaço de trabalho neste layout através de `Super + L`.

Carregar outra vez em `Super + L` torna o espaço de trabalho flutuante, onde as janelas se sobrepõem livremente e és tu que as colocas, e um terceiro toque devolve-o ao dwindle. `Super + Alt + L` percorre-os na ordem inversa. Uma janela que já seja flutuante de qualquer forma — uma que tenhas retirado com `Super + T`, ou uma aplicação que abre sempre flutuante — continua flutuante quando o espaço de trabalho volta ao tiling. A barra superior marca o espaço de trabalho onde estás com o seu layout: um quadrado para o dwindle, um círculo para o scrolling e um triângulo para o flutuante. Clicar nessa marca também percorre o layout, e o mesmo acontece com a tecla de ecrã dos computadores portáteis que têm uma.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por espaço de trabalho, e fica guardada. Por isso, podes manter o espaço de trabalho 1 em dwindle para navegar e o espaço de trabalho 2 em scrolling para código, e eles vão voltar dessa forma depois de um reinício.

Se quiseres usar o layout scrolling como predefinido, podes defini-lo em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espaços de trabalho flutuantes

Um espaço de trabalho flutuante funciona como um ambiente de trabalho tradicional: as janelas sobrepõem-se e és tu que as moves e dimensionas. Cada janela recebe uma barra de título nas cores do teu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela focada. Uma janela minimizada espera na dock; clica na sua aplicação para a trazer de volta. Clica numa janela para a trazer para a frente. Redimensiona-a a partir de qualquer limite ou canto. Faz duplo clique numa barra de título para maximizar a janela e manter a barra superior à vista, e faz duplo clique outra vez para recuperar o seu tamanho antigo. O Chrome e outros navegadores baseados em Chromium, o Disks e o Document Viewer ignoram a barra de título e usam antes o seu próprio cabeçalho; `Super + Alt + F` maximiza-os e `Super + M` minimiza-os.

Um espaço de trabalho flutuante também mostra uma dock, com as tuas aplicações fixadas, tudo o que está a correr e uma grelha de todas as aplicações por trás do botão de aplicações, que `Super + Alt + Space` e _Aplicações_ no menu Omarchy também abrem. Clica com o botão direito numa aplicação na grelha, ou carrega em `Delete`, para a desinstalar. Clica numa aplicação para a abrir, ou para trazer a sua janela para a frente; clica outra vez para percorrer as suas janelas. O Files só traz de volta uma janela do espaço de trabalho onde estás e, caso contrário, abre uma nova, e o Terminal e o Agent arrancam sempre outra, embora uma janela minimizada volte primeiro. Clicar com o botão do meio abre uma nova janela. Arrasta um ícone ao longo da dock para o mover; arrastar uma aplicação em execução para o meio das outras mantém-na lá. Clica com o botão direito para manter uma aplicação na dock, para a retirar de lá ou para a fechar. A dock sai do caminho de uma janela em ecrã inteiro. Clica com o botão direito no botão de aplicações para mover a dock para outro limite ou para a fazer esconder-se até o ponteiro chegar ao seu limite. A posição também está em _Aparência > Dock > Posição da Dock_, e `omarchy dock position left` e `omarchy dock autohide on` definem ambas a partir de um terminal. As aplicações que manténs na dock ficam esbatidas enquanto não estiverem a correr.

Os novos espaços de trabalho, e qualquer um a que não tenhas dado um layout próprio com `Super + L`, usam o layout predefinido. Mudar a predefinição repõe todos os espaços de trabalho sem janelas nesse layout, enquanto um espaço de trabalho com janelas mantém o layout que tem. Uma janela minimizada para a dock continua a contar como uma janela no espaço de trabalho de onde saiu. Escolhe-o em _Aparência > Layout do Espaço de Trabalho_: Tiling, Scrolling ou Floating. `omarchy hyprland workspace layout default scrolling` define-o a partir de um terminal.

### Agrupar janelas

As janelas podem ser agrupadas com `Super + G`. Quando estiveres num grupo, todas as janelas que arrancares enquanto esse grupo estiver ativo vão pertencer ao grupo. Podes mover-te entre estas janelas agrupadas com `Super + Ctrl + Arrow Left/Right` ou com `Super + Alt + 1/2/3/4` para ires diretamente para as janelas agrupadas por ordem.

Podes mover uma janela para fora do agrupamento com `Super + Alt + G` ou desmontar o grupo inteiro ao carregar outra vez em `Super + G`. Por fim, podes mover janelas de fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Destacar janelas

Podes destacar uma janela da sua atribuição ao espaço de trabalho com `Super + O`. Isso fixa-a como uma janela flutuante que te segue para qualquer espaço de trabalho a que vás. Ótimo para leitores de vídeo e afins.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espaço de trabalho scratchpad

Existe um espaço de trabalho scratchpad especial, de tamanho total, que se sobrepõe ao espaço de trabalho onde estás no momento. Acedes ao que está nele com `Super + S` e colocas lá janelas com `Super + Alt + S`.

Funciona bem para controlos ou para um terminal com que queiras interagir rapidamente sem sair do espaço de trabalho atual.

### Consola Quake

Por fim, existe uma consola Quake com metade da altura que desce sobre o espaço de trabalho onde estás no momento. Alterna-a com `Super + Grave` e coloca lá uma janela com `Super + Shift + Grave`.

Na primeira vez que abre, arranca o teu agente predefinido, ou pede-te para escolheres um, se ainda não tiveres escolhido nenhum. Enquanto a consola tiver uma única janela, desce como um painel centrado em vez de ocupar todo o ecrã. Coloca lá uma segunda aplicação e ela volta à largura total, para as duas terem espaço para ficarem lado a lado.

Para mover uma janela para fora do scratchpad ou da consola, envia-a diretamente para outro espaço de trabalho com algo como `Super + Shift + 1`.

### É preciso habituar-se!

Leva algum tempo até te habituares a navegar no teu ambiente de trabalho desta forma, mas, quando o fizeres, vai ser difícil voltar a uma experiência tradicional de ambiente de trabalho controlada pelo rato!
