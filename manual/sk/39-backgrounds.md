# Pozadia

Každá téma sa dodáva s vlastnou sadou pozadí a ďalšie vlastné si môžete pridať do `~/.config/omarchy/backgrounds/[theme]`. Ak chcete pridať ďalší obrázok pozadia napríklad k téme nord, jednoducho vložíte súbor do `~/.config/omarchy/backgrounds/nord`.

Najjednoduchšie to urobíte tak, že v Omarchy Menu prejdete na _Install > Style > Background_. Tým sa otvorí priečinok, v ktorom sú uložené pozadia pre danú tému. Stlačte `Super + Shift + F`, čím spustíte ďalší správca súborov, nájdite svoje pozadie a skopírujte ho tam. Teraz bude súčasťou ponuky pozadí, medzi ktorými môžete vyberať pomocou `Super + Ctrl + W`.

Pozadia môžu byť videá aj statické obrázky. Vložte súbor `mp4`, `m4v`, `mov`, `webm`, `mkv` alebo `avi` do rovnakého priečinka a zobrazí sa spolu s obrázkami. Videá prehráva engine tapiet OWE. Dekóduje video raz pre všetky monitory a prehráva jeho zvuk cez predvolený zvukový výstup a zastaví prehrávanie vždy, keď ho nič nevidí. Video pozadie stále spotrebúva oveľa viac energie ako statické.

Témy môžu obsahovať krátke intro pre statické pozadie. Pre `backgrounds/road.webp` sa zodpovedajúce video nachádza v `backgrounds/intros/road.mp4`. Prehrá sa automaticky pri spustení a pri prepnutí na tému s vybratým daným pozadím, potom sa vráti na statický obrázok. Intro videá sa nezobrazujú vo výbere pozadí a nikdy sa neopakujú v slučke.

Vypnutie _Appearance > Animations_ vypne aj intrá pozadí. Omarchy to vo virtuálnom počítači robí predvolene. Príkaz `omarchy theme bg intro toggle` môže intrá prepínať samostatne. Obnovenie témy alebo výber iného pozadia v rámci tej istej témy intro neprehrá.

Obrovskú zbierku skvelých starostlivo vybraných pozadí nájdete na https://github.com/dharmx/walls.

Uzamknutá obrazovka zobrazuje statický snímok video pozadia, rovnako ako zobrazuje statický snímok animovaného GIF.
