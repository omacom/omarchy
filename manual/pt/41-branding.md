# Branding

O Omarchy permite-lhe definir o logótipo da sua empresa ou uma imagem pessoal para o desbloqueio no arranque, para a proteção de ecrã e para o ecrã Acerca de.

### Desbloqueio no arranque

Pode utilizar `omarchy plymouth preview` para ver como ficariam o seu logótipo e as suas cores personalizados. Aceita uma cor de fundo, uma cor de texto, um png de logótipo e um caminho para a imagem de pré-visualização:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Depois, aplique a configuração com `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, que também dará ao ecrã de início de sessão do SDDM as mesmas cores e o mesmo logótipo. Se quiser reverter, pode utilizar `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Proteção de ecrã

Pode alterar o logótipo utilizado na proteção de ecrã em _Appearance > Branding > Screensaver_. É um logótipo ASCII, por isso pode editar o texto diretamente, mas também pode dar-lhe uma imagem png ou svg, e nós convertemo-la para ASCII. Fica bastante fixe.

 ![branding-screensaver](images/branding-screensaver.webp)

Há três entradas nesse menu:

- **Edit Text** abre `~/.config/omarchy/branding/screensaver.txt` no seu editor. Escreva ou cole o que quiser — arte ASCII, o seu nome, um palavrão. Guarde e saia, e a proteção de ecrã arranca imediatamente para a poder ver.
- **Set From Image** abre um seletor de ficheiros para um png ou svg, converte-o para ASCII e mostra-lhe o resultado. Logótipos com uma silhueta nítida funcionam muito melhor do que fotografias.
- **Restore Default** repõe o logótipo do Omarchy.

### Ecrã Acerca de

As mesmas três opções estão em _Appearance > Branding > About_ para o ecrã _About_ que obtém a partir do menu do Omarchy, e funcionam de forma idêntica — o ficheiro é `~/.config/omarchy/branding/about.txt`, e a janela About surge após cada alteração. A arte do About é convertida para um tamanho menor do que o da proteção de ecrã, uma vez que tem de caber numa janela em vez de encher o seu ecrã.

Enquanto a janela está aberta, um brilho verde inclina-se sobre a arte a cada poucos segundos e depois deixa-a novamente imóvel. A sua própria arte também o recebe, desde que cada carácter nela tenha a largura de uma coluna — tudo o que o _Set From Image_ produz tem. A arte construída a partir de emoji ou de caracteres de largura dupla fica imóvel, em vez disso, e o mesmo acontece ao ecrã se mantiver uma configuração fastfetch sua: um logótipo imóvel nesses casos é a animação a manter-se fora do caminho, e não uma falha, uma vez que deslizar um brilho sobre eles colocaria o resto da linha no sítio errado.

 ![branding-about](images/branding-about.webp)

### Converter imagens por si próprio

Ambas as opções _Set From Image_ estão simplesmente a chamar `omarchy transcode ascii`, que pode executar diretamente se quiser controlar a conversão:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Aceita `--width` e `--height` em colunas e linhas do terminal, um `--mode` de `braille` (a predefinição, e muito mais fino) ou `block`, uma percentagem `--threshold` para decidir que pixels contam como parte do logótipo, e `--invert` para quando o seu logótipo é claro sobre um fundo escuro. Se uma conversão sair como uma mancha, o threshold é normalmente o parâmetro que deve ajustar.

### Palavras em vez de um logótipo

`omarchy ascii` desenha texto em Delta Corps Priest 1, a fonte FIGlet em que a própria marca nominativa do Omarchy é desenhada, para que uma proteção de ecrã possa dizer algo em vez de mostrar uma imagem:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Aceita o texto como argumentos, ou lê-o de um pipe quando não lhe é dado nenhum. A fonte só tem letras e espaços — foi desenhada sem algarismos nem pontuação —, por isso tudo o resto é descartado e indicado no stderr, em vez de ser engolido em silêncio.
