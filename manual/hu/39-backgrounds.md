# Hátterek

Minden téma saját háttérkészlettel érkezik, és a `~/.config/omarchy/backgrounds/[theme]` mappába saját extrákat is tehetsz. Ha például a nord témához szeretnél egy extra háttérképet hozzáadni, egyszerűen tedd a fájlt a `~/.config/omarchy/backgrounds/nord` mappába.

Ezt a legegyszerűbben úgy teheted meg, hogy az Omarchy Menu menüben a _Telepítés > Stílus > Háttér_ pontra mész. Ez megnyitja azt a mappát, ahol az adott téma hátterei találhatók. Nyomd meg a `Super + Shift + F` billentyűkombinációt egy másik fájlkezelő indításához, keresd meg a hátteredet, és másold át. Mostantól szerepelni fog a választható hátterek között, amelyek közül a `Super + Ctrl + W` billentyűkombinációval választhatsz.

A hátterek videók is lehetnek, nem csak állóképek. Dobj egy `mp4`, `m4v`, `mov`, `webm`, `mkv` vagy `avi` fájlt ugyanabba a mappába, és megjelenik a képek mellett. A videókat az OWE háttérkép-motor játssza le. A videót egyszer dekódolja az összes monitor számára, a hangját az alapértelmezett hangkimeneten játssza le, és leállítja a lejátszást, amikor semmi sem látja. Egy videós háttérkép így is sokkal több energiát fogyaszt, mint egy álló.

A témák tartalmazhatnak egy rövid intrót egy álló háttérhez. A `backgrounds/road.webp` esetén a hozzá tartozó videó a `backgrounds/intros/road.mp4` helyen található. Automatikusan lejátszódik rendszerindításkor, amikor olyan témára váltasz, amelynél ez a háttér van kiválasztva, és amikor kiválasztod ezt a hátteret, majd visszatér az állóképre. Az intróvideók nem jelennek meg a háttérválasztóban, és soha nem ismétlődnek.

A _Megjelenés > Animációk_ kikapcsolása a háttérintrókat is kikapcsolja. Az Omarchy ezt alapértelmezetten megteszi egy virtuális gépben. Az `omarchy theme bg intro toggle` paranccsal az intrók külön is ki- és bekapcsolhatók. Egy téma frissítése nem játszik le intrót.

Egy állóképnek loopja is lehet, ugyanannak a képnek egy csendes, folyamatosan mozgó változata, a `backgrounds/loops/road.mp4` helyen. Az állókép helyett játszódik le, az intrója után, ha van neki, és leáll, amikor kikapcsolod az animációkat. Akkumulátoros használatkor helyette az állókép jelenik meg, és a loop visszatér, amint csatlakoztatod a tápellátást. A loopok nem jelennek meg a háttérválasztóban.

Hatalmas, menő, gondosan válogatott hátterekből álló gyűjteményt találsz itt: [dharmx/walls](https://github.com/dharmx/walls).

A zárolási képernyő egy videós háttér álló képkockáját mutatja, ugyanúgy, ahogy egy animált GIF álló képkockáját is mutatja.
