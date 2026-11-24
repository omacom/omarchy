# Enhetligt urklipp och historik

I vanliga fall på Linux behöver du `Ctrl + Shift + C/V` för att kopiera och klistra in i terminalen och `Ctrl + C/V` för att göra det överallt annars. Det är svårt att vänja sig vid för alla som inte är födda och uppvuxna med Linux! Det är också bytet från super till ctrl, om du kommer från Mac.

Omarchy löser båda problemen med enhetliga snabbtangenter för urklippet som fungerar (nästan) överallt. De är:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Markera allt |
| Super + C | Kopiera |
| Super + X | Klipp ut |
| Super + V | Klistra in |
| Super + Ctrl + V | Urklippshistorik |

_Observera att de flesta agentramverk använder `Ctrl + V` för att klistra in bilder, men `Super + V` för att klistra in text._

Använd `Super + A` och sedan `Super + C` för att kopiera allt i ett fokuserat textfält eller en annan app som stöder `Ctrl + A`. I en terminal flyttar `Ctrl + A` till början av kommandoraden i stället för att markera dess text.

### Urklippshistorik

Urklippshistoriken tillhandahålls av Omarchy-skalet och fungerar för både text och bilder. Du öppnar den med `Super + Ctrl + V` och väljer din post med retur, vilket klistrar in den direkt i appen du var i. Använd `Shift + Return` för att bara kopiera den till urklippet, `Alt + Return` för att öppna den, `Delete` för att ta bort den från historiken och `Shift + Delete` för att rensa hela historiken.

 ![clipboard-history](images/clipboard-history.webp)

Du kan också söka i historiken genom att bara börja skriva:

 ![clipboard-history-search](images/clipboard-history-search.webp)
