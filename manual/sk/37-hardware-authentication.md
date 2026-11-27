# Hardvérová autentifikácia

### Overovanie odtlačkom prsta

Mnoho notebookov má snímač odtlačkov prstov na overovanie. V Omarchy ho môžete použiť spustením _Setup > Security > Fingerprint_ v ponuke Omarchy (`Super + Space`).

Otvorí sa odtlačok prsta na celú obrazovku, ktorý sa postupne zapĺňa, ako sa dotýkate snímača. Omarchy medzitým nainštaluje balík pre odtlačky prstov, zaznamená váš odtlačok, overí ho a budete pripravení používať svoj odtlačok prsta na odomykanie zo zamknutej obrazovky (ktorú môžete vyvolať pomocou `Super + Ctrl + L`), na vstup do režimu sudo a na autorizáciu systémových výziev.

Keď zamknutá obrazovka vypne displej, snímač odpočíva, aby šetril energiu, takže pred dotykom snímača zobuďte obrazovku ľubovoľnou klávesou alebo touchpadom.

Keď je veko notebooku zatvorené, výzva na odtlačok prsta sa automaticky preskočí, takže prejdete rovno na výzvu na zadanie hesla namiesto čakania na snímač, ku ktorému sa nedostanete. Ak inak potrebujete pracovať na externej klávesnici, ktorá snímač nemá, pri výzve na odtlačok prsta počas `sudo` jednoducho stlačte `CTRL + C`.

Overovanie odtlačkom prsta môžete odstrániť v ponuke Omarchy pod _Remove > Security > Fingerprint_.

### Overovanie pomocou Fido2

Ak používate zariadenie Fido2, môžete ho nastaviť na overovanie `sudo` pomocou _Setup > Security > Fido2_ v ponuke Omarchy (`Super + Space`). Pokrýva však výzvy `sudo` a systémovej autorizácie, nie odomykanie počítača.

Overovanie fido2 môžete odstrániť v ponuke Omarchy pod _Remove > Security > Fido2_.
