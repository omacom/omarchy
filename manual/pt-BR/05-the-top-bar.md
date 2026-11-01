# A Barra Superior

A faixa ao longo do topo da sua tela é a barra do Omarchy. Não é uma barra de status anexada depois, mas parte do shell do Omarchy, o único processo Quickshell de longa duração que também desenha o menu, as notificações, os popups OSD e a tela de bloqueio. É por isso que ela combina perfeitamente com todo o resto e por que um painel abre instantaneamente em vez de iniciar um novo aplicativo.

Ela também é a única parte do desktop que está sempre na tela, então vale a pena saber o que todos aqueles pequenos glifos fazem.

## O que vem nela por padrão

A barra tem três seções. À esquerda ficam o logotipo do Omarchy (o lançador do menu) e os indicadores de workspaces. No centro você tem os indicadores de status, o relógio, o Elsewhen (um relógio mundial), o clima e um distintivo de atualização do Omarchy. À direita: a bandeja do sistema, o layout do teclado (quando mais de um está configurado), agentes, bluetooth, rede, áudio, display e energia.

Alguns deles só aparecem quando têm algo a dizer. O layout do teclado aparece somente se você configurou mais de um layout. O distintivo de atualização aparece somente quando há uma atualização do Omarchy esperando. E o ícone de agentes aparece na primeira vez que o Omarchy encontra uso de codificação com AI na máquina (veja [IA](17-ai.md)).

## Clicando por aí

Quase todos os widgets fazem algo com o clique esquerdo, direito e do meio, e vários respondem à rolagem. Essa é a parte que as pessoas deixam passar — os botões direito e do meio são onde muita coisa boa se esconde.

| Widget | Esquerdo | Direito | Meio / rolagem |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Novo terminal | — |
| Workspaces | Focaliza aquele workspace neste monitor | — | Rolagem: workspace seguinte/anterior |
| Relógio | Popup de calendário | Alterna o formato do rótulo | Meio: seletor de fuso horário |
| Clima | Popup de previsão | Clima completo como notificação | Meio: atualizar |
| Áudio | Painel de áudio | Silenciar | Meio: painel · rolagem: volume |
| Microfone | Silencia o microfone | — | Meio: painel de áudio · rolagem: volume de entrada |
| Rede | Painel de rede | — | — |
| Bluetooth | Painel Bluetooth | Alterna o rádio | — |
| Display | Painel de display | — | Rolagem: brilho |
| Energia | Painel de energia | Alterna a porcentagem da bateria | — |
| Mídia | Reproduzir/pausar | Popup da arte da capa | Meio: seguinte · rolagem: anterior/seguinte |
| Agentes | Painel Agentes | Inicia seu agente | Meio: próxima assinatura |
| Bandeja | Passe o cursor para revelar a gaveta | Clique com o botão direito no chevron para gerenciar | — |
| Atualização do Omarchy | Executa a atualização | — | — |

Nem tudo nessa tabela está na sua barra de fábrica. O widget de mídia (MPRIS tocando agora, com faixa e artista rolando) e o widget de microfone são ambos integrados, mas desligados por padrão — adicione-os se quiser, como descrito abaixo.

## Os painéis

Clicar em um ícone da barra abre um painel, que é um popup de verdade com controles deslizantes, listas e navegação por teclado em vez de uma dica de ferramenta. Cada um também tem uma tecla de atalho, então você nunca precisa mirar em um glifo de 16 pixels:

| Atalho | Painel |
| --- | --- |
| `Super + Ctrl + A` | Áudio |
| `Super + Ctrl + N` | Rede |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Calendário |
| `Super + Ctrl + Alt + E` | Relógio mundial |
| `Super + Ctrl + 1-9` | Alterna o enésimo painel na seção direita |

Os painéis não são só leituras. É neles que você realmente faz a coisa:

- **Audio** tem um controle deslizante de volume principal, um seletor de dispositivo de saída e um mixer por aplicativo, para você baixar aquela única aba do navegador sem mexer em todo o resto.
- **Network** procura Wi-Fi, mostra a intensidade do sinal, conecta e permite escolher um provedor de DNS.
- **Bluetooth** lista seus dispositivos com conectar/desconectar e níveis de bateria.
- **Power** mostra estatísticas da bateria, troca perfis de energia (ele lembra uma escolha separada para bateria e AC) e exibe algumas informações do sistema.
- **Display** traz um controle deslizante de brilho, tamanho do texto, predefinições de escala do monitor e — quando você tem mais de uma tela — controles por monitor. Veja [monitores](33-monitors.md) para a história mais aprofundada.
- **Clock** abre uma grade mensal com números de semana ISO e navegação entre meses.
- **World clock** mantém uma linha por cidade, com seu clima e como está seu dia. A busca encontra cidades além de fusos horários, então Fort Lauderdale é Fort Lauderdale e não New York. Se a linha no topo nomeia a cidade errada, clique nela e diga onde você está; escolha algum lugar em outro fuso horário e o relógio do sistema também se move para lá, o que é prático quando você viaja. Passe o cursor sobre uma cidade e clique no botão de pessoa para dizer quem mora lá — nomes simples, ou identificadores do GitHub com `@` para trazer suas fotos junto.

Todo painel aceita o teclado além do mouse: as setas movem, Return ativa, Tab passa para o painel vizinho e Escape fecha.

`Super + Ctrl + 1-9` conta os painéis da esquerda para a direita na seção direita, pulando a bandeja, já que ela não tem painel próprio. Então o número corresponde ao ícone que você apontaria.

### Tailscale e Dropbox

Mais dois widgets aparecem na barra somente depois que você instala o serviço correspondente em **Install → Service**, e vale a pena conhecer os dois porque eles fazem mais do que relatar status.

O painel **Tailscale** conecta e desconecta a tailnet, alterna entre contas e escolhe um nó de saída (suas próprias máquinas e regiões Mullvad aparecem nessa lista). Ele também navega pelas suas máquinas — e, com uma selecionada, `s` envia arquivos para ela pelo Taildrop, que é a forma mais rápida de mover um arquivo para seu telefone ou outro laptop. `c` copia o IP da máquina, `n` seu nome e `d` seu nome DNS completo. Há também um botão de envio em cada linha de máquina, se você preferir clicar. A mesma coisa pelo terminal é `omarchy tailscale send <machine> [file...]`.

O painel **Dropbox** cuida do login, mostra quanto armazenamento você usou e lista arquivos sincronizados recentemente.

Remover qualquer um dos serviços tira seu widget da barra novamente.

## Indicadores

O pequeno grupo no centro é o widget de indicadores. São glifos de status para modos que você ativou: não perturbe, luz noturna, um [lembrete](09-reminders.md) na fila, uma gravação de tela ativa, manter acordado e [ditado](11-text-extraction-dictation.md). Eles acendem quando o modo está ativo e, caso contrário, ficam fora do caminho — passe o cursor em qualquer parte da barra para espiar os inativos. Clicar em um indicador alterna aquele modo. Mais um é somente status: uma sessão remota acende em vermelho enquanto alguém está conectado a esta máquina pelo gliff.

Se preferir que eles estejam sempre visíveis, defina `alwaysShow` como `true` no widget. E se você só se importa com alguns deles, liste os que quer em `items`: `["Dnd", "Reminder", "NightLight"]`. Você pode ter mais de um widget de indicadores, para seções diferentes mostrarem subconjuntos diferentes.

## Reorganizando a barra

A barra se configura sozinha. Você não precisa abrir um arquivo de configuração para mover as coisas.

Agarre um pedaço vazio da barra ao redor do centro e arraste-o em direção a outra borda da tela, e a barra se move para lá — esquerda, direita, topo ou base funcionam, e todos os widgets se adaptam (barras verticais recuam para formas compactas só com ícones). Um clique-e-segure inicia o mesmo arrastar. Clique duas vezes com o botão esquerdo nesse mesmo espaço vazio para alternar o fundo da barra de transparente para vítreo para opaco. E arraste qualquer widget para reordená-lo ou jogá-lo em outra seção; os outros widgets se afastam para abrir espaço onde ele vai pousar.

O meio da barra é uma caixa: o que estiver nela permanece centrado como um grupo, e os widgets de cada lado dela pendem de suas bordas. Enquanto você arrasta um widget, a caixa aparece como um contorno, ou uma linha atravessando a barra quando está vazia, e você pode soltá-lo dentro dela ou ao lado dela. Quando uma soltura pousaria na caixa, a caixa cresce para acolher o widget.

Um widget que você quer por perto, mas nem sempre visível, pode ir para a gaveta da bandeja: arraste-o sobre a bandeja, e a gaveta se abre para recebê-lo. Ele fica ali depois dos ícones dos aplicativos, aparece sempre que a gaveta aparece e mantém sua gaveta aberta enquanto seu painel está aberto. Arraste-o de volta para a barra para colocá-lo de volta.

Se preferir escolher em um menu, **Appearance → Menu Bar** tem a posição, e **Bar Background** escolhe como a barra é desenhada: **Opaque Bar**, **Glassy Bar** (transparente, com o que está atrás dela desfocado) ou **Clear Bar**.

As mesmas coisas têm comandos, que é o que você quer para uma configuração de [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para adicionar ou remover um widget por completo, use os comandos de plugin. `omarchy plugin list` imprime todos os widgets que o shell conhece com seu id, e então:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Escondendo a barra

`Super + Shift + Space` alterna a barra desligando e ligando sem matar o shell — painéis e atalhos continuam funcionando, você só ganha os pixels de volta. Também está no menu em **Appearance → Menu Bar → Hide Bar**.

## O arquivo de configuração

Tudo isso é armazenado em `~/.config/omarchy/shell.json`, sob a chave `bar`. Aqui está uma versão reduzida:

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

Todo widget é uma entrada em um dos cinco arrays de layout, e suas configurações ficam inline nessa entrada — não há arquivo de configurações separado nem subobjeto `config`. O `format`, o `formatAlt` (para o qual o clique com o botão direito alterna) e o `verticalFormat` do relógio vivem todos ali mesmo em `{ "id": "omarchy.clock" }`.

`center` é a caixa no meio da barra: tudo nela é centrado na tela como um grupo. `centerBegin` e `centerEnd` pendem de cada lado da caixa, que é como o relógio fica bem no centro mesmo enquanto o clima e o distintivo de atualização vêm e vão. Coloque mais de um widget em `center` e eles são centrados juntos; deixe-a vazia e `centerBegin` e `centerEnd` se encontram no meio da barra.

Uma regra que vale a pena internalizar: **depois que você tem seu próprio `shell.json`, ele é canônico**. Até você personalizar qualquer coisa, o shell lê o arquivo padrão do Omarchy. No momento em que você arrasta um widget, executa `omarchy bar` ou edita o arquivo por conta própria, ele é seu — não há merge profundo, então novos widgets padrão em versões futuras do Omarchy não aparecerão automaticamente na sua barra. `omarchy bar defaults` restaura o layout original sempre que você quiser uma lousa limpa.

O mesmo arquivo também guarda seus tempos de ociosidade no nível superior, fora da chave `bar`: `idle.screensaver` e `idle.lock`, ambos em segundos desde que você ficou ocioso. Então a proteção de tela padrão entra aos 150 segundos e o bloqueio aos 300.
