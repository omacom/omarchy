# Alternâncias, Inatividade e a Proteção de Ecrã

Muito do que alteras no dia a dia não é propriamente uma definição. É um modo que ativas por uma hora e voltas a desativar: luz noturna enquanto estás a trabalhar até tarde, não incomodar enquanto estás a fazer uma apresentação, manter acordado enquanto estás a ver alguma coisa. O Omarchy chama a isso alternâncias, e funcionam todas da mesma maneira — uma tecla de atalho, uma entrada de menu e um comando, todos a atuar sobre o mesmo interruptor.

### O menu de alternâncias

`Super + Ctrl + O` abre _Trigger > Toggle_ diretamente, ou podes lá chegar a partir do menu do Omarchy (`Super + Space`). Tudo o que está nessa lista é um interruptor que podes ligar e desligar sem pensar onde vive o estado. Os interruptores relativos ao aspeto do ambiente de trabalho ficam ao lado, em _Appearance_.

A partir do terminal, os mesmos interruptores são `omarchy toggle <thing>`. Executa `omarchy toggle` sozinho para veres o grupo completo.

| Alternância | Tecla de atalho | Comando |
| ------ | ------ | ------- |
| Luz noturna | — | `omarchy toggle nightlight` |
| Silenciar notificações | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Manter acordado (sem bloqueio por inatividade) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de falhas | — | `omarchy toggle crash-capture` |
| Proteção de ecrã | — | `omarchy toggle screensaver` |
| Sincronização de tema do [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra de menus | `Super + Shift + Space` | `omarchy toggle bar` |
| Painel tátil | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Ecrã tátil | — | `omarchy toggle touchscreen` |
| Suspender | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Os interruptores do painel tátil, do ecrã tátil e da GPU híbrida ficam em _Trigger > Hardware_ (`Super + Ctrl + H`) e não em Toggle, uma vez que só aparecem quando tens realmente esse hardware. Os do painel tátil e do ecrã tátil sobrevivem a um recarregamento do Hyprland — o nome do dispositivo desativado é guardado num pequeno ficheiro de estado que o Hyprland lê no arranque para o voltar a desativar.

_Appearance_ reúne a barra de menus e as animações, mais algumas coisas que não são comandos `omarchy toggle` mas que se comportam da mesma forma: a percentagem da bateria na barra, a disposição predefinida da área de trabalho e, em _Windows_, os espaços entre janelas (`Super + Shift + Backspace`) e o aspeto quadrado com 1 janela (`Super + Ctrl + Backspace`).

Quando o Hyprland não tem nenhuma GPU com que desenhar e renderiza antes no CPU (llvmpipe), como nos Macs cuja GPU ainda não é suportada, na maioria das máquinas virtuais, ou quando um controlador gráfico não carrega, o Omarchy desliga as animações, o desfoque e as sombras durante essa sessão e avisa-te disso uma vez com uma notificação. _Appearance > Animations On_ volta a ativar tudo isso, e o Omarchy lembra-se disso também para sessões posteriores.

A maioria são apenas um ficheiro de sinalização em `~/.local/state/omarchy/toggles/`. Se quiseres condicionar um script com base num deles, `omarchy-toggle-enabled` dá-te um código de saída em vez de te obrigar a ir procurar:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Os sinalizadores têm nomes correspondentes ao estado desligado — `screensaver-off`, `suspend-off`, `bar-off` — pelo que a sua presença significa que a funcionalidade está desativada.

### Indicadores na barra

Quando um modo está ativo, aparece um pequeno glifo no meio da barra superior, ao lado do relógio. É o widget de indicadores, e inclui ditado, gravação de ecrã, lembretes pendentes, luz noturna, não incomodar e manter acordado.

Os indicadores inativos ficam ocultos. Passa o rato por qualquer ponto da barra e eles surgem esbatidos, para poderes clicar num para o ativar sem saberes a sua tecla de atalho. Clicar num ativo volta a desativá-lo. Se preferires vê-los todos sempre, define `alwaysShow` como `true` na entrada `omarchy.indicators` em `~/.config/omarchy/shell.json` — consulta [a barra superior](05-the-top-bar.md) para saberes como se configuram os widgets da barra.

### Luz noturna

A luz noturna aquece o ecrã para 4000K, e voltar a alterná-la repõe os 6500K. Ativa-a a partir do menu de alternâncias (`Super + Ctrl + O`) ou com `omarchy toggle nightlight`. É controlada pelo hyprsunset, que a alternância arranca por ti se ainda não estiver a correr.

Por predefinição, o hyprsunset não faz absolutamente nada ao teu ecrã. `~/.config/hypr/hyprsunset.conf` vem com um perfil de identidade precisamente para o ecrã ficar intocado até pedires calor. Se preferires que mude de acordo com o relógio, substitui isso por um perfil de horário:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Depois, arranca o hyprsunset ao iniciar sessão adicionando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. O par 4000K/6500K usado pela alternância é fixo, pelo que é ao ficheiro de configuração que recorres se quiseres uma temperatura diferente.

### Não incomodar

`Super + Ctrl + Alt + ,` silencia as notificações. Não surgem avisos flutuantes enquanto estiver ativo, e o indicador do sino riscado fica na barra para te lembrar por que razão o ambiente de trabalho ficou em silêncio.

Mas nada se perde. As notificações silenciadas ficam retidas: volta a mostrar as últimas no ecrã com `Super + Shift + Alt + ,`. Consulta [avisos](10-notices.md) para o resto.

Dois tipos de mensagens continuam a passar: os avisos de confirmação do próprio Omarchy relativos a algo que acabaste de fazer ("Theme changed", "Screenshot saved"), e os alertas críticos enviados a partir da linha de comandos. As aplicações de conversa que marcam tudo como crítico para se imporem à tua frente não contam.

### Inatividade

A shell do Omarchy é responsável pelo comportamento em inatividade, e as temporizações são um bloco `idle` de nível superior em `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambos os números são segundos contados a partir do momento em que ficaste inativo — não um a partir do outro. Assim, com as predefinições, a proteção de ecrã surge ao fim de dois minutos e meio e o ecrã de bloqueio assume ao fim de cinco minutos, quer a proteção de ecrã tenha corrido ou não. Guarda o ficheiro e a shell adota de imediato os novos tempos.

Se fechares a proteção de ecrã antes do prazo de bloqueio, isso conta como atividade e o bloqueio pendente é cancelado. Não ficas bloqueado por espreitares a tua máquina.

Para deixares de bloquear por inatividade por completo, `Super + Ctrl + I` — ou `omarchy toggle idle` — ativa o manter acordado, e o indicador da chávena de café aparece na barra. É esse que deves premir antes de uma apresentação longa ou de uma compilação que queres acompanhar. Prime-o outra vez para voltares ao normal. `omarchy toggle idle status` imprime o estado atual como JSON se precisares dele a partir de um script.

Isto diz respeito ao bloqueio e à proteção de ecrã, não à energia. A suspensão e a hibernação têm a sua própria configuração em [suspensão do sistema](36-system-sleep.md).

### A proteção de ecrã

A proteção de ecrã do Omarchy é arte ASCII a passar por efeitos de texto aleatórios, uma instância por monitor. Qualquer tecla ou movimento do rato faz sair dela.

Podes arrancá-la a pedido a partir de _System > Screensaver_ (`Super + Esc`), o que a força a aparecer mesmo que tenhas desligado a proteção de ecrã por inatividade. Por predefinição, não há nenhuma tecla de atalho associada a ela.

É `omarchy toggle screensaver` que desliga a de inatividade, se preferires passar diretamente do trabalho para o bloqueio. Qualquer tecla, clique, deslocamento ou movimento do rato fecha-a.

O logótipo que desenha pode ser alterado por ti, em _Appearance > Branding > Screensaver_. Carrega um png ou svg e o Omarchy converte-o para ASCII. Consulta [identidade visual](41-branding.md).

### O ecrã de bloqueio

`Super + Ctrl + L` bloqueia a máquina. Isso corre o ecrã de bloqueio da shell do Omarchy, apaga o ecrã, repõe a disposição do teclado na primeira para não estares a escrever a tua palavra-passe no alfabeto errado e — se o tiveres a correr — bloqueia o 1Password à saída.

O ecrã de bloqueio aceita uma palavra-passe, e também aceita uma impressão digital assim que tiveres configurado uma. Isso, e as outras formas de autenticação, estão tratados em [autenticação por hardware](37-hardware-authentication.md).
