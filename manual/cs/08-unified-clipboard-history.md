# Sjednocená schránka a historie

Na Linuxu obvykle potřebujete `Ctrl + Shift + C/V` ke kopírování a vkládání v terminálu a `Ctrl + C/V` všude jinde. Pro každého, kdo se na Linuxu nenarodil a nevyrostl na něm, je na to těžké si zvyknout! Stejně tak na přechod ze Super na Ctrl, pokud přecházíte z Macu.

Omarchy řeší oba problémy sjednocenými klávesovými zkratkami schránky, které fungují (téměř) všude. Jsou to:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Vybrat vše |
| Super + C | Kopírovat |
| Super + X | Vyjmout |
| Super + V | Vložit |
| Super + Ctrl + V | Historie schránky |

_Poznámka: většina agentních harnessů používá `Ctrl + V` pro vkládání obrázků, ale `Super + V` pro vkládání textu._

Pomocí `Super + A` a poté `Super + C` zkopírujete vše ve zaměřeném textovém poli nebo jiné aplikaci, která podporuje `Ctrl + A`. V terminálu `Ctrl + A` přesune na začátek příkazového řádku, místo aby vybral jeho text.

### Historie schránky

Historii schránky poskytuje shell Omarchy a funguje pro text i obrázky. Vyvoláte ji pomocí `Super + Ctrl + V`, vyberete položku klávesou Return a ta pak bude umístěna do schránky připravená k vložení pomocí `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

V historii můžete také vyhledávat prostě tím, že začnete psát:

 ![clipboard-history-search](images/clipboard-history-search.webp)
