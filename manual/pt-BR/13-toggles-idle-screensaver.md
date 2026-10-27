# Alternâncias, Ociosidade e o Protetor de Tela

Muita coisa que você muda no dia a dia não é bem uma configuração. É um modo que você liga por uma hora e depois desliga: luz noturna enquanto trabalha até tarde, não perturbe enquanto faz uma apresentação, manter acordado enquanto assiste a algo. O Omarchy chama isso de alternâncias, e todas funcionam do mesmo jeito — uma tecla de atalho, uma entrada de menu e um comando, todos acionando o mesmo interruptor.

### O menu de alternâncias

`Super + Ctrl + O` abre diretamente _Acionar > Alternar_, ou você pode chegar lá pelo menu do Omarchy (`Super + Space`). Tudo nessa lista é um interruptor que você pode acionar sem pensar onde o estado fica guardado. Os interruptores de aparência da área de trabalho ficam ao lado, em _Aparência_.

Pelo terminal, os mesmos interruptores são `omarchy toggle <thing>`. Execute `omarchy toggle` sozinho para ver o grupo inteiro.

| Alternância | Tecla de atalho | Comando |
| ------ | ------ | ------- |
| Luz noturna | — | `omarchy toggle nightlight` |
| Silenciar notificações | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Manter acordado (sem bloqueio por ociosidade) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de falhas | — | `omarchy toggle crash-capture` |
| Protetor de tela | — | `omarchy toggle screensaver` |
| Sincronização de tema do [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra de menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Tela sensível ao toque | — | `omarchy toggle touchscreen` |
| Suspender | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Os interruptores de touchpad, tela sensível ao toque e GPU híbrida ficam em _Acionar > Hardware_ (`Super + Ctrl + H`) em vez de em Alternar, porque eles só aparecem quando você realmente tem esse hardware. Os de touchpad e tela sensível ao toque sobrevivem a um recarregamento do Hyprland — o nome do dispositivo desativado é salvo em um pequeno arquivo de estado que o Hyprland lê na inicialização para desativá-lo de novo.

_Aparência_ guarda a barra de menu e as animações, além de algumas coisas que não são comandos `omarchy toggle`, mas se comportam do mesmo jeito: a porcentagem da bateria na barra, o layout padrão do espaço de trabalho e, em _Janelas_, os espaçamentos entre janelas (`Super + Shift + Backspace`) e a proporção quadrada de 1 janela (`Super + Ctrl + Backspace`).

A maioria delas é só um arquivo de sinalização em `~/.local/state/omarchy/toggles/`. Se quiser ramificar com base em uma delas em um script, `omarchy-toggle-enabled` fornece um código de saída em vez de obrigar você a ir procurar:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

As sinalizações são nomeadas pelo estado desligado — `screensaver-off`, `suspend-off`, `bar-off` — então a presença delas significa que o recurso está desativado.

### Indicadores na barra

Quando um modo está ligado, você ganha um pequeno glifo no meio da barra superior, ao lado do relógio. Esse é o widget de indicadores, e ele carrega ditado, gravação de tela, lembretes pendentes, luz noturna, não perturbe e manter acordado.

Indicadores inativos ficam ocultos. Passe o mouse em qualquer lugar da barra e eles aparecem esmaecidos, para você poder clicar em um para ligá-lo sem saber sua tecla de atalho. Clicar em um ativo o desliga de novo. Se preferir ver todos eles o tempo todo, defina `alwaysShow` como `true` na entrada `omarchy.indicators` em `~/.config/omarchy/shell.json` — veja [a barra superior](05-the-top-bar.md) para saber como os widgets da barra são configurados.

### Luz noturna

A luz noturna aquece a tela para 4000K, e alterná-la de novo a coloca de volta em 6500K. Acione-a pelo menu de alternâncias (`Super + Ctrl + O`) ou com `omarchy toggle nightlight`. Ela é controlada pelo hyprsunset, que a alternância inicia para você se ele ainda não estiver em execução.

Por padrão, o hyprsunset não faz absolutamente nada com a sua tela. `~/.config/hypr/hyprsunset.conf` vem com um perfil de identidade justamente para a tela ficar intocada até você pedir calor. Se preferir que ele mude pelo relógio, substitua isso por um perfil de horário:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Depois inicie o hyprsunset no login adicionando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. O par 4000K/6500K usado pela alternância é fixo, então o arquivo de configuração é onde você vai se quiser uma temperatura diferente.

### Não perturbe

`Super + Ctrl + Alt + ,` silencia as notificações. Nenhuma notificação instantânea aparece enquanto ele está ligado, e o indicador de sino riscado fica na barra para lembrar por que a área de trabalho ficou quieta.

Nada se perde, porém. Notificações silenciadas são retidas: coloque as últimas de volta na tela com `Super + Shift + Alt + ,`. Veja [avisos](10-notices.md) para o restante.

Dois tipos de mensagem ainda passam: as notificações de confirmação do próprio Omarchy para algo que você acabou de fazer ("Theme changed", "Screenshot saved") e alertas críticos enviados pela linha de comando. Aplicativos de bate-papo que marcam tudo como crítico para forçar passagem na sua frente não se qualificam.

### Ociosidade

O shell do Omarchy é dono do comportamento de ociosidade, e os tempos são um bloco `idle` de nível superior em `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambos os números são segundos contados a partir do momento em que você ficou ocioso — não um a partir do outro. Então, com os padrões, o protetor de tela aparece depois de dois minutos e meio e a tela de bloqueio assume aos cinco minutos, o protetor de tela tendo executado ou não. Salve o arquivo e o shell adota os novos tempos na hora.

Se você dispensar o protetor de tela antes do prazo de bloqueio, isso conta como atividade e o bloqueio pendente é cancelado. Você não fica bloqueado por dar uma olhada na sua máquina.

Para parar totalmente de bloquear por ociosidade, `Super + Ctrl + I` — ou `omarchy toggle idle` — liga o manter acordado, e o indicador de xícara de café aparece na barra. É esse que você deve acionar antes de uma apresentação longa ou de uma compilação que quer acompanhar. Acione de novo para voltar ao normal. `omarchy toggle idle status` imprime o estado atual como JSON se você precisar dele em um script.

Isso é sobre bloqueio e protetor de tela, não sobre energia. Suspensão e hibernação têm sua própria configuração em [suspensão do sistema](36-system-sleep.md).

### O protetor de tela

O protetor de tela do Omarchy é arte ASCII passando por efeitos de texto aleatórios, uma instância por monitor. Qualquer tecla ou movimento do mouse sai dele.

Você pode iniciá-lo sob demanda em _Sistema > Protetor de tela_ (`Super + Esc`), o que o força a aparecer mesmo se você tiver desligado o protetor de tela por ociosidade. Não há tecla de atalho vinculada a ele por padrão.

`omarchy toggle screensaver` é o que desliga o de ociosidade, se você preferir ir direto do trabalho para o bloqueio. Ele precisa de um terminal que saiba configurar — Alacritty, Foot, Ghostty ou Kitty — e vai avisar se o seu terminal padrão for outra coisa.

O logo que ele desenha é seu para mudar, em _Aparência > Identidade visual > Protetor de tela_. Envie um png ou svg e o Omarchy o converte para ASCII. Veja [identidade visual](41-branding.md).

### A tela de bloqueio

`Super + Ctrl + L` bloqueia a máquina. Isso executa a tela de bloqueio do shell do Omarchy, apaga a tela, redefine seu layout de teclado para o primeiro para você não digitar sua senha no alfabeto errado e — se você o tiver em execução — bloqueia o 1Password na saída.

A tela de bloqueio aceita uma senha, e também aceita uma impressão digital depois que você configurar uma. Isso, e as outras formas de autenticação, são abordados em [autenticação de hardware](37-hardware-authentication.md).
