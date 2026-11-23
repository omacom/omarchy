# Jednotná schránka a historie

Na Linuxu obvykle potřebujete `Ctrl + Shift + C/V` na kopírování a vkládání v terminálu a `Ctrl + C/V` na totéž všude jinde. Na to si těžko zvyká každý, kdo se na Linuxu nenarodil a nevyrostl! Stejně tak přechod ze super na ctrl, pokud přicházíte z Macu.

Omarchy řeší oba problémy jednotnými klávesovými zkratkami pro schránku, které fungují (téměř) všude. Jsou to:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Vybrat vše |
| Super + C | Kopírovat |
| Super + X | Vyjmout |
| Super + V | Vložit |
| Super + Ctrl + V | Historie schránky |

_Všimněte si, že většina harnessů pro agenty použije `Ctrl + V` na vkládání obrázků, ale `Super + V` na vkládání textu._

Pomocí `Super + A` a následně `Super + C` zkopírujete vše v aktivním textovém poli nebo jiné aplikaci, která podporuje `Ctrl + A`. V terminálu `Ctrl + A` místo výběru textu přesune na začátek příkazového řádku.

### Historie schránky

Historii schránky zajišťuje shell Omarchy a funguje pro text i obrázky. Spustíte ji pomocí `Super + Ctrl + V` a svou položku vyberete klávesou return, čímž ji vložíte přímo do aplikace, ve které jste byli. Pomocí `Shift + Return` ji pouze zkopírujete do schránky, pomocí `Alt + Return` ji otevřete, pomocí `Delete` ji odstraníte z historie a pomocí `Shift + Delete` vymažete celou historii.

 ![clipboard-history](images/clipboard-history.webp)

Historii můžete také prohledávat prostě tím, že začnete psát:

 ![clipboard-history-search](images/clipboard-history-search.webp)
