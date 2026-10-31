# Kaip pradėti

Omarchy įdiegiama naudojant ISO. Galite rinktis viso disko įdiegimą, kuris perima visą diską, arba įdiegimą į laisvą vietą, kuris patalpina Omarchy nepaskirstytoje disko vietoje — taip galite naudoti dvigubą įkrovą kartu su Windows arba kita OS (žr. [dvigubos įkrovos įdiegimas](50-dual-boot-install.md) — atkreipkite dėmesį, kad pirmiausia Windows turėsite išjungti BitLocker). Bet kuriuo atveju įdiegimas pagal numatytuosius nustatymus atliekamas su visu šifravimu, o viso disko parinktis išvalys pasirinktą diską, todėl prieš naudodami esamą diską būtinai pasidarykite atsarginę kopiją!

Pirmiausia [atsisiųskite Omarchy ISO](https://omarchy.org/), įkelkite jį į USB atmintinę (naudokite [balenaEtcher](https://etcher.balena.io/) Mac/Windows arba [caligula](https://github.com/ifd3f/caligula) Linux) ir paleiskite kompiuterį iš šios atmintinės.

_BIOS turite išjungti Secure Boot ir (arba) TPM. Turite juos išjungti, kad galėtumėte įdiegti Omarchy. Tai Microsoft saugos schemos, skirtos Windows ir su Microsoft susijusioms Linux distribucijoms._

Tada atsakykite į konfigūracijos klausimus ir patvirtinkite juos taip:

 ![install-config](images/install-config.webp)

Tada pasirinkite diską įdiegimui, atsipalaiduokite ir stebėkite įdiegimo šou. Greičiausiuose šiuolaikiniuose kompiuteriuose tai galima padaryti per mažiau nei minutę, tačiau net ir senesniame kompiuteryje tai neturėtų užtrukti ilgiau nei 5 minutes.

 ![install-done](images/install-done.webp)

Dabar esate pasiruošę Omarchy!

### Naudokite laidinę arba 2.4ghz klaviatūrą!

Viso disko šifravimas neleis paleidimo metu įvesti slaptažodžio iš Bluetooth klaviatūros. Kaip ir negalite naudoti Bluetooth klaviatūros norėdami įeiti į BIOS PC. Jums reikės klaviatūros, kuri naudoja arba 2.4ghz raktą, arba kabelį (kuris vis tiek daug geresnis dėl delsos!). Man pačiam labai patinka [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Įdiegimas kitam savininkui

Jei rengiate kompiuterį kažkam kitam — šeimos nariui, naujam darbuotojui, pirkėjui — neturėtumėte atsakinėti į asmeninius klausimus už juos. Pirmajame diegimo programos ekrane (klaviatūros pasirinkime) paspauskite `Ctrl + C`, ir Omarchy pasiūlys vietoj to paruošti kompiuterį kitam savininkui. Sistema įdiegiama iš karto, tačiau visa asmeninė sąranka — klaviatūros išdėstymas, vartotojo vardas, slaptažodis — atidedama iki pirmojo kompiuterio paleidimo. Diskas pagal numatytuosius nustatymus vis tiek šifruojamas, o slaptažodis, kurį naujas savininkas pasirenka pirmojo paleidimo metu, taip pat tampa šifravimo slaptažodžiu. (Kompiuterį, kurį jau naudojote, taip pat galima perduoti be perįdiegimo — žr. [kompiuterio atstatymas](48-security.md).)

### Įdiegimas be priežiūros

ISO taip pat gali įsidiegti visiškai savarankiškai — be klaviatūros, be vediklio — kai jam antrame diske pateikiama jo konfigūracija. Tai būdas laikyti Omarchy baziniu atvaizdu VMs ir parko kompiuteriams. Žr. [įdiegimas be priežiūros](51-unattended-installs.md).

### Įdiegimas be šifravimo

Omarchy pagal numatytuosius nustatymus įdiegiama su šifravimu. Tai saugus ir atsakingas pasirinkimas bet kuriam kompiuteriui, kuris gali būti pamestas arba pavogtas. Nenorite, kad kas nors, gavęs prieigą prie jūsų techninės įrangos, galėtų pasiekti jūsų duomenis!

Tačiau ypatingomis aplinkybėmis, pavyzdžiui, nuotoliniams Omarchy įdiegimams apsaugotuose kompiuteriuose arba vienkartiniams įdiegimams be jautrių duomenų, galbūt norėsite įdiegti be šifravimo. Disko formatavimo patvirtinime galite paspausti `Ctrl + C`, kad persijungtumėte į įdiegimą be šifravimo.

### Kalba

Omarchy kalba 50 kalbų — tuo pačiu rinkiniu kaip omarchy.org — o anglų kalba yra numatytoji. Norėdami perjungti, atidarykite Omarchy meniu ir eikite į _Nustatymai > Kalba_ arba terminale paleiskite `omarchy language <code>` (`omarchy language list` rodo kodus). Meniu, darbalaukis ir paties Omarchy pranešimai kalbą pakeičia iš karto, o kiekviena vėliau atidaroma programa taip pat seks paskui. Jau atidarytos programos persijungs, kai jas paleisite iš naujo.

### Pagalba, jei įstrigote

Jei įstrigsite, [bendruomenės Discord](https://omarchy.org/discord) kanale _#omarchy-help_ paprastai galite rasti norinčių pagelbėti.
