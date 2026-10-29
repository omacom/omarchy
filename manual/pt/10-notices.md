# Avisos

As notificações surgem no canto superior direito do ecrã em foco. Também pode aceder rapidamente à data e à hora, ao estado da bateria e ao tempo atual através dos avisos por tecla de atalho.

## Notificações

As notificações da mesma aplicação ou do mesmo site empilham-se num baralho, para que um canal de Slack tagarela não empurre o erro da sua compilação para fora do ecrã. Passe o cursor sobre um baralho para o abrir em leque; nada de novo desliza para debaixo do ponteiro enquanto está a ler. Clique num cartão para saltar para a sua origem, clique com o botão direito, clique com o botão do meio ou toque no ✕ para o dispensar.

Os cartões oferecem o que trazem: _Copiar código_ para códigos de verificação (mantidos fora do [histórico da área de transferência](08-unified-clipboard-history.md) e limpos ao fim de um minuto), além de quaisquer botões disponibilizados pela aplicação. As ligações no texto de uma notificação abrem-se quando clicadas.

Para as usar sem o rato, prima `Super + Ctrl + ,`. A notificação mais recente fica selecionada e os seus botões numerados: prima um número para usar um deles, `Enter` para clicar na notificação, `↑` e `↓` para se mover entre notificações, `Delete` para dispensar uma e `Esc` para devolver o teclado. Também se desativa sozinho ao fim de alguns segundos sem atividade.

Silenciar as notificações retém-nas, exceto as confirmações do próprio Omarchy, os alertas de emergência e os códigos de verificação, que pediu há instantes. Volte a colocar as últimas no ecrã, retidas ou não, com `Super + Shift + Alt + ,`. O histórico é mantido durante um dia.

## Avisos por tecla de atalho

### Data e hora

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Tempo

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

A localização é detetada a partir do seu endereço IP, o que normalmente é suficientemente próximo, mas nem sempre. Pode fixá-la com `omarchy weather location --set Malibu`, ou ser exato ao adicionar coordenadas: `omarchy weather location --set Malibu 34.0259,-118.7798`. Execute `omarchy weather location` sozinho para ver onde pensa que está, e `--clear` para voltar à deteção automática.

### Bateria

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
