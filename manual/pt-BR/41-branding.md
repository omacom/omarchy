# Identidade visual

O Omarchy permite definir o logotipo da sua empresa ou uma imagem pessoal para o desbloqueio na inicialização, para a proteção de tela e para a tela Sobre.

### Desbloqueio na inicialização

Você pode usar `omarchy plymouth preview` para ver como ficariam seu logotipo e suas cores personalizadas. Ele recebe uma cor de fundo, uma cor de texto, um png do logotipo e um caminho para a imagem de pré-visualização:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Depois aplique a configuração com `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, que também dará à tela de login do SDDM as mesmas cores e o mesmo logotipo. Se quiser reverter, você pode usar `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Proteção de tela

Você pode alterar o logotipo usado na proteção de tela em _Estilo > Proteção de tela_. É um logotipo em ASCII, então você pode editar o texto diretamente, mas também pode passar uma imagem png ou svg, e nós a converteremos para ASCII. Fica bem legal.

 ![branding-screensaver](images/branding-screensaver.webp)

Há três entradas nesse menu:

- **Editar texto** abre `~/.config/omarchy/branding/screensaver.txt` no seu editor. Digite ou cole o que quiser — arte ASCII, seu nome, um palavrão. Salve e saia, e a proteção de tela é acionada imediatamente para você ver o resultado.
- **Definir da imagem** abre um seletor de arquivos para um png ou svg, converte-o para ASCII e mostra o resultado. Logotipos com uma silhueta clara funcionam muito melhor do que fotos.
- **Restaurar padrão** coloca o logotipo do Omarchy de volta.

### Tela Sobre

As mesmas três opções estão em _Estilo > Sobre_ para a tela _Sobre_ que você abre no menu do Omarchy, e funcionam de forma idêntica — o arquivo é `~/.config/omarchy/branding/about.txt`, e a janela Sobre aparece após cada mudança. A arte do Sobre é convertida para um tamanho menor do que o da proteção de tela, já que ela precisa caber em uma janela em vez de preencher sua tela inteira.

Enquanto a janela está aberta, um brilho verde atravessa a arte a cada poucos segundos e depois a deixa parada de novo. A sua própria arte também ganha isso, desde que cada caractere dela tenha uma coluna de largura — tudo o que _Definir da imagem_ produz tem. Arte feita de emoji ou caracteres de largura dupla fica parada, em vez disso, e o mesmo acontece com a tela se você mantiver sua própria configuração do fastfetch: um logotipo parado nesses casos é a animação saindo do caminho em vez de falhando, já que deslizar um brilho sobre eles colocaria o resto da linha no lugar errado.

 ![branding-about](images/branding-about.webp)

### Convertendo imagens por conta própria

Ambas as opções _Definir da imagem_ estão apenas chamando `omarchy transcode ascii`, que você pode executar diretamente se quiser controle sobre a conversão:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Ele recebe `--width` e `--height` em colunas e linhas do terminal, um `--mode` de `braille` (o padrão, e muito mais fino) ou `block`, uma porcentagem `--threshold` para decidir quais pixels contam como parte do logotipo, e `--invert` para quando seu logotipo é claro sobre um fundo escuro. Se uma conversão sair como um borrão, o threshold costuma ser o botão a girar.

### Palavras em vez de um logotipo

`omarchy ascii` desenha texto em Delta Corps Priest 1, a fonte FIGlet em que a própria marca do Omarchy é desenhada, então uma proteção de tela pode dizer algo em vez de mostrar uma imagem:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Ele recebe o texto como argumentos, ou o lê de um pipe quando nenhum é passado. A fonte traz apenas letras e espaços — ela foi desenhada sem dígitos nem pontuação — então qualquer outra coisa é descartada e nomeada no stderr em vez de ser engolida silenciosamente.
