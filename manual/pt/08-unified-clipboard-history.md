# Área de Transferência Unificada e Histórico

Normalmente, no Linux, precisas de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para o fazer em todo o resto. É difícil habituares-te a isso se não nasceste e foste criado no Linux! O mesmo acontece com a troca do super para o ctrl, se vens do Mac.

O Omarchy resolve os dois problemas com atalhos de teclado unificados para a área de transferência que funcionam (quase) em todo o lado. São eles:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Selecionar tudo |
| Super + C | Copiar |
| Super + X | Cortar |
| Super + V | Colar |
| Super + Ctrl + V | Histórico da área de transferência |

_Repara que a maioria dos agent harnesses vai usar `Ctrl + V` para colar imagens, mas `Super + V` para colar texto._

Usa `Super + A` e depois `Super + C` para copiar tudo num campo de texto focado ou noutra aplicação que suporte `Ctrl + A`. Num terminal, `Ctrl + A` move para o início da linha de comandos em vez de selecionar o seu texto.

### Histórico da área de transferência

O histórico da área de transferência é fornecido pela shell do Omarchy e funciona tanto para texto como para imagens. Aciona-lo com `Super + Ctrl + V`, selecionas a tua entrada com return, e ela fica colocada na área de transferência, pronta a colar com `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Também podes pesquisar no histórico bastando começar a escrever:

 ![clipboard-history-search](images/clipboard-history-search.webp)
