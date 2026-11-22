# A barra superior

A faixa ao longo do topo da sua tela é a barra do Omarchy. Ela não é uma barra de status encaixada por cima, mas parte do shell do Omarchy, o único processo Quickshell de longa duração que também desenha o menu, as notificações, os popups OSD e a tela de bloqueio. É por isso que ela combina perfeitamente com todo o resto e que um painel abre instantaneamente em vez de iniciar um novo aplicativo.

Ela também é a única parte da área de trabalho que está sempre na tela, então vale a pena saber o que todos aqueles glifinhos fazem.

## O que vem nela por padrão

A barra tem três seções. À esquerda fica o logotipo do Omarchy (o lançador do menu) e os indicadores de espaços de trabalho. No centro, você tem os indicadores de status, o relógio, o Elsewhen (um relógio mundial), o clima e um selo de atualização do Omarchy. À direita: a bandeja do sistema, o layout do teclado (quando mais de um layout ou método de entrada está configurado), agentes, bluetooth, rede, áudio, tela e energia.

Alguns deles só aparecem quando têm algo a dizer. O layout do teclado aparece apenas se você configurou mais de um layout ou método de entrada. O selo de atualização aparece apenas quando há uma atualização do Omarchy esperando.

## Clicando por aí

Quase todos os widgets fazem algo ao clicar com o botão esquerdo, direito e do meio, e vários respondem à rolagem. Essa é a parte que as pessoas deixam passar — os botões direito e do meio são onde boa parte das coisas boas se esconde.

| Widget | Esquerdo | Direito | Meio / rolagem |
| --- | --- | --- | --- |
| Menu | Menu do Omarchy | Novo terminal | — |
| Espaços de trabalho | Dar foco àquele espaço de trabalho neste monitor | — | Rolagem: espaço de trabalho seguinte/anterior |
| Relógio | Popup de calendário | Alternar o formato do rótulo | Meio: seletor de fuso horário |
| Relógio mundial | Painel do relógio mundial | Atualizar | Meio: atualizar |
| Clima | Popup de previsão | Clima completo como uma notificação | Meio: atualizar |
| Áudio | Painel de áudio | Silenciar | Meio: painel · rolagem: volume |
| Microfone | Silenciar o microfone | — | Meio: painel de áudio · rolagem: volume de entrada |
| Rede | Painel de rede | — | — |
| Bluetooth | Painel Bluetooth | Ligar/desligar o rádio | — |
| Tela | Painel de tela | — | Rolagem: brilho |
| Energia | Painel de energia | Alternar a porcentagem da bateria | — |
| Mídia | Reproduzir/pausar | Popup da capa | Meio: próxima · rolagem: anterior/próxima |
| Agentes | Painel de agentes | Abrir seu agente | Meio: atualizar o uso |
| Bandeja | Passar o mouse para revelar a gaveta | Clique com o botão direito na seta para gerenciar | — |
| Atualização do Omarchy | Executar a atualização | — | — |

Nem tudo nessa tabela está na sua barra de fábrica. O widget de mídia (MPRIS tocando agora, com faixa e artista em rolagem) e o widget de microfone são ambos integrados, mas vêm desligados por padrão — adicione-os se quiser, como descrito abaixo.

## Os painéis

Clicar em um ícone da barra abre um painel, que é um popup de verdade com controles deslizantes, listas e navegação pelo teclado, e não uma dica flutuante. Cada um também tem um atalho, então você nunca precisa mirar em um glifo de 16 pixels:

| Atalho | Painel |
| --- | --- |
| `Super + Ctrl + A` | Áudio |
| `Super + Ctrl + N` | Rede |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Tela |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Calendário |
| `Super + Ctrl + Alt + E` | Relógio mundial |
| `Super + Ctrl + X` | Agentes |
| `Super + Ctrl + 1-9` | Alternar o enésimo painel na seção da direita |

Os painéis não são só leituras. É neles que você realmente faz a coisa:

- **Áudio** tem um controle deslizante de volume principal, um seletor de dispositivo de saída e um mixer por aplicativo, para você abaixar aquela única aba do navegador sem mexer em todo o resto.
- **Rede** procura Wi-Fi, mostra a força do sinal, conecta e permite escolher um provedor de DNS.
- **Bluetooth** lista seus dispositivos com conectar/desconectar e níveis de bateria.
- **Energia** mostra estatísticas da bateria, troca perfis de energia (ele lembra uma escolha separada para bateria e para AC) e exibe algumas informações do sistema.
- **Tela** traz um controle deslizante de brilho, tamanho do texto, predefinições de escala do monitor e — quando você tem mais de uma tela — controles por monitor. Veja [monitores](33-monitors.md) para a história mais aprofundada.
- **Relógio** abre uma grade mensal com números de semana ISO e navegação entre meses.
- **Relógio mundial** mantém uma linha por cidade, com o clima dela e como está indo o dia por lá. A busca encontra cidades além de fusos horários, então Fort Lauderdale é Fort Lauderdale e não New York. Se a linha no topo indicar a cidade errada, clique nela e diga onde você está; escolha um lugar em outro fuso horário e o relógio do sistema se move para lá também, o que é útil quando você viaja. Passe o mouse sobre uma cidade e clique no botão de pessoa para dizer quem mora lá — nomes simples, ou identificadores do GitHub com `@` para trazer os rostos deles junto.

Todo painel aceita o teclado além do mouse: as setas movem, Return ativa, Tab passa para o painel vizinho e Escape fecha.

`Super + Ctrl + 1-9` conta os painéis da esquerda para a direita na seção da direita, pulando a bandeja, já que ela não tem um painel próprio. Então o número corresponde ao ícone que você apontaria.

### Tailscale e Dropbox

Mais dois widgets aparecem na barra somente depois que você instala o serviço correspondente em **Instalar → Serviço**, e vale a pena conhecer os dois porque eles fazem mais do que relatar status.

O painel do **Tailscale** conecta e desconecta a tailnet, alterna entre contas e escolhe um nó de saída (suas próprias máquinas e as regiões do Mullvad aparecem nessa lista). Ele também navega pelas suas máquinas — e, com uma selecionada, `s` envia arquivos para ela via Taildrop, que é a maneira mais rápida de mover um arquivo para o seu celular ou outro laptop. `c` copia o IP da máquina, `n` o nome dela e `d` o nome DNS completo dela. Também há um botão de enviar em cada linha de máquina, se você preferir clicar. A mesma coisa pelo terminal é `omarchy tailscale send <machine> [file...]`.

O painel do **Dropbox** cuida do login, mostra quanto do armazenamento você já usou e lista os arquivos sincronizados recentemente.

Remover qualquer um dos serviços tira o widget dele de volta da barra.

## Indicadores

O pequeno agrupamento no centro é o widget de indicadores. Eles são glifos de status para modos que você ativou: não perturbe, luz noturna, um [lembrete](09-reminders.md) na fila, uma gravação de tela ativa e manter acordado, além de avisos enquanto o sudo sem senha estiver ativado ou alguém estiver conectado a uma sessão remota. Eles acendem quando o modo está ativo e, no resto do tempo, ficam fora do caminho — passe o mouse logo ao lado deles, onde os inativos ficariam, para dar uma espiada neles. Clicar em um indicador liga/desliga aquele modo. Mais um é só de status: uma sessão remota acende em vermelho enquanto alguém está conectado a esta máquina por meio do gliff.

Se você preferir que eles fiquem sempre visíveis, defina `alwaysShow` como `true` no widget. E se você só se importa com alguns deles, liste os que quer em `items`: `["Dnd", "Reminder", "NightLight"]`. Você pode ter mais de um widget de indicadores, então seções diferentes podem mostrar subconjuntos diferentes.

## Reorganizando a barra

A barra se configura sozinha. Você não precisa abrir um arquivo de configuração para mover as coisas.

Pegue um trecho vazio da barra ao redor do centro e arraste-o em direção a outra borda da tela, e a barra se move para lá — esquerda, direita, topo ou parte inferior, tudo funciona, e cada widget se adapta (barras verticais recorrem a formas compactas, só com ícones). Clicar e segurar inicia o mesmo arrastar. Clique duas vezes com o botão esquerdo nesse mesmo espaço vazio para alternar o fundo da barra de transparente para vítreo e para opaco. E arraste qualquer widget para reordená-lo ou jogá-lo em outra seção; os outros widgets se afastam para abrir espaço onde ele vai pousar.

O meio da barra é uma caixa: o que estiver nela fica centralizado como um único grupo, e os widgets de cada lado dela ficam pendurados nas bordas dela. Enquanto você arrasta um widget, a caixa aparece como um contorno, ou como uma linha ao longo da barra quando está vazia, e você pode soltá-lo dentro dela ou ao lado dela. Quando uma soltura cairia dentro da caixa, a caixa cresce para receber o widget.

Um widget que você quer por perto, mas nem sempre à vista, pode ir para a gaveta da bandeja: arraste-o para a bandeja, e a gaveta se abre para recebê-lo. Ele fica lá depois dos ícones dos aplicativos, aparece sempre que a gaveta aparece e mantém a gaveta dele aberta enquanto o painel dele está aberto. Arraste-o de volta para a barra para colocá-lo de volta.

Se você preferir escolher em um menu, **Aparência → Barra de Menu** tem a posição, e **Fundo da Barra** escolhe como a barra é desenhada: **Barra Opaca**, **Barra Vítrea** (transparente, com o que está atrás dela desfocado) ou **Barra Transparente**.

As mesmas coisas têm comandos, que é o que você quer para uma configuração de [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para adicionar ou remover um widget por completo, use os comandos de plugin. `omarchy plugin list` exibe todos os widgets que o shell conhece, com o id deles, e então:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ocultando a barra

`Super + Shift + Space` liga/desliga a barra sem matar o shell — os painéis e atalhos continuam funcionando, você só recupera os pixels. Ele também está no menu em **Aparência → Barra de Menu → Ocultar Barra**.

## O arquivo de configuração

Tudo isso fica guardado em `~/.config/omarchy/shell.json`, sob a chave `bar`. Aqui está uma versão resumida:

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

Cada widget é uma entrada em um dos cinco arrays de layout, e as configurações dele ficam inline naquela entrada — não há um arquivo de configurações separado e nenhum sub-objeto `config`. O `format`, o `formatAlt` (para onde o clique com o botão direito alterna) e o `verticalFormat` do relógio vivem todos ali mesmo em `{ "id": "omarchy.clock" }`.

`center` é a caixa no meio da barra: tudo nela fica centralizado na tela como um único grupo. `centerBegin` e `centerEnd` ficam pendurados de cada lado da caixa, que é como o relógio fica bem no centro mesmo quando o clima e o selo de atualização vêm e vão. Coloque mais de um widget em `center` e eles ficam centralizados juntos; deixe-o vazio e `centerBegin` e `centerEnd` se encontram no meio da barra.

Uma regra que vale a pena internalizar: **depois que você tem seu próprio `shell.json`, ele é canônico**. Até você personalizar qualquer coisa, o shell lê o arquivo padrão do Omarchy. No momento em que você arrasta um widget, executa `omarchy bar` ou edita o arquivo por conta própria, ele é seu — não há uma mesclagem profunda, então widgets padrão novos em versões futuras do Omarchy não vão aparecer na sua barra automaticamente. `omarchy bar defaults` restaura o layout de fábrica sempre que você quiser começar do zero.

O mesmo arquivo também guarda seus tempos de inatividade no nível superior, fora da chave `bar`: `idle.screensaver` e `idle.lock`, ambos em segundos desde que você ficou inativo. Então o protetor de tela padrão entra em ação aos 150 segundos e o bloqueio, aos 300.
