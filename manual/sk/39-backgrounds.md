# Pozadia

Každá téma sa dodáva s vlastnou sadou pozadí a môžete si pridať ďalšie vlastné do `~/.config/omarchy/backgrounds/[theme]`. Ak chcete pridať ďalší obrázok pozadia napríklad do témy nord, jednoducho vložte súbor do `~/.config/omarchy/backgrounds/nord`.

Najjednoduchšie to urobíte tak, že v Omarchy Menu prejdete na _Inštalovať > Štýl > Pozadie_. Otvorí sa priečinok, v ktorom sú uložené pozadia pre danú tému. Stlačte `Super + Shift + F`, čím otvoríte ďalšieho správcu súborov, nájdite svoje pozadie a skopírujte ho tam. Teraz bude zahrnuté medzi pozadiami, medzi ktorými môžete prepínať pomocou `Super + Ctrl + W`.

Pozadia môžu byť videá aj statické obrázky. Vložte do rovnakého priečinka súbor `mp4`, `m4v`, `mov`, `webm`, `mkv` alebo `avi` a zobrazí sa spolu s obrázkami. Videá prehráva engine pozadí OWE. Video dekóduje raz pre všetky monitory, jeho zvuk prehráva cez predvolený zvukový výstup a prehrávanie zastaví vždy, keď ho nič nemôže vidieť. Videopozadie stále spotrebúva oveľa viac energie ako statické.

Témy môžu obsahovať krátke intro pre statické pozadie. Pre `backgrounds/road.webp` sa zodpovedajúce video nachádza na `backgrounds/intros/road.mp4`. Prehrá sa automaticky pri spustení systému a pri prepnutí na tému s vybratým týmto pozadím, potom sa vráti späť na statický obrázok. Videá intier sa nezobrazujú vo výbere pozadí a nikdy sa nehrajú v slučke.

Vypnutie _Vzhľad > Animácie_ vypne aj intrá pozadí. Omarchy to vo virtuálnom počítači robí predvolene. Príkaz `omarchy theme bg intro toggle` dokáže intrá prepínať samostatne. Obnovenie témy ani výber iného pozadia v rámci tej istej témy intro neprehrá.

Obrovskú zbierku skvelých, starostlivo vybraných pozadí nájdete v [dharmx/walls](https://github.com/dharmx/walls).

Uzamknutá obrazovka zobrazuje statický záber videopozadia, rovnako ako zobrazuje statický záber animovaného GIF.
