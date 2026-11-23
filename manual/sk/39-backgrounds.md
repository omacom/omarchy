# Pozadia

Každá téma sa dodáva s vlastnou sadou pozadí a ďalšie vlastné si môžete pridať do `~/.config/omarchy/backgrounds/[theme]`. Ak chcete pridať extra obrázok pozadia napríklad do témy nord, stačí vložiť súbor do `~/.config/omarchy/backgrounds/nord`.

Najľahšie to urobíte tak, že v Omarchy Menu prejdete na _Install > Style > Background_. Otvorí sa vám priečinok, kde sú uložené pozadia pre danú tému. Stlačte `Super + Shift + F`, čím spustíte ďalší správca súborov, nájdite svoje pozadie a skopírujte ho tam. Teraz bude zahrnuté medzi pozadiami, medzi ktorými môžete vyberať pomocou `Super + Ctrl + W`.

Pozadia môžu byť videá aj statické obrázky. Vhoďte do toho istého priečinka súbor `mp4`, `m4v`, `mov`, `webm`, `mkv` alebo `avi` a objaví sa vedľa obrázkov. Videá prehráva engine pozadí OWE. Dekóduje video raz pre všetky monitory a jeho zvuk prehráva cez predvolený zvukový výstup a prehrávanie zastaví vždy, keď ho nie je vidieť. Videopozadie napriek tomu spotrebúva oveľa viac energie ako statické pozadie.

Témy môžu obsahovať krátke intro pre statické pozadie. Pre `backgrounds/road.webp` sa zodpovedajúce video nachádza na `backgrounds/intros/road.mp4`. Automaticky sa prehrá pri spustení systému, pri prepnutí na tému s vybraným týmto pozadím a pri výbere tohto pozadia, potom sa vráti na statický obrázok. Introvideá sa nezobrazujú vo výbere pozadí a nikdy sa neopakujú v slučke.

Výberom _Appearance > Animations Off_ sa vypnú aj intrá pozadí. Omarchy to vo virtuálnom stroji robí predvolene. Príkazom `omarchy theme bg intro toggle` môžete intrá prepínať samostatne. Obnovenie témy intro neprehrá.

Statický obrázok môže mať aj slučku, pokojnú verziu toho istého obrázka, ktorá sa stále hýbe, na `backgrounds/loops/road.mp4`. Prehráva sa namiesto statického obrázka, po jeho intre, ak ho má, a zastaví sa, keď sú animácie vypnuté. Pri napájaní z batérie sa namiesto nej zobrazuje statický obrázok a slučka sa vráti, hneď ako zariadenie pripojíte k napájaniu. Slučky sa nezobrazujú vo výbere pozadí.

Obrovskú zbierku skvelých starostlivo vybraných pozadí nájdete v [dharmx/walls](https://github.com/dharmx/walls).

Uzamknutá obrazovka zobrazuje statický záber videopozadia, rovnako ako zobrazuje statický záber animovaného GIF.
