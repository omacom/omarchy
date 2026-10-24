# Hardvérová autentifikácia

### Autentifikácia odtlačkom prsta

Veľa notebookov má snímač odtlačkov prstov na autentifikáciu. V Omarchy ho môžeš použiť spustením _Nastavenie > Zabezpečenie > Odtlačok prsta_ v menu Omarchy (`Super + Space`).

Tým sa nainštaluje balík pre odtlačky prstov, nasníma sa tvoj odtlačok, overí sa a budeš môcť odtlačok prsta používať na odomykanie zo zamykacej obrazovky (ktorú vyvoláš stlačením `Super + Ctrl + L`), na vstup do režimu sudo a na autorizáciu systémových výziev.

Keď zamykacia obrazovka vypne displej, snímač odpočíva, aby šetril energiu, takže pred jeho dotykom prebuď obrazovku ľubovoľnou klávesou alebo touchpadom.

Keď je veko notebooku zatvorené, výzva na odtlačok prsta sa automaticky preskočí, takže prejdeš rovno na výzvu na zadanie hesla namiesto čakania na snímač, na ktorý nedočiahneš. Ak inak potrebuješ pracovať na externej klávesnici, ktorá snímač nemá, stačí stlačiť `CTRL + C`, keď ťa počas `sudo` vyzve na odtlačok prsta.

Autentifikáciu odtlačkom prsta môžeš odstrániť v menu Omarchy pod _Odstrániť > Zabezpečenie > Odtlačok prsta_.

### Autentifikácia Fido2

Ak používaš zariadenie Fido2, môžeš ho nastaviť na autentifikáciu pre `sudo` pomocou _Nastavenie > Zabezpečenie > Fido2_ v menu Omarchy (`Super + Space`). Vzťahuje sa však na výzvy pre `sudo` a systémovú autorizáciu, nie na odomykanie počítača.

Autentifikáciu fido2 môžeš odstrániť v menu Omarchy pod _Odstrániť > Zabezpečenie > Fido2_.
