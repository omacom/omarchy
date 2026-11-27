# Sistemos miegas

Omarchy pagal numatytuosius nustatymus įjungia pristabdymą, o sukonfigūravus – ir sulaikytąją veikseną, bet jei jūsų kompiuteryje kyla problemų dėl kurio nors iš jų, galite juos išjungti.

Kompiuteriuose su NVIDIA GB10, tokiuose kaip DGX Spark ir ASUS Ascent GX10, pristabdymas ir sulaikytoji veiksena yra išjungti, kaip ir NVIDIA DGX OS, nes dar neįrodyta, kad miego režimas veiktų šioje aparatinėje įrangoje. Tas pats galioja ir ASUS Zenbook A16 (UX3607OA), kuriame pristabdymas dar neperjungia lusto į visišką miego režimą ir gali užstrigti per naktį. Pristabdymo jungiklis ir sulaikytosios veiksenos sąranka ten netaikomi. Norėdami vėl įjungti miego režimą, pašalinkite `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` naudodami `sudo rm`; tada Suspend vėl atsiras meniu, o sulaikytąją veikseną bus galima nustatyti kaip ir kituose kompiuteriuose. Paleidus `sudo omarchy apply hardware --install-user "$USER"`, failas bus atkurtas.

### Galios profiliai

Nešiojamajame kompiuteryje Omarchy įsimena jūsų galios profilį atskirai, kai kompiuteris prijungtas prie maitinimo ir kai veikia nuo baterijos, ir persijungia tarp jų jums prijungiant ir atjungiant maitinimą. Iš karto tai reiškia našumo režimą, kai maitinama iš tinklo, ir subalansuotą režimą, kai maitinama iš baterijos.

Galite peržiūrėti, ką siūlo jūsų kompiuteris, naudodami `omarchy powerprofiles list`, ir nustatyti norimą profilį dabartinei būsenai naudodami `omarchy powerprofiles set autodetect power-saver`. Norėdami nustatyti kitą būseną nieko neatjungdami, nurodykite ją tiesiogiai: `omarchy powerprofiles set battery power-saver`. Kad ir ką pasirinktumėte, tą ir gausite kitą kartą būdami toje būsenoje.

### Pristabdymo įjungimas ir išjungimas

Pristabdymą įjungsite arba išjungsite terminale paleidę `omarchy toggle suspend`. Tai tiesiog parodo / paslepia parinktį skiltyje _System_ (arba `Super + Esc`), ir tada galite patikrinti, ar ji jūsų sistemoje veikia nuosekliai. Jei ne, galite ją vėl paslėpti ta pačia komanda.

### Sulaikytosios veiksenos įjungimas ir išjungimas

Sulaikytąją veikseną nustatysite terminale paleidę `omarchy hibernation setup` (ji nepasiekiama Apple Silicon Mac kompiuteriuose). Sulaikytoji veiksena jūsų įkrovos diske sukuria /swap podiskį, kurio dydis lygus jūsų fizinės RAM apimčiai, todėl įsitikinkite, kad turite pakankamai laisvos vietos. 32GB kompiuteryje šiam tomui visada reikės 32GB+ laisvos vietos. Sulaikytajai veiksenai taip pat reikalinga numatytoji Limine įkrovos tvarkyklė.

Kai ji bus nustatyta, sulaikytosios veiksenos parinktį matysite skiltyje _System_ (arba `Super + Esc`), ir tada galėsite patikrinti, ar ji jūsų sistemoje veikia nuosekliai. Jei ne, galite ją vėl pašalinti paleidę `omarchy hibernation remove`.
