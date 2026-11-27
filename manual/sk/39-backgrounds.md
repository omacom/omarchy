# Pozadia

Každá téma sa dodáva s vlastnou sadou pozadí a svoje vlastné si môžete pridať do `~/.config/omarchy/backgrounds/[theme]`. Ak chcete pridať ďalší obrázok pozadia napríklad do témy nord, jednoducho umiestnite súbor do `~/.config/omarchy/backgrounds/nord`.

Najjednoduchšie to urobíte tak, že v Menu Omarchy prejdete na _Inštalovať > Štýl > Pozadie_. Otvorí sa priečinok, v ktorom sú uložené pozadia pre danú tému. Stlačením `Super + Shift + F` spustíte ďalší správca súborov, nájdete svoje pozadie a skopírujete ho tam. Teraz bude zahrnuté medzi pozadiami, medzi ktorými môžete prepínať pomocou `Super + Ctrl + W`.

Téma, ktorá nemá žiadne vlastné pozadia, dostane jedno vykreslené zo svojich farieb: logo Omarchy v akcentovej farbe témy na jej farbe pozadia. Pridajte si vlastné a nahraďte ho.

Pozadia môžu byť aj videá, nielen statické obrázky. Vložte do rovnakého priečinka súbor `mp4`, `m4v`, `mov`, `webm`, `mkv` alebo `avi` a zobrazí sa popri obrázkoch. Videá prehráva tapetový engine OWE. Video dekóduje raz pre všetky monitory a jeho zvuk prehráva cez predvolený zvukový výstup, a prehrávanie zastaví vždy, keď ho nič nevidí. Video pozadie stále spotrebúva oveľa viac energie než statické.

Témy môžu obsahovať krátke intro pre statické pozadie. Pre `backgrounds/road.webp` sa zodpovedajúce video nachádza v `backgrounds/intros/road.mp4`. Prehrá sa automaticky pri spustení systému, pri prepnutí na tému s vybraným daným pozadím a pri výbere daného pozadia, a potom sa vráti na statický obrázok. Intro videá sa nezobrazujú vo výbere pozadí a nikdy sa neopakujú v slučke.

Výberom _Vzhľad > Animácie vypnuté_ sa vypnú aj intrá pozadí. Omarchy to robí predvolene vo virtuálnom stroji. Príkaz `omarchy theme bg intro toggle` dokáže intrá prepínať samostatne. Obnovenie témy intro neprehrá.

Statický obrázok môže mať aj slučku, tichú verziu toho istého obrázka, ktorá sa stále hýbe, v `backgrounds/loops/road.mp4`. Prehráva sa namiesto statického obrázka, po jeho intre, ak nejaké má, a zastaví sa, keď sa animácie vypnú. Pri napájaní z batérie sa namiesto toho zobrazí statický obrázok a slučka sa vráti, keď zariadenie pripojíte k napájaniu. Slučky sa nezobrazujú vo výbere pozadí.

Obrovskú kolekciu skvelých starostlivo vybraných pozadí nájdete v [dharmx/walls](https://github.com/dharmx/walls).

Uzamknutá obrazovka zobrazuje statický snímok video pozadia, rovnako ako zobrazuje statický snímok animovaného GIFu.
