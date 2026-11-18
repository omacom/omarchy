# Navegação

Tudo no Omarchy acontece através do teclado — _TUDO!_ Quando o sistema arranca pela primeira vez, literalmente não consegues fazer nada só com o rato. Mas podes premir `Super + Space` para revelar o Menu Omarchy e, a partir daqui, podes fazer praticamente tudo.

Mas nem sequer é suposto o menu Omarchy ser a principal forma de operar o sistema na maior parte do tempo. Conseguimos ser mais rápidos do que isso! Todas as aplicações mais importantes estão associadas diretamente a teclas de atalho individuais. Inicias o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Experimenta fazer um a seguir ao outro e vais ver a magia do mosaico do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Depois podes premir `Super + J` para as empilhar uma em cima da outra em vez de lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Prime `Super + J` outra vez para as devolver às posições lado a lado. Depois experimenta `Super + Shift + Arrow Right` enquanto estás no navegador para trocar as janelas.

Agora experimenta `Super + Shift + T` para iniciar o Monitor de Atividade. Esse vai aparecer como uma janela flutuante. Podes colocá-lo em mosaico com `Super + T` (e premir isso outra vez para o tornar flutuante outra vez). Agora prime `Super + Shift + F` para abrir o gestor de ficheiros. Vais ficar com uma bela configuração em quatro partes:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegas entre a janela que queres ativar com `Super + Arrow`. Isto muda o foco e move o cursor para o centro da nova aplicação. Na extremidade de um ecrã, continua para o monitor desse lado.

Se premires `Super + Shift + 2`, moves a aplicação com foco atual para o segundo espaço de trabalho. `Super + Shift + 1` move-a de volta. (E `Super + Shift + Alt + 2` move a aplicação com foco atual para o segundo espaço de trabalho sem mudar para ele).

Com mais do que um monitor, cada monitor tem os seus próprios espaços de trabalho de 1 a 10. `Super + 2` vai para o segundo espaço de trabalho do monitor onde estás, e a barra superior de cada monitor mostra os seus próprios espaços de trabalho e aquele que está a mostrar. `Super + Tab` percorre os espaços de trabalho do monitor onde estás. `Super + Shift + Ctrl + Arrows` move a janela onde estás para o monitor nessa direção, para o espaço de trabalho que ele está a mostrar, e `Super + Shift + Alt + Arrows` move o espaço de trabalho onde estás para o monitor nessa direção, onde assume o mesmo número se estiver livre. Um monitor mantém os seus espaços de trabalho quando o desligas: eles juntam-se aos de outro ecrã, numerados a seguir aos que este já tem, e voltam aos números antigos quando o monitor regressa.

Se mantiveres `Super` premido e usares o rato para clicar numa janela, consegues reorganizar onde ela fica. Se mantiveres `Super` premido e usares o botão direito do rato, podes redimensionar a janela livremente.

Fechas uma janela com `Super + W` ou `Super + Q` (e fechas todas as janelas com `Ctrl + Alt + Delete`).

Também podes passar para ecrã inteiro com `Super + F`, ou apenas para largura total (sem esconder a barra superior) com `Super + Alt + F`, ou para ecrã inteiro dentro de uma janela com `Super + Ctrl + F` (ideal para o YouTube!).

### Disposição dwindle vs. scrolling

A disposição predefinida do Omarchy chama-se dwindle. Mantém todas as janelas que abres num único espaço de trabalho visíveis a todo o momento, mesmo que tenha de as encolher.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas também podes optar por transformar um espaço de trabalho na disposição scrolling, onde as janelas ficam alinhadas lado a lado, para lá da extremidade visível do ecrã. Transformas um único espaço de trabalho nesta disposição através de `Super + L`.

Premir `Super + L` outra vez torna o espaço de trabalho flutuante, onde as janelas se sobrepõem livremente e és tu a colocá-las, e uma terceira vez devolve-o a dwindle. `Super + Alt + L` percorre-as na direção oposta. Uma janela que já seja flutuante de qualquer forma — uma que tenhas retirado com `Super + T`, ou uma aplicação que abra sempre como flutuante — continua flutuante quando o espaço de trabalho volta a mosaico. A barra superior assinala o espaço de trabalho onde estás com a sua disposição: um quadrado para dwindle, um círculo para scrolling e um triângulo para flutuante. Clicar nessa marca também percorre as disposições.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por espaço de trabalho e fica guardada. Assim, podes manter o espaço de trabalho 1 em dwindle para navegar e o espaço de trabalho 2 em scrolling para programar, e eles vão voltar assim depois de um reinício.

Se quiseres usar a disposição scrolling como predefinição, podes definir isso em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espaços de trabalho flutuantes

Um espaço de trabalho flutuante funciona como um ambiente de trabalho tradicional: as janelas sobrepõem-se e és tu a movê-las e a dimensioná-las. Cada janela recebe uma barra de título nas cores do teu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela com foco. Uma janela minimizada fica à espera na dock; clica na sua aplicação para a trazer de volta. Clica numa janela para a trazer para a frente. Redimensiona-a a partir de qualquer extremidade ou canto. Faz duplo clique numa barra de título para maximizar a janela sem esconder a barra superior, e outra vez para recuperar o tamanho antigo. O Chrome e outros navegadores baseados em Chromium, o Disks e o Document Viewer ignoram a barra de título e usam o seu próprio cabeçalho; `Super + Alt + F` maximiza-os e `Super + M` minimiza-os.

Um espaço de trabalho flutuante também mostra uma dock, com as tuas aplicações afixadas, tudo o que está em execução e uma grelha de todas as aplicações atrás do botão das aplicações, que `Super + Alt + Space` e _Aplicações_ no menu Omarchy também abrem. Clica com o botão direito numa aplicação na grelha, ou prime `Delete`, para a desinstalar. Clica numa aplicação para a abrir, ou para trazer a sua janela para a frente; clica outra vez para percorrer as suas janelas. O Files só traz de volta uma janela do espaço de trabalho onde estás e, caso contrário, abre uma nova, e o Terminal e o Agent iniciam sempre outra, embora uma janela minimizada volte primeiro. Um clique com o botão do meio abre uma nova janela. Arrasta um ícone ao longo da dock para o mover; arrastar uma aplicação em execução para entre as outras mantém-na lá. Clica com o botão direito para manter uma aplicação na dock, retirá-la de lá ou fechá-la. A dock sai do caminho de uma janela em ecrã inteiro. Clica com o botão direito no botão das aplicações para mover a dock para outra extremidade ou para a esconder até o ponteiro chegar à sua extremidade. A posição também está em _Aparência > Dock > Posição do Dock_, e `omarchy dock position left` e `omarchy dock autohide on` definem ambas a partir de um terminal. As aplicações que manténs na dock ficam esbatidas enquanto não estiverem em execução.

Os espaços de trabalho novos, e qualquer um a que não tenhas dado uma disposição própria com `Super + L`, usam a disposição predefinida. Alterar a predefinição repõe nela todos os espaços de trabalho sem janelas, enquanto um com janelas mantém a disposição que tem. Uma janela minimizada para a dock continua a contar como uma janela no espaço de trabalho de onde saiu. Escolhe-a em _Aparência > Disposição do Espaço de Trabalho_: Mosaico, Scrolling ou Flutuante. `omarchy-hyprland-workspace-layout-default scrolling` define-a a partir de um terminal.

### Agrupar janelas

As janelas podem ser agrupadas com `Super + G`. Assim que estiveres num grupo, todas as janelas que iniciares enquanto esse grupo estiver ativo vão pertencer ao grupo. Podes mover-te entre estas janelas agrupadas com `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` para ir diretamente para as janelas agrupadas por ordem.

Podes mover uma janela para fora do grupo com `Super + Alt + G` ou desfazer o grupo inteiro ao premir `Super + G` outra vez. Por fim, podes mover janelas de fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Destacar janelas

Podes retirar uma janela da atribuição ao seu espaço de trabalho com `Super + O`. Isso vai afixá-la como uma janela flutuante que te segue para qualquer espaço de trabalho para onde vás. Ótimo para reprodutores de vídeo e afins.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espaço de trabalho scratchpad

Existe um espaço de trabalho scratchpad especial de tamanho completo que se sobrepõe a qualquer espaço de trabalho onde estejas de momento. Acedes ao que está nele com `Super + S` e colocas lá janelas com `Super + Alt + S`.

Funciona bem para controlos ou um terminal com que queres interagir rapidamente sem sair do espaço de trabalho atual.

### Consola Quake

Por fim, existe uma consola Quake de meia altura que desce sobre qualquer espaço de trabalho onde estejas de momento. Ativa-a e desativa-a com `Super + Grave` e coloca lá uma janela com `Super + Shift + Grave`.

Abre com o teu agente predefinido pronto a arrancar. Enquanto a consola tiver uma única janela, desce como um painel centrado em vez de ocupar toda a largura do ecrã. Coloca uma segunda aplicação nela e ela volta à largura total, para as duas terem espaço para ficar lado a lado.

Para mover uma janela para fora do scratchpad ou da consola, envia-a diretamente para outro espaço de trabalho com algo como `Super + Shift + 1`.

### É preciso algum tempo para te habituares!

Demora um pouco a habituares-te a navegar no teu ambiente de trabalho assim, mas, assim que te habituares, vai ser difícil voltar a uma experiência tradicional de ambiente de trabalho controlada pelo rato!
