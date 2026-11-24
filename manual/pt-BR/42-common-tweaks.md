# Ajustes comuns

Esta é uma coleção de personalizações comuns para a configuração do Omarchy. Saiba que, ocasionalmente, pode ser necessário que as atualizações do sistema restaurem determinadas configurações à sua condição original. Se isso acontecer, suas alterações não serão perdidas, mas colocadas em um arquivo `.bak.<timestamp>` ao lado do original.

Se você fizer besteira, pode restaurar configurações individuais à sua configuração original em _Update > Config_ no menu do Omarchy. Se você _realmente_ estragar tudo, pode redefinir todas as configurações com `omarchy reinstall configs`, ou reinstalar todos os pacotes e configurações padrão com `omarchy reinstall`.

### Mostrar todos os ícones da bandeja o tempo todo

Por padrão, os ícones da bandeja, como Dropbox, 1password ou Steam, ficam ocultos atrás da seta expansora da bandeja, que os revela quando você passa o cursor sobre ela. Se quiser deixá-los expostos o tempo todo, clique com o botão direito na seta expansora para abrir o gerenciador de ícones da bandeja e fixe os ícones que deseja manter visíveis (você também pode ocultar aqueles que nunca quer ver).

### Cantos arredondados das janelas

O design padrão do Omarchy é de cantos retos, mas se você quiser suavizar um pouco isso, escolha _Appearance > Windows > Window Corners > Rounded Corners_ no menu do Omarchy, ou execute `omarchy hyprland corners rounded`. _Theme Corners_ volta para o que o tema usa. Para escolher seu próprio raio, permaneça em _Theme Corners_ (`omarchy hyprland corners theme`), já que Rounded e Sharp são carregados depois da sua configuração e a substituem, e descomente o arredondamento em `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Remover os espaços entre janelas

Em telas de laptop, algumas pessoas preferem não desperdiçar nenhum pixel com espaços entre janelas (ou até mesmo com uma barra superior, que você pode ativar e desativar com `Super + Shift + Space`). Você pode ativar e desativar todos os espaços e bordas com `Super + Shift + Backspace`, ou removê-los permanentemente removendo os comentários nesta seção de `~/.config/hypr/looknfeel.lua`:

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
