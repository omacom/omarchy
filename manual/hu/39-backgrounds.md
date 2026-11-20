# Hátterek

Minden téma a saját háttérkészletével érkezik, és a saját extra háttereidet is hozzáadhatod a `~/.config/omarchy/backgrounds/[theme]` mappába. Ha mondjuk a nord témához szeretnél egy extra háttérképet adni, egyszerűen csak tedd a fájlt a `~/.config/omarchy/backgrounds/nord` mappába.

Ezt a legegyszerűbben az Omarchy Menu _Telepítés > Stílus > Háttér_ menüpontjába lépve teheted meg. Ez megnyitja azt a mappát, ahol az adott téma háttereit tárolja a rendszer. Nyomd meg a `Super + Shift + F` billentyűkombinációt egy másik fájlkezelő indításához, keresd meg a hátteredet, és másold át. Mostantól szerepelni fog a választható hátterek között, amelyek közül a `Super + Ctrl + W` billentyűkombinációval választhatsz.

A hátterek videók is lehetnek, nem csak állóképek. Dobj egy `mp4`, `m4v`, `mov`, `webm`, `mkv` vagy `avi` fájlt ugyanabba a mappába, és megjelenik a képek mellett. A videókat az OWE wallpaper engine játssza le. Egyszer dekódolja a videót az összes monitor számára, a hangját az alapértelmezett hangkimeneten játssza le, és leállítja a lejátszást, amikor semmi sem láthatja. Egy videós háttérkép még így is jóval több energiát fogyaszt, mint egy álló.

A témák tartalmazhatnak egy rövid intrót egy álló háttérhez. A `backgrounds/road.webp` esetében a hozzá tartozó videó a `backgrounds/intros/road.mp4` helyen található. Automatikusan lejátszódik rendszerindításkor, amikor olyan témára váltasz, amelynél ez a háttér van kiválasztva, és amikor kiválasztod az adott hátteret, majd visszatér az állóképre. Az intróvideók nem jelennek meg a háttérválasztóban, és soha nem ismétlődnek.

A _Megjelenés > Animációk_ kikapcsolása a háttérintrókat is kikapcsolja. Az Omarchy ezt alapértelmezetten megteszi egy virtuális gépen. Az `omarchy theme bg intro toggle` parancs külön is ki- és bekapcsolhatja az intrókat. Egy téma frissítése nem játszik le intrót.

Egy állóképnek loopja is lehet, ugyanannak a képnek egy visszafogott, folyamatosan mozgó változata a `backgrounds/loops/road.mp4` helyen. Az állókép helyén játszódik le, az intrója után, ha van neki, és leáll, amikor az animációk ki vannak kapcsolva. A loopok nem jelennek meg a háttérválasztóban, és mint minden videós háttér, több energiát fogyasztanak, mint egy állókép.

Hatalmas, gondosan összeválogatott, menő háttérgyűjteményt találsz itt: [dharmx/walls](https://github.com/dharmx/walls).

A zárolási képernyő egy videós háttér álló képkockáját mutatja, ugyanúgy, ahogyan egy animált GIF álló képkockáját is mutatja.
