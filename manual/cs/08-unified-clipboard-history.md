# Jednotná schránka a historie

Obvykle na Linuxu potřebujete `Ctrl + Shift + C/V` pro kopírování a vkládání v terminálu a `Ctrl + C/V` všude jinde. Na to je těžké si zvyknout pro každého, kdo se na Linuxu nenarodil a nebyl na něm vychován! Stejně tak na přechod ze super na ctrl, pokud přicházíte z Macu.

Omarchy řeší oba problémy jednotnými klávesovými zkratkami schránky, které fungují (téměř) všude. Jsou to:

| Klávesová zkratka | Příkaz |
| ------- | ----------- |
| Super + C | Kopírovat |
| Super + X | Vyjmout |
| Super + V | Vložit |
| Super + Ctrl + V | Historie schránky |

_Upozorňujeme, že většina harnessů agentů bude používat `Ctrl + V` pro vkládání obrázků, ale `Super + V` pro vkládání textu._

### Historie schránky

Historii schránky poskytuje shell Omarchy a funguje pro text i obrázky. Spustíte ji pomocí `Super + Ctrl + V`, vyberete položku klávesou return a ta se umístí do schránky připravená k vložení pomocí `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

V historii můžete také vyhledávat pouhým začátkem psaní:

 ![clipboard-history-search](images/clipboard-history-search.webp)
