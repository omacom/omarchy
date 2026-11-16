# Sistemos miegas

Omarchy pagal numatytuosius nustatymus įjungia pristabdymą ir hibernaciją, bet jei jūsų kompiuteryje su vienu iš jų kyla problemų, galite juos išjungti.

NVIDIA GB10 kompiuteriuose, pavyzdžiui, DGX Spark ir ASUS Ascent GX10, pristabdymas ir hibernacija yra išjungti, kaip ir NVIDIA DGX OS, nes dar neįrodyta, kad miego režimas toje aparatinėje įrangoje veikia. Tas pats galioja ASUS Zenbook A16 (UX3607OA), kuriame pristabdymas dar nevisiškai užmigdo lustą ir per naktį gali pakibti. Pristabdymo perjungimas ir hibernacijos sąranka ten negalioja. Norėdami vėl įjungti miego režimą, pašalinkite `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` naudodami `sudo rm`; tada Pristabdymas grįš į meniu, o hibernaciją galėsite nustatyti kaip ir kituose kompiuteriuose. Paleidus `sudo omarchy apply hardware --install-user "$USER"` failas bus atkurtas.

### Maitinimo profiliai

Nešiojamajame kompiuteryje Omarchy atskirai atsimena jūsų maitinimo profilį, kai kompiuteris prijungtas prie tinklo ir kai veikia iš baterijos, ir persijungia tarp jų, kai prijungiate arba atjungiate laidą. Pagal numatytuosius nustatymus tai reiškia našumo režimą naudojant AC ir subalansuotą režimą naudojant bateriją.

Matyti, ką siūlo jūsų kompiuteris, galite su `omarchy powerprofiles list`, o norimą profilį dabartinei būsenai nustatyti su `omarchy powerprofiles set autodetect power-saver`. Norėdami nustatyti kitą būseną nieko neatjungdami, nurodykite ją tiesiogiai: `omarchy powerprofiles set battery power-saver`. Kad ir ką pasirinktumėte, tą ir gausite kitą kartą būdami toje būsenoje.

### Pristabdymo perjungimas

Pristabdymą perjungsite paleidę `omarchy toggle suspend` terminale. Tai tiesiog parodo / paslepia parinktį meniu _Sistema_ (arba `Super + Esc`), ir tada galėsite patikrinti, ar ji jūsų sistemoje veikia patikimai. Jei ne, ta pačia komanda galėsite ją vėl paslėpti.

### Hibernacijos perjungimas

Hibernaciją nustatysite paleidę `omarchy hibernation setup` terminale. Hibernacija sukuria /swap subtomą jūsų įkrovos diske, kurio dydis lygus jūsų fizinės RAM apimčiai, todėl įsitikinkite, kad turite pakankamai laisvos vietos. 32GB kompiuteryje šiam tomui visada reikės 32GB+ laisvos vietos. Hibernacijai taip pat reikalinga numatytoji Limine įkrovos tvarkyklė.

Nustačius matysite hibernacijos parinktį meniu _Sistema_ (arba `Super + Esc`), ir tada galėsite patikrinti, ar ji jūsų sistemoje veikia patikimai. Jei ne, galėsite ją vėl pašalinti paleidę `omarchy hibernation remove`.
