# Ajustes comuns

Esta é uma coleção de adaptações comuns à configuração do Omarchy. Saiba que ocasionalmente pode ser necessário que as atualizações do sistema restaurem certas configurações à sua condição original. Se isso acontecer, suas alterações não serão perdidas, mas colocadas em um arquivo `.bak` no mesmo diretório.

Se você estragar alguma coisa, pode restaurar configurações individuais à sua configuração original em _Atualizar > Configuração_ no menu do Omarchy. Se você estragar _tudo de verdade_, pode redefinir todas as configurações com `omarchy-reinstall`.

### Mostrar todos os ícones da bandeja o tempo todo

Por padrão, os ícones da bandeja, como Dropbox, 1Password ou Steam, ficam escondidos atrás da seta expansora da bandeja, que os revela quando você passa o mouse sobre ela. Se você quer que eles fiquem expostos o tempo todo, clique com o botão direito na seta expansora para abrir o gerenciador de ícones da bandeja e fixe os ícones que quer manter visíveis (você também pode ocultar aqueles que nunca quer ver).

### Cantos arredondados das janelas

O design padrão do Omarchy é de cantos retos, mas se você gosta de suavizar um pouco isso, pode alterar `~/.config/hypr/looknfeel.lua` para que o arredondamento não fique mais comentado:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Remover os espaçamentos das janelas

Em telas de notebook, algumas pessoas preferem não desperdiçar nenhum pixel com espaçamentos das janelas (ou até com uma barra superior, que você pode alternar com `Super + Shift + Space`). Você pode alternar todos os espaçamentos e bordas com `Super + Shift + Backspace`, ou removê-los permanentemente removendo os comentários nesta seção de `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
