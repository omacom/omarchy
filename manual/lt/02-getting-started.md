# Darbo pradžia

Omarchy diegiama naudojant ISO. Galite rinktis diegimą į visą diską, kuris perima visą diską, arba diegimą į laisvą vietą, kuris įdeda Omarchy į nepaskirtą disko vietą — taip galite naudoti dvigubą įkrovą kartu su Windows ar kita OS (žr. [dvigubo įkrovimo diegimą](50-dual-boot-install.md) — atminkite, kad pirmiausia turėsite išjungti BitLocker sistemoje Windows). Bet kuriuo atveju diegimas pagal numatytuosius nustatymus naudoja visišką šifravimą, o pasirinkus visą diską, pasirinktas diskas bus ištrintas, todėl prieš naudodami esamą diską būtinai pasidarykite atsarginę kopiją!

Pirmiausia [atsisiųskite Omarchy ISO](https://omarchy.org/), įrašykite jį į USB atmintinę (naudokite [Rufus](https://rufus.ie/) sistemoje Windows, [balenaEtcher](https://etcher.balena.io/) sistemoje Mac arba [caligula](https://github.com/ifd3f/caligula) sistemoje Linux) ir paleiskite kompiuterį iš atmintinės.

_BIOS turite išjungti Secure Boot ir (arba) TPM. Turite juos išjungti, kad galėtumėte įdiegti Omarchy. Tai Microsoft saugumo schemos, skirtos Windows ir su Microsoft susijusiems Linux platinimams._

Tada atsakykite į konfigūracijos klausimus ir patvirtinkite juos taip:

 ![install-config](images/install-config.webp)

Tada pasirinkite diską diegimui, atsiloškite ir stebėkite diegimo šou. Greičiausiuose šiuolaikiniuose kompiuteriuose tai galima atlikti per mažiau nei minutę, tačiau net senesniame kompiuteryje tai neturėtų užtrukti ilgiau nei 5 minutes.

 ![install-done](images/install-done.webp)

Dabar esate pasiruošę Omarchy!

### Naudokite laidinę arba 2.4ghz klaviatūrą!

Visiškas disko šifravimas neleis paleidžiant įvesti slaptažodžio iš Bluetooth klaviatūros. Lygiai taip pat negalite naudoti Bluetooth klaviatūros, norėdami įeiti į BIOS kompiuteryje. Jums reikės klaviatūros, kuri naudoja 2.4ghz adapterį arba laidą (kas bet kuriuo atveju yra daug maloniau dėl delsos!). Aš asmeniškai dievinu [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Diegimas kitam savininkui

Jei ruošiate kompiuterį kitam asmeniui — šeimos nariui, naujam darbuotojui, pirkėjui — neturėtumėte atsakinėti į asmeninius klausimus jų vardu. Pačiame pirmame diegimo programos ekrane (klaviatūros pasirinkimas) paspauskite `Ctrl + C`, ir Omarchy pasiūlys vietoj to paruošti kompiuterį kitam savininkui. Sistema įdiegiama iš karto, tačiau visa asmeninė sąranka — klaviatūros išdėstymas, vartotojo vardas, slaptažodis — atidedama iki pirmojo kompiuterio paleidimo. Diskas vis tiek pagal numatytuosius nustatymus šifruojamas, o slaptažodis, kurį naujasis savininkas pasirenka pirmojo paleidimo metu, tampa ir šifravimo slaptažodžiu. (Jau naudotą kompiuterį taip pat galima perduoti be pakartotinio diegimo — žr. [kompiuterio atstatymas](48-security.md).)

### Neprižiūrimi diegimai

ISO taip pat gali įdiegti visiškai savarankiškai — be klaviatūros, be vedlio — kai jo konfigūracija pateikiama antrame diske. Tai būdas traktuoti Omarchy kaip bazinį atvaizdą VM ir mašinų parkui. Žr. [neprižiūrimi diegimai](51-unattended-installs.md).

### Diegimai be šifravimo

Omarchy pagal numatytuosius nustatymus diegiama su šifravimu. Tai saugus, atsakingas pasirinkimas bet kuriam kompiuteriui, kuris gali būti pamestas ar pavogtas. Juk nenorite, kad kas nors, turintis prieigą prie jūsų aparatinės įrangos, galėtų pasiekti jūsų duomenis!

Tačiau ypatingomis aplinkybėmis, pavyzdžiui, nuotoliniuose Omarchy diegimuose apsaugotuose kompiuteriuose arba vienkartiniuose diegimuose be jautrių duomenų, galite norėti diegti be šifravimo. Disko formatavimo patvirtinimo metu galite paspausti `Ctrl + C`, kad persijungtumėte į diegimą be šifravimo.

### Kalba

Omarchy kalba 50 kalbų — tuo pačiu rinkiniu kaip omarchy.org — o anglų kalba yra numatytoji. Norėdami ją pakeisti, atidarykite Omarchy meniu ir eikite į _Sąranka > Kalba_ arba terminale paleiskite `omarchy language <code>` (`omarchy language list` rodo kodus). Meniu, darbalaukis ir paties Omarchy pranešimai iš karto pakeičia kalbą, o kiekviena vėliau atidaryta programa taip pat ją seka. Jau atidarytos programos persijungia, kai jas paleidžiate iš naujo.

### Pagalba, jei įstrigote

Jei įstrigsite, paprastai galite rasti ką nors, norintį padėti, _#omarchy-help_ kanale [bendruomenės Discord](https://omarchy.org/discord).
