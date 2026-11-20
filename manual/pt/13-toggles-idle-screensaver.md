# Alternâncias, Inatividade e a Proteção de Ecrã

Muito do que muda no dia a dia não é bem uma definição. É um modo que liga durante uma hora e volta a desligar: luz noturna enquanto está a trabalhar até tarde, não incomodar enquanto está a fazer uma apresentação, manter acordado enquanto está a ver alguma coisa. O Omarchy chama-lhes alternâncias, e todas funcionam da mesma forma — uma tecla de atalho, uma entrada de menu e um comando, tudo a atuar sobre o mesmo interruptor.

### O menu de alternâncias

`Super + Ctrl + O` abre diretamente _Trigger > Toggle_, ou pode ir até lá a partir do menu do Omarchy (`Super + Space`). Tudo nessa lista é um interruptor que pode acionar sem pensar onde vive o estado. Os interruptores relativos ao aspeto do ambiente de trabalho ficam ao lado, em _Appearance_.

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
| Painel tátil | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Ecrã tátil | — | `omarchy device touchscreen` |
| Suspensão | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Os interruptores do painel tátil, do ecrã tátil e da GPU híbrida vivem em _Trigger > Hardware_ (`Super + Ctrl + H`) e não em Toggle, uma vez que só aparecem quando tem mesmo esse hardware. Os do painel tátil e do ecrã tátil sobrevivem a um recarregamento do Hyprland — o nome do dispositivo desativado é guardado num pequeno ficheiro de estado que o Hyprland lê no arranque para o voltar a desativar.

_Appearance_ contém a barra de menus e as animações, além de algumas coisas que não são comandos `omarchy toggle` mas que se comportam da mesma forma: a percentagem da bateria na barra, o esquema predefinido dos espaços de trabalho e, em _Windows_, os intervalos entre janelas (`Super + Shift + Backspace`) e o formato quadrado de 1 janela (`Super + Ctrl + Backspace`).

Quando o Hyprland não tem nenhuma GPU com que desenhar e renderiza no CPU (llvmpipe), como em Macs cuja GPU ainda não é suportada, na maioria das máquinas virtuais ou quando um controlador gráfico não consegue carregar, o Omarchy desliga as animações, o desfoque e as sombras nessa sessão e avisa-o uma vez com uma notificação. _Appearance > Animations On_ volta a ativá-los, e o Omarchy também se lembra disso para sessões posteriores.

A maioria são apenas um ficheiro de sinalização em `~/.local/state/omarchy/toggles/`. Se quiser ramificar com base num deles num script, `omarchy-toggle-enabled` dá-lhe um código de saída em vez de o obrigar a ir procurar:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Os sinalizadores têm nomes relativos ao estado desligado — `screensaver-off`, `suspend-off`, `bar-off` — por isso a sua presença significa que a funcionalidade está desativada.

### Indicadores na barra

Quando um modo está ligado, aparece um pequeno glifo no meio da barra superior, ao lado do relógio. É o widget de indicadores e inclui ditado, gravação de ecrã, lembretes pendentes, luz noturna, não incomodar e manter acordado.

Os indicadores inativos ficam ocultos. Passe o rato por qualquer ponto da barra e eles surgem esbatidos, para poder clicar num para o ligar sem saber a sua tecla de atalho. Clicar num ativo volta a desligá-lo. Se preferir vê-los todos sempre, defina `alwaysShow` como `true` na entrada `omarchy.indicators` em `~/.config/omarchy/shell.json` — consulte [a barra superior](05-the-top-bar.md) para saber como são configurados os widgets da barra.

### Luz noturna

A luz noturna aquece o ecrã para 4000K, e voltar a alterná-la repõe-no nos 6500K. Acione-a a partir do menu de alternâncias (`Super + Ctrl + O`) ou com `omarchy toggle nightlight`. É controlada pelo hyprsunset, que a alternância inicia por si se ainda não estiver em execução.

Por defeito, o hyprsunset não faz absolutamente nada ao ecrã. O `~/.config/hypr/hyprsunset.conf` vem com um perfil de identidade precisamente para o ecrã ficar intocado até pedir calor. Se preferir que mude de acordo com o relógio, substitua-o por um perfil temporal:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Depois, inicie o hyprsunset no início de sessão adicionando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. O par 4000K/6500K usado pela alternância é fixo, por isso é ao ficheiro de configuração que deve recorrer se quiser uma temperatura diferente.

### Não incomodar

`Super + Ctrl + Alt + ,` silencia as notificações. Não surge nenhuma notificação emergente enquanto estiver ligado, e o indicador do sino riscado fica na barra para lhe lembrar por que razão o ambiente de trabalho ficou silencioso.

Mas nada se perde. As notificações silenciadas ficam retidas: volte a colocar as últimas no ecrã com `Super + Shift + Alt + ,`. Consulte [avisos](10-notices.md) para saber o resto.

Dois tipos de mensagens continuam a passar: as notificações emergentes de confirmação do próprio Omarchy relativas a algo que acabou de fazer ("Theme changed", "Screenshot saved") e os alertas críticos enviados a partir da linha de comandos. As aplicações de chat que marcam tudo como crítico para se imporem à sua frente não contam.

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

Ambos os números são segundos contados a partir do momento em que entrou em inatividade — e não um a partir do outro. Assim, com os valores predefinidos, a proteção de ecrã surge ao fim de dois minutos e meio e o ecrã de bloqueio assume o controlo aos cinco minutos, quer a proteção de ecrã tenha sido executada ou não. Guarde o ficheiro e a shell adota de imediato os novos tempos.

Se dispensar a proteção de ecrã antes do prazo de bloqueio, isso conta como atividade e o bloqueio pendente é cancelado. Não fica bloqueado por dar uma espreitadela à sua máquina.

Para deixar de bloquear por inatividade de todo, `Super + Ctrl + I` — ou `omarchy toggle idle` — ativa o manter acordado, e o indicador da chávena de café aparece na barra. É esse que deve acionar antes de uma apresentação longa ou de uma compilação que quer acompanhar. Acione-o novamente para voltar ao normal. `omarchy toggle idle status` imprime o estado atual como JSON, se precisar dele a partir de um script.

Isto diz respeito ao bloqueio e à proteção de ecrã, não à energia. A suspensão e a hibernação têm a sua própria configuração em [suspensão do sistema](36-system-sleep.md).

### A proteção de ecrã

A proteção de ecrã do Omarchy é arte ASCII a passar por efeitos de texto aleatórios, uma instância por monitor. Qualquer tecla ou movimento do rato fecha-a.

Pode iniciá-la a pedido a partir de _System > Screensaver_ (`Super + Esc`), o que a força a surgir mesmo que tenha desligado a proteção de ecrã por inatividade. Por defeito, não lhe está associada nenhuma tecla de atalho.

`omarchy toggle screensaver` é o que desliga a de inatividade, se preferir passar diretamente do trabalho para o bloqueio. Qualquer tecla, clique, deslocamento ou movimento do rato fecha-a.

O logótipo que desenha pode ser alterado por si, em _Appearance > Branding > Screensaver_. Carregue um png ou svg e o Omarchy converte-o para ASCII. Consulte [identidade visual](41-branding.md).

### O ecrã de bloqueio

`Super + Ctrl + L` bloqueia a máquina. Isso executa o ecrã de bloqueio da shell do Omarchy, apaga o ecrã, repõe o esquema do teclado no primeiro para não estar a escrever a palavra-passe no alfabeto errado e — se o tiver em execução — bloqueia o 1Password ao sair.

O ecrã de bloqueio aceita uma palavra-passe e também aceitará uma impressão digital depois de a configurar. Isso, e as outras formas de autenticação, são tratados em [autenticação de hardware](37-hardware-authentication.md).
