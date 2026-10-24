# Sistemos miegas

Omarchy pagal numatytuosius įjungia pristabdymą ir užmigdymą, bet jei tavo kompiuteryje su kuriuo nors kyla problemų, gali juos išjungti.

### Maitinimo profiliai

Nešiojamajame kompiuteryje Omarchy tavo maitinimo profilį prisimena atskirai prijungtam prie tinklo ir veikiančiam nuo akumuliatoriaus, ir persijungia tarp jų, kai įjungi ir atjungi laidą. Iš karto tai reiškia našumą nuo tinklo ir subalansuotą nuo akumuliatoriaus.

Gali pamatyti, ką tavo kompiuteris siūlo, su `omarchy powerprofiles list`, ir nustatyti norimą tai būsenai, kurioje dabar esi, su `omarchy powerprofiles set autodetect power-saver`. Kad nustatytum kitą būseną nieko neatjungdamas, pavadink ją tiesiogiai: `omarchy powerprofiles set battery power-saver`. Kad ir ką pasirinksi, tai gausi atgal kitą kartą būdamas toje būsenoje.

### Pristabdymo perjungimas

Pristabdymą perjungi terminale paleidęs `omarchy toggle suspend`. Tai tiesiog parodo / paslepia parinktį po _Sistema_ (arba `Super + Esc`), ir tada gali pamatyti, ar tavo sistemoje ji veikia stabiliai. Jei ne, gali ją vėl paslėpti ta pačia komanda.

### Užmigdymo perjungimas

Užmigdymą nustatai terminale paleidęs `omarchy hibernation setup`. Užmigdymas sukuria /swap povolumį tavo įkrovos diske tavo fizinės RAM dydžio, todėl įsitikink, kad turi pakankamai laisvos vietos. 32GB kompiuteryje šiam volumiui visada reikės 32GB+ laisvų. Užmigdymui taip pat reikia numatytojo Limine įkroviklio.

Kai nustatysi, užmigdymo parinktį matysi po _Sistema_ (arba `Super + Esc`), ir tada gali pamatyti, ar tavo sistemoje ji veikia stabiliai. Jei ne, gali ją vėl pašalinti paleidęs `omarchy hibernation remove`.
