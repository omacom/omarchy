# Enhetligt urklipp & historik

Vanligtvis på Linux behöver du `Ctrl + Shift + C/V` för att kopiera och klistra in i terminalen och `Ctrl + C/V` för att göra det överallt annars. Det är svårt att vänja sig vid för alla som inte är födda och uppvuxna med Linux! Det är också bytet från super till ctrl, om du kommer från Mac.

Omarchy löser båda problemen med enhetliga snabbkommandon för urklipp som fungerar (nästan) överallt. De är:

| Snabbkommando | Kommando |
| ------- | ----------- |
| Super + A | Markera allt |
| Super + C | Kopiera |
| Super + X | Klipp ut |
| Super + V | Klistra in |
| Super + Ctrl + V | Urklippshistorik |

_Observera att de flesta agentramverk använder `Ctrl + V` för att klistra in bilder, men `Super + V` för att klistra in text._

Använd `Super + A`, sedan `Super + C` för att kopiera allt i ett fokuserat textfält eller en annan app som stöder `Ctrl + A`. I en terminal flyttar `Ctrl + A` till början av kommandoraden istället för att markera dess text.

### Urklippshistorik

Urklippshistoriken tillhandahålls av Omarchy-skalet och fungerar för både text och bilder. Du öppnar den med `Super + Ctrl + V`, väljer din post med return, och sedan placeras den i urklippet redo att klistras in med `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Du kan också söka i historiken bara genom att börja skriva:

 ![clipboard-history-search](images/clipboard-history-search.webp)
