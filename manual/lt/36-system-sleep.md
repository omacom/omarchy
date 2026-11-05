# Sistemos miegas

Omarchy pagal numatytuosius nustatymus įjungia sustabdymą ir hibernaciją, bet jei jūsų kompiuteryje kyla problemų dėl kurio nors iš jų, galite juos išjungti.

NVIDIA GB10 kompiuteriuose, pavyzdžiui, DGX Spark ir ASUS Ascent GX10, sustabdymas ir hibernacija yra išjungti, kaip ir NVIDIA DGX OS, nes dar neparodyta, kad miego režimas veiktų šioje aparatinėje įrangoje. Sustabdymo perjungimas ir hibernacijos nustatymas ten netaikomi. Norėdami vėl įjungti miego režimą, pašalinkite `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` naudodami `sudo rm`; tada Sustabdymas grįš į meniu, o hibernaciją bus galima nustatyti kaip kituose kompiuteriuose. Paleidus `sudo omarchy apply hardware --install-user "$USER"`, failas bus vėl įdėtas atgal.

### Maitinimo profiliai

Nešiojamajame kompiuteryje Omarchy atskirai įsimena jūsų maitinimo profilį, kai kompiuteris prijungtas prie elektros tinklo ir kai veikia naudodamas akumuliatorių, ir perjungia juos, kai prijungiate ir atjungiate kompiuterį. Iš karto tai reiškia performance esant AC ir balanced naudojant akumuliatorių.

Galite peržiūrėti, ką siūlo jūsų kompiuteris, naudodami `omarchy powerprofiles list`, ir nustatyti norimą profilį dabartinei būsenai naudodami `omarchy powerprofiles set autodetect power-saver`. Norėdami nustatyti kitą būseną nieko neatjungdami, nurodykite ją tiesiogiai: `omarchy powerprofiles set battery power-saver`. Kad ir kurį pasirinktumėte, tokį patį gausite kitą kartą, kai būsite toje būsenoje.

### Sustabdymo perjungimas

Sustabdymą perjungiate paleisdami `omarchy toggle suspend` iš terminalo. Tai tik parodo arba paslepia parinktį skiltyje _System_ (arba `Super + Esc`), o tada galite patikrinti, ar ji nuosekliai veikia jūsų sistemoje. Jei ne, galite ją vėl paslėpti ta pačia komanda.

### Hibernacijos perjungimas

Hibernaciją nustatote paleisdami `omarchy hibernation setup` iš terminalo. Hibernacija jūsų įkrovos diske sukuria /swap potonį, kurio dydis lygus jūsų fizinės RAM apimčiai, todėl įsitikinkite, kad turite pakankamai laisvos vietos. 32GB kompiuteryje šiam tomui visada reikės 32GB+ laisvos vietos. Hibernacijai taip pat reikalinga numatytoji Limine įkrovos tvarkyklė.

Nustačius, hibernacijos parinktį matysite skiltyje _System_ (arba `Super + Esc`), o tada galėsite patikrinti, ar ji nuosekliai veikia jūsų sistemoje. Jei ne, galite ją vėl pašalinti paleisdami `omarchy hibernation remove`.
