# Imagem de marca

O Omarchy permite-lhe definir o logótipo da sua empresa ou uma imagem pessoal para o desbloqueio no arranque, para a proteção de ecrã e para o ecrã Sobre.

### Desbloqueio no arranque

Pode usar `omarchy plymouth preview` para ver como ficariam o seu logótipo e as suas cores personalizados. Recebe uma cor de fundo, uma cor de texto, um png do logótipo e um caminho para a imagem de pré-visualização:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Depois aplique a configuração com `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, o que também dará ao ecrã de início de sessão SDDM as mesmas cores e o mesmo logótipo. Se quiser reverter, pode usar `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Proteção de ecrã

Pode alterar o logótipo usado na proteção de ecrã em _Aparência > Imagem de Marca > Proteção de Ecrã_. É um logótipo ASCII, por isso pode editar o texto diretamente, mas também lhe pode passar uma imagem png ou svg, e nós convertemo-la para ASCII. Fica mesmo giro.

 ![branding-screensaver](images/branding-screensaver.webp)

Esse menu tem três entradas:

- **Editar Texto** abre `~/.config/omarchy/branding/screensaver.txt` no seu editor. Escreva ou cole o que quiser — arte ASCII, o seu nome, um palavrão. Guarde e saia, e a proteção de ecrã arranca de imediato para a poder ver.
- **Definir a Partir de uma Imagem** abre um seletor de ficheiros para um png ou svg, converte-o para ASCII e mostra-lhe o resultado. Logótipos com uma silhueta nítida resultam muito melhor do que fotografias.
- **Repor Predefinição** repõe o logótipo do Omarchy.

### Ecrã Sobre

As mesmas três opções estão em _Aparência > Imagem de Marca > Sobre_ para o ecrã _Sobre_ que obtém a partir do menu do Omarchy, e funcionam de forma idêntica — o ficheiro é `~/.config/omarchy/branding/about.txt`, e a janela Sobre surge após cada alteração. A imagem do Sobre é convertida para um tamanho mais pequeno do que a da proteção de ecrã, porque tem de caber numa janela em vez de encher o ecrã.

Enquanto a janela estiver aberta, uma faixa de luz branca intensa inclina-se sobre a imagem de poucos em poucos segundos e depois deixa-a outra vez imóvel. A sua própria imagem também a recebe, desde que cada carácter nela ocupe apenas uma coluna — tudo o que _Definir a Partir de uma Imagem_ produz ocupa. Imagens feitas com emoji ou caracteres de largura dupla ficam imóveis, em vez disso, e o mesmo acontece ao ecrã se mantiver uma configuração do fastfetch só sua: um logótipo imóvel nesses casos significa que a animação se está a manter fora do caminho, e não que falhou, porque fazer deslizar um brilho sobre elas faria o resto da linha ir parar ao sítio errado.

 ![branding-about](images/branding-about.webp)

### Converter imagens por si próprio

Ambas as opções _Definir a Partir de uma Imagem_ se limitam a chamar `omarchy transcode ascii`, que pode executar diretamente se quiser controlar a conversão:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Recebe `--width` e `--height` em colunas e linhas do terminal, um `--mode` de `braille` (a predefinição, e muito mais fino) ou `block`, uma percentagem `--threshold` para decidir que píxeis contam como parte do logótipo, e `--invert` para quando o seu logótipo é claro sobre um fundo escuro. Se uma conversão sair como um borrão, o limiar é normalmente o parâmetro a mexer.

### Palavras em vez de um logótipo

`omarchy ascii` desenha texto em Delta Corps Priest 1, o tipo de letra FIGlet em que a própria marca nominativa do Omarchy está desenhada, por isso uma proteção de ecrã pode dizer alguma coisa em vez de mostrar uma imagem:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Recebe o texto como argumentos, ou lê-o de um pipe quando não lhe é dado nenhum. O tipo de letra só tem letras e espaços — foi desenhado sem dígitos nem pontuação —, por isso tudo o resto é descartado e indicado em stderr, em vez de ser engolido em silêncio.
