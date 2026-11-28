# Ajustes comuns

Esta é uma coleção de personalizações comuns da configuração do Omarchy. Tenha em atenção que, ocasionalmente, pode ser necessário que as atualizações do sistema reponham determinadas configurações no seu estado original. Se isso acontecer, as suas alterações não se perdem, mas são colocadas num ficheiro `.bak.<timestamp>` ao lado do original.

Se estragares alguma coisa, podes repor configurações individuais na sua configuração original através de _Atualizar > Configuração_ no menu do Omarchy. Se _realmente_ estragares tudo, podes repor todas as configurações com `omarchy reinstall configs`, ou reinstalar todos os pacotes e configurações predefinidos com `omarchy reinstall`.

### Mostrar sempre todos os ícones da área de notificação

Por predefinição, os ícones da área de notificação, como o Dropbox, o 1password, ou o Steam, estão escondidos atrás da seta de expansão da área de notificação, que os revela quando passas o rato sobre ela. Se quiseres que estejam sempre expostos, clica com o botão direito do rato na seta de expansão para abrir o gestor de ícones da área de notificação, e depois fixa os ícones que queres manter visíveis (também podes ocultar os que nunca queres ver).

### Cantos das janelas arredondados

O design predefinido do Omarchy tem cantos retos, mas se quiseres suavizar um pouco esse aspeto, escolhe _Aspeto > Janelas > Cantos das Janelas > Cantos Arredondados_ no menu do Omarchy, ou executa `omarchy hyprland corners rounded`. _Cantos do Tema_ volta ao que o tema utilizar. Para escolheres o teu próprio raio, mantém _Cantos do Tema_ (`omarchy hyprland corners theme`), uma vez que Arredondados e Retos são carregados depois da tua configuração e a substituem, e retira o comentário do arredondamento em `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Remover os espaços entre janelas

Nos ecrãs de portátil, algumas pessoas preferem não desperdiçar nenhum pixel com espaços entre janelas (ou mesmo com uma barra superior, que podes ativar ou desativar com `Super + Shift + Space`). Podes desativar todos os espaços e contornos com `Super + Shift + Backspace`, ou removê-los permanentemente ao retirar os comentários nesta parte de `~/.config/hypr/looknfeel.lua`:

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
