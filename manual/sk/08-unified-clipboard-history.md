# Jednotná schránka a história

Na Linuxe zvyčajne potrebujete `Ctrl + Shift + C/V` na kopírovanie a prilepovanie v termináli a `Ctrl + C/V` na to isté všade inde. Pre každého, kto sa na Linuxe nenarodil a nevyrastal na ňom, sa na to ťažko zvyká! Rovnako aj na prechod zo Super na Ctrl, ak prichádzate z Macu.

Omarchy rieši oba problémy jednotnými klávesovými skratkami schránky, ktoré fungujú (takmer) všade. Sú to:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Vybrať všetko |
| Super + C | Kopírovať |
| Super + X | Vystrihnúť |
| Super + V | Prilepiť |
| Super + Ctrl + V | História schránky |

_Upozorňujeme, že väčšina prostredí agentov použije `Ctrl + V` na prilepenie obrázkov, ale `Super + V` na prilepenie textu._

Použite `Super + A` a potom `Super + C` na skopírovanie všetkého v aktívnom textovom poli alebo inej aplikácii, ktorá podporuje `Ctrl + A`. V termináli `Ctrl + A` presunie na začiatok príkazového riadka namiesto výberu jeho textu.

### História schránky

Históriu schránky poskytuje shell Omarchy a funguje pre text aj obrázky. Spustíte ju pomocou `Super + Ctrl + V`, klávesom return vyberiete svoju položku a tá sa potom umiestni do schránky, pripravená na prilepenie pomocou `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

V histórii môžete vyhľadávať aj tak, že jednoducho začnete písať:

 ![clipboard-history-search](images/clipboard-history-search.webp)
