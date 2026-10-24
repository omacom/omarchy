# Jednotná schránka a história

Na Linuxe zvyčajne potrebujete `Ctrl + Shift + C/V` na kopírovanie a vkladanie v termináli a `Ctrl + C/V` na to všade inde. Na to je ťažké si zvyknúť pre každého, kto sa na Linuxe nenarodil a nevyrástol! Rovnako aj prepnutie zo Super na Ctrl, ak prichádzate z Macu.

Omarchy rieši oba problémy jednotnými klávesovými skratkami pre schránku, ktoré fungujú (takmer) všade. Sú to:

| Skratka | Príkaz |
| ------- | ----------- |
| Super + C | Kopírovať |
| Super + X | Vystrihnúť |
| Super + V | Prilepiť |
| Super + Ctrl + V | História schránky |

_Všimnite si, že väčšina agentových nástrojov použije `Ctrl + V` na vkladanie obrázkov, ale `Super + V` na vkladanie textu._

### História schránky

Históriu schránky poskytuje shell Omarchy a funguje pre text aj obrázky. Spustíte ju pomocou `Super + Ctrl + V`, klávesou Enter vyberiete položku a tá sa umiestni do schránky pripravená na prilepenie pomocou `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

V histórii môžete vyhľadávať aj jednoducho tým, že začnete písať:

 ![clipboard-history-search](images/clipboard-history-search.webp)
