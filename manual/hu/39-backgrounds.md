# Hátterek

Minden téma saját hátterkészlettel érkezik, és a `~/.config/omarchy/backgrounds/[theme]` mappában saját extrákat is hozzáadhatsz. Ha például a nord témához szeretnél egy extra háttérképet adni, csak tedd be a fájlt a `~/.config/omarchy/backgrounds/nord` mappába.

Ezt a legegyszerűbben az Omarchy menü _Telepítés > Stílus > Háttér_ menüpontjával teheted meg. Ez előhozza azt a mappát, ahol az adott téma háttereit tárolja a rendszer. Nyomd meg a `Super + Shift + F` billentyűkombinációt egy másik fájlkezelő indításához, keresd meg a hátteredet, és másold át. Mostantól szerepelni fog a választható hátterek között, amelyek között a `Super + Ctrl + W` billentyűkombinációval válthatsz.

A hátterek videók is lehetnek, nem csak állóképek. Dobj egy `mp4`, `m4v`, `mov`, `webm`, `mkv` vagy `avi` fájlt ugyanabba a mappába, és megjelenik a képek mellett. A videókat az OWE háttérképmotor játssza le. Egyszer dekódolja a videót az összes monitorhoz, a hangját az alapértelmezett hangkimeneten játssza le, és leállítja a lejátszást, amikor semmi sem láthatja. Egy videós háttérkép még így is sokkal több energiát fogyaszt, mint egy állókép.

A témák tartalmazhatnak egy rövid intrót egy álló háttérhez. A `backgrounds/road.webp` esetében a hozzá tartozó videó a `backgrounds/intros/road.mp4` helyen található. Automatikusan lejátszódik rendszerindításkor, amikor olyan témára váltasz, amelynél ez a háttér van kiválasztva, és amikor kiválasztod azt a hátteret, majd visszatér az állóképhez. Az intróvideók nem jelennek meg a háttérválasztóban, és soha nem ismétlődnek.

A _Megjelenés > Animációk ki_ választása a háttérintrókat is kikapcsolja. Az Omarchy ezt alapértelmezés szerint megteszi egy virtuális gépben. Az `omarchy theme bg intro toggle` paranccsal az intrókat külön is ki- és bekapcsolhatod. A téma frissítése nem játszik le intrót.

Egy állóképhez tartozhat egy loop is, ugyanannak a képnek egy visszafogott, folyamatosan mozgó változata a `backgrounds/loops/road.mp4` helyen. Az állókép helyén játszódik le, az intrója után, ha van neki, és leáll, amikor kikapcsolod az animációkat. Akkumulátoron helyette az állókép jelenik meg, és a loop visszatér, amint újra tápellátásra kötöd a gépet. A loopok nem jelennek meg a háttérválasztóban.

Hatalmas, menő, gondosan összeválogatott hátterekből álló gyűjteményt találsz itt: [dharmx/walls](https://github.com/dharmx/walls).

A zárolási képernyő egy videós háttér állóképét mutatja, ugyanúgy, ahogyan egy animált GIF állóképét is mutatja.
