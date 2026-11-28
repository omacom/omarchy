# Avisos

As notificações aparecem no canto superior direito do ecrã em foco. Também pode aceder rapidamente à data e à hora, ao estado da bateria e ao tempo atual através dos avisos por tecla de atalho.

## Notificações

As notificações da mesma aplicação ou site agrupam-se numa pilha, por isso um canal do Slack que não se cala não empurra a sua falha de compilação para fora do ecrã. Passe o rato sobre uma pilha para a abrir em leque; nada de novo desliza para debaixo do seu ponteiro enquanto está a ler. Clique num cartão para saltar para a sua origem, clique com o botão direito, clique com o botão do meio ou toque no ✕ para o fechar.

Os cartões oferecem o que trazem: _Copiar código_ para códigos de verificação (mantidos fora do [histórico da área de transferência](08-unified-clipboard-history.md) e apagados após um minuto), além de quaisquer botões fornecidos pela aplicação. As hiperligações no texto de uma notificação abrem-se quando clica nelas.

`Super + ,` fecha a notificação mais recente, ou abre aquilo para que aponta quando oferece essa opção, `Super + Alt + ,` fecha apenas a última, `Super + Shift + ,` fecha-as todas e `Super + Shift + Alt + ,` abre o histórico. Para as utilizar sem o rato, prima `Super + Ctrl + ,`. A notificação mais recente fica selecionada e os seus botões numerados: prima um número para utilizar um, `Enter` para clicar na notificação, `↑` e `↓` para se mover entre notificações, `Delete` para fechar uma e `Esc` para devolver o teclado. Também liberta o teclado sozinho após alguns segundos de inatividade.

Silenciar as notificações retém-nas, exceto as confirmações do próprio Omarchy, os alertas de emergência e os códigos de verificação, que pediu há instantes. Volte a mostrar as últimas no ecrã, tenham sido retidas ou não, com `Super + Shift + Alt + ,`. O histórico é guardado durante um dia.

## Avisos por tecla de atalho

### Data e Hora

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Tempo

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

A localização é detetada a partir do seu endereço IP, o que normalmente é suficientemente próximo, mas nem sempre. Pode fixá-la com `omarchy weather location --set Malibu`, ou ser exato ao adicionar coordenadas: `omarchy weather location --set Malibu 34.0259,-118.7798`. Execute `omarchy weather location` sem mais nada para ver onde pensa que está, e `--clear` para voltar à deteção automática.

### Bateria

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
