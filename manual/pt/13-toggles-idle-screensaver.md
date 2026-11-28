# Alternâncias, Inatividade e a Proteção de Ecrã

Muito do que altera no dia a dia não é bem uma definição. É um modo que ativa durante uma hora e volta a desativar: a luz noturna enquanto está a trabalhar até tarde, o não incomodar enquanto está a fazer uma apresentação, manter acordado enquanto está a ver alguma coisa. O Omarchy chama-lhes alternâncias e todas funcionam da mesma maneira — uma tecla de atalho, uma entrada de menu e um comando, todos a atuar sobre o mesmo interruptor.

### O menu de alternâncias

`Super + Ctrl + O` abre diretamente _Acionar > Alternar_, ou pode ir até lá a partir do menu do Omarchy (`Super + Space`). Tudo o que está nessa lista é um interruptor que pode alternar sem pensar em onde vive o estado. Os interruptores relativos ao aspeto do ambiente de trabalho estão ao lado, em _Aspeto_.

A partir do terminal, os mesmos interruptores são `omarchy toggle <thing>`. Execute `omarchy toggle` sozinho para ver o grupo completo.

| Alternância | Tecla de atalho | Comando |
| ------ | ------ | ------- |
| Luz noturna | — | `omarchy toggle nightlight` |
| Silenciar notificações | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Manter acordado (sem bloqueio por inatividade) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de falhas | — | `omarchy toggle crash-capture` |
| Proteção de ecrã | — | `omarchy toggle screensaver` |
| Sincronização de tema do [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra de menus | `Super + Shift + Space` | `omarchy toggle bar` |
| Ambiente de trabalho em ecrã inteiro (sem barra, sem intervalos) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animações, desfocagem e sombras | — | `omarchy toggle animations` |
| Painel tátil | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Ecrã tátil | — | `omarchy device touchscreen` |
| Suspender | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy device gpu hybrid` |

Os interruptores do painel tátil, do ecrã tátil e da GPU híbrida vivem em _Acionar > Hardware_ (`Super + Ctrl + H`) e não em Alternar, porque só aparecem quando tem realmente esse hardware. Os do painel tátil e do ecrã tátil sobrevivem a um recarregamento do Hyprland — o nome do dispositivo desativado é guardado num pequeno ficheiro de estado que o Hyprland lê no arranque para o desativar outra vez.

_Aspeto_ contém a barra de menus e as animações, mais algumas coisas que não são comandos `omarchy toggle` mas se comportam da mesma maneira: a percentagem da bateria na barra, o esquema predefinido das áreas de trabalho e, em _Janelas_, os intervalos entre janelas (`Super + Shift + Backspace`) e o aspeto quadrado de 1 janela (`Super + Ctrl + Backspace`).

Quando o Hyprland não tem nenhuma GPU com que desenhar e faz a renderização no CPU (llvmpipe), como nos Mac cuja GPU ainda não é suportada, na maioria das máquinas virtuais ou quando um controlador gráfico não consegue carregar, o Omarchy desativa as animações, a desfocagem e as sombras durante essa sessão e avisa-o uma vez com uma notificação. _Aspeto > Ativar Animações_ traz tudo de volta, e o Omarchy também se lembra disso para sessões posteriores.

A maioria destas alternâncias é apenas um ficheiro de sinalização em `~/.local/state/omarchy/toggles/`. Se quiser ramificar com base numa delas num script, `omarchy-toggle-enabled` devolve-lhe um código de saída em vez de o obrigar a ir à procura:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Os sinalizadores têm nomes relativos ao estado desativado — `screensaver-off`, `suspend-off`, `bar-off` —, por isso a presença deles significa que a funcionalidade está desativada.

### Indicadores na barra

Quando um modo está ativo, aparece um pequeno glifo no meio da barra superior, junto ao relógio. É o widget de indicadores e inclui a gravação de ecrã, os lembretes pendentes, a luz noturna, o não incomodar e o manter acordado, além de avisos enquanto o sudo sem palavra-passe estiver ativo ou alguém estiver ligado a uma sessão remota.

Os indicadores inativos ficam ocultos. Passe o cursor por qualquer ponto da barra e eles surgem esbatidos, para poder clicar num para o ativar sem conhecer a respetiva tecla de atalho. Clicar num indicador ativo volta a desativá-lo. Se preferir vê-los todos o tempo todo, defina `alwaysShow` como `true` na entrada `omarchy.indicators` em `~/.config/omarchy/shell.json` — consulte [a barra superior](05-the-top-bar.md) para saber como são configurados os widgets da barra.

### Luz noturna

A luz noturna aquece o ecrã para 4000K, e alterná-la outra vez repõe os 6500K. Alterne-a a partir do menu de alternâncias (`Super + Ctrl + O`) ou com `omarchy toggle nightlight`. É acionada pelo hyprsunset, que a alternância arranca por si se ele ainda não estiver em execução.

Por predefinição, o hyprsunset não faz rigorosamente nada ao seu ecrã. `~/.config/hypr/hyprsunset.conf` é fornecido com um perfil de identidade precisamente para o ecrã permanecer intocado até pedir calor. Se preferir que ele mude de acordo com o relógio, substitua isso por um perfil temporal:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Depois arranque o hyprsunset no início de sessão, adicionando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. O par 4000K/6500K usado pela alternância é fixo, por isso o ficheiro de configuração é onde deve ir se quiser uma temperatura diferente.

### Não incomodar

`Super + Ctrl + Alt + ,` silencia as notificações. Não surgem avisos no ecrã enquanto estiver ativo, e o indicador do sino riscado fica na barra para lhe lembrar por que razão o ambiente de trabalho ficou silencioso.

Mas nada se perde. As notificações silenciadas ficam retidas: volte a pôr as últimas no ecrã com `Super + Shift + Alt + ,`. Consulte [avisos](10-notices.md) para o resto.

Três tipos de mensagem continuam a passar: os avisos de confirmação do próprio Omarchy relativos a algo que acabou de fazer ("Tema alterado", "Captura de ecrã guardada"), alertas críticos enviados a partir da linha de comandos e códigos de verificação. As aplicações de chat que marcam tudo como crítico para forçarem a passagem à sua frente não contam.

### Inatividade

A shell do Omarchy é responsável pelo comportamento em inatividade, e os tempos são um bloco `idle` de nível superior em `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambos os números são segundos contados a partir do momento em que ficou inativo — não um a partir do outro. Por isso, com as predefinições, a proteção de ecrã surge ao fim de dois minutos e meio e o ecrã de bloqueio assume o controlo aos cinco minutos, quer a proteção de ecrã tenha sido executada quer não. Guarde o ficheiro e a shell adota os novos tempos de imediato.

Se dispensar a proteção de ecrã antes do prazo de bloqueio, isso conta como atividade e o bloqueio pendente é cancelado. Não fica bloqueado por dar uma espreitadela à sua máquina.

Para deixar de bloquear por inatividade por completo, `Super + Ctrl + I` — ou `omarchy toggle idle` — ativa o manter acordado, e o indicador da chávena de café aparece na barra. É esse que deve acionar antes de uma apresentação longa ou de uma compilação que quer estar a acompanhar. Acione-o outra vez para voltar ao normal. `omarchy toggle idle status` imprime o estado atual como JSON, se precisar dele a partir de um script.

Isto diz respeito ao bloqueio e à proteção de ecrã, não à energia. A suspensão e a hibernação têm a sua própria configuração em [suspensão do sistema](36-system-sleep.md).

### A proteção de ecrã

A proteção de ecrã do Omarchy é arte ASCII a passar por efeitos de texto aleatórios, uma instância por monitor. Qualquer tecla ou movimento do rato faz sair dela.

Pode arrancá-la a pedido a partir de _Sistema > Proteção de Ecrã_ (`Super + Esc`), o que a força a aparecer mesmo que tenha desativado a proteção de ecrã por inatividade. Por predefinição, não há nenhuma tecla de atalho associada a ela.

`omarchy toggle screensaver` é o que desativa a proteção por inatividade, se preferir passar diretamente do trabalho para o bloqueio. Qualquer tecla, clique, deslocamento ou movimento do rato fecha-a.

O logótipo que ela desenha pode ser alterado por si, em _Aspeto > Imagem de Marca > Proteção de Ecrã_. Carregue um png ou svg e o Omarchy converte-o em ASCII. Consulte [imagem de marca](41-branding.md).

### O ecrã de bloqueio

`Super + Ctrl + L` bloqueia a máquina. Isso executa o ecrã de bloqueio da shell do Omarchy, apaga o ecrã, repõe o esquema de teclado no primeiro, para não estar a escrever a palavra-passe no alfabeto errado, e — se o tiver em execução — bloqueia o 1Password ao sair.

O ecrã de bloqueio aceita uma palavra-passe, e também aceitará uma impressão digital depois de a ter configurado. Isso, e as outras formas de autenticação, estão descritos em [autenticação por hardware](37-hardware-authentication.md).
