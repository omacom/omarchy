# Navegação

Tudo no Omarchy acontece através do teclado — _TUDO!_ Quando o sistema arranca pela primeira vez, literalmente não consegue fazer nada só com o rato. Mas pode premir `Super + Space` para revelar o Menu Omarchy e, a partir daí, pode fazer praticamente tudo.

Mas nem sequer é suposto o menu Omarchy ser a forma principal de operar o sistema na maior parte do tempo. Conseguimos ser mais rápidos do que isso! Todas as aplicações mais importantes estão associadas diretamente a teclas de atalho individuais. Inicia o terminal com `Super + Return` e um navegador com `Super + Shift + Return`. Experimente fazer um a seguir ao outro e verá a magia do mosaico do Hyprland em ação:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Depois pode premir `Super + J` para as empilhar uma por cima da outra em vez de ficarem lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Volte a premir `Super + J` para as devolver às posições lado a lado. Depois experimente `Super + Shift + Arrow Right` enquanto está no navegador para trocar as janelas.

Agora experimente `Super + Shift + T` para iniciar o monitor de Atividade. Surgirá como uma janela flutuante. Pode colocá-la em mosaico com `Super + T` (e voltar a premir a mesma combinação para a tornar novamente flutuante). Agora prima `Super + Shift + F` para abrir o gestor de ficheiros. Ficará com uma organização impecável em quatro partes:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navega entre as janelas para ativar a que pretende com `Super + Arrow`. Isto muda o foco e move o cursor para o centro da nova aplicação. No limite de um ecrã, continua para o monitor desse lado.

Se premir `Super + Shift + 2`, move a aplicação atualmente em foco para a segunda área de trabalho. `Super + Shift + 1` devolve-a. (E `Super + Shift + Alt + 2` move a aplicação atualmente em foco para a segunda área de trabalho sem mudar para ela).

Com mais do que um monitor, cada monitor tem as suas próprias áreas de trabalho de 1 a 10. `Super + 2` vai para a segunda área de trabalho do monitor onde está, e a barra superior de cada monitor mostra as suas próprias áreas de trabalho e aquela que está a apresentar. `Super + Tab` percorre as áreas de trabalho do monitor onde está. `Super + Shift + Ctrl + Arrows` move a janela onde está para o monitor nessa direção, para a área de trabalho que ele está a apresentar, e `Super + Shift + Alt + Arrows` move a área de trabalho onde está para o monitor nessa direção, onde assume o mesmo número se estiver livre. Um monitor mantém as suas áreas de trabalho quando o desliga: juntam-se às de outro ecrã, numeradas a seguir às que este já tem, e voltam aos números antigos quando o monitor regressa.

Se mantiver premida a tecla `Super` e usar o rato para clicar numa janela, poderá reorganizar a posição onde esta se encontra. Se mantiver premida a tecla `Super` e usar o botão direito do rato, pode redimensionar livremente a janela.

Fecha uma janela com `Super + W` ou `Super + Q` (e fecha todas as janelas com `Ctrl + Alt + Delete`).

Também pode passar para ecrã inteiro com `Super + F`, ou apenas para a largura total (mantendo a barra superior) com `Super + Alt + F`, ou para ecrã inteiro dentro de uma janela com `Super + Ctrl + F` (ótimo para o YouTube!).

### Dwindle vs. esquema de deslocamento

O esquema predefinido do Omarchy chama-se dwindle. Mantém sempre visíveis todas as janelas que abrir numa única área de trabalho, mesmo que tenha de as reduzir.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mas também pode optar por transformar uma área de trabalho no esquema de deslocamento, em que as janelas estão alinhadas lado a lado, para além do limite visível do ecrã. Transforma uma única área de trabalho neste esquema através de `Super + L`.

Voltar a premir `Super + L` torna a área de trabalho flutuante, em que as janelas se sobrepõem livremente e é o utilizador que as posiciona, e uma terceira pressão devolve-a ao dwindle. `Super + Alt + L` percorre-os na direção oposta. Uma janela que já é flutuante de qualquer forma — uma que destacou com `Super + T`, ou uma aplicação que abre sempre como flutuante — continua flutuante quando a área de trabalho volta ao mosaico. A barra superior assinala a área de trabalho onde está com o respetivo esquema: um quadrado para dwindle, um círculo para deslocamento e um triângulo para flutuante. Clicar nessa marca também percorre os esquemas.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

A escolha é por área de trabalho e mantém-se. Assim, pode manter a área de trabalho 1 em dwindle para navegar e a área de trabalho 2 em deslocamento para código, e voltarão a estar assim após um reinício.

Se pretender utilizar o esquema de deslocamento como predefinição, pode defini-lo em `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Áreas de trabalho flutuantes

Uma área de trabalho flutuante funciona como um ambiente de trabalho tradicional: as janelas sobrepõem-se e é o utilizador que as move e dimensiona. Cada janela recebe uma barra de título com as cores do seu tema, com botões para minimizar, maximizar e fechar. `Super + M` também minimiza a janela em foco. Uma janela minimizada aguarda na dock; clique na respetiva aplicação para a trazer de volta. Clique numa janela para a trazer para a frente. Redimensione-a a partir de qualquer extremidade ou canto. Faça duplo clique numa barra de título para maximizar a janela mantendo a barra superior visível, e novamente para recuperar o tamanho anterior. O Chrome e outros navegadores baseados em Chromium, o Disks e o Document Viewer dispensam a barra de título e utilizam, em vez disso, o seu próprio cabeçalho; `Super + Alt + F` maximiza-os e `Super + M` minimiza-os.

Uma área de trabalho flutuante também mostra uma dock, com as suas aplicações fixadas, tudo o que está em execução e uma grelha com todas as aplicações atrás do botão de aplicações, que `Super + Alt + Space` e _Apps_ no menu Omarchy também abrem. Clique com o botão direito numa aplicação na grelha, ou prima `Delete`, para a desinstalar. Clique numa aplicação para a abrir, ou para trazer a sua janela para a frente; clique novamente para percorrer as suas janelas. Um clique com o botão do meio abre uma nova janela. Arraste um ícone ao longo da dock para o mover; arrastar uma aplicação em execução para junto das outras mantém-na lá. Clique com o botão direito para manter uma aplicação na dock, retirá-la de lá ou encerrá-la. A dock sai do caminho de uma janela em ecrã inteiro. Clique com o botão direito no botão de aplicações para mover a dock para outra extremidade ou para fazer com que se oculte até o ponteiro chegar a essa extremidade. A posição também se encontra em _Appearance > Dock > Dock Position_, e `omarchy dock position left` e `omarchy dock autohide on` definem ambas a partir de um terminal. As aplicações que mantiver na dock ficam esbatidas enquanto não estiverem em execução.

As novas áreas de trabalho, e quaisquer áreas a que não tenha atribuído um esquema próprio com `Super + L`, utilizam o esquema predefinido. Alterar a predefinição repõe nela todas as áreas de trabalho sem janelas, enquanto uma área com janelas mantém o esquema que tem. Uma janela minimizada para a dock continua a contar como uma janela na área de trabalho que deixou. Escolha-o em _Appearance > Workspace Layout_: Tiling, Scrolling ou Floating. `omarchy-hyprland-workspace-layout-default scrolling` define-o a partir de um terminal.

### Agrupar janelas

As janelas podem ser agrupadas com `Super + G`. Quando estiver num grupo, todas as janelas que iniciar enquanto este estiver ativo pertencerão ao grupo. Pode mover-se entre estas janelas agrupadas com `Super + Ctrl + Arrow Left/Right` ou com `Super + Alt + 1/2/3/4` para ir diretamente para as janelas agrupadas por ordem.

Pode retirar uma janela do grupo com `Super + Alt + G` ou desmontar o grupo inteiro voltando a premir `Super + G`. Por fim, pode mover janelas que estão fora do grupo para dentro dele com `Super + Alt + Arrows`.

### Destacar janelas

Pode destacar uma janela da sua atribuição de área de trabalho com `Super + O`. Isso fixa-a como uma janela flutuante que o segue para qualquer área de trabalho para onde vá. Ótimo para leitores de vídeo e afins.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Área de trabalho scratchpad

Existe uma área de trabalho scratchpad especial, de tamanho completo, que se sobrepõe a qualquer área de trabalho onde esteja no momento. Acede ao que lá está com `Super + S` e coloca janelas lá com `Super + Alt + S`.

Funciona bem para controlos ou um terminal com os quais pretenda interagir rapidamente sem sair da área de trabalho atual.

### Consola Quake

Por fim, existe uma consola Quake com metade da altura que desce sobre qualquer área de trabalho onde esteja no momento. Ative-a e desative-a com `Super + Grave` e coloque uma janela lá com `Super + Shift + Grave`.

Abre com o seu agente predefinido pronto a arrancar. Enquanto a consola contiver uma única janela, desce como um painel centrado, em vez de abranger todo o ecrã. Coloque lá uma segunda aplicação e volta à largura total, para que as duas tenham espaço para ficar lado a lado.

Para retirar uma janela do scratchpad ou da consola, envie-a diretamente para outra área de trabalho com algo como `Super + Shift + 1`.

### É preciso algum tempo para se habituar!

É preciso algum tempo para se habituar a navegar no seu ambiente de trabalho desta forma, mas, assim que o fizer, será difícil voltar a uma experiência tradicional de ambiente de trabalho orientada pelo rato!
