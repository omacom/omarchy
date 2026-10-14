# Hátterek

Minden téma a saját háttérkészletével érkezik, és saját extrákat adhatsz hozzá a `~/.config/omarchy/backgrounds/[theme]` mappában. Ha mondjuk a nord témához akarsz extra háttérképet adni, csak tedd a fájlt a `~/.config/omarchy/backgrounds/nord` mappába.

Ezt a legkönnyebben úgy teheted meg, hogy az Omarchy menüben a _Telepítés > Stílus > Háttér_ pontra mész. Ez előhozza azt a mappát, ahol az adott téma hátterei vannak tárolva. Nyomd meg a `Super + Shift + F` kombinációt egy másik fájlkezelő indításához, keresd meg a háttered, és másold át. Mostantól benne lesz azokban a hátterekben, amelyek közül a `Super + Ctrl + Space` kombinációval választhatsz.

A hátterek videók is lehetnek, nem csak állóképek. Dobj egy `mp4`, `m4v`, `mov`, `webm`, `mkv` vagy `avi` fájlt ugyanabba a mappába, és megjelenik a képek mellett. A videókat az OWE háttérkép-motor játssza le. Egyszer dekódolja a videót minden monitorhoz, a hangját az alapértelmezett hangkimeneten játssza le, és leállítja a lejátszást, amikor semmi sem látja. A zárolási képernyő ugyanazt a dekódolást rajzolja, némítva, az OWE-n keresztül. Egy videós háttérkép még mindig sokkal több energiát fogyaszt, mint egy álló.

A témák tartalmazhatnak egy rövid bevezetőt egy álló háttérhez. A `backgrounds/road.webp` esetén a megfelelő videó a `backgrounds/intros/road.mp4` helyen él. Automatikusan lejátszódik rendszerindításkor és akkor, amikor egy olyan témára váltasz, amelynél ez a háttér van kiválasztva, majd visszatér az álló képhez. A bevezető videók kívül maradnak a háttérválasztón, és soha nem ismétlődnek.

Az _Indító > Megjelenés > Animációk_ kikapcsolása a háttér-bevezetőket is kikapcsolja. Az Omarchy ezt alapértelmezetten megteszi egy virtuális gépen. Az `omarchy theme bg intro toggle` parancs külön kapcsolhatja a bevezetőket. Egy téma frissítése vagy egy másik háttér kiválasztása ugyanazon a témán belül nem játszik le bevezetőt.

Hatalmas, szuper válogatott háttérgyűjteményt találsz itt: https://github.com/dharmx/walls.

A videós hátterek gyorsítótárazott állóképet tartanak a zárolási képernyőn, amíg a lejátszás szünetel vagy nem érhető el. Az animált GIF-ek az asztalon játszódnak le, és egy álló képkockát mutatnak a zárolási képernyőn.
