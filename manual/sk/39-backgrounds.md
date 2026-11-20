# Pozadia

Každá téma sa dodáva s vlastnou sadou pozadí a vlastné ďalšie si môžete pridať do `~/.config/omarchy/backgrounds/[theme]`. Ak chcete pridať ďalšie obrázkové pozadie napríklad do témy nord, jednoducho vložte súbor do `~/.config/omarchy/backgrounds/nord`.

Najjednoduchšie to urobíte tak, že v ponuke Omarchy Menu prejdete na _Install > Style > Background_. Tým sa otvorí priečinok, v ktorom sú uložené pozadia pre danú tému. Stlačením `Super + Shift + F` spustíte ďalší správca súborov, nájdete svoje pozadie a skopírujete ho sem.  Teraz bude zahrnuté medzi pozadiami, z ktorých si môžete vyberať pomocou `Super + Ctrl + W`.

Pozadia môžu byť videá aj statické obrázky. Vložte súbor `mp4`, `m4v`, `mov`, `webm`, `mkv` alebo `avi` do rovnakého priečinka a zobrazí sa spolu s obrázkami. Videá prehráva engine pozadí OWE. Video dekóduje raz pre všetky monitory, jeho zvuk prehráva cez predvolený zvukový výstup a prehrávanie zastaví vždy, keď ho nič nevidí. Videopozadie stále spotrebúva oveľa viac energie ako statické.

Témy môžu obsahovať krátke intro pre statické pozadie. Pre `backgrounds/road.webp` sa zodpovedajúce video nachádza na adrese `backgrounds/intros/road.mp4`. Prehrá sa automaticky pri štarte, pri prepnutí na tému s vybraným týmto pozadím a pri výbere tohto pozadia, a potom sa vráti na statický obrázok. Introvideá sa nezobrazujú vo výbere pozadí a nikdy sa neopakujú v slučke.

Vypnutím _Appearance > Animations_ vypnete aj intrá pozadí. Omarchy to vo virtuálnom počítači robí predvolene. Príkazom `omarchy theme bg intro toggle` môžete intrá prepínať samostatne. Obnovenie témy intro neprehrá.

Statický obrázok môže mať aj slučku, pokojnú verziu toho istého obrázka, ktorá sa stále hýbe, na adrese `backgrounds/loops/road.mp4`. Prehráva sa namiesto statického obrázka, po jeho intre, ak nejaké má, a zastaví sa, keď sú animácie vypnuté. Pri napájaní z batérie sa namiesto nej zobrazuje statický obrázok a slučka sa vráti, keď zariadenie pripojíte k napájaniu. Slučky sa nezobrazujú vo výbere pozadí.

Obrovskú zbierku skvelých starostlivo vybraných pozadí nájdete v [dharmx/walls](https://github.com/dharmx/walls).

Uzamknutá obrazovka zobrazuje statický snímok videopozadia, rovnako ako zobrazuje statický snímok animovaného GIF-u.
