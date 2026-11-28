# Branding

O Omarchy permite-lhe definir o logótipo da sua empresa ou uma imagem pessoal tanto para a proteção de ecrã como para o ecrã Acerca de.

### Proteção de ecrã

Pode alterar o logótipo utilizado na proteção de ecrã em _Appearance > Branding > Screensaver_. É um logótipo em ASCII, por isso pode editar o texto diretamente, mas também pode fornecer-lhe uma imagem png ou svg e nós convertemo-la em ASCII. Fica muito fixe.

 ![branding-screensaver](images/branding-screensaver.webp)

Há três entradas nesse menu:

- **Edit Text** abre `~/.config/omarchy/branding/screensaver.txt` no seu editor. Escreva ou cole o que quiser — arte ASCII, o seu nome, um palavrão. Guarde e saia, e a proteção de ecrã arranca imediatamente para poder vê-la.
- **Set From Image** abre um seletor de ficheiros para um png ou svg, converte-o em ASCII e mostra-lhe o resultado. Logótipos com uma silhueta nítida funcionam muito melhor do que fotografias.
- **Restore Default** repõe o logótipo do Omarchy.

### Ecrã Acerca de

As mesmas três opções estão em _Appearance > Branding > About_ para o ecrã _About_ que obtém a partir do menu do Omarchy, e funcionam de forma idêntica — o ficheiro é `~/.config/omarchy/branding/about.txt`, e a janela About surge após cada alteração. A arte do About é convertida para um tamanho mais pequeno do que a da proteção de ecrã, uma vez que tem de caber numa janela em vez de encher o seu ecrã.

Enquanto a janela está aberta, uma faixa de luz branca brilhante inclina-se sobre a arte de poucos em poucos segundos e depois deixa-a novamente imóvel. A sua própria arte também a recebe, desde que cada carácter nela tenha a largura de uma coluna — qualquer coisa produzida por _Set From Image_ tem. Arte construída a partir de emoji ou caracteres de largura dupla permanece imóvel, e o mesmo acontece ao ecrã se mantiver uma configuração do fastfetch sua: um logótipo imóvel nesses casos é a animação a manter-se fora do caminho em vez de falhar, uma vez que deslizar um brilho sobre eles colocaria o resto da linha no sítio errado.

 ![branding-about](images/branding-about.webp)

### Converter imagens por si próprio

Ambas as opções _Set From Image_ estão simplesmente a chamar `omarchy transcode ascii`, que pode executar diretamente se quiser controlar a conversão:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Aceita `--width` e `--height` em colunas e linhas do terminal, um `--mode` de `braille` (a predefinição, e muito mais fino) ou `block`, um `--threshold` em percentagem para decidir que píxeis contam como parte do logótipo, e `--invert` para quando o seu logótipo é claro sobre um fundo escuro. Se uma conversão sair como uma mancha, o limiar é normalmente o parâmetro a ajustar.

### Palavras em vez de um logótipo

`omarchy ascii` desenha texto em Delta Corps Priest 1, a fonte FIGlet em que o próprio wordmark do Omarchy é desenhado, para que uma proteção de ecrã possa dizer algo em vez de mostrar uma imagem:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Aceita o texto como argumentos, ou lê-o a partir de um pipe quando não lhe é dado nenhum. A fonte inclui apenas letras e espaços — foi desenhada sem dígitos nem pontuação — por isso qualquer outra coisa é descartada e indicada no stderr em vez de ser engolida silenciosamente.
