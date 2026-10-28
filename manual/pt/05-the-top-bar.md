# A Barra Superior

A faixa ao longo do topo do seu ecrã é a barra do Omarchy. Não é uma barra de estado encaixada à pressa, mas parte da shell do Omarchy, o único processo Quickshell de longa duração que também desenha o menu, as notificações, os popups OSD e o ecrã de bloqueio. É por isso que combina na perfeição com tudo o resto e que um painel abre instantaneamente em vez de lançar uma nova aplicação.

É também o único elemento do ambiente de trabalho que está sempre no ecrã, por isso vale a pena saber o que fazem todos aqueles pequenos glifos.

## O que traz por predefinição

A barra tem três secções. À esquerda fica o logótipo do Omarchy (o lançador do menu) e os indicadores de espaços de trabalho. Ao centro tem os indicadores de estado, o relógio, Elsewhen (um relógio mundial), o tempo e um distintivo de atualização do Omarchy. À direita: a bandeja do sistema, a disposição do teclado (quando está configurada mais do que uma), agentes, bluetooth, rede, áudio, ecrã e energia.

Alguns deles só aparecem quando têm algo para dizer. A disposição do teclado só aparece se tiver configurado mais do que uma disposição. O distintivo de atualização só aparece quando há uma atualização do Omarchy à espera. E o ícone dos agentes aparece da primeira vez que o Omarchy encontra utilização de programação com IA na máquina (consulte [IA](17-ai.md)).

## Clicar por aí

Quase todos os widgets fazem alguma coisa com o botão esquerdo, o botão direito e o botão do meio, e vários respondem à roda do rato. É esta a parte que escapa a muita gente — os botões direito e do meio são onde se esconde grande parte do melhor.

| Widget | Esquerda | Direita | Meio / roda |
| --- | --- | --- | --- |
| Menu | Menu do Omarchy | Novo terminal | — |
| Espaços de trabalho | Focar esse espaço de trabalho neste monitor | — | Roda: espaço de trabalho seguinte/anterior |
| Relógio | Popup de calendário | Alternar o formato do rótulo | Meio: seletor de fuso horário |
| Tempo | Popup de previsão | Tempo completo como notificação | Meio: atualizar |
| Áudio | Painel de áudio | Silenciar | Meio: painel · roda: volume |
| Microfone | Silenciar o microfone | — | Meio: painel de áudio · roda: volume de entrada |
| Rede | Painel de rede | — | — |
| Bluetooth | Painel Bluetooth | Ligar/desligar o rádio | — |
| Ecrã | Painel de ecrã | — | Roda: brilho |
| Energia | Painel de energia | Alternar a percentagem da bateria | — |
| Multimédia | Reproduzir/pausar | Popup da capa | Meio: seguinte · roda: anterior/seguinte |
| Agentes | Painel de agentes | Lançar o seu agente | Meio: subscrição seguinte |
| Bandeja | Passar o cursor para revelar a gaveta | Botão direito na seta para gerir | — |
| Atualização do Omarchy | Executar a atualização | — | — |

Nem tudo o que está nessa tabela está na sua barra de origem. O widget de multimédia (MPRIS a reproduzir agora, com faixa e artista a deslizar) e o widget de microfone estão ambos integrados, mas desativados por predefinição — adicione-os se os quiser, como descrito abaixo.

## Os painéis

Ao clicar num ícone da barra abre um painel, que é um popup a sério com controlos deslizantes, listas e navegação por teclado em vez de uma dica. Cada um também tem uma tecla de atalho, por isso nunca tem de apontar para um glifo de 16 píxeis:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | Toggle the nth panel in the right section |

Os painéis não são apenas leituras. É neles que faz realmente a coisa:

- **Audio** has a master volume slider, an output-device picker, and a per-app mixer, so you can turn down that one browser tab without touching everything else.
- **Network** scans for Wi-Fi, shows signal strength, connects, and lets you pick a DNS provider.
- **Bluetooth** lists your devices with connect/disconnect and battery levels.
- **Power** shows battery stats, switches power profiles (it remembers a separate choice for battery and AC), and prints some system info.
- **Display** carries a brightness slider, text size, monitor scaling presets, and — when you have more than one screen — per-monitor controls. See [monitors](33-monitors.md) for the deeper story.
- **Clock** opens a month grid with ISO week numbers and month stepping.
- **World clock** keeps a row per city, with its weather and how its day is going. Search finds towns as well as time zones, so Fort Lauderdale is Fort Lauderdale and not New York. If the line at the top names the wrong city, click it and say where you are; pick somewhere on another time zone and the system clock moves there too, which is handy when you travel. Hover a city and click the person button to say who lives there — plain names, or `@` GitHub handles to bring their faces along.

Todos os painéis aceitam o teclado bem como o rato: as setas movem, Return ativa, Tab passa para o painel vizinho e Escape fecha.

`Super + Ctrl + 1-9` conta os painéis da esquerda para a direita na secção da direita, a saltar a bandeja, uma vez que esta não tem um painel próprio. Por isso, o número corresponde ao ícone para o qual apontaria.

### Tailscale e Dropbox

Mais dois widgets aparecem na barra só depois de instalar o serviço correspondente em **Install → Service**, e vale a pena conhecer ambos porque fazem mais do que reportar estado.

O painel **Tailscale** liga e desliga a tailnet, alterna entre contas e escolhe um nó de saída (as suas próprias máquinas e as regiões Mullvad aparecem ambas nessa lista). Também navega pelas suas máquinas — e, com uma selecionada, `s` envia-lhe ficheiros através do Taildrop, que é a forma mais rápida de mover um ficheiro para o seu telemóvel ou para outro portátil. `c` copia o IP da máquina, `n` o seu nome e `d` o seu nome DNS completo. Há também um botão de envio em cada linha de máquina, se preferir clicar. O mesmo a partir do terminal é `omarchy tailscale send <machine> [file...]`.

O painel **Dropbox** trata do início de sessão, mostra quanto armazenamento já utilizou e lista ficheiros sincronizados recentemente.

Remover qualquer um dos serviços retira o respetivo widget da barra.

## Indicadores

O pequeno conjunto ao centro é o widget de indicadores. São glifos de estado para modos que ativou: não incomodar, luz noturna, um [lembrete](09-reminders.md) em fila, uma gravação de ecrã ativa, manter acordado e [ditado](11-text-extraction-dictation.md). Acendem quando o modo está ativo e, de resto, mantêm-se fora do caminho — passe o cursor em qualquer parte da barra para espreitar os inativos. Ao clicar num indicador alterna esse modo. Mais um é apenas de estado: uma sessão remota acende a vermelho enquanto alguém estiver ligado a esta máquina através do gliff.

Se preferir que estejam sempre visíveis, defina `alwaysShow` como `true` no widget. E se só se importar com alguns deles, liste os que quer em `items`: `["Dnd", "Reminder", "NightLight"]`. Pode ter mais do que um widget de indicadores, para secções diferentes poderem mostrar subconjuntos diferentes.

## Reorganizar a barra

A barra configura-se a si própria. Não tem de abrir um ficheiro de configuração para mover coisas.

Agarre num pedaço vazio da barra à volta do centro e arraste-o para outra extremidade do ecrã, e a barra muda-se para lá — esquerda, direita, topo ou fundo funcionam todos, e cada widget adapta-se (as barras verticais recorrem a formas compactas só com ícones). Um clique prolongado inicia o mesmo arrasto. Faça duplo clique com o botão esquerdo nesse mesmo espaço vazio para alternar o fundo da barra entre transparente, vidrado e opaco. E arraste qualquer widget para o reordenar ou atirá-lo para outra secção; os outros widgets afastam-se para abrir espaço onde ele vai ficar.

O meio da barra é uma caixa: o que estiver nela mantém-se centrado como um grupo, e os widgets de cada lado pendem das suas extremidades. Enquanto arrasta um widget, a caixa aparece como um contorno, ou uma linha através da barra quando está vazia, e pode largar dentro dela ou ao lado dela. Quando uma largada ficaria na caixa, a caixa cresce para acolher o widget.

Um widget que quer por perto, mas nem sempre visível, pode ir para a gaveta da bandeja: arraste-o para a bandeja, e a gaveta abre-se para o receber. Fica lá depois dos ícones das aplicações, aparece sempre que a gaveta aparece e mantém a gaveta aberta enquanto o seu painel estiver aberto. Arraste-o de volta para a barra para o repor.

Se preferir escolher a partir de um menu, **Appearance → Menu Bar** tem a posição, e **Bar Background** escolhe como a barra é desenhada: **Opaque Bar**, **Glassy Bar** (transparente, com o que está atrás desfocado) ou **Clear Bar**.

As mesmas coisas têm comandos, que é o que quer para uma configuração de [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para adicionar ou remover um widget por completo, use os comandos de plugin. `omarchy plugin list` imprime todos os widgets que a shell conhece com o seu id, e depois:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Esconder a barra

`Super + Shift + Space` alterna a barra entre desligada e ligada sem matar a shell — os painéis e as teclas de atalho continuam a funcionar, apenas recupera os píxeis. Também está no menu em **Appearance → Menu Bar → Hide Bar**.

## O ficheiro de configuração

Tudo fica guardado em `~/.config/omarchy/shell.json`, na chave `bar`. Aqui está uma versão reduzida:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Cada widget é uma entrada num dos cinco arrays de layout, e as suas definições ficam inline nessa entrada — não há um ficheiro de definições separado nem um subobjeto `config`. O `format`, o `formatAlt` (para onde o clique com o botão direito alterna) e o `verticalFormat` do relógio vivem todos ali mesmo em `{ "id": "omarchy.clock" }`.

`center` é a caixa no meio da barra: tudo o que nela estiver fica centrado no ecrã como um grupo. `centerBegin` e `centerEnd` pendem de cada lado da caixa, e é assim que o relógio fica mesmo ao centro mesmo quando o tempo e o distintivo de atualização vêm e vão. Coloque mais do que um widget em `center` e eles ficam centrados juntos; deixe-o vazio e `centerBegin` e `centerEnd` encontram-se no meio da barra.

Uma regra que vale a pena interiorizar: **depois de ter o seu próprio `shell.json`, ele é canónico**. Até personalizar alguma coisa, a shell lê o ficheiro predefinido do Omarchy. No momento em que arrasta um widget, executa `omarchy bar` ou edita o ficheiro, ele passa a ser seu — não há fusão profunda, por isso novos widgets predefinidos em futuras versões do Omarchy não aparecerão automaticamente na sua barra. `omarchy bar defaults` repõe o layout fornecido sempre que quiser começar de novo.

O mesmo ficheiro também guarda os seus tempos de inatividade ao nível superior, fora da chave `bar`: `idle.screensaver` e `idle.lock`, ambos em segundos desde que ficou inativo. Por isso, a proteção de ecrã predefinida entra aos 150 segundos e o bloqueio aos 300.
