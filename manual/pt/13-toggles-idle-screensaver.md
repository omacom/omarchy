# Alternâncias, Inatividade e a Proteção de Ecrã

Muito do que muda no dia a dia não é bem uma definição. É um modo que liga durante uma hora e volta a desligar: luz noturna enquanto está a trabalhar até tarde, não incomodar enquanto está a apresentar, manter-se acordado enquanto está a ver alguma coisa. O Omarchy chama-lhes alternâncias, e todas funcionam da mesma maneira — uma tecla de atalho, uma entrada de menu e um comando, todos a atuar no mesmo interruptor.

### O menu de alternâncias

`Super + Ctrl + O` abre diretamente _Acionar > Alternar_, ou pode ir lá a partir do menu do Omarchy (`Super + Space`). Tudo nessa lista é um interruptor que pode acionar sem pensar onde vive o estado. Os interruptores relativos ao aspeto do ambiente de trabalho ficam ao lado, em _Aspeto_.

A partir do terminal, os mesmos interruptores são `omarchy toggle <thing>`. Execute `omarchy toggle` por si só para ver o grupo completo.

| Alternância | Tecla de atalho | Comando |
| ------ | ------ | ------- |
| Luz noturna | — | `omarchy toggle nightlight` |
| Silenciar notificações | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Manter acordado (sem bloqueio por inatividade) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de falhas | — | `omarchy toggle crash-capture` |
| Proteção de ecrã | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sincronização de tema | — | `omarchy toggle theme sync` |
| Barra de menus | `Super + Shift + Space` | `omarchy toggle bar` |
| Painel tátil | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Ecrã tátil | — | `omarchy toggle touchscreen` |
| Suspender | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Os interruptores do painel tátil, do ecrã tátil e da GPU híbrida ficam em _Acionar > Hardware_ (`Super + Ctrl + H`) e não em Alternar, uma vez que só aparecem quando tem efetivamente esse hardware. Os do painel tátil e do ecrã tátil sobrevivem a um recarregamento do Hyprland — o nome do dispositivo desativado é guardado num pequeno ficheiro de estado que o Hyprland lê no arranque para o voltar a desativar.

_Aspeto_ reúne a barra de menus e as animações, além de algumas coisas que não são comandos `omarchy toggle` mas se comportam da mesma forma: a percentagem da bateria na barra, o esquema predefinido da área de trabalho e, em _Janelas_, os intervalos entre janelas (`Super + Shift + Backspace`) e o aspeto quadrado de 1 janela (`Super + Ctrl + Backspace`).

A maioria destes é apenas um ficheiro de sinalização em `~/.local/state/omarchy/toggles/`. Se quiser ramificar com base num deles num script, `omarchy-toggle-enabled` dá-lhe um código de saída em vez de o obrigar a ir à procura:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Os sinalizadores têm nomes correspondentes ao estado desligado — `screensaver-off`, `suspend-off`, `bar-off` — pelo que a sua presença significa que a funcionalidade está desativada.

### Indicadores na barra

Quando um modo está ligado, aparece um pequeno glifo no meio da barra superior, ao lado do relógio. É o widget de indicadores e inclui ditado, gravação de ecrã, lembretes pendentes, luz noturna, não incomodar e manter acordado.

Os indicadores inativos ficam ocultos. Passe o rato por qualquer ponto da barra e eles surgem esbatidos, para poder clicar num para o ligar sem conhecer a sua tecla de atalho. Clicar num ativo volta a desligá-lo. Se preferir vê-los todos o tempo todo, defina `alwaysShow` como `true` na entrada `omarchy.indicators` em `~/.config/omarchy/shell.json` — consulte [a barra superior](05-the-top-bar.md) para saber como os widgets da barra são configurados.

### Luz noturna

A luz noturna aquece o ecrã para 4000K, e voltar a alterná-la repõe-no nos 6500K. Ative-a no menu de alternâncias (`Super + Ctrl + O`) ou com `omarchy toggle nightlight`. É acionada pelo hyprsunset, que a alternância arranca por si se ele ainda não estiver a correr.

Por predefinição, o hyprsunset não faz rigorosamente nada ao ecrã. `~/.config/hypr/hyprsunset.conf` vem com um perfil de identidade precisamente para o ecrã ficar intocado até pedir calor. Se preferir que mude de acordo com o relógio, substitua isso por um perfil de horas:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Depois faça o hyprsunset arrancar no início de sessão adicionando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. O par 4000K/6500K usado pela alternância é fixo, pelo que o ficheiro de configuração é o sítio a ir se quiser uma temperatura diferente.

### Não incomodar

`Super + Ctrl + Alt + ,` silencia as notificações. Não surgem avisos flutuantes enquanto estiver ligado, e o indicador da campainha riscada fica na barra para lhe lembrar por que razão o ambiente de trabalho ficou silencioso.

Nada se perde, porém. As notificações silenciadas ficam retidas: volte a pôr as últimas no ecrã com `Super + Shift + Alt + ,`. Consulte [avisos](10-notices.md) para o resto.

Dois tipos de mensagem continuam a passar: os avisos de confirmação do próprio Omarchy relativos a algo que acabou de fazer ("Theme changed", "Screenshot saved"), e alertas críticos enviados a partir da linha de comandos. As aplicações de chat que marcam tudo como crítico para forçarem a entrada à sua frente não contam.

### Inatividade

A shell do Omarchy é responsável pelo comportamento de inatividade, e os tempos são um bloco `idle` de nível superior em `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambos os números são segundos contados a partir do momento em que ficou inativo — não um a partir do outro. Por isso, com as predefinições, a proteção de ecrã surge ao fim de dois minutos e meio e o ecrã de bloqueio assume ao fim de cinco minutos, quer a proteção de ecrã tenha corrido ou não. Guarde o ficheiro e a shell adota os novos tempos de imediato.

Se dispensar a proteção de ecrã antes do prazo de bloqueio, isso conta como atividade e o bloqueio pendente é cancelado. Não fica com a sessão bloqueada só por espreitar a sua máquina.

Para deixar de bloquear por inatividade por completo, `Super + Ctrl + I` — ou `omarchy toggle idle` — liga o manter acordado, e o indicador da chávena de café aparece na barra. É esse que deve acionar antes de uma apresentação longa ou de uma compilação que quer observar. Acione-o outra vez para voltar ao normal. `omarchy toggle idle status` imprime o estado atual como JSON se precisar dele a partir de um script.

Isto diz respeito ao bloqueio e à proteção de ecrã, não à energia. A suspensão e a hibernação têm a sua própria configuração em [suspensão do sistema](36-system-sleep.md).

### A proteção de ecrã

A proteção de ecrã do Omarchy é arte ASCII a correr através de efeitos de texto aleatórios, uma instância por monitor. Qualquer tecla ou movimento do rato sai dela.

Pode iniciá-la a pedido a partir de _Sistema > Proteção de Ecrã_ (`Super + Esc`), o que a força a surgir mesmo que tenha desligado a proteção de ecrã por inatividade. Não há nenhuma tecla de atalho associada por predefinição.

`omarchy toggle screensaver` é o que desliga a de inatividade, se preferir ir direto do trabalho para o bloqueado. Precisa de um terminal que saiba configurar — Alacritty, Foot, Ghostty ou Kitty — e dir-lhe-á isso mesmo se o seu terminal predefinido for outro.

O logótipo que desenha é seu para alterar, em _Aspeto > Identidade Visual > Proteção de Ecrã_. Carregue um png ou svg e o Omarchy converte-o para ASCII. Consulte [identidade visual](41-branding.md).

### O ecrã de bloqueio

`Super + Ctrl + L` bloqueia a máquina. Isso corre o ecrã de bloqueio da shell do Omarchy, apaga o ecrã, repõe o esquema de teclado no primeiro para não escrever a palavra-passe no alfabeto errado e — se o tiver a correr — bloqueia o 1Password à saída.

O ecrã de bloqueio aceita uma palavra-passe, e também aceita uma impressão digital depois de a ter configurado. Isso, e as outras formas de autenticação, são tratados em [autenticação de hardware](37-hardware-authentication.md).
