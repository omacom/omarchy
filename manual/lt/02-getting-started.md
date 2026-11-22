# Darbo pradžia

Omarchy diegiama naudojant ISO. Galite rinktis diegimą į visą diską, kai užimamas visas diskas, arba diegimą į laisvą vietą, kai Omarchy įdiegiama į nepaskirstytą disko vietą — taip galite naudoti dvigubą paleidimą kartu su Windows arba kita OS (žr. [dvigubo paleidimo diegimas](50-dual-boot-install.md) — atminkite, kad pirmiausia Windows reikės išjungti BitLocker). Bet kuriuo atveju diegimas pagal numatytuosius nustatymus naudoja visą šifravimą, o pasirinkus viso disko variantą pasirinktas diskas bus ištrintas, todėl prieš naudodami esamą diską būtinai pasidarykite atsarginę kopiją!

Pirmiausia [atsisiųskite Omarchy ISO](https://omarchy.org/), įrašykite jį į USB atmintinę (naudokite [Rufus](https://rufus.ie/) Windows, [balenaEtcher](https://etcher.balena.io/) Mac arba [caligula](https://github.com/ifd3f/caligula) Linux) ir paleiskite kompiuterį iš atmintinės.

_BIOS turite išjungti Secure Boot ir (arba) TPM. Turite juos išjungti, kad galėtumėte įdiegti Omarchy. Tai Microsoft saugumo schemos, skirtos Windows ir su Microsoft susijusiems Linux paskirstymams._

Tada atsakykite į konfigūracijos klausimus ir patvirtinkite juos taip:

 ![install-config](images/install-config.webp)

Tada pasirinkite diską diegimui ir atsipalaiduokite stebėdami diegimo šou. Greičiausiuose šiuolaikiniuose kompiuteriuose tai galima atlikti greičiau nei per minutę, bet net ir senesniame kompiuteryje tai neturėtų užtrukti ilgiau nei 5 minutes.

 ![install-done](images/install-done.webp)

Dabar esate pasiruošę Omarchy!

### Naudokite laidinę arba 2.4ghz klaviatūrą!

Viso disko šifravimas neleis paleidžiant kompiuterį įvesti slaptažodžio iš Bluetooth klaviatūros. Lygiai taip pat, kaip negalite naudoti Bluetooth klaviatūros PC BIOS atidaryti. Jums reikės klaviatūros, kuri naudoja arba 2.4ghz raktą, arba laidą (kas bet kuriuo atveju yra daug maloniau dėl delsos!). Man asmeniškai labai patinka [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Diegimas kitam savininkui

Jei ruošiate kompiuterį kitam žmogui — šeimos nariui, naujam darbuotojui, pirkėjui — neturėtumėte jų vardu atsakinėti į asmeninius klausimus. Pačiame pirmame diegimo programos ekrane (klaviatūros pasirinkimo) paspauskite `Ctrl + C` ir Omarchy pasiūlys vietoj to paruošti kompiuterį kitam savininkui. Sistema įdiegiama iš karto, bet visa asmeninė sąranka — klaviatūros išdėstymas, vartotojo vardas, slaptažodis — atidedama iki pirmojo kompiuterio paleidimo. Diskas vis tiek pagal numatytuosius nustatymus yra užšifruotas, o slaptažodis, kurį naujasis savininkas pasirenka to pirmojo paleidimo metu, tampa ir šifravimo slaptažodžiu. (Jau naudotą kompiuterį taip pat galima perduoti be pakartotinio diegimo — žr. [kompiuterio atstatymas](48-security.md).)

### Diegimas be priežiūros

ISO taip pat gali įdiegti visiškai savarankiškai — be klaviatūros, be vedlio — kai jo konfigūracija jam perduodama antrame diske. Tai būdas naudoti Omarchy kaip bazinį atvaizdą VM ir kompiuterių parkams. Žr. [diegimas be priežiūros](51-unattended-installs.md).

### Diegimas be šifravimo

Omarchy pagal numatytuosius nustatymus diegiama su šifravimu. Tai saugus, atsakingas pasirinkimas bet kuriam kompiuteriui, kuris gali būti pamestas arba pavogtas. Nenorite, kad kas nors, turintis prieigą prie jūsų aparatinės įrangos, galėtų pasiekti jūsų duomenis!

Bet ypatingomis aplinkybėmis, pavyzdžiui, nuotoliniams Omarchy diegimams apsaugotuose kompiuteriuose arba vienkartiniams diegimams be jautrių duomenų, galite norėti diegti be šifravimo. Disko formatavimo patvirtinime galite paspausti `Ctrl + C`, kad persijungtumėte į diegimą be šifravimo.

### Kalba

Omarchy kalba 50 kalbų — tas pats rinkinys kaip ir omarchy.org — o anglų kalba yra numatytoji. Norėdami ją pakeisti, atidarykite Omarchy meniu ir eikite į _Nustatymai > Regionas > Kalba_ arba terminale paleiskite `omarchy language <code>` (`omarchy language list` rodo kodus). Meniu, darbalaukis ir paties Omarchy pranešimai iš karto pakeičia kalbą, o kiekviena po to atidaryta programa taip pat ją naudoja. Jau atidarytos programos persijungia, kai jas paleidžiate iš naujo.

Norėdami pasilikti kalbą, bet datas, laiką, skaičius, pinigus, vienetus ir popieriaus formatus rašyti taip, kaip priimta kitame regione (pavyzdžiui, anglų kalba su europietiškomis datomis ir 24 valandų laikrodžiu), pasirinkite regioną skiltyje _Nustatymai > Regionas > Formatai_, kur prie kiekvieno pasirinkimo rodomas pavyzdys, arba paleiskite `omarchy region formats <code>` (`omarchy region formats list` rodo kodus). _Kaip kalboje_ grąžina kalbos numatytuosius formatus. Kaip ir kalbos keitimas, tai pasiekia programas, kurias atidarote po to.

### Pagalba, jei užstrigote

Jei užstrigote, paprastai galite rasti ką nors, norintį padėti, _#omarchy-help_ kanale [bendruomenės Discord](https://omarchy.org/discord).
