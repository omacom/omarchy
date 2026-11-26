# A Barra Superior

A faixa ao longo do topo do seu ecrã é a barra do Omarchy. Não é uma barra de estado aparafusada por cima, mas parte da shell do Omarchy, o único processo Quickshell de longa duração que também desenha o menu, as notificações, os popups OSD e o ecrã de bloqueio. É por isso que o tema combina na perfeição com tudo o resto e que um painel abre instantaneamente em vez de lançar uma nova aplicação.

Também é a única parte do ambiente de trabalho que está sempre no ecrã, por isso vale a pena saber o que fazem todos aqueles pequenos glifos.

## O que traz por omissão

A barra tem três secções. À esquerda fica o logótipo do Omarchy (o lançador do menu) e os indicadores de áreas de trabalho. Ao centro tem os indicadores de estado, o relógio, Elsewhen (um relógio mundial), a meteorologia e um emblema de atualização do Omarchy. À direita: o tabuleiro do sistema, a disposição do teclado (quando está configurada mais do que uma disposição ou método de entrada), agents, bluetooth, rede, áudio, ecrã e energia.

Alguns deles só aparecem quando têm alguma coisa a dizer. A disposição do teclado aparece apenas se tiver configurado mais do que uma disposição ou método de entrada. O emblema de atualização aparece apenas quando há uma atualização do Omarchy à espera.

## Clicar aqui e ali

Quase todos os componentes fazem alguma coisa com o clique esquerdo, direito e do meio, e vários respondem à roda do rato. É esta a parte que escapa a muita gente — é nos botões direito e do meio que se esconde muita da parte boa.

| Componente | Esquerdo | Direito | Meio / roda |
| --- | --- | --- | --- |
| Menu | Menu do Omarchy | Novo terminal | — |
| Áreas de trabalho | Focar essa área de trabalho neste monitor | — | Roda: área de trabalho seguinte/anterior |
| Relógio | Janela emergente do calendário | Percorrer os formatos da etiqueta | Meio: seletor de fuso horário |
| Relógio mundial | Painel do relógio mundial | Atualizar | Meio: atualizar |
| Meteorologia | Janela emergente da previsão | Meteorologia completa como notificação | Meio: atualizar |
| Áudio | Painel de áudio | Silenciar | Meio: painel · roda: volume |
| Microfone | Silenciar o microfone | — | Meio: painel de áudio · roda: volume de entrada |
| Rede | Painel de rede | — | — |
| Bluetooth | Painel Bluetooth | Alternar o rádio | — |
| Ecrã | Painel do ecrã | — | Roda: brilho |
| Energia | Painel de energia | Alternar a percentagem da bateria | — |
| Multimédia | Reproduzir/pausar | Janela emergente da capa do álbum | Meio: seguinte · roda: anterior/seguinte |
| Agents | Painel Agents | Iniciar o seu agent | Meio: atualizar a utilização |
| Tabuleiro | Passar o cursor para revelar a gaveta | Botão direito no chevron para gerir | — |
| Atualização do Omarchy | Executar a atualização | — | — |

Nem tudo o que está nessa tabela está na sua barra de origem. O componente de multimédia (MPRIS a reproduzir agora, com a faixa e o artista a deslocarem-se) e o componente do microfone já vêm incluídos, mas estão desligados por omissão — adicione-os se os quiser, como se descreve abaixo.

## Os painéis

Clicar num ícone da barra abre um painel, que é uma janela emergente a sério, com controlos deslizantes, listas e navegação por teclado, e não uma simples dica. Cada um também tem uma tecla de atalho, para nunca ter de acertar num glifo de 16 píxeis:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | Toggle the nth panel in the right section |

Os painéis não são só mostradores de leitura. É neles que faz realmente a coisa:

- **Áudio** tem um controlo deslizante de volume principal, um seletor de dispositivo de saída e um misturador por aplicação, para poder baixar só aquele separador do browser sem mexer em tudo o resto.
- **Rede** procura redes Wi-Fi, mostra a intensidade do sinal, estabelece ligação e permite-lhe escolher um fornecedor de DNS.
- **Bluetooth** lista os seus dispositivos, com ligar/desligar e níveis de bateria.
- **Energia** mostra as estatísticas da bateria, muda os perfis de energia (guarda uma escolha separada para bateria e para AC) e imprime algumas informações do sistema.
- **Ecrã** traz um controlo deslizante de brilho, o tamanho do texto, predefinições de escala do monitor e — quando tem mais do que um ecrã — controlos por monitor. Consulte [monitores](33-monitors.md) para conhecer a história mais a fundo.
- **Relógio** abre uma grelha mensal com números de semana ISO e navegação por meses.
- **Relógio mundial** mantém uma linha por cidade, com a respetiva meteorologia e como está a correr o dia por lá. A pesquisa encontra localidades além de fusos horários, por isso Fort Lauderdale é Fort Lauderdale e não Nova Iorque. Se a linha no topo indicar a cidade errada, clique nela e diga onde está; escolha um local noutro fuso horário e o relógio do sistema também se muda para lá, o que dá jeito quando está a viajar. Passe o cursor sobre uma cidade e clique no botão da pessoa para dizer quem vive lá — nomes simples, ou identificadores do GitHub com `@` para trazer também as caras deles.

Todos os painéis aceitam o teclado além do rato: as setas movem, Return ativa, Tab passa para o painel vizinho e Escape fecha.

`Super + Ctrl + 1-9` conta os painéis da esquerda para a direita na secção da direita, saltando o tabuleiro, uma vez que este não tem painel próprio. Por isso, o número corresponde ao ícone para o qual apontaria.

### Tailscale e Dropbox

Dois componentes adicionais aparecem na barra apenas quando instala o serviço correspondente em **Instalar → Serviço**, e vale a pena conhecer ambos porque fazem mais do que mostrar o estado.

O painel **Tailscale** liga e desliga a tailnet, muda de conta e escolhe um nó de saída (tanto as suas próprias máquinas como as regiões Mullvad aparecem nessa lista). Também explora as suas máquinas — e, com uma selecionada, `s` envia-lhe ficheiros através do Taildrop, que é a forma mais rápida de passar um ficheiro para o seu telemóvel ou para outro portátil. `c` copia o IP da máquina, `n` o seu nome e `d` o seu nome DNS completo. Também há um botão de envio em cada linha de máquina, se preferir clicar. A mesma coisa a partir do terminal é `omarchy tailscale send <machine> [file...]`.

O painel **Dropbox** trata do início de sessão, mostra quanto armazenamento já utilizou e lista os ficheiros sincronizados recentemente.

Remover qualquer um dos serviços volta a retirar o respetivo componente da barra.

## Indicadores

O pequeno grupo no centro é o componente de indicadores. São glifos de estado para modos que ativou: não incomodar, luz noturna, um [lembrete](09-reminders.md) em fila, uma gravação de ecrã ativa e manter acordado, além de avisos enquanto o sudo sem palavra-passe estiver ligado ou alguém estiver ligado a uma sessão remota. Acendem quando o modo está ativo e, caso contrário, ficam fora do caminho — passe o cursor mesmo ao lado deles, onde estariam os inativos, para espreitar esses. Clicar num indicador alterna esse modo. Há mais um que é só de estado: uma sessão remota acende a vermelho enquanto alguém estiver ligado a esta máquina através do gliff.

Se preferir que estejam sempre visíveis, defina `alwaysShow` como `true` no componente. E se só lhe interessarem alguns deles, liste os que quer em `items`: `["Dnd", "Reminder", "NightLight"]`. Pode ter mais do que um componente de indicadores, por isso secções diferentes podem mostrar subconjuntos diferentes.

## Reorganizar a barra

A barra configura-se a si própria. Não tem de abrir um ficheiro de configuração para mover coisas.

Agarre num pedaço vazio da barra à volta do centro e arraste-o em direção a outra extremidade do ecrã, e a barra muda-se para lá — esquerda, direita, topo ou fundo, tudo funciona, e todos os componentes se adaptam (as barras verticais recorrem a formas compactas, só com ícones). Um clique sem largar inicia o mesmo arrasto. Faça duplo clique com o botão esquerdo nesse mesmo espaço vazio para percorrer o fundo da barra de transparente para vidrado para opaco. E arraste qualquer componente para o reordenar ou para o atirar para outra secção; os outros componentes afastam-se para abrir espaço onde ele vai ficar.

O meio da barra é uma caixa: tudo o que estiver dentro dela fica centrado como um único grupo, e os componentes de cada lado ficam encostados às suas extremidades. Enquanto arrasta um componente, a caixa aparece como um contorno, ou como uma linha a atravessar a barra quando está vazia, e pode largar dentro dela ou ao lado dela. Quando uma largada ficaria dentro da caixa, a caixa cresce para acolher o componente.

Um componente que quer por perto, mas nem sempre à vista, pode ir para a gaveta do tabuleiro: arraste-o para cima do tabuleiro e a gaveta abre-se para o receber. Ele fica lá depois dos ícones das aplicações, aparece sempre que a gaveta aparece e mantém a gaveta aberta enquanto o seu painel estiver aberto. Arraste-o de volta para a barra para o repor no sítio.

Se preferir escolher a partir de um menu, **Aparência → Barra de Menus** tem a posição, e **Fundo da Barra** escolhe como a barra é desenhada: **Barra Opaca**, **Barra Vidrada** (transparente, com o que está por trás desfocado) ou **Barra Transparente**.

As mesmas coisas têm comandos, que é o que quer para uma configuração com [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para adicionar ou remover um componente por completo, utilize os comandos de plugin. `omarchy plugin list` imprime todos os componentes que a shell conhece, com o respetivo id, e depois:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ocultar a barra

`Super + Shift + Space` alterna a barra entre desligada e ligada sem matar a shell — os painéis e as teclas de atalho continuam a funcionar, só recupera os píxeis. Também está no menu em **Aparência → Barra de Menus → Ocultar Barra**.

## O ficheiro de configuração

Tudo isto está guardado em `~/.config/omarchy/shell.json`, na chave `bar`. Eis uma versão resumida:

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

Cada componente é uma entrada num dos cinco arrays de disposição, e as suas definições ficam embutidas nessa entrada — não há um ficheiro de definições separado nem um subobjeto `config`. O `format`, o `formatAlt` (para o qual o clique direito avança) e o `verticalFormat` do relógio vivem todos ali mesmo, em `{ "id": "omarchy.clock" }`.

`center` é a caixa no meio da barra: tudo o que estiver dentro dela fica centrado no ecrã como um único grupo. `centerBegin` e `centerEnd` ficam encostados a cada lado da caixa, e é assim que o relógio se mantém mesmo ao centro, mesmo quando a meteorologia e o emblema de atualização vêm e vão. Coloque mais do que um componente em `center` e eles ficam centrados em conjunto; deixe-o vazio e `centerBegin` e `centerEnd` encontram-se no meio da barra.

Uma regra que vale a pena interiorizar: **a partir do momento em que tem o seu próprio `shell.json`, é ele que manda**. Até personalizar alguma coisa, a shell lê o ficheiro predefinido do Omarchy. No instante em que arrasta um componente, executa `omarchy bar` ou edita o ficheiro por si, ele passa a ser seu — não há fusão profunda, por isso os novos componentes predefinidos em futuras versões do Omarchy não vão aparecer automaticamente na sua barra. `omarchy bar defaults` repõe a disposição de origem sempre que quiser começar de novo.

O mesmo ficheiro também guarda os seus tempos de inatividade ao nível superior, fora da chave `bar`: `idle.screensaver` e `idle.lock`, ambos em segundos desde que ficou inativo. Por isso, a proteção de ecrã predefinida entra aos 150 segundos e o bloqueio aos 300.
