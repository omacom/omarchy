# Pozadia

Každá téma sa dodáva s vlastnou sadou pozadí a vy si môžete pridať vlastné do `~/.config/omarchy/backgrounds/[theme]`. Ak chcete pridať ďalší obrázok pozadia napríklad do témy nord, stačí vložiť súbor do `~/.config/omarchy/backgrounds/nord`.

Najjednoduchšie to urobíte tak, že prejdete do časti _Inštalovať > Style > Background_ v ponuke Omarchy. Tým sa otvorí priečinok, v ktorom sú uložené pozadia pre danú tému. Stlačte `Super + Shift + F`, ak chcete spustiť ďalší správca súborov, nájdite svoje pozadie a skopírujte ho tam.  Teraz bude zahrnuté medzi pozadiami, medzi ktorými môžete vyberať skratkou `Super + Ctrl + Space`.

Pozadia môžu byť videá aj statické obrázky. Vložte súbor `mp4`, `m4v`, `mov`, `webm`, `mkv` alebo `avi` do rovnakého priečinka a zobrazí sa vedľa obrázkov. Videá prehráva nástroj na tapety OWE. Dekóduje video raz pre všetky monitory a prehráva jeho zvuk cez predvolený zvukový výstup a zastaví prehrávanie vždy, keď ho nič nevidí. Zamknutá obrazovka kreslí to isté dekódované video, stlmené, cez OWE. Video tapeta stále stojí oveľa viac energie než statická tapeta.

Témy môžu obsahovať krátky úvod pre statické pozadie. Pre `backgrounds/road.webp` sa zodpovedajúce video nachádza na `backgrounds/intros/road.mp4`. Prehrá sa automaticky pri zavádzaní a pri prepnutí na tému s vybraným týmto pozadím a potom sa vráti na statický obrázok. Úvodné videá zostávajú mimo výberu pozadia a nikdy sa neopakujú v slučke.

Vypnutie možnosti _Akcie > Vzhľad > Animácie_ vypne aj úvody pozadí. Omarchy to predvolene robí vo virtuálnom stroji. Príkaz `omarchy theme bg intro toggle` môže úvody prepínať samostatne. Obnovenie témy alebo výber iného pozadia v rámci tej istej témy úvod neprehrá.

Obrovskú zbierku skvelých vybraných pozadí nájdete na https://github.com/dharmx/walls.

Videopozadia si na zamknutej obrazovke ponechávajú uložený statický obrázok, kým je prehrávanie pozastavené alebo nedostupné. Animované súbory GIF sa prehrávajú na pracovnej ploche a na zamknutej obrazovke zobrazujú statický snímok.
