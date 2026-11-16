# Área de Transferência Unificada e Histórico

Normalmente no Linux, você precisa de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para fazer isso em todo o resto. É difícil de se acostumar para quem não nasceu e foi criado no Linux! O mesmo vale para a troca do super pelo ctrl, se você está vindo do Mac.

O Omarchy resolve os dois problemas com atalhos de área de transferência unificados que funcionam (quase) em todo lugar. São eles:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Selecionar tudo |
| Super + C | Copiar |
| Super + X | Recortar |
| Super + V | Colar |
| Super + Ctrl + V | Histórico da área de transferência |

_Observe que a maioria dos agent harnesses usa `Ctrl + V` para colar imagens, mas `Super + V` para colar texto._

Use `Super + A` e depois `Super + C` para copiar tudo em um campo de texto focado ou em outro aplicativo que suporte `Ctrl + A`. Em um terminal, `Ctrl + A` move para o início da linha de comando em vez de selecionar o texto dela.

### Histórico da área de transferência

O histórico da área de transferência é fornecido pelo shell do Omarchy e funciona tanto para texto quanto para imagens. Você o aciona com `Super + Ctrl + V`, seleciona a entrada com Enter, e ela será colocada na área de transferência, pronta para colar com `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Você também pode pesquisar no histórico simplesmente começando a digitar:

 ![clipboard-history-search](images/clipboard-history-search.webp)
