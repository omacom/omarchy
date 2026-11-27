# Sistemos miegas

Omarchy pagal numatytuosius nustatymus įjungia pristabdymą, o hibernaciją – kai ji sukonfigūruota, bet jei kuri nors iš šių funkcijų jūsų kompiuteryje kelia problemų, galite jas išjungti.

NVIDIA GB10 kompiuteriuose, tokiuose kaip DGX Spark ir ASUS Ascent GX10, pristabdymas ir hibernacija yra išjungti, kaip ir NVIDIA DGX OS, nes dar neįrodyta, kad miegas šioje aparatinėje įrangoje veikia. Pristabdymo perjungimas ir hibernacijos sąranka ten netaikomi. Norėdami vėl įjungti miegą, su `sudo rm` pašalinkite `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`; tada į meniu grįš pristabdymas, o hibernaciją galėsite sukonfigūruoti kaip ir kituose kompiuteriuose. Paleidus `sudo omarchy apply hardware --install-user "$USER"`, failas bus grąžintas.

### Maitinimo profiliai

Nešiojamajame kompiuteryje Omarchy atskirai įsimena jūsų maitinimo profilį, kai kompiuteris prijungtas prie maitinimo ir kai veikia naudodamas akumuliatorių, ir perjungia tarp šių dviejų profilių, kai prijungiate ir atjungiate maitinimą. Iš karto tai reiškia našumą esant AC ir subalansuotą režimą naudojant akumuliatorių.

Galite pamatyti, ką siūlo jūsų kompiuteris, su `omarchy powerprofiles list`, o norimą profilį dabartinei būsenai nustatyti su `omarchy powerprofiles set autodetect power-saver`. Norėdami nustatyti kitą būseną nieko neatjungdami, nurodykite ją tiesiogiai: `omarchy powerprofiles set battery power-saver`. Kad ir ką pasirinksite, tą ir gausite kitą kartą, kai būsite toje būsenoje.

### Pristabdymo perjungimas

Pristabdymą perjungiate paleisdami `omarchy toggle suspend` iš terminalo. Tai tik parodo arba paslepia parinktį skiltyje _Sistema_ (arba `Super + Esc`), o tada galite patikrinti, ar ji jūsų sistemoje veikia nuosekliai. Jei ne, galite ją vėl paslėpti ta pačia komanda.

### Hibernacijos perjungimas

Hibernaciją sukonfigūruojate paleisdami `omarchy hibernation setup` iš terminalo (Apple Silicon Mac kompiuteriuose ji negalima). Hibernacija jūsų įkrovos diske sukuria /swap subtomą, kurio dydis lygus jūsų fizinės RAM apimčiai, todėl įsitikinkite, kad turite pakankamai laisvos vietos. 32GB kompiuteryje šiam tomui visada reikės 32GB+ laisvos vietos. Hibernacijai taip pat reikalinga numatytoji Limine įkrovos tvarkyklė.

Kai hibernacija sukonfigūruota, jos parinktį matysite skiltyje _Sistema_ (arba `Super + Esc`), o tada galite patikrinti, ar ji jūsų sistemoje veikia nuosekliai. Jei ne, galite ją vėl pašalinti paleisdami `omarchy hibernation remove`.
