# A Barra Superior

A faixa ao longo do topo do seu ecrã é a barra do Omarchy. Não é uma barra de estado aparafusada à pressa, mas parte da shell do Omarchy, o único processo Quickshell de longa duração que também desenha o menu, as notificações, os popups OSD e o ecrã de bloqueio. É por isso que combina na perfeição com tudo o resto e que um painel abre instantaneamente em vez de lançar uma nova aplicação.

É também a única parte do ambiente de trabalho que está sempre no ecrã, por isso vale a pena saber o que fazem todos aqueles pequenos glifos.

## O que traz por predefinição

A barra tem três secções. À esquerda fica o logótipo do Omarchy (o lançador do menu) e os indicadores de áreas de trabalho. Ao centro tem os indicadores de estado, o relógio, o Elsewhen (um relógio mundial), o tempo e um distintivo de atualização do Omarchy. À direita: a bandeja do sistema, a disposição do teclado (quando está configurada mais do que uma), agentes, bluetooth, rede, áudio, ecrã e energia.

Alguns deles só aparecem quando têm alguma coisa para dizer. A disposição do teclado aparece apenas se tiver configurado mais do que uma disposição. O distintivo de atualização aparece apenas quando há uma atualização do Omarchy à espera. E o ícone dos agentes aparece na primeira vez que o Omarchy encontra utilização de codificação com IA na máquina (ver [IA](17-ai.md)).

## Clicar por todo o lado

Quase todos os widgets fazem alguma coisa com o clique esquerdo, direito e do meio, e vários respondem à roda do rato. Esta é a parte que escapa às pessoas — é nos botões direito e do meio que se esconde muita da parte boa.

| Widget | Esquerdo | Direito | Meio / roda |
| --- | --- | --- | --- |
| Menu | Menu do Omarchy | Novo terminal | — |
| Áreas de trabalho | Focar essa área de trabalho neste monitor | — | Roda: área de trabalho seguinte/anterior |
| Relógio | Popup de calendário | Ciclar o formato da etiqueta | Meio: seletor de fuso horário |
| Tempo | Popup da previsão | Tempo completo como notificação | Meio: atualizar |
| Áudio | Painel de áudio | Silenciar | Meio: painel · roda: volume |
| Microfone | Silenciar o microfone | — | Meio: painel de áudio · roda: volume de entrada |
| Rede | Painel de rede | — | — |
| Bluetooth | Painel Bluetooth | Ligar/desligar o rádio | — |
| Ecrã | Painel de ecrã | — | Roda: brilho |
| Energia | Painel de energia | Alternar a percentagem da bateria | — |
| Multimédia | Reproduzir/pausa | Popup da capa | Meio: seguinte · roda: anterior/seguinte |
| Agentes | Painel de agentes | Lançar o seu agente | Meio: subscrição seguinte |
| Bandeja | Passar o rato para revelar a gaveta | Clique direito na seta para gerir | — |
| Atualização do Omarchy | Executar a atualização | — | — |

Nem tudo o que está nessa tabela está na sua barra de origem. O widget de multimédia (MPRIS a reproduzir agora, com faixa e artista a deslocarem-se) e o widget do microfone estão ambos integrados mas desligados por predefinição — adicione-os se os quiser, como descrito abaixo.

## Os painéis

Clicar num ícone da barra abre um painel, que é um popup a sério com controlos deslizantes, listas e navegação por teclado, e não uma simples dica. Cada um tem também uma tecla de atalho, por isso nunca tem de apontar a um glifo de 16 píxeis:

| Tecla de atalho | Painel |
| --- | --- |
| `Super + Ctrl + A` | Áudio |
| `Super + Ctrl + N` | Rede |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ecrã |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Calendário |
| `Super + Ctrl + Alt + E` | Relógio mundial |
| `Super + Ctrl + 1-9` | Alternar o enésimo painel na secção direita |

Os painéis não são meros mostradores. É neles que faz realmente a coisa:

- **Áudio** tem um controlo deslizante do volume principal, um seletor de dispositivo de saída e um misturador por aplicação, para poder baixar só aquele separador do navegador sem tocar em tudo o resto.
- **Rede** procura Wi-Fi, mostra a intensidade do sinal, liga e permite-lhe escolher um fornecedor de DNS.
- **Bluetooth** lista os seus dispositivos com ligar/desligar e níveis de bateria.
- **Energia** mostra estatísticas da bateria, muda perfis de energia (lembra-se de uma escolha separada para bateria e AC) e apresenta algumas informações do sistema.
- **Ecrã** traz um controlo deslizante de brilho, tamanho do texto, predefinições de escala do monitor e — quando tem mais do que um ecrã — controlos por monitor. Consulte [monitores](33-monitors.md) para saber mais a fundo.
- **Relógio** abre uma grelha mensal com números de semana ISO e navegação entre meses.
- **Relógio mundial** mantém uma linha por cidade, com o seu tempo e como vai o seu dia. A pesquisa encontra localidades além de fusos horários, por isso Fort Lauderdale é Fort Lauderdale e não Nova Iorque. Se a linha no topo indicar a cidade errada, clique nela e diga onde está; escolha um local noutro fuso horário e o relógio do sistema também se move para lá, o que dá jeito quando viaja. Passe o rato sobre uma cidade e clique no botão da pessoa para dizer quem vive lá — nomes simples, ou identificadores `@` do GitHub para trazer também as caras deles.

Todos os painéis aceitam o teclado além do rato: as setas movem, Return ativa, Tab passa para o painel vizinho e Escape fecha.

`Super + Ctrl + 1-9` conta os painéis da esquerda para a direita na secção direita, saltando a bandeja, uma vez que esta não tem painel próprio. Assim, o número corresponde ao ícone para o qual apontaria.

### Tailscale e Dropbox

Mais dois widgets aparecem na barra apenas depois de instalar o serviço correspondente em **Instalar → Serviço**, e vale a pena conhecer os dois porque fazem mais do que indicar o estado.

O painel **Tailscale** liga e desliga a tailnet, alterna entre contas e escolhe um nó de saída (as suas próprias máquinas e as regiões Mullvad aparecem ambas nessa lista). Também navega pelas suas máquinas — e, com uma selecionada, `s` envia-lhe ficheiros através do Taildrop, que é a forma mais rápida de mover um ficheiro para o seu telemóvel ou para outro portátil. `c` copia o IP da máquina, `n` o seu nome e `d` o seu nome DNS completo. Há também um botão de enviar em cada linha de máquina, se preferir clicar. A mesma coisa a partir do terminal é `omarchy tailscale send <machine> [file...]`.

O painel **Dropbox** trata do início de sessão, mostra quanto armazenamento já utilizou e lista os ficheiros sincronizados recentemente.

Remover qualquer um dos serviços retira outra vez o seu widget da barra.

## Indicadores

O pequeno grupo ao centro é o widget de indicadores. São glifos de estado para modos que ativou: não incomodar, luz noturna, um [lembrete](09-reminders.md) na fila, uma gravação de ecrã ativa, manter acordado e [ditado](11-text-extraction-dictation.md). Acendem-se quando o modo está ativo e, caso contrário, ficam fora do caminho — passe o rato mesmo ao lado deles, onde ficariam os inativos, para espreitar esses. Clicar num indicador alterna esse modo. Há mais um que é só de estado: uma sessão remota acende-se a vermelho enquanto alguém estiver ligado a esta máquina através do gliff.

Se preferir que estejam sempre visíveis, defina `alwaysShow` como `true` no widget. E se só lhe interessarem alguns deles, liste os que quer em `items`: `["Dnd", "Reminder", "NightLight"]`. Pode ter mais do que um widget de indicadores, para que secções diferentes possam mostrar subconjuntos diferentes.

## Reorganizar a barra

A barra configura-se a si própria. Não tem de abrir um ficheiro de configuração para mover coisas.

Agarre numa zona vazia da barra à volta do centro e arraste-a em direção a outra extremidade do ecrã, e a barra move-se para lá — esquerda, direita, topo ou fundo, tudo funciona, e cada widget adapta-se (as barras verticais recorrem a formas compactas só com ícones). Clicar e manter premido inicia o mesmo arrastar. Faça duplo clique com o botão esquerdo nesse mesmo espaço vazio para ciclar o fundo da barra de transparente para vítreo e para opaco. E arraste qualquer widget para o reordenar ou para o atirar para outra secção; os outros widgets afastam-se para abrir espaço onde ele vai ficar.

O meio da barra é uma caixa: o que estiver nela fica centrado como um só grupo, e os widgets de cada lado dela ficam pendurados nas suas extremidades. Enquanto arrasta um widget, a caixa aparece como um contorno, ou como uma linha ao longo da barra quando está vazia, e pode largar dentro dela ou ao lado dela. Quando uma largada ficaria dentro da caixa, a caixa cresce para acolher o widget.

Um widget que quer por perto, mas nem sempre à vista, pode ir para a gaveta da bandeja: arraste-o para cima da bandeja e a gaveta abre-se para o receber. Fica lá depois dos ícones das aplicações, aparece sempre que a gaveta aparecer e mantém a sua gaveta aberta enquanto o seu painel estiver aberto. Arraste-o de volta para a barra para o repor.

Se preferir escolher a partir de um menu, **Aparência → Barra de Menu** tem a posição, e **Fundo da Barra** escolhe como a barra é desenhada: **Barra Opaca**, **Barra Vítrea** (transparente, com o que está atrás desfocado) ou **Barra Transparente**.

As mesmas coisas têm comandos, que é o que quer para uma configuração de [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para adicionar ou remover um widget por completo, utilize os comandos de plugins. `omarchy plugin list` imprime todos os widgets que a shell conhece, com o respetivo id, e depois:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Esconder a barra

`Super + Shift + Space` desliga e volta a ligar a barra sem matar a shell — os painéis e as teclas de atalho continuam a funcionar, só recupera os píxeis. Também está no menu em **Aparência → Barra de Menu → Esconder Barra**.

## O ficheiro de configuração

Tudo isto está guardado em `~/.config/omarchy/shell.json`, na chave `bar`. Aqui está uma versão reduzida:

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

Cada widget é uma entrada num dos cinco arrays de disposição, e as suas definições ficam em linha nessa entrada — não há um ficheiro de definições separado nem um subobjeto `config`. O `format`, o `formatAlt` (aquilo para que o clique direito cicla) e o `verticalFormat` do relógio vivem todos mesmo ali em `{ "id": "omarchy.clock" }`.

`center` é a caixa no meio da barra: tudo o que estiver nela fica centrado no ecrã como um só grupo. `centerBegin` e `centerEnd` ficam pendurados de cada lado da caixa, e é assim que o relógio se mantém mesmo ao centro, mesmo quando o tempo e o distintivo de atualização vão e vêm. Coloque mais do que um widget em `center` e eles ficam centrados juntos; deixe-o vazio e `centerBegin` e `centerEnd` encontram-se no meio da barra.

Uma regra que vale a pena interiorizar: **a partir do momento em que tem o seu próprio `shell.json`, ele é canónico**. Até personalizar alguma coisa, a shell lê o ficheiro predefinido do Omarchy. No momento em que arrasta um widget, executa `omarchy bar` ou edita o ficheiro por si próprio, ele passa a ser seu — não há fusão profunda, por isso os novos widgets predefinidos em futuras versões do Omarchy não aparecerão na sua barra automaticamente. `omarchy bar defaults` repõe a disposição distribuída sempre que quiser começar do zero.

O mesmo ficheiro guarda também os seus tempos de inatividade ao nível superior, fora da chave `bar`: `idle.screensaver` e `idle.lock`, ambos em segundos desde que ficou inativo. Por isso, a proteção de ecrã predefinida entra aos 150 segundos e o bloqueio aos 300.
