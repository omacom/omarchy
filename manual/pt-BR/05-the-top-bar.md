# A Barra Superior

A faixa ao longo do topo da sua tela é a barra do Omarchy. Ela não é uma barra de status encaixada, mas parte do shell do Omarchy, o único processo Quickshell de longa execução que também desenha o menu, as notificações, os pop-ups OSD e a tela de bloqueio. É por isso que ela combina perfeitamente em tema com todo o resto e por que um painel abre instantaneamente em vez de gerar um novo aplicativo.

Ela também é a única parte do desktop que está sempre na tela, então vale a pena saber o que todos aqueles pequenos glifos fazem.

## O que há nela por padrão

A barra tem três seções. À esquerda ficam o logotipo do Omarchy (o iniciador do menu) e os indicadores de áreas de trabalho. No centro, você tem os indicadores de status, o relógio, o Elsewhen (um relógio mundial), o clima e um selo de atualização do Omarchy. À direita: o layout do teclado (quando mais de um está configurado), a bandeja do sistema, agentes, bluetooth, rede, áudio, tela e energia.

Alguns deles só aparecem quando têm algo a dizer. O layout do teclado aparece somente se você configurou mais de um layout. O selo de atualização aparece somente quando há uma atualização do Omarchy esperando. E o ícone de agentes aparece na primeira vez que o Omarchy encontra uso de codificação por IA na máquina (veja [IA](17-ai.md)).

## Clicando por aí

Quase todos os widgets fazem algo com cliques esquerdo, direito e do meio, e vários respondem à rolagem. Esta é a parte que as pessoas perdem — os botões direito e do meio são onde se esconde muita coisa boa.

| Widget | Esquerdo | Direito | Meio / rolagem |
| --- | --- | --- | --- |
| Menu | Menu do Omarchy | Novo terminal | — |
| Áreas de trabalho | Focar aquela área de trabalho | — | Rolagem: próxima/anterior área de trabalho |
| Relógio | Pop-up do calendário | Alternar o formato do rótulo | Meio: seletor de fuso horário |
| Clima | Pop-up da previsão | Clima completo como uma notificação | Meio: atualizar |
| Áudio | Painel de áudio | Silenciar | Meio: painel · rolagem: volume |
| Microfone | Silenciar o microfone | — | Meio: painel de áudio · rolagem: volume de entrada |
| Rede | Painel de rede | — | — |
| Bluetooth | Painel Bluetooth | Alternar o rádio | — |
| Tela | Painel de tela | — | Rolagem: brilho |
| Energia | Painel de energia | Alternar a porcentagem da bateria | — |
| Mídia | Reproduzir/pausar | Pop-up da capa | Meio: próxima · rolagem: anterior/próxima |
| Agentes | Painel de agentes | Abrir seu agente | Meio: próxima assinatura |
| Bandeja | Passar o mouse para revelar a gaveta | Botão direito no chevron para gerenciar | — |
| Atualização do Omarchy | Executar a atualização | — | — |

Nem tudo nessa tabela está na sua barra de imediato. O widget de mídia (MPRIS tocando agora, com faixa e artista rolando) e o widget de microfone são ambos integrados, mas desligados por padrão — adicione-os se quiser, como descrito abaixo.

## Os painéis

Clicar em um ícone da barra abre um painel, que é um pop-up de verdade com controles deslizantes, listas e navegação por teclado, em vez de uma dica de ferramenta. Cada um também tem um atalho, então você nunca precisa mirar em um glifo de 16 pixels:

| Atalho | Painel |
| --- | --- |
| `Super + Ctrl + A` | Áudio |
| `Super + Ctrl + W` | Rede |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Tela |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Calendário |
| `Super + Ctrl + Alt + E` | Relógio mundial |
| `Super + Ctrl + 1-9` | Alternar o enésimo painel na seção da direita |

Os painéis não são só leituras. Eles são onde você realmente faz a coisa:

- **Áudio** tem um controle deslizante de volume principal, um seletor de dispositivo de saída e um mixer por aplicativo, para você abaixar aquela aba do navegador sem mexer em todo o resto.
- **Rede** procura Wi-Fi, mostra a intensidade do sinal, conecta e permite escolher um provedor de DNS.
- **Bluetooth** lista seus dispositivos com conectar/desconectar e níveis de bateria.
- **Energia** mostra estatísticas da bateria, muda perfis de energia (ele lembra uma escolha separada para bateria e tomada) e imprime algumas informações do sistema.
- **Tela** traz um controle deslizante de brilho, tamanho do texto, predefinições de escala do monitor e — quando você tem mais de uma tela — controles por monitor. Veja [monitores](33-monitors.md) para a história mais profunda.
- **Relógio** abre uma grade mensal com números de semana ISO e navegação entre meses.

Todo painel aceita o teclado além do mouse: setas movem, Return ativa, Tab vai para o painel vizinho e Escape fecha.

`Super + Ctrl + 1-9` conta os painéis da esquerda para a direita na seção da direita, pulando a bandeja, já que ela não tem painel próprio. Então o número corresponde ao ícone para o qual você apontaria.

### Tailscale e Dropbox

Mais dois widgets aparecem na barra somente depois que você instala o serviço correspondente em **Instalar → Serviço**, e ambos merecem ser conhecidos porque fazem mais do que relatar status.

O painel do **Tailscale** conecta e desconecta a tailnet, alterna entre contas e escolhe um nó de saída (suas próprias máquinas e regiões Mullvad aparecem nessa lista). Ele também navega pelas suas máquinas — e, com uma selecionada, `s` envia arquivos para ela pelo Taildrop, que é a maneira mais rápida de mover um arquivo para o seu telefone ou outro laptop. `c` copia o IP da máquina, `n` o nome dela e `d` seu nome DNS completo. Há também um botão de envio em cada linha de máquina, se você preferir clicar. O mesmo a partir do terminal é `omarchy tailscale send <machine> [file...]`.

O painel do **Dropbox** cuida do login, mostra quanto de armazenamento você usou e lista arquivos sincronizados recentemente.

Remover qualquer um dos serviços tira seu widget da barra novamente.

## Indicadores

O pequeno aglomerado no centro é o widget de indicadores. Esses são glifos de status para modos que você ativou: não perturbe, luz noturna, um [lembrete](09-reminders.md) na fila, uma gravação de tela ativa, manter acordado e [ditado](11-text-extraction-dictation.md). Eles acendem quando o modo está ativo e, caso contrário, ficam fora do caminho — passe o mouse à esquerda do relógio (acima dele em uma barra vertical) para espiar os inativos. Clicar em um indicador alterna aquele modo. Mais um é apenas de status: uma sessão remota acende em vermelho enquanto alguém está conectado a esta máquina pelo gliff.

Se você prefere que eles estejam sempre visíveis, defina `alwaysShow` como `true` no widget. E se você só se importa com alguns deles, liste os que quer em `items`: `["Dnd", "Reminder", "NightLight"]`. Você pode ter mais de um widget de indicadores, então seções diferentes podem mostrar subconjuntos diferentes.

## Reorganizando a barra

A barra se configura sozinha. Você não precisa abrir um arquivo de configuração para mover as coisas.

Pegue um trecho vazio da barra ao redor do centro e arraste-o na direção de outra borda da tela, e a barra se move para lá — esquerda, direita, topo ou parte inferior, tudo funciona, e todos os widgets se adaptam (barras verticais recorrem a formas compactas só de ícones). Um clique pressionado inicia o mesmo arraste. Clique duas vezes com o botão esquerdo nesse mesmo espaço vazio para alternar o fundo da barra de transparente para translúcido para opaco. E arraste qualquer widget para reordená-lo ou jogá-lo em outra seção.

Um widget que você quer por perto, mas nem sempre à vista, pode ir para a gaveta da bandeja: arraste-o para cima da bandeja e a gaveta se abre para recebê-lo. Ele fica ali depois dos ícones dos aplicativos, aparece sempre que a gaveta aparece e mantém a sua gaveta aberta enquanto seu painel estiver aberto. Arraste-o de volta para a barra para colocá-lo no lugar.

Se você prefere escolher em um menu, **Acionar → Aparência → Barra de menu** tem a posição, e **Fundo da barra** escolhe como a barra é desenhada: **Barra opaca**, **Barra translúcida** (transparente, com o que está atrás desfocado) ou **Barra transparente**.

As mesmas coisas têm comandos, que é o que você quer para uma configuração de [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para adicionar ou remover um widget por completo, use os comandos de plugin. `omarchy plugin list` imprime todos os widgets que o shell conhece com seu id, e então:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Ocultando a barra

`Super + Shift + Space` alterna a barra entre desligada e ligada sem matar o shell — painéis e atalhos continuam funcionando, você apenas recupera os pixels. Também está no menu em **Acionar → Aparência → Barra de menu → Ocultar barra**.

## O arquivo de configuração

Tudo fica armazenado em `~/.config/omarchy/shell.json`, sob a chave `bar`. Aqui está uma versão resumida:

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

Todo widget é uma entrada em um dos três arrays de layout, e suas configurações ficam inline nessa entrada — não há arquivo de configurações separado nem sub-objeto `config`. O `format` do relógio, o `formatAlt` (para o qual o clique direito alterna) e o `verticalFormat` vivem todos bem ali em `{ "id": "omarchy.clock" }`.

`centerAnchor` nomeia o único widget central que fica fixado no centro exato da tela, com os outros o flanqueando. É assim que o relógio fica bem no centro mesmo quando o clima e o selo de atualização vão e vêm. Defina-o como uma string vazia e a lista central é apenas centralizada como um grupo.

Uma regra que vale internalizar: **depois que você tem seu próprio `shell.json`, ele é canônico**. Até você personalizar qualquer coisa, o shell lê o arquivo padrão do Omarchy. No momento em que você arrasta um widget, executa `omarchy bar` ou edita o arquivo, ele é seu — não há mesclagem profunda, então novos widgets padrão em versões futuras do Omarchy não aparecerão na sua barra automaticamente. `omarchy bar defaults` restaura o layout de fábrica sempre que você quiser uma lousa limpa.

O mesmo arquivo também guarda seus tempos de ociosidade no nível superior, fora da chave `bar`: `idle.screensaver` e `idle.lock`, ambos em segundos desde que você ficou ocioso. Então a proteção de tela padrão entra em 150 segundos e o bloqueio em 300.
