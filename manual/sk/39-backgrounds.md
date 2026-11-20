# Pozadia

Každá téma sa dodáva s vlastnou sadou pozadí a ďalšie vlastné si môžete pridať do `~/.config/omarchy/backgrounds/[theme]`. Ak chcete pridať ďalší obrázok pozadia napríklad do témy nord, jednoducho vložíte súbor do `~/.config/omarchy/backgrounds/nord`.

Najjednoduchšie to urobíte tak, že v ponuke Omarchy Menu prejdete na _Install > Style > Background_. Otvorí sa priečinok, v ktorom sú uložené pozadia pre danú tému. Stlačte `Super + Shift + F` na spustenie ďalšieho správcu súborov, nájdite svoje pozadie a skopírujte ho tam. Teraz bude zahrnuté medzi pozadiami, ktoré môžete vyberať pomocou `Super + Ctrl + W`.

Pozadia môžu byť aj videá, nielen statické obrázky. Vložte do rovnakého priečinka súbor `mp4`, `m4v`, `mov`, `webm`, `mkv` alebo `avi` a zobrazí sa popri obrázkoch. Videá prehráva wallpaper engine OWE. Video dekóduje raz pre všetky monitory a jeho zvuk prehráva cez predvolený zvukový výstup a prehrávanie zastaví vždy, keď ho nič nevidí. Videopozadie stále spotrebúva oveľa viac energie ako statické pozadie.

Témy môžu obsahovať krátke intro pre statické pozadie. Pre `backgrounds/road.webp` sa zodpovedajúce video nachádza na `backgrounds/intros/road.mp4`. Prehrá sa automaticky pri spustení systému, pri prepnutí na tému s vybraným daným pozadím a pri výbere daného pozadia, a potom sa vráti k statickému obrázku. Introvideá sa nezobrazujú vo výbere pozadí a nikdy sa neopakujú v slučke.

Vypnutie _Appearance > Animations_ vypne aj intrá pozadí. Omarchy to robí predvolene vo virtuálnom počítači. Príkaz `omarchy theme bg intro toggle` môže intrá prepínať samostatne. Obnovenie témy intro neprehrá.

Statický obrázok môže mať aj slučku, tichú verziu toho istého obrázka, ktorá sa stále pohybuje, na `backgrounds/loops/road.mp4`. Prehráva sa namiesto statického obrázka, po jeho intre, ak nejaké má, a zastaví sa, keď sú animácie vypnuté. Slučky sa nezobrazujú vo výbere pozadí a, ako každé videopozadie, spotrebúvajú viac energie ako statický obrázok.

Obrovskú zbierku skvelých starostlivo vybraných pozadí nájdete v [dharmx/walls](https://github.com/dharmx/walls).

Na uzamknutej obrazovke sa zobrazuje statický snímok videopozadia, rovnako ako sa zobrazuje statický snímok animovaného GIF-u.
