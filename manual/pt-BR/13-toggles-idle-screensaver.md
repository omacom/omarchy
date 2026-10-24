# Alternâncias, Ociosidade e a Proteção de Tela

Muito do que você muda no dia a dia não é realmente uma configuração. É um modo que você liga por uma hora e desliga de novo: luz noturna enquanto trabalha até tarde, não perturbe enquanto apresenta, manter acordado enquanto assiste a algo. O Omarchy chama isso de alternâncias, e todas funcionam do mesmo jeito — um atalho, uma entrada de menu e um comando, todos acionando o mesmo interruptor.

### O menu de alternâncias

`Super + Ctrl + O` abre _Acionar > Alternar_ diretamente, ou você pode ir até lá a partir do menu do Omarchy (`Super + Space`). Tudo nessa lista é um interruptor que você pode acionar sem pensar onde o estado mora. Interruptores de como o desktop se parece ficam ao lado, em _Acionar > Aparência_.

No terminal, os mesmos interruptores são `omarchy toggle <thing>`. Execute `omarchy toggle` sozinho para ver o grupo inteiro.

| Alternância | Atalho | Comando |
| ------ | ------ | ------- |
| Luz noturna | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Silenciar notificações | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Manter acordado (sem bloqueio por ociosidade) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de crashes | — | `omarchy toggle crash-capture` |
| Proteção de tela | — | `omarchy toggle screensaver` |
| Sincronização de tema do [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra de menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Tela sensível ao toque | — | `omarchy toggle touchscreen` |
| Suspender | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Os interruptores de touchpad, tela sensível ao toque e GPU híbrida vivem em _Acionar > Hardware_ (`Super + Ctrl + H`) em vez de em Alternar, já que só aparecem quando você realmente tem aquele hardware. Os de touchpad e tela sensível ao toque sobrevivem a uma recarga do Hyprland — o nome do dispositivo desativado é salvo em um pequeno arquivo de estado que o Hyprland lê na inicialização para desativá-lo novamente.

_Acionar > Aparência_ guarda a barra de menu e as animações, além de algumas coisas que não são comandos `omarchy toggle`, mas se comportam do mesmo jeito: porcentagem da bateria na barra, o layout padrão da área de trabalho, espaçamentos entre janelas (`Super + Shift + Backspace`) e a proporção quadrada de 1 janela (`Super + Ctrl + Backspace`).

A maioria deles é apenas um arquivo de sinalização em `~/.local/state/omarchy/toggles/`. Se você quer ramificar com base em um deles em um script, `omarchy-toggle-enabled` lhe dá um código de saída em vez de fazer você ir procurar:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

As sinalizações são nomeadas pelo estado desligado — `screensaver-off`, `suspend-off`, `bar-off` — então sua presença significa que o recurso está desativado.

### Indicadores na barra

Quando um modo está ligado, você ganha um pequeno glifo no meio da barra superior, ao lado do relógio. Esse é o widget de indicadores, e ele carrega ditado, gravação de tela, lembretes pendentes, luz noturna, não perturbe e manter acordado.

Indicadores inativos ficam ocultos. Passe o mouse sobre a área ao redor deles e eles surgem esmaecidos, para você clicar em um e ligá-lo sem saber seu atalho. Clicar em um ativo o desliga. Se você prefere ver todos eles o tempo todo, defina `alwaysShow` como `true` na entrada `omarchy.indicators` em `~/.config/omarchy/shell.json` — veja [a barra superior](05-the-top-bar.md) para como os widgets da barra são configurados.

### Luz noturna

`Super + Ctrl + N` esquenta a tela para 4000K, e pressionar de novo a devolve a 6500K. É controlado pelo hyprsunset, que a alternância inicia para você se ele ainda não estiver rodando.

Por padrão, o hyprsunset não faz absolutamente nada com a sua tela. `~/.config/hypr/hyprsunset.conf` vem com um perfil de identidade justamente para a tela permanecer intocada até você pedir calor. Se você prefere que ele mude pelo relógio, substitua isso por um perfil de horário:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Depois inicie o hyprsunset no login adicionando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. O par 4000K/6500K usado pela alternância é fixo, então o arquivo de configuração é onde você vai se quiser uma temperatura diferente.

### Não perturbe

`Super + Ctrl + ,` silencia as notificações. Nenhum toast surge enquanto estiver ligado, e o indicador de sino riscado fica na barra para lembrá-lo de por que o desktop ficou silencioso.

Nada se perde, porém. Uma notificação silenciada é escrita direto no seu histórico de notificações, que é exatamente o registro que você quer quando volta e se pergunta o que perdeu. Abra-o com `Super + Shift + Alt + ,`. Veja [avisos](10-notices.md) para o resto da história das notificações.

Dois tipos de mensagem ainda passam: os toasts de confirmação do próprio Omarchy para algo que você acabou de fazer ("Tema alterado", "Captura de tela salva"), e alertas críticos enviados da linha de comando. Aplicativos de chat que marcam tudo como crítico para forçar caminho até você não se qualificam.

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

Ambos os números são segundos contados a partir do momento em que você ficou ocioso — não um a partir do outro. Então, com os padrões, a proteção de tela aparece depois de dois minutos e meio e a tela de bloqueio assume aos cinco minutos, tenha a proteção de tela rodado ou não. Salve o arquivo e o shell capta os novos tempos imediatamente.

Se você dispensar a proteção de tela antes do prazo de bloqueio, isso conta como atividade e o bloqueio pendente é cancelado. Você não fica bloqueado por dar uma olhada na sua máquina.

Para parar de bloquear por ociosidade por completo, `Super + Ctrl + I` — ou `omarchy toggle idle` — liga o manter acordado, e o indicador de xícara de café aparece na barra. É esse que você aciona antes de uma apresentação longa ou de um build que quer assistir. Acione de novo para voltar ao normal. `omarchy toggle idle status` imprime o estado atual como JSON, se você precisar dele em um script.

Isso trata de bloqueio e da proteção de tela, não de energia. Suspensão e hibernação têm sua própria configuração em [suspensão do sistema](36-system-sleep.md).

### A proteção de tela

A proteção de tela do Omarchy é arte ASCII passando por efeitos de texto aleatórios, uma instância por monitor. Qualquer tecla ou movimento do mouse a encerra.

Você pode iniciá-la sob demanda em _Sistema > Proteção de tela_ (`Super + Esc`), o que a força mesmo se você tiver desligado a proteção de tela por ociosidade. Não há atalho vinculado a ela por padrão.

`omarchy toggle screensaver` é o que desliga a de ociosidade, se você preferir ir direto do trabalho ao bloqueio. Ele precisa de um terminal que saiba configurar — Alacritty, Foot, Ghostty ou Kitty — e lhe dirá isso se seu terminal padrão for outro.

O logotipo que ela desenha é seu para mudar, em _Estilo > Proteção de tela_. Envie um png ou svg e o Omarchy o converte para ASCII. Veja [branding](41-branding.md).

### A tela de bloqueio

`Super + Ctrl + L` bloqueia a máquina. Isso executa a tela de bloqueio do shell do Omarchy, apaga a tela, redefine seu layout de teclado para o primeiro, para você não digitar sua senha no alfabeto errado, e — se você o tiver rodando — bloqueia o 1Password ao sair.

A tela de bloqueio aceita uma senha, e também aceitará uma impressão digital depois que você configurar uma. Isso, e as outras formas de se autenticar, são tratados em [autenticação de hardware](37-hardware-authentication.md).
