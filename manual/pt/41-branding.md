# Identidade visual

O Omarchy permite-lhe definir o logótipo da sua empresa ou uma imagem pessoal para o desbloqueio no arranque, para a proteção de ecrã e para o ecrã sobre.

### Desbloqueio no arranque

Pode usar `omarchy plymouth preview` para ver como o seu logótipo e cores personalizados ficariam. Recebe uma cor de fundo, uma cor de texto, um png do logótipo e um caminho para a imagem de pré-visualização:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Depois aplique a configuração com `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, o que também dá ao ecrã de início de sessão SDDM as mesmas cores e logótipo. Se quiser reverter, pode usar `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Proteção de ecrã

Pode mudar o logótipo usado para a proteção de ecrã em _Estilo > Proteção de ecrã_. É um logótipo ASCII, por isso pode editar o texto diretamente, mas também lhe pode dar uma imagem png ou svg, e nós convertemo-la para ASCII. Fica mesmo bem.

 ![branding-screensaver](images/branding-screensaver.webp)

Nesse menu há três entradas:

- **Editar texto** abre `~/.config/omarchy/branding/screensaver.txt` no seu editor. Escreva ou cole o que quiser — arte ASCII, o seu nome, um palavrão. Guarde e saia, e a proteção de ecrã arranca imediatamente para a poder ver.
- **Definir por imagem** abre um seletor de ficheiros para um png ou svg, converte-o para ASCII e mostra-lhe o resultado. Logótipos com uma silhueta nítida funcionam muito melhor do que fotografias.
- **Repor predefinição** volta a colocar o logótipo do Omarchy.

### Ecrã Sobre

As mesmas três opções estão em _Estilo > Sobre_ para o ecrã _Sobre_ que obtém a partir do menu Omarchy, e funcionam de forma idêntica — o ficheiro é `~/.config/omarchy/branding/about.txt`, e a janela Sobre aparece depois de cada mudança. A arte do Sobre é convertida para um tamanho mais pequeno do que a da proteção de ecrã, já que tem de caber numa janela em vez de preencher o seu ecrã.

Enquanto a janela está aberta, um brilho verde inclina-se sobre a arte de poucos em poucos segundos e depois volta a deixá-la quieta. A sua própria arte também o recebe, desde que todos os caracteres nela tenham a largura de uma coluna — tudo o que _Definir por imagem_ produz tem. A arte construída a partir de emoji ou caracteres de largura dupla fica, em vez disso, quieta, e o mesmo acontece ao ecrã se mantiver uma configuração fastfetch sua: um logótipo quieto nesses casos é a animação a não estorvar, em vez de falhar, já que deslizar um brilho sobre eles colocaria o resto da linha no sítio errado.

 ![branding-about](images/branding-about.webp)

### Converter imagens por si

Ambas as opções _Definir por imagem_ estão simplesmente a chamar `omarchy transcode ascii`, que pode executar diretamente se quiser controlo sobre a conversão:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Recebe `--width` e `--height` em colunas e linhas do terminal, um `--mode` de `braille` (a predefinição, e muito mais fino) ou `block`, uma percentagem `--threshold` para decidir que píxeis contam como parte do logótipo, e `--invert` para quando o seu logótipo é claro sobre um fundo escuro. Se uma conversão sair como um borrão, o limiar é normalmente o botão a girar.

### Palavras em vez de um logótipo

O `omarchy ascii` desenha texto em Delta Corps Priest 1, o tipo de letra FIGlet em que o próprio wordmark do Omarchy é desenhado, para uma proteção de ecrã poder dizer algo em vez de mostrar uma imagem:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Recebe o texto como argumentos, ou lê-o de um tubo quando não lhe é dado nenhum. O tipo de letra tem apenas letras e espaços — foi desenhado sem dígitos nem pontuação — por isso tudo o resto é descartado e nomeado no stderr em vez de engolido silenciosamente.
