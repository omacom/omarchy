# Ajustes comuns

Isto é uma coleção de personalizações comuns à configuração do Omarchy. Saiba que pode ser ocasionalmente necessário que atualizações do sistema restaurem certas configurações ao seu estado original. Se isso acontecer, as suas alterações não se perdem, mas são colocadas num ficheiro `.bak` no mesmo diretório.

Se estragar alguma coisa, pode restaurar configurações individuais para a sua configuração original através de _Atualizar > Configuração_ no menu Omarchy. Se estragar _mesmo_ tudo, pode repor todas as configurações através de `omarchy-reinstall`.

### Mostrar todos os ícones do tabuleiro sempre

Por predefinição, os ícones do tabuleiro, como o Dropbox, o 1password ou o Steam, estão ocultos atrás da seta de expansão do tabuleiro, que os revela quando passa o rato sobre ela. Se quiser tê-los sempre expostos, clique com o botão direito na seta de expansão para abrir o gestor de ícones do tabuleiro e depois fixe os ícones que quer manter visíveis (pode também ocultar aqueles que nunca quer ver).

### Cantos arredondados das janelas

O design predefinido do Omarchy é de cantos retos, mas se gostar de o suavizar um pouco, pode alterar `~/.config/hypr/looknfeel.lua` para o arredondamento deixar de estar comentado:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Remover os espaços entre janelas

Nos ecrãs de portáteis, algumas pessoas preferem não desperdiçar píxeis com espaços entre janelas (ou até com uma barra superior, que pode desligar com `Super + Shift + Space`). Pode desligar todos os espaços e contornos com `Super + Shift + Backspace`, ou removê-los permanentemente retirando os comentários nesta secção de `~/.config/hypr/looknfeel.lua`:

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
