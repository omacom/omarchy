# Pozadia

Každá téma sa dodáva s vlastnou sadou pozadí a ďalšie vlastné si môžeš pridať do `~/.config/omarchy/backgrounds/[theme]`. Ak chceš pridať ďalší obrázok pozadia napríklad k téme nord, stačí vložiť súbor do `~/.config/omarchy/backgrounds/nord`.

Najjednoduchšie to urobíš cez _Install > Style > Background_ v Omarchy Menu. Otvorí sa ti priečinok, v ktorom sú uložené pozadia pre danú tému. Stlač `Super + Shift + F` na spustenie ďalšieho správcu súborov, nájdi svoje pozadie a skopíruj ho tam. Teraz bude zahrnuté medzi pozadiami, z ktorých si môžeš vyberať pomocou `Super + Ctrl + W`.

Pozadia môžu byť aj videá, nielen statické obrázky. Vlož do rovnakého priečinka súbor `mp4`, `m4v`, `mov`, `webm`, `mkv` alebo `avi` a objaví sa spolu s obrázkami. Videá prehráva OWE wallpaper engine. Video dekóduje raz pre všetky monitory a jeho zvuk prehráva cez predvolený audio výstup, a prehrávanie zastaví vždy, keď ho nič nevidí. Video pozadie stále spotrebúva oveľa viac energie ako statické.

Témy môžu obsahovať krátke intro pre statické pozadie. Pre `backgrounds/road.webp` sa zodpovedajúce video nachádza v `backgrounds/intros/road.mp4`. Prehrá sa automaticky pri štarte, pri prepnutí na tému s vybraným daným pozadím a pri výbere daného pozadia, a potom sa vráti k statickému obrázku. Intro videá sa nezobrazujú vo výbere pozadí a nikdy sa neopakujú v slučke.

Vypnutie _Appearance > Animations_ vypne aj intrá pozadí. Omarchy to robí predvolene vo virtuálnom stroji. Príkaz `omarchy theme bg intro toggle` dokáže intrá prepínať samostatne. Obnovenie témy intro neprehrá.

Obrovskú zbierku skvelých starostlivo vybraných pozadí nájdeš v [dharmx/walls](https://github.com/dharmx/walls).

Zamykacia obrazovka zobrazuje statický snímok video pozadia, rovnako ako zobrazuje statický snímok animovaného GIF.
