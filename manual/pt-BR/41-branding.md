# Identidade visual

O Omarchy permite que você defina o logotipo da sua empresa ou uma imagem pessoal tanto para o protetor de tela quanto para a tela Sobre.

### Protetor de tela

Você pode alterar o logotipo usado no protetor de tela em _Appearance > Branding > Screensaver_. É um logotipo em ASCII, então você pode editar o texto diretamente, mas também pode passar uma imagem png ou svg, e nós a converteremos para ASCII. Fica bem legal.

 ![branding-screensaver](images/branding-screensaver.webp)

Há três itens nesse menu:

- **Edit Text** abre `~/.config/omarchy/branding/screensaver.txt` no seu editor. Digite ou cole o que quiser — arte ASCII, seu nome, um palavrão. Salve e saia, e o protetor de tela é acionado imediatamente para você ver.
- **Set From Image** abre um seletor de arquivos para um png ou svg, converte para ASCII e mostra o resultado para você. Logotipos com uma silhueta nítida funcionam muito melhor do que fotos.
- **Restore Default** coloca o logotipo do Omarchy de volta.

### Tela Sobre

As mesmas três opções estão em _Appearance > Branding > About_ para a tela _About_ que você abre pelo menu do Omarchy, e funcionam de forma idêntica — o arquivo é `~/.config/omarchy/branding/about.txt`, e a janela Sobre aparece após cada alteração. A arte da tela Sobre é convertida em um tamanho menor do que a do protetor de tela, já que precisa caber em uma janela em vez de preencher sua tela.

Enquanto a janela está aberta, uma faixa de luz branca brilhante se inclina sobre a arte a cada poucos segundos e depois a deixa parada de novo. A sua própria arte também recebe esse efeito, desde que cada caractere nela tenha uma coluna de largura — tudo o que o _Set From Image_ produz tem. Arte feita com emoji ou caracteres de largura dupla fica parada, e a tela também fica assim se você mantiver uma configuração do fastfetch própria: um logotipo parado nesses casos é a animação ficando fora do caminho em vez de falhar, já que deslizar um brilho sobre eles colocaria o restante da linha no lugar errado.

 ![branding-about](images/branding-about.webp)

### Convertendo imagens por conta própria

Ambas as opções _Set From Image_ estão apenas chamando `omarchy transcode ascii`, que você pode executar diretamente se quiser controle sobre a conversão:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Ele aceita `--width` e `--height` em colunas e linhas do terminal, um `--mode` de `braille` (o padrão, e bem mais fino) ou `block`, uma porcentagem em `--threshold` para decidir quais pixels contam como parte do logotipo, e `--invert` para quando seu logotipo é claro sobre um fundo escuro. Se uma conversão sair como um borrão, o threshold geralmente é o ajuste a mexer.

### Palavras em vez de um logotipo

`omarchy ascii` desenha texto em Delta Corps Priest 1, a fonte FIGlet em que a própria marca nominativa do Omarchy é desenhada, então um protetor de tela pode dizer algo em vez de mostrar uma imagem:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Ele recebe o texto como argumentos, ou o lê de um pipe quando nenhum é fornecido. A fonte traz apenas letras e espaços — foi desenhada sem dígitos ou pontuação — então qualquer outra coisa é descartada e nomeada no stderr em vez de ser engolida silenciosamente.
