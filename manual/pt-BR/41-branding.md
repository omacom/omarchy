# Branding

Omarchy permite que você defina o logo da sua empresa ou uma imagem pessoal para o desbloqueio de inicialização, para o protetor de tela e para a tela Sobre.

### Desbloqueio de inicialização

Você pode usar `omarchy plymouth preview` para ver como ficariam seu logo e suas cores personalizados. Ele recebe uma cor de fundo, uma cor de texto, um png do logo e um caminho para a imagem de prévia:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Depois aplique a configuração com `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, que também dará à tela de login do SDDM as mesmas cores e o mesmo logo. Se quiser reverter, você pode usar `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Protetor de tela

Você pode alterar o logo usado no protetor de tela em _Aparência > Branding > Protetor de tela_. É um logo em ASCII, então você pode editar o texto diretamente, mas também pode passar uma imagem png ou svg, e nós converteremos isso para ASCII. Fica bem legal.

 ![branding-screensaver](images/branding-screensaver.webp)

Há três entradas nesse menu:

- **Editar texto** abre `~/.config/omarchy/branding/screensaver.txt` no seu editor. Digite ou cole o que quiser — arte ASCII, seu nome, um palavrão. Salve e saia, e o protetor de tela inicia imediatamente para você ver.
- **Definir a partir de uma imagem** abre um seletor de arquivos para um png ou svg, converte para ASCII e mostra o resultado. Logos com uma silhueta nítida funcionam muito melhor do que fotos.
- **Restaurar padrão** coloca o logo do Omarchy de volta.

### Tela Sobre

As mesmas três opções estão em _Aparência > Branding > Sobre_ para a tela _Sobre_ que você abre pelo menu do Omarchy, e elas funcionam de forma idêntica — o arquivo é `~/.config/omarchy/branding/about.txt`, e a janela Sobre aparece depois de cada alteração. A arte do Sobre é convertida para um tamanho menor do que a do protetor de tela, já que ela precisa caber em uma janela em vez de preencher sua tela.

Enquanto a janela estiver aberta, uma faixa de luz branca intensa atravessa a arte inclinada a cada poucos segundos e depois a deixa imóvel de novo. Sua própria arte também recebe esse efeito, desde que cada caractere nela tenha uma coluna de largura — tudo o que _Definir a partir de uma imagem_ produz tem. Arte feita com emoji ou caracteres de largura dupla fica parada, e a tela também fica se você mantiver uma configuração do fastfetch própria: um logo parado nesses casos é a animação saindo do caminho em vez de falhando, já que deslizar um brilho sobre eles colocaria o restante da linha no lugar errado.

 ![branding-about](images/branding-about.webp)

### Convertendo imagens por conta própria

As duas opções _Definir a partir de uma imagem_ apenas chamam `omarchy transcode ascii`, que você pode executar diretamente se quiser controle sobre a conversão:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Ele aceita `--width` e `--height` em colunas e linhas do terminal, um `--mode` de `braille` (o padrão, e bem mais fino) ou `block`, um `--threshold` em porcentagem para decidir quais pixels contam como parte do logo, e `--invert` para quando seu logo for claro sobre um fundo escuro. Se uma conversão sair como um borrão, o threshold costuma ser o ajuste a mexer.

### Palavras em vez de um logo

`omarchy ascii` desenha texto em Delta Corps Priest 1, a fonte FIGlet na qual a própria marca nominal do Omarchy é desenhada, então um protetor de tela pode dizer algo em vez de mostrar uma imagem:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Ele recebe o texto como argumentos, ou o lê de um pipe quando nenhum é fornecido. A fonte traz apenas letras e espaços — ela foi desenhada sem dígitos nem pontuação — então qualquer outra coisa é descartada e nomeada no stderr em vez de ser engolida silenciosamente.
