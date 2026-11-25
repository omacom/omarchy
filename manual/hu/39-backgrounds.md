# Hátterek

Minden téma saját háttérkészlettel érkezik, és te is hozzáadhatsz saját extrákat a `~/.config/omarchy/backgrounds/[theme]` mappába. Ha például a nord témához szeretnél egy extra háttérképet hozzáadni, egyszerűen tedd a fájlt a `~/.config/omarchy/backgrounds/nord` mappába.

Ezt a legkönnyebben úgy teheted meg, hogy az Omarchy Menu menüben a _Telepítés > Stílus > Háttér_ pontra mész. Ez megnyitja azt a mappát, ahol az adott téma hátterei vannak tárolva. Nyomd meg a `Super + Shift + F` billentyűkombinációt egy másik fájlkezelő indításához, keresd meg a hátteredet, és másold át. Mostantól szerepelni fog a választható hátterek között, amelyek közül a `Super + Ctrl + W` billentyűkombinációval választhatsz.

Egy olyan téma, amelynek nincsenek saját hátterei, a színeiből rajzolt hátteret kap: az Omarchy logót a téma kiemelő színével a háttér színén. Adj hozzá sajátot, hogy lecseréld.

A hátterek videók is lehetnek, nem csak állóképek. Dobj egy `mp4`, `m4v`, `mov`, `webm`, `mkv` vagy `avi` fájlt ugyanabba a mappába, és megjelenik a képek mellett. A videókat az OWE wallpaper engine játssza le. Egyszer dekódolja a videót az összes monitor számára, a hangját az alapértelmezett hangkimeneten keresztül játssza le, és leállítja a lejátszást, amikor semmi sem láthatja. A videós háttérkép így is sokkal több energiát fogyaszt, mint egy állóképes.

A témák tartalmazhatnak rövid intrót egy álló háttérhez. A `backgrounds/road.webp` esetében a hozzá tartozó videó a `backgrounds/intros/road.mp4` helyen található. Automatikusan lejátszódik indításkor, amikor olyan témára váltasz, amelynél ez a háttér van kiválasztva, és amikor kiválasztod az adott hátteret, majd visszatér az állóképhez. Az intróvideók nem jelennek meg a háttérválasztóban, és soha nem ismétlődnek.

A _Megjelenés > Animációk ki_ kiválasztása a háttérintrókat is kikapcsolja. Az Omarchy ezt alapértelmezetten megteszi virtuális gépben. Az `omarchy theme bg intro toggle` parancs külön kapcsolhatja az intrókat. Egy téma frissítése nem játszik le intrót.

Egy állóképnek loopja is lehet, ugyanannak a képnek egy halk, folyamatosan mozgó változata, a `backgrounds/loops/road.mp4` helyen. Az állókép helyett játszódik le, az intrója után, ha van neki, és leáll, amikor az animációk ki vannak kapcsolva. Akkumulátorról helyette az állókép jelenik meg, a loop pedig visszatér, amint csatlakoztatod a gépet. A loopok nem jelennek meg a háttérválasztóban.

Hatalmas, gondosan összeválogatott, menő hátterekből álló gyűjteményt találsz a [dharmx/walls](https://github.com/dharmx/walls) oldalon.

A zárolási képernyő egy videós háttér álló képkockáját mutatja, ugyanúgy, ahogyan egy animált GIF álló képkockáját mutatja.
