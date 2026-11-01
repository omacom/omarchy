# Interruptores, Inatividade e o Protetor de Ecrã

Muito do que mudas no dia a dia não é bem uma definição. É um modo que ligas durante uma hora e voltas a desligar: luz noturna enquanto estás a trabalhar até tarde, não incomodar enquanto estás a apresentar, manter acordado enquanto estás a ver alguma coisa. O Omarchy chama-lhes interruptores, e todos funcionam da mesma maneira — uma tecla de atalho, uma entrada de menu e um comando, tudo a atuar sobre o mesmo interruptor.

### O menu de interruptores

`Super + Ctrl + O` abre diretamente _Trigger > Toggle_, ou podes ir até lá a partir do menu do Omarchy (`Super + Space`). Tudo o que está nessa lista é um interruptor que podes alternar sem pensares onde vive o estado. Os interruptores relativos ao aspeto do ambiente de trabalho ficam ao lado, em _Appearance_.

A partir do terminal, os mesmos interruptores são `omarchy toggle <thing>`. Corre `omarchy toggle` sozinho para veres o grupo inteiro.

| Interruptor | Tecla de atalho | Comando |
| ------ | ------ | ------- |
| Luz noturna | — | `omarchy toggle nightlight` |
| Silenciar notificações | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Manter acordado (sem bloqueio por inatividade) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de falhas | — | `omarchy toggle crash-capture` |
| Protetor de ecrã | — | `omarchy toggle screensaver` |
| Sincronização de tema do [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra de menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Ecrã tátil | — | `omarchy toggle touchscreen` |
| Suspender | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Os interruptores do touchpad, do ecrã tátil e da GPU híbrida ficam em _Trigger > Hardware_ (`Super + Ctrl + H`) e não em Toggle, porque só aparecem quando tens mesmo esse hardware. Os do touchpad e do ecrã tátil sobrevivem a um recarregamento do Hyprland — o nome do dispositivo desativado é guardado num pequeno ficheiro de estado que o Hyprland lê no arranque para o desativar outra vez.

Em _Appearance_ ficam a barra de menu e as animações, mais algumas coisas que não são comandos `omarchy toggle`, mas se comportam da mesma forma: a percentagem da bateria na barra, a disposição predefinida das áreas de trabalho e, em _Windows_, os espaços entre janelas (`Super + Shift + Backspace`) e o formato quadrado de 1 janela (`Super + Ctrl + Backspace`).

A maioria destes é apenas um ficheiro de sinalização em `~/.local/state/omarchy/toggles/`. Se quiseres fazer uma ramificação com base num deles num script, o `omarchy-toggle-enabled` dá-te um código de saída em vez de te obrigar a ir procurar:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

As sinalizações têm nomes correspondentes ao estado desligado — `screensaver-off`, `suspend-off`, `bar-off` — por isso a presença delas significa que a funcionalidade está desativada.

### Indicadores na barra

Quando um modo está ligado, aparece um pequeno glifo no meio da barra superior, ao lado do relógio. É o widget de indicadores, e inclui ditado, gravação de ecrã, lembretes pendentes, luz noturna, não incomodar e manter acordado.

Os indicadores inativos ficam ocultos. Passa o cursor sobre qualquer ponto da barra e eles surgem esbatidos, para poderes clicar num para o ligar sem conheceres a tecla de atalho dele. Clicar num ativo volta a desligá-lo. Se preferires vê-los todos o tempo todo, define `alwaysShow` como `true` na entrada `omarchy.indicators` em `~/.config/omarchy/shell.json` — consulta [a barra superior](05-the-top-bar.md) para saberes como os widgets da barra são configurados.

### Luz noturna

A luz noturna aquece o ecrã para 4000K, e voltar a alterná-la repõe-no nos 6500K. Alterna-a a partir do menu de interruptores (`Super + Ctrl + O`) ou com `omarchy toggle nightlight`. É o hyprsunset que a controla, e o interruptor arranca-o por ti se ele ainda não estiver em execução.

Por predefinição, o hyprsunset não faz absolutamente nada ao teu ecrã. O `~/.config/hypr/hyprsunset.conf` vem com um perfil de identidade precisamente para o ecrã ficar intocado até pedires calor. Se preferires que ele mude de acordo com o relógio, substitui isso por um perfil baseado na hora:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Depois, arranca o hyprsunset no início de sessão adicionando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. O par 4000K/6500K usado pelo interruptor é fixo, por isso é ao ficheiro de configuração que recorres se quiseres uma temperatura diferente.

### Não incomodar

O `Super + Ctrl + Alt + ,` silencia as notificações. Não surgem avisos enquanto estiver ativo, e o indicador do sino riscado fica na barra para te lembrar porque é que o ambiente de trabalho ficou em silêncio.

Mas nada se perde. As notificações silenciadas ficam retidas: volta a pôr as últimas no ecrã com `Super + Shift + Alt + ,`. Consulta [avisos](10-notices.md) para o resto.

Dois tipos de mensagem continuam a passar: os avisos de confirmação do próprio Omarchy para algo que acabaste de fazer ("Theme changed", "Screenshot saved"), e os alertas críticos enviados a partir da linha de comandos. As aplicações de chat que marcam tudo como crítico para se imporem à tua frente não contam.

### Inatividade

A shell do Omarchy é responsável pelo comportamento em inatividade, e os tempos estão num bloco `idle` de nível superior em `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambos os números são segundos contados a partir do momento em que entraste em inatividade — não um a partir do outro. Por isso, com as predefinições, o protetor de ecrã surge ao fim de dois minutos e meio e o ecrã de bloqueio assume aos cinco minutos, quer o protetor de ecrã tenha corrido ou não. Guarda o ficheiro e a shell adota os novos tempos de imediato.

Se dispensares o protetor de ecrã antes do prazo de bloqueio, isso conta como atividade e o bloqueio pendente é cancelado. Não ficas com a sessão bloqueada só por deitares um olhar à tua máquina.

Para deixares de bloquear por inatividade de vez, o `Super + Ctrl + I` — ou `omarchy toggle idle` — ativa o manter acordado, e o indicador da chávena de café aparece na barra. É esse que deves premir antes de uma apresentação longa ou de uma compilação que queres acompanhar. Preme-o outra vez para voltares ao normal. O `omarchy toggle idle status` imprime o estado atual como JSON, se precisares dele a partir de um script.

Isto diz respeito ao bloqueio e ao protetor de ecrã, não à energia. A suspensão e a hibernação têm a sua própria configuração em [suspensão do sistema](36-system-sleep.md).

### O protetor de ecrã

O protetor de ecrã do Omarchy é arte ASCII a passar por efeitos de texto aleatórios, uma instância por monitor. Qualquer tecla ou movimento do rato fecha-o.

Podes arrancá-lo a pedido a partir de _System > Screensaver_ (`Super + Esc`), o que o força a aparecer mesmo que tenhas desligado o protetor de ecrã por inatividade. Por predefinição, não há nenhuma tecla de atalho associada a ele.

O `omarchy toggle screensaver` é o que desliga o de inatividade, se preferires passar diretamente do trabalho para o bloqueio. Qualquer tecla, clique, uso da roda ou movimento do rato fecha-o.

O logótipo que ele desenha pode ser alterado por ti, em _Appearance > Branding > Screensaver_. Carrega um png ou svg e o Omarchy converte-o para ASCII. Consulta [identidade visual](41-branding.md).

### O ecrã de bloqueio

O `Super + Ctrl + L` bloqueia a máquina. Isso executa o ecrã de bloqueio da shell do Omarchy, deixa o ecrã em branco, repõe a disposição do teclado na primeira opção para não escreveres a palavra-passe no alfabeto errado e — se o tiveres em execução — bloqueia o 1Password à saída.

O ecrã de bloqueio aceita uma palavra-passe, e também aceita uma impressão digital assim que tiveres uma configurada. Isso, e as outras formas de autenticação, estão tratados em [autenticação por hardware](37-hardware-authentication.md).
