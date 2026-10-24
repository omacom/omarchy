# A barra superior

A faixa ao longo do topo do ecrã é a barra do Omarchy. Não é uma barra de estado aparafusada, mas sim parte da shell do Omarchy, o único processo Quickshell de longa duração que também desenha o menu, as notificações, os pop-ups OSD e o ecrã de bloqueio. É por isso que combina na perfeição com tudo o resto e que um painel abre instantaneamente em vez de lançar uma nova aplicação.

É também a única parte do ambiente de trabalho que está sempre no ecrã, por isso vale a pena saber o que todos aqueles pequenos glifos fazem.

## O que ela tem por predefinição

A barra tem três secções. À esquerda fica o logótipo do Omarchy (o lançador do menu) e os indicadores de espaços de trabalho. No centro tens os indicadores de estado, o relógio, o Elsewhen (um relógio mundial), o tempo e um distintivo de atualização do Omarchy. À direita: a disposição do teclado (quando está configurada mais do que uma), a área de notificação, os agentes, o bluetooth, a rede, o áudio, o ecrã e a energia.

Alguns deles só aparecem quando têm alguma coisa para dizer. A disposição do teclado só aparece se tiveres configurado mais do que uma disposição. O distintivo de atualização só aparece quando há uma atualização do Omarchy à espera. E o ícone dos agentes aparece da primeira vez que o Omarchy encontra utilização de agentes de programação com IA na máquina (vê [IA](17-ai.md)).

## Clicar por aí

Quase todos os widgets fazem alguma coisa com o clique esquerdo, direito e do meio, e vários respondem ao scroll. É esta a parte que as pessoas perdem — os botões direito e do meio são onde se esconde muita da boa coisa.

| Widget | Esquerdo | Direito | Do meio / scroll |
| --- | --- | --- | --- |
| Menu | Menu do Omarchy | Novo terminal | — |
| Espaços de trabalho | Focar esse espaço de trabalho | — | Scroll: espaço de trabalho seguinte/anterior |
| Relógio | Pop-up do calendário | Percorrer o formato do rótulo | Do meio: seletor de fuso horário |
| Tempo | Pop-up da previsão | Tempo completo como notificação | Do meio: atualizar |
| Áudio | Painel de áudio | Silenciar | Do meio: painel · scroll: volume |
| Microfone | Silenciar o microfone | — | Do meio: painel de áudio · scroll: volume de entrada |
| Rede | Painel de rede | — | — |
| Bluetooth | Painel de Bluetooth | Alternar o rádio | — |
| Ecrã | Painel do ecrã | — | Scroll: brilho |
| Energia | Painel de energia | Alternar a percentagem da bateria | — |
| Multimédia | Reproduzir/colocar em pausa | Pop-up da capa | Do meio: seguinte · scroll: anterior/seguinte |
| Agentes | Painel de agentes | Lançar o teu agente | Do meio: subscrição seguinte |
| Área de notificação | Passa o cursor por cima para revelar a gaveta | Clica com o botão direito no chevron para gerir | — |
| Atualização do Omarchy | Executar a atualização | — | — |

Nem tudo nessa tabela está na tua barra à saída da caixa. O widget de multimédia (a tocar agora através de MPRIS, com a faixa e o artista em deslocamento) e o widget do microfone estão ambos integrados, mas desligados por predefinição — adiciona-os se os quiseres, como se descreve abaixo.

## Os painéis

Clicar num ícone da barra abre um painel, que é um pop-up a sério com cursor de deslizamento, listas e navegação pelo teclado, em vez de uma dica. Cada um também tem um atalho, para nunca teres de apontar a um glifo de 16 píxeis:

| Atalho | Painel |
| --- | --- |
| `Super + Ctrl + A` | Áudio |
| `Super + Ctrl + W` | Rede |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ecrã |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Calendário |
| `Super + Ctrl + Alt + E` | Relógio mundial |
| `Super + Ctrl + 1-9` | Alternar o enésimo painel na secção da direita |

Os painéis não são meros indicadores. São onde realmente fazes a coisa:

- **Áudio** tem um cursor de volume principal, um seletor de dispositivos de saída e um misturador por aplicação, para poderes baixar aquele único separador do browser sem tocares em tudo o resto.
- **Rede** procura Wi-Fi, mostra a força do sinal, liga-se e permite-te escolher um fornecedor de DNS.
- **Bluetooth** lista os teus dispositivos com ligar/desligar e níveis de bateria.
- **Energia** mostra estatísticas da bateria, muda perfis de energia (memoriza uma escolha separada para bateria e para corrente alternada) e apresenta algumas informações do sistema.
- **Ecrã** traz um cursor de brilho, o tamanho do texto, predefinições de escala dos monitores e — quando tens mais do que um ecrã — controlos por monitor. Vê [monitores](33-monitors.md) para a história mais profunda.
- **Relógio** abre uma grelha do mês com números de semana ISO e navegação por meses.

Todos os painéis aceitam o teclado tanto quanto o rato: as setas movem, Return ativa, Tab passa para o painel vizinho e Escape fecha.

`Super + Ctrl + 1-9` conta os painéis da esquerda para a direita na secção da direita, saltando a área de notificação, uma vez que ela não tem um painel próprio. Por isso o número corresponde ao ícone para o qual apontarias.

### Tailscale e Dropbox

Aparecem mais dois widgets na barra apenas depois de instalares o serviço correspondente a partir de **Instalar → Serviço**, e vale a pena conhecer os dois porque fazem mais do que reportar o estado.

O painel **Tailscale** liga e desliga a tailnet, muda entre contas e escolhe um nó de saída (tanto as tuas próprias máquinas como as regiões Mullvad aparecem nessa lista). Também navega pelas tuas máquinas — e com uma selecionada, `s` envia-lhe ficheiros através do Taildrop, que é a forma mais rápida de mover um ficheiro para o telemóvel ou outro portátil. `c` copia o IP da máquina, `n` o seu nome e `d` o seu nome DNS completo. Também há um botão de envio em cada linha de máquina, se preferires clicar. A mesma coisa a partir do terminal é `omarchy tailscale send <máquina> [ficheiro...]`.

O painel **Dropbox** trata do início de sessão, mostra quanto espaço de armazenamento já usaste e lista os ficheiros sincronizados recentemente.

Remover qualquer um dos serviços retira o seu widget da barra.

## Indicadores

O pequeno grupo ao centro é o widget de indicadores. São glifos de estado para modos que ligaste: não incomodar, luz noturna, um [lembrete](09-reminders.md) em espera, uma gravação de ecrã ativa, manter ativo e [ditado](11-text-extraction-dictation.md). Acendem quando o modo está ativo e, de resto, mantêm-se fora do caminho — passa o cursor à esquerda do relógio (acima dele numa barra vertical) para espreitares os inativos. Clicar num indicador alterna esse modo. Há mais um só de estado: uma sessão remota acende a vermelho enquanto alguém estiver ligado a esta máquina através do gliff.

Se preferires que estivessem sempre visíveis, define `alwaysShow` como `true` no widget. E se só te importares com alguns deles, lista os que queres em `items`: `["Dnd", "Reminder", "NightLight"]`. Podes ter mais do que um widget de indicadores, para que secções diferentes mostrem subconjuntos diferentes.

## Reorganizar a barra

A barra configura-se a si própria. Não tens de abrir um ficheiro de configuração para mover coisas.

Agarra um pedaço vazio da barra à volta do centro e arrasta-o em direção a outro bordo do ecrã, e a barra move-se para lá — esquerda, direita, topo ou fundo, tudo funciona, e todos os widgets se adaptam (as barras verticais caem para formas compactas só de ícone). Clicar e segurar inicia o mesmo arrasto. Faz duplo clique com o botão esquerdo nesse mesmo espaço vazio para percorreres o fundo da barra de sem fundo para vidro e depois para opaco. E arrasta qualquer widget para o reordenares ou atirares para outra secção.

Um widget que queiras ter por perto mas nem sempre à vista pode ir para a gaveta da área de notificação: arrasta-o para cima da área de notificação e a gaveta abre-se para o receber. Fica lá depois dos ícones das aplicações, aparece sempre que a gaveta aparece e mantém-na aberta enquanto o seu painel estiver aberto. Arrasta-o de volta para a barra para o repores.

Se preferires escolher a partir de um menu, **Acionar → Aspeto → Barra de menus** tem a posição, e **Fundo da barra** escolhe como a barra é desenhada: **Barra opaca**, **Barra vidro** (transparente, com o que estiver atrás desfocado) ou **Barra sem fundo**.

As mesmas coisas têm comandos, que é o que queres para uma configuração de [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para adicionares ou removeres um widget por completo, usa os comandos de plugin. `omarchy plugin list` apresenta todos os widgets que a shell conhece, com o seu ID, e depois:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Ocultar a barra

`Super + Shift + Space` desliga a barra e volta a ligá-la sem matar a shell — os painéis e os atalhos continuam a funcionar, apenas recuperas os píxeis. Também está no menu em **Acionar → Aspeto → Barra de menus → Ocultar barra**.

## O ficheiro de configuração

Tudo fica guardado em `~/.config/omarchy/shell.json`, na chave `bar`. Aqui está uma versão resumida:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Cada widget é uma entrada num dos três arrays da disposição, e as suas definições ficam em linha nessa entrada — não há um ficheiro de definições separado nem um sub-objeto `config`. O `format` do relógio, o `formatAlt` (aquilo para onde o clique direito o faz percorrer) e o `verticalFormat` vivem mesmo ali no `{ "id": "omarchy.clock" }`.

O `centerAnchor` nomeia o único widget central que fica fixo mesmo no centro do ecrã, com os outros a flanqueá-lo. É assim que o relógio fica mesmo ao centro, mesmo quando o tempo e o distintivo de atualização vêm e vão. Define-o como uma cadeia vazia e a lista central fica apenas centrada como um grupo.

Há uma regra que vale a pena interiorizar: **a partir do momento em que tens o teu próprio `shell.json`, ele é canónico**. Até personalizares algo, a shell lê o ficheiro predefinido do Omarchy. No momento em que arrastas um widget, executas `omarchy bar` ou editas tu próprio o ficheiro, ele passa a ser teu — não há fusão profunda, por isso os novos widgets predefinidos em futuras versões do Omarchy não vão aparecer automaticamente na tua barra. `omarchy bar defaults` repõe a disposição fornecida sempre que quiseres começar do zero.

O mesmo ficheiro também guarda os teus tempos de inatividade ao nível superior, fora da chave `bar`: `idle.screensaver` e `idle.lock`, ambos em segundos desde que ficaste inativo. Por isso a proteção de ecrã predefinida entra aos 150 segundos e o bloqueio aos 300.
