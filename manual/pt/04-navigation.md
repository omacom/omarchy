# Navegação

Tudo no Omarchy acontece através do teclado — _TUDO!_ Quando o sistema arranca pela primeira vez, literalmente não consegue fazer nada só com o rato. Mas pode premir `Super + Space` para revelar o Menu Omarchy e, a partir daí, pode fazer praticamente tudo.

Mas o menu Omarchy nem sequer foi pensado para ser a principal forma de operar o sistema na maior parte do tempo. Conseguimos ser mais rápidos do que isso! Todas as aplicações mais importantes estão associadas diretamente a teclas de atalho individuais. Arranca o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Experimente fazer uma coisa a seguir à outra e verá a magia da disposição em mosaico do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pode depois premir `Super + J` para as empilhar uma por cima da outra, em vez de as colocar lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Prima `Super + J` outra vez para as devolver às posições lado a lado. Depois experimente `Super + Shift + Arrow Right` enquanto está no navegador para trocar as janelas.

Agora experimente `Super + Shift + T` para arrancar o monitor de Atividade. Esse vai aparecer como uma janela flutuante. Pode colocá-lo em mosaico com `Super + T` (e premir outra vez para o voltar a tornar flutuante). Agora prima `Super + Shift + F` para abrir o gestor de ficheiros. Terá uma configuração elegante em quatro partes:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navega entre as janelas para escolher a que quer ter ativa com `Super + Arrow`. Isto muda o foco e move o cursor para o centro da nova aplicação. Na extremidade de um ecrã, continua para o monitor que estiver desse lado.

Se premir `Super + Shift + 2`, move a aplicação focada atualmente para o segundo espaço de trabalho. `Super + Shift + 1` move-a de volta. (E `Super + Shift + Alt + 2` move a aplicação focada atualmente para o segundo espaço de trabalho sem mudar para ele).

Com mais do que um monitor, cada monitor tem os seus próprios espaços de trabalho de 1 a 10. `Super + 2` vai para o segundo espaço de trabalho do monitor em que está, e a barra superior de cada monitor mostra os seus próprios espaços de trabalho e aquele que está a apresentar. `Super + Tab` percorre os espaços de trabalho do monitor em que está. `Super + Shift + Ctrl + Arrows` move a janela em que está para o monitor nessa direção, para o espaço de trabalho que ele está a apresentar, e `Super + Shift + Alt + Arrows` move o espaço de trabalho em que está para o monitor nessa direção, onde fica com o mesmo número, se estiver livre. Um monitor mantém os seus espaços de trabalho quando o desliga: juntam-se aos de outro ecrã, numerados a seguir aos que esse já tem, e voltam aos números antigos quando o monitor regressa.

Se mantiver premida a tecla `Super` e usar o rato para clicar numa janela, poderá reorganizar a posição que ela ocupa. Se mantiver premida a tecla `Super` e usar o botão direito do rato, pode redimensionar livremente a janela.

Fecha uma janela com `Super + W` ou `Super + Q` (e fecha todas as janelas com `Ctrl + Alt + Delete`).

Também pode passar para ecrã inteiro com `Super + F`, ou mesmo apenas para a largura total (mantendo a barra superior) com `Super + Alt + F`, ou para ecrã inteiro dentro de uma janela com `Super + Ctrl + F` (bom para o YouTube!).

### Dwindle vs. disposição em deslocamento

A disposição predefinida do Omarchy chama-se dwindle. Mantém todas as janelas que abrir num único espaço de trabalho sempre visíveis, mesmo que tenha de as encolher.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas também pode optar por transformar um espaço de trabalho na disposição em deslocamento, em que as janelas ficam alinhadas lado a lado, para além da extremidade visível do ecrã. Transforma um único espaço de trabalho nesta disposição através de `Super + L`.

Premir `Super + L` outra vez torna o espaço de trabalho flutuante, em que as janelas se sobrepõem livremente e é o utilizador que as coloca, e uma terceira pressão devolve-o a dwindle. `Super + Alt + L` percorre-as na direção oposta. Uma janela que já seja flutuante de qualquer forma — uma que tenha retirado com `Super + T`, ou uma aplicação que abra sempre como flutuante — continua flutuante quando o espaço de trabalho volta à disposição em mosaico. A barra superior assinala o espaço de trabalho em que está com a sua disposição: um quadrado para dwindle, um círculo para deslocamento e um triângulo para flutuante. Clicar nessa marca também percorre a disposição.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é feita por espaço de trabalho e mantém-se. Por isso, pode manter o espaço de trabalho 1 em dwindle para navegar e o espaço de trabalho 2 em deslocamento para código, e eles voltarão dessa forma depois de um reinício.

Se quiser usar a disposição em deslocamento como predefinição, pode defini-la em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espaços de trabalho flutuantes

Um espaço de trabalho flutuante funciona como um ambiente de trabalho tradicional: as janelas sobrepõem-se e é o utilizador que as move e dimensiona. Cada janela recebe uma barra de título nas cores do seu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela focada. Uma janela minimizada fica à espera na dock; clique na sua aplicação para a trazer de volta. Clique numa janela para a trazer para a frente. Redimensione-a a partir de qualquer extremidade ou canto. Faça duplo clique numa barra de título para maximizar a janela mantendo a barra superior visível, e outra vez para recuperar o tamanho antigo.

Um espaço de trabalho flutuante também mostra uma dock, com as suas aplicações fixadas, tudo o que está a ser executado e uma grelha de todas as aplicações por trás do botão de aplicações, que `Super + Alt + Space` e _Aplicações_ no menu Omarchy também abrem. Clique com o botão direito numa aplicação na grelha, ou prima `Delete`, para a desinstalar. Clique numa aplicação para a abrir, ou para trazer a sua janela para a frente; clique outra vez para percorrer as suas janelas. O clique com o botão do meio abre uma nova janela. Arraste um ícone ao longo da dock para o mover; arrastar uma aplicação em execução para o meio das outras mantém-na lá. Clique com o botão direito para manter uma aplicação na dock, retirá-la de lá ou terminá-la. A dock sai do caminho de uma janela em ecrã inteiro. Clique com o botão direito no botão de aplicações para mover a dock para outra extremidade ou para fazer com que se oculte até o ponteiro chegar à sua extremidade. A posição também está em _Aspeto > Dock > Posição do Dock_, e `omarchy dock position left` e `omarchy dock autohide on` definem ambas a partir de um terminal. As aplicações que mantiver na dock ficam esbatidas enquanto não estiverem a ser executadas.

Os novos espaços de trabalho, e quaisquer espaços a que não tenha dado uma disposição própria com `Super + L`, usam a disposição predefinida. Alterar a predefinição redefine para ela todos os espaços de trabalho sem janelas, ao passo que um espaço com janelas mantém a disposição que tem. Uma janela minimizada para a dock continua a contar como uma janela no espaço de trabalho de onde saiu. Escolha-a em _Aspeto > Disposição do Espaço de Trabalho_: Em Mosaico, Em Deslocamento ou Flutuante. `omarchy-hyprland-workspace-layout-default scrolling` define-a a partir de um terminal.

### Agrupar janelas

As janelas podem ser agrupadas com `Super + G`. Quando estiver num grupo, todas as janelas que arrancar enquanto esse estiver ativo pertencerão ao grupo. Pode mover-se entre estas janelas agrupadas com `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` para ir diretamente para a janela agrupada por ordem.

Pode mover uma janela para fora do agrupamento com `Super + Alt + G` ou desmontar todo o grupo premindo `Super + G` outra vez. Por fim, pode mover janelas que estão fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Destacar janelas

Pode destacar uma janela da sua atribuição ao espaço de trabalho com `Super + O`. Isso vai fixá-la como uma janela flutuante que o acompanha para qualquer espaço de trabalho para onde vá. Ótimo para leitores de vídeo e coisas do género.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espaço de trabalho scratchpad

Há um espaço de trabalho scratchpad especial de tamanho completo que se sobrepõe ao espaço de trabalho em que estiver atualmente. Acede ao que está nele com `Super + S` e coloca lá janelas com `Super + Alt + S`.

Funciona bem para controlos ou para um terminal com que queira interagir rapidamente sem sair do espaço de trabalho atual.

### Consola Quake

Por fim, há uma consola Quake de meia altura que desce sobre o espaço de trabalho em que estiver atualmente. Ative-a e desative-a com `Super + Grave` e coloque lá uma janela com `Super + Shift + Grave`.

Abre com o seu agente predefinido pronto a arrancar. Enquanto a consola tiver uma única janela, desce como um painel centrado, em vez de ocupar todo o ecrã. Coloque nela uma segunda aplicação e ela volta à largura total, para que as duas tenham espaço para ficarem lado a lado.

Para mover uma janela para fora do scratchpad ou da consola, envie-a diretamente para outro espaço de trabalho com algo como `Super + Shift + 1`.

### É preciso habituar-se!

Demora um pouco a habituar-se a navegar no seu ambiente de trabalho desta forma, mas, quando o fizer, será difícil voltar a uma experiência tradicional de ambiente de trabalho controlado pelo rato!
