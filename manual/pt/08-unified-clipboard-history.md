# Área de transferência unificada e histórico

Normalmente, no Linux, precisas de `Ctrl + Shift + C/V` para copiar e colar no terminal e de `Ctrl + C/V` para fazeres isso em todo o resto. Isso é difícil de interiorizar para quem não nasceu e cresceu no Linux! O mesmo se aplica à troca do super pelo ctrl, se vens do Mac.

O Omarchy trata dos dois problemas com atalhos de área de transferência unificados que funcionam (quase) em todo o lado. São estes:

| Atalho | Comando |
| ------- | ----------- |
| Super + C | Copiar |
| Super + X | Cortar |
| Super + V | Colar |
| Super + Ctrl + V | Histórico da área de transferência |

_Repara que a maioria dos arneses de agentes usa `Ctrl + V` para colar imagens, mas `Super + V` para colar texto._

### Histórico da área de transferência

O histórico da área de transferência é fornecido pela shell do Omarchy e funciona tanto para texto como para imagens. Acionas-o com `Super + Ctrl + V`, selecionas a entrada com Return, e essa entrada fica colocada na área de transferência pronta para colar com `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Também podes pesquisar no histórico apenas começando a escrever:

 ![clipboard-history-search](images/clipboard-history-search.webp)
