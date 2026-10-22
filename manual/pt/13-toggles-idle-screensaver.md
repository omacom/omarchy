# Alternâncias, inatividade e proteção de ecrã

Muito daquilo que mudas no dia a dia não é bem uma definição. É um modo que ligas durante uma hora e voltas a desligar: luz noturna enquanto trabalhas até tarde, não incomodar enquanto estás a apresentar, manter ativo enquanto estás a ver alguma coisa. O Omarchy chama-lhes alternâncias, e funcionam todas da mesma forma — um atalho, uma entrada de menu e um comando, todos a agir no mesmo interruptor.

### O menu de alternâncias

`Super + Ctrl + O` abre diretamente _Acionar > Alternar_, ou podes navegar até lá a partir do menu do Omarchy (`Super + Space`). Tudo nessa lista é um interruptor que podes acionar sem pensares em onde vive o estado. Os interruptores relativos ao aspeto do ambiente de trabalho ficam ao lado, em _Acionar > Aspeto_.

A partir do terminal, os mesmos interruptores são `omarchy toggle <coisa>`. Executa `omarchy toggle` sozinho para veres o grupo todo.

| Alternância | Atalho | Comando |
| ------ | ------ | ------- |
| Luz noturna | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Silenciar notificações | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Manter ativo (sem bloqueio por inatividade) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de falhas | — | `omarchy toggle crash-capture` |
| Proteção de ecrã | — | `omarchy toggle screensaver` |
| Sincronizar tema [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra de menus | `Super + Shift + Space` | `omarchy toggle bar` |
| Painel tátil | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Ecrã tátil | — | `omarchy toggle touchscreen` |
| Suspender | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Os interruptores do painel tátil, do ecrã tátil e da GPU híbrida vivem em _Acionar > Hardware_ (`Super + Ctrl + H`) em vez de em Alternar, uma vez que só aparecem quando tens realmente esse hardware. Os do painel tátil e do ecrã tátil sobrevivem a um recarregamento do Hyprland — o nome do dispositivo desativado fica guardado num pequeno ficheiro de estado que o Hyprland lê no arranque para o desativar outra vez.

_Acionar > Aspeto_ guarda a barra de menus e as animações, além de algumas coisas que não são comandos `omarchy toggle` mas se comportam da mesma forma: a percentagem da bateria na barra, a disposição predefinida dos espaços de trabalho, o espaçamento entre janelas (`Super + Shift + Backspace`) e a proporção quadrada de 1 janela (`Super + Ctrl + Backspace`).

A maioria delas é apenas um ficheiro de sinalização em `~/.local/state/omarchy/toggles/`. Se quiseres ramificar num script com base numa delas, `omarchy-toggle-enabled` dá-te um código de saída em vez de te obrigar a ires à procura:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Os sinalizadores têm nomes relativos ao estado desligado — `screensaver-off`, `suspend-off`, `bar-off` — por isso a sua presença significa que a funcionalidade está desativada.

### Indicadores na barra

Quando um modo está ligado, tens um pequeno glifo no meio da barra superior, ao lado do relógio. É o widget de indicadores, e transporta o ditado, a gravação de ecrã, os lembretes pendentes, a luz noturna, o não incomodar e o manter ativo.

Os indicadores inativos estão ocultos. Passa o cursor sobre a área à volta deles e eles surgem esbatidos, para poderes clicar num para o ligares sem conheceres o seu atalho. Clicar num ativo desliga-o outra vez. Se preferires vê-los todos em permanência, define `alwaysShow` como `true` na entrada `omarchy.indicators` em `~/.config/omarchy/shell.json` — vê [a barra superior](05-the-top-bar.md) para saberes como os widgets da barra são configurados.

### Luz noturna

`Super + Ctrl + N` aquece o ecrã para 4000 K, e premir outra vez devolve-o a 6500 K. É controlado pelo hyprsunset, que a alternância arranca por ti se ainda não estiver a correr.

Por predefinição, o hyprsunset não faz absolutamente nada ao teu ecrã. `~/.config/hypr/hyprsunset.conf` vem com um perfil de identidade precisamente para que o ecrã fique intocado até pedires calor. Se preferires que ele mude pelo relógio, substitui isso por um perfil de hora:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Depois arranca o hyprsunset no início de sessão adicionando `o.launch_on_start("hyprsunset")` ao `~/.config/hypr/autostart.lua`. O par de 4000 K/6500 K usado pela alternância é fixo, por isso o ficheiro de configuração é onde vais se quiseres uma temperatura diferente.

### Não incomodar

`Super + Ctrl + ,` silencia as notificações. Não surgem toasts enquanto estiver ligado, e o indicador do sino riscado fica na barra para te lembrar porque é que o ambiente de trabalho ficou silencioso.

Mas nada se perde. Uma notificação silenciada é escrita diretamente no teu histórico de notificações, que é exatamente o registo que queres quando voltas e te perguntas o que perdeste. Abre-o com `Super + Shift + Alt + ,`. Vê [avisos](10-notices.md) para o resto da história das notificações.

Dois tipos de mensagem continuam a passar: os toasts de confirmação do próprio Omarchy para algo que acabaste de fazer ("Theme changed", "Screenshot saved"), e os alertas críticos enviados a partir da linha de comandos. As aplicações de chat que marcam tudo como crítico para forçarem a entrada à tua frente não contam.

### Inatividade

A shell do Omarchy é dona do comportamento de inatividade, e os tempos são um bloco de nível superior `idle` em `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambos os números são segundos contados a partir do momento em que ficaste inativo — não um a partir do outro. Por isso, com as predefinições, a proteção de ecrã surge ao fim de dois minutos e meio e o ecrã de bloqueio assume aos cinco minutos, quer a proteção de ecrã tenha corrido ou não. Guarda o ficheiro e a shell apanha os novos tempos de imediato.

Se dispensares a proteção de ecrã antes do prazo de bloqueio, isso conta como atividade e o bloqueio pendente é cancelado. Não ficas bloqueado por dares uma vista de olhos à máquina.

Para parares por completo o bloqueio por inatividade, `Super + Ctrl + I` — ou `omarchy toggle idle` — liga o manter ativo, e o indicador da chávena de café aparece na barra. É esse que deves acionar antes de uma longa apresentação ou de uma compilação que queres observar. Aciona-o outra vez para voltares ao normal. `omarchy toggle idle status` apresenta o estado atual como JSON, se precisares dele a partir de um script.

Isto trata do bloqueio e da proteção de ecrã, não da energia. A suspensão e a hibernação têm a sua própria configuração em [suspensão do sistema](36-system-sleep.md).

### A proteção de ecrã

A proteção de ecrã do Omarchy é arte ASCII a correr através de efeitos de texto aleatórios, uma instância por monitor. Qualquer tecla ou movimento do rato sai dela.

Podes arrancá-la a pedido a partir de _Sistema > Proteção de ecrã_ (`Super + Esc`), o que a força a aparecer mesmo que tenhas desligado a proteção de ecrã por inatividade. Não há qualquer atalho associado a ela por predefinição.

`omarchy toggle screensaver` é aquilo que desliga a proteção por inatividade, se preferires ir diretamente de a trabalhar para bloqueado. Precisa de um terminal que saiba configurar — Alacritty, Foot, Ghostty ou Kitty — e diz-te isso se o teu terminal predefinido for outra coisa.

O logótipo que ela desenha é teu para mudares, em _Estilo > Proteção de ecrã_. Carrega um png ou um svg e o Omarchy converte-o para ASCII. Vê [branding](41-branding.md).

### O ecrã de bloqueio

`Super + Ctrl + L` bloqueia a máquina. Isso executa o ecrã de bloqueio a partir da shell do Omarchy, escurece o ecrã, repõe a disposição do teclado na primeira para não estares a escrever a tua palavra-passe no alfabeto errado e — se o tiveres a correr — bloqueia o 1Password à saída.

O ecrã de bloqueio aceita uma palavra-passe, e também aceita uma impressão digital assim que tiveres configurado uma. Isso, e as outras formas de te autenticares, estão tratados em [autenticação por hardware](37-hardware-authentication.md).
