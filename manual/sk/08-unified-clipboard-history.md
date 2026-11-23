# Jednotná schránka a história

Zvyčajne v Linuxe potrebujete `Ctrl + Shift + C/V` na kopírovanie a prilepovanie v termináli a `Ctrl + C/V` na to isté všade inde. Pre každého, kto sa v Linuxe nenarodil a nevyrastal v ňom, je ťažké si na to zvyknúť! Rovnako aj na prechod zo super na ctrl, ak prichádzate z Macu.

Omarchy rieši oba problémy jednotnými klávesovými skratkami schránky, ktoré fungujú (takmer) všade. Sú to:

| Klávesová skratka | Príkaz |
| ------- | ----------- |
| Super + A | Vybrať všetko |
| Super + C | Kopírovať |
| Super + X | Vystrihnúť |
| Super + V | Prilepiť |
| Super + Ctrl + V | História schránky |

_Upozorňujeme, že väčšina agent harnessov bude používať `Ctrl + V` na prilepovanie obrázkov, ale `Super + V` na prilepovanie textu._

Použite `Super + A` a potom `Super + C` na skopírovanie všetkého v zameranom textovom poli alebo inej aplikácii, ktorá podporuje `Ctrl + A`. V termináli vás `Ctrl + A` presunie na začiatok príkazového riadka namiesto výberu jeho textu.

### História schránky

Históriu schránky poskytuje shell Omarchy a funguje pre text aj obrázky. Spustíte ju pomocou `Super + Ctrl + V` a svoju položku vyberiete klávesom Return, čím ju prilepíte priamo do aplikácie, v ktorej ste boli. Použite `Shift + Return`, ak ju chcete iba skopírovať do schránky, `Alt + Return` na jej otvorenie, `Delete` na jej odstránenie z histórie a `Shift + Delete` na vymazanie celej histórie.

 ![clipboard-history](images/clipboard-history.webp)

V histórii môžete vyhľadávať aj jednoducho tak, že začnete písať:

 ![clipboard-history-search](images/clipboard-history-search.webp)
