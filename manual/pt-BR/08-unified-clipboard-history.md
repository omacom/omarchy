# Área de Transferência Unificada e Histórico

Normalmente no Linux, você precisa de `Ctrl + Shift + C/V` para copiar e colar no terminal e `Ctrl + C/V` para fazer isso em todos os outros lugares. Isso é difícil de acostumar para quem não nasceu e cresceu no Linux! Assim como a troca de super para ctrl, se você está vindo do Mac.

O Omarchy enfrenta os dois problemas com atalhos de área de transferência unificados que funcionam (quase) em todo lugar. Eles são:

| Atalho | Comando |
| ------- | ----------- |
| Super + C | Copiar |
| Super + X | Recortar |
| Super + V | Colar |
| Super + Ctrl + V | Histórico da área de transferência |

_Note que a maioria dos harnesses de agentes usará `Ctrl + V` para colar imagens, mas `Super + V` para colar texto._

### Histórico da área de transferência

O histórico da área de transferência é fornecido pelo shell do Omarchy e funciona tanto para texto quanto para imagens. Você o aciona com `Super + Ctrl + V`, seleciona sua entrada com return, e ela será colocada na área de transferência pronta para colar com `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Você também pode pesquisar no histórico apenas começando a digitar:

 ![clipboard-history-search](images/clipboard-history-search.webp)
