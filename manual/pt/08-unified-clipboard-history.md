# Área de Transferência Unificada e Histórico

Normalmente no Linux, precisas de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para o fazeres em todo o resto. É difícil habituares-te a isso se não nasceste e cresceste no Linux! O mesmo acontece com a mudança de super para ctrl, se vieres do Mac.

O Omarchy resolve ambos os problemas com teclas de atalho unificadas para a área de transferência que funcionam (quase) em todo o lado. São as seguintes:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Selecionar tudo |
| Super + C | Copiar |
| Super + X | Cortar |
| Super + V | Colar |
| Super + Ctrl + V | Histórico da área de transferência |

_Nota que a maioria dos harnesses de agentes usa `Ctrl + V` para colar imagens, mas `Super + V` para colar texto._

Usa `Super + A` e depois `Super + C` para copiares tudo o que está num campo de texto com o foco ou noutra aplicação que suporte `Ctrl + A`. Num terminal, `Ctrl + A` move para o início da linha de comandos em vez de selecionar o seu texto.

### Histórico da área de transferência

O histórico da área de transferência é fornecido pela shell do Omarchy e funciona tanto para texto como para imagens. Ativa-lo com `Super + Ctrl + V` e selecionas a tua entrada com return, o que a cola diretamente na aplicação onde estavas. Usa `Shift + Return` para a copiares apenas para a área de transferência, `Alt + Return` para a abrires, `Delete` para a removeres do histórico e `Shift + Delete` para limpares todo o histórico.

 ![clipboard-history](images/clipboard-history.webp)

Também podes pesquisar no histórico simplesmente começando a escrever:

 ![clipboard-history-search](images/clipboard-history-search.webp)
