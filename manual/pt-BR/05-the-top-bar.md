# A barra superior

A faixa ao longo do topo da sua tela é a barra do Omarchy. Não é uma barra de status encaixada por cima, mas parte do shell do Omarchy, o único processo Quickshell de longa duração que também desenha o menu, as notificações, os popups do OSD e a tela de bloqueio. É por isso que ela combina perfeitamente com todo o resto e que um painel abre instantaneamente em vez de iniciar um novo aplicativo.

Também é a única peça da área de trabalho que está sempre na tela, então vale a pena saber o que todos aqueles glifinhos fazem.

## O que há nela por padrão

A barra tem três seções. À esquerda ficam o logo do Omarchy (o lançador do menu) e os indicadores de workspace. No centro você tem os indicadores de status, o relógio, o Elsewhen (um relógio mundial), o clima e um selo de atualização do Omarchy. À direita: a bandeja do sistema, o layout do teclado (quando mais de um está configurado), agentes, bluetooth, rede, áudio, tela e energia.

Alguns deles só aparecem quando têm algo a dizer. O layout do teclado aparece só se você configurou mais de um layout. O selo de atualização aparece só quando há uma atualização do Omarchy esperando. E o ícone de agentes aparece na primeira vez que o Omarchy encontra uso de programação com AI na máquina (veja [AI](17-ai.md)).

## Clicando por aí

Quase todo widget faz alguma coisa com clique esquerdo, direito e do meio, e vários respondem à rolagem. Essa é a parte que as pessoas perdem — é nos botões direito e do meio que se esconde muita coisa boa.

| Widget | Esquerdo | Direito | Do meio / rolagem |
| --- | --- | --- | --- |
| Menu | Menu do Omarchy | Novo terminal | — |
| Workspaces | Focar aquele workspace neste monitor | — | Rolagem: workspace anterior/seguinte |
| Relógio | Popup do calendário | Alternar o formato do rótulo | Do meio: seletor de fuso horário |
| Clima | Popup da previsão | Clima completo como notificação | Do meio: atualizar |
| Áudio | Painel de áudio | Silenciar | Do meio: painel · rolagem: volume |
| Microfone | Silenciar o microfone | — | Do meio: painel de áudio · rolagem: volume de entrada |
| Rede | Painel de rede | — | — |
| Bluetooth | Painel Bluetooth | Alternar o rádio | — |
| Tela | Painel de tela | — | Rolagem: brilho |
| Energia | Painel de energia | Alternar a porcentagem da bateria | — |
| Mídia | Reproduzir/pausar | Popup da arte da capa | Do meio: seguinte · rolagem: anterior/seguinte |
| Agentes | Painel de agentes | Iniciar seu agente | Do meio: próxima assinatura |
| Bandeja | Passar o mouse para revelar a gaveta | Clique com o botão direito na seta para gerenciar | — |
| Atualização do Omarchy | Executar a atualização | — | — |

Nem tudo nessa tabela está na sua barra de fábrica. O widget de mídia (MPRIS tocando agora, com faixa e artista em rolagem) e o widget de microfone já vêm embutidos, mas desligados por padrão — adicione-os se quiser, como descrito abaixo.

## Os painéis

Clicar em um ícone da barra abre um painel, que é um popup de verdade, com controles deslizantes, listas e navegação pelo teclado, em vez de uma dica de ferramenta. Cada um também tem uma tecla de atalho, para você nunca precisar mirar em um glifo de 16 pixels:

| Tecla de atalho | Painel |
| --- | --- |
| `Super + Ctrl + A` | Áudio |
| `Super + Ctrl + N` | Rede |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Tela |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Calendário |
| `Super + Ctrl + Alt + E` | Relógio mundial |
| `Super + Ctrl + 1-9` | Alternar o enésimo painel na seção da direita |

Os painéis não são só leituras. É neles que você realmente faz a coisa:

- **Áudio** tem um controle deslizante de volume principal, um seletor de dispositivo de saída e um mixer por aplicativo, para você baixar aquela única aba do navegador sem mexer em todo o resto.
- **Rede** procura Wi-Fi, mostra a intensidade do sinal, conecta e permite escolher um provedor de DNS.
- **Bluetooth** lista seus dispositivos com conectar/desconectar e níveis de bateria.
- **Energia** mostra estatísticas da bateria, alterna perfis de energia (ele lembra uma escolha separada para bateria e AC) e exibe algumas informações do sistema.
- **Tela** traz um controle deslizante de brilho, tamanho do texto, predefinições de escala do monitor e — quando você tem mais de uma tela — controles por monitor. Veja [monitores](33-monitors.md) para a história mais profunda.
- **Relógio** abre uma grade do mês com números de semana ISO e navegação entre meses.
- **Relógio mundial** mantém uma linha por cidade, com seu clima e como está indo o dia por lá. A busca encontra cidades pequenas além de fusos horários, então Fort Lauderdale é Fort Lauderdale e não New York. Se a linha no topo indicar a cidade errada, clique nela e diga onde você está; escolha um lugar em outro fuso horário e o relógio do sistema se move para lá também, o que é útil quando você viaja. Passe o mouse sobre uma cidade e clique no botão de pessoa para dizer quem mora lá — nomes simples, ou identificadores do GitHub com `@` para trazer os rostos junto.

Todo painel aceita o teclado além do mouse: as setas movem, Return ativa, Tab passa para o painel vizinho e Escape fecha.

`Super + Ctrl + 1-9` conta os painéis da esquerda para a direita na seção da direita, pulando a bandeja, já que ela não tem um painel próprio. Então o número corresponde ao ícone para o qual você apontaria.

### Tailscale e Dropbox

Mais dois widgets aparecem na barra só depois que você instala o serviço correspondente em **Install → Service**, e vale a pena conhecer os dois porque eles fazem mais do que relatar status.

O painel do **Tailscale** conecta e desconecta a tailnet, alterna entre contas e escolhe um nó de saída (suas próprias máquinas e regiões do Mullvad aparecem nessa lista). Ele também navega pelas suas máquinas — e, com uma selecionada, `s` envia arquivos para ela pelo Taildrop, que é a maneira mais rápida de mover um arquivo para seu telefone ou outro laptop. `c` copia o IP da máquina, `n` seu nome e `d` seu nome DNS completo. Há também um botão de enviar em cada linha de máquina, se você preferir clicar. A mesma coisa pelo terminal é `omarchy tailscale send <machine> [file...]`.

O painel do **Dropbox** cuida do login, mostra quanto armazenamento você usou e lista os arquivos sincronizados recentemente.

Remover qualquer um dos serviços tira seu widget da barra novamente.

## Indicadores

O pequeno conjunto no centro é o widget de indicadores. São glifos de status para modos que você ativou: não perturbe, luz noturna, um [lembrete](09-reminders.md) na fila, uma gravação de tela ativa, manter acordado e [ditado](11-text-extraction-dictation.md). Eles acendem quando o modo está ativo e, fora isso, ficam fora do caminho — passe o mouse logo ao lado deles, onde os inativos ficariam, para espiar esses. Clicar em um indicador alterna aquele modo. Mais um é só de status: uma sessão remota acende em vermelho enquanto alguém está conectado a esta máquina pelo gliff.

Se preferir que eles fiquem sempre visíveis, defina `alwaysShow` como `true` no widget. E se você só se importa com alguns deles, liste os que quer em `items`: `["Dnd", "Reminder", "NightLight"]`. Você pode ter mais de um widget de indicadores, para seções diferentes mostrarem subconjuntos diferentes.

## Reorganizando a barra

A barra se configura sozinha. Você não precisa abrir um arquivo de configuração para mover as coisas.

Pegue um trecho vazio da barra ao redor do centro e arraste-o em direção a outra borda da tela, e a barra se move para lá — esquerda, direita, topo ou parte inferior, tudo funciona, e todo widget se adapta (barras verticais recorrem a formas compactas só com ícones). Clicar e segurar inicia o mesmo arraste. Clique duas vezes com o botão esquerdo nesse mesmo espaço vazio para alternar o fundo da barra de transparente para vítreo para opaco. E arraste qualquer widget para reordená-lo ou jogá-lo em outra seção; os outros widgets se afastam para abrir espaço onde ele vai pousar.

O meio da barra é uma caixa: o que estiver nela fica centralizado como um único grupo, e os widgets de cada lado dela ficam pendurados em suas bordas. Enquanto você arrasta um widget, a caixa aparece como um contorno, ou uma linha atravessando a barra quando está vazia, e você pode soltar dentro dela ou ao lado dela. Quando a soltura cairia na caixa, a caixa cresce para acolher o widget.

Um widget que você quer por perto, mas nem sempre à vista, pode ir para a gaveta da bandeja: arraste-o para a bandeja, e a gaveta se abre para recebê-lo. Ele fica lá depois dos ícones dos aplicativos, aparece sempre que a gaveta aparece e mantém sua gaveta aberta enquanto seu painel está aberto. Arraste-o de volta para a barra para colocá-lo de volta.

Se preferir escolher por um menu, **Appearance → Menu Bar** tem a posição, e **Bar Background** escolhe como a barra é desenhada: **Opaque Bar**, **Glassy Bar** (transparente, com o que está atrás desfocado) ou **Clear Bar**.

As mesmas coisas têm comandos, que é o que você quer para uma configuração de [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para adicionar ou remover um widget por completo, use os comandos de plugin. `omarchy plugin list` imprime todo widget que o shell conhece, com seu id, e então:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ocultando a barra

`Super + Shift + Space` desliga e religa a barra sem matar o shell — painéis e teclas de atalho continuam funcionando, você só recupera os pixels. Também está no menu em **Appearance → Menu Bar → Hide Bar**.

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

Todo widget é uma entrada em um dos cinco arrays de layout, e suas configurações ficam inline nessa entrada — não há um arquivo de configurações separado nem um subobjeto `config`. O `format`, o `formatAlt` (para o que o clique com o botão direito alterna) e o `verticalFormat` do relógio vivem todos bem ali em `{ "id": "omarchy.clock" }`.

`center` é a caixa no meio da barra: tudo nela é centralizado na tela como um único grupo. `centerBegin` e `centerEnd` ficam pendurados de cada lado da caixa, que é como o relógio permanece bem no centro mesmo quando o clima e o selo de atualização vão e vêm. Coloque mais de um widget em `center` e eles são centralizados juntos; deixe-o vazio e `centerBegin` e `centerEnd` se encontram no meio da barra.

Uma regra que vale internalizar: **depois que você tem seu próprio `shell.json`, ele é canônico**. Até você personalizar qualquer coisa, o shell lê o arquivo padrão do Omarchy. No momento em que você arrasta um widget, executa `omarchy bar` ou edita o arquivo por conta própria, ele é seu — não há mesclagem profunda, então novos widgets padrão em versões futuras do Omarchy não aparecerão na sua barra automaticamente. `omarchy bar defaults` restaura o layout de fábrica sempre que você quiser começar do zero.

O mesmo arquivo também guarda seus tempos de inatividade no nível superior, fora da chave `bar`: `idle.screensaver` e `idle.lock`, ambos em segundos desde que você ficou inativo. Então o protetor de tela padrão entra aos 150 segundos e o bloqueio aos 300.
