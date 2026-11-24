# Avisos

As notificações chegam no canto superior direito da tela em foco. Você também pode acessar rapidamente a data e a hora, o status da bateria e o clima atual usando os avisos por tecla de atalho.

## Notificações

Notificações do mesmo aplicativo ou site se empilham em uma pilha, então um canal barulhento do Slack não empurra sua falha de build para fora da tela. Passe o cursor sobre uma pilha para abri-la em leque; nada novo desliza para debaixo do seu ponteiro enquanto você está lendo. Clique em um cartão para ir até sua origem, clique com o botão direito, clique com o botão do meio ou toque no ✕ para dispensá-lo.

Os cartões oferecem o que carregam: _Copiar código_ para códigos de verificação (mantidos fora do [histórico da área de transferência](08-unified-clipboard-history.md) e apagados depois de um minuto), além de quaisquer botões que o aplicativo forneça. Links no texto de uma notificação abrem quando clicados.

`Super + ,` dispensa a notificação mais recente, ou abre o que ela aponta quando ela oferece isso, `Super + Alt + ,` dispensa só a última, `Super + Shift + ,` dispensa todas, e `Super + Shift + Alt + ,` abre o histórico. Para usá-las sem o mouse, pressione `Super + Ctrl + ,`. A notificação mais recente é selecionada e seus botões são numerados: pressione um número para usar um, `Enter` para clicar na notificação, `↑` e `↓` para mover entre as notificações, `Delete` para dispensar uma, e `Esc` para devolver o teclado. Ele também libera o teclado sozinho após alguns segundos de inatividade.

Silenciar as notificações as segura, exceto as próprias confirmações do Omarchy, alertas de emergência e códigos de verificação, que você pediu há um momento. Coloque as últimas de volta na tela, seguradas ou não, com `Super + Shift + Alt + ,`. O histórico é mantido por um dia.

## Avisos por tecla de atalho

### Data e hora

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Clima

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

A localização é detectada a partir do seu endereço IP, o que geralmente é perto o suficiente, mas nem sempre. Você pode fixá-la com `omarchy weather location --set Malibu`, ou ser exato sobre ela adicionando coordenadas: `omarchy weather location --set Malibu 34.0259,-118.7798`. Execute `omarchy weather location` sozinho para ver onde ele acha que você está, e `--clear` para voltar à detecção automática.

### Bateria

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
