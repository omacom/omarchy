# Área de Transferência Unificada e Histórico

Normalmente no Linux, você precisa de `Ctrl + Shift + C/V` para copiar e colar no terminal e `Ctrl + C/V` para fazer isso em todos os outros lugares. Isso é difícil de acostumar para quem não nasceu e foi criado no Linux! O mesmo vale para a troca de super para ctrl, se você vem do Mac.

O Omarchy resolve os dois problemas com atalhos unificados da área de transferência que funcionam (quase) em todos os lugares. Eles são:

| Atalho | Comando |
| ------- | ----------- |
| Super + A | Selecionar tudo |
| Super + C | Copiar |
| Super + X | Recortar |
| Super + V | Colar |
| Super + Ctrl + V | Histórico da área de transferência |

_Observe que a maioria dos harnesses de agentes usará `Ctrl + V` para colar imagens, mas `Super + V` para colar texto._

Use `Super + A`, depois `Super + C` para copiar tudo em um campo de texto focado ou outro aplicativo que suporte `Ctrl + A`. Em um terminal, `Ctrl + A` move para o início da linha de comando em vez de selecionar seu texto.

### Histórico da área de transferência

O histórico da área de transferência é fornecido pelo shell do Omarchy e funciona tanto para texto quanto para imagens. Você o aciona com `Super + Ctrl + V` e seleciona sua entrada com Return, o que a cola direto no aplicativo em que você estava. Use `Shift + Return` para apenas copiá-la para a área de transferência, `Alt + Return` para abri-la, `Delete` para removê-la do histórico e `Shift + Delete` para limpar todo o histórico.

 ![clipboard-history](images/clipboard-history.webp)

Você também pode pesquisar no histórico apenas começando a digitar:

 ![clipboard-history-search](images/clipboard-history-search.webp)
