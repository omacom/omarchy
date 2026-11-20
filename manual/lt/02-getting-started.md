# Darbo pradžia

Omarchy diegiama naudojant ISO. Galite rinktis diegimą visame diske, kai užimamas visas diskas, arba diegimą į laisvą vietą, kai Omarchy įdiegiama į nepadalintą disko vietą — taip veikia dviguba įkrova kartu su Windows ar kita OS (žr. [dvigubos įkrovos diegimas](50-dual-boot-install.md) — atminkite, kad pirmiausia Windows reikės išjungti BitLocker). Bet kuriuo atveju diegimas pagal numatytuosius nustatymus naudoja visišką šifravimą, o pasirinkus viso disko variantą pasirinktas diskas bus ištrintas, todėl prieš naudodami esamą diską būtinai pasidarykite atsarginę kopiją!

Pirmiausia [atsisiųskite Omarchy ISO](https://omarchy.org/), įrašykite jį į USB atmintinę (Windows naudokite [Rufus](https://rufus.ie/), Mac — [balenaEtcher](https://etcher.balena.io/), o Linux — [caligula](https://github.com/ifd3f/caligula)) ir paleiskite kompiuterį iš atmintinės.

_BIOS turite išjungti Secure Boot ir (arba) TPM. Turite juos išjungti, kad galėtumėte įdiegti Omarchy. Tai Microsoft saugumo schemos, skirtos Windows ir su Microsoft susijusioms Linux distribucijoms._

Tada atsakykite į konfigūracijos klausimus ir patvirtinkite juos taip:

 ![install-config](images/install-config.webp)

Tada pasirinkite diegimo diską, atsiloškite ir stebėkite diegimo šou. Greičiausiuose šiuolaikiniuose kompiuteriuose tai galima atlikti greičiau nei per minutę, o net senesniame kompiuteryje tai neturėtų užtrukti ilgiau nei 5 minutes.

 ![install-done](images/install-done.webp)

Dabar esate pasiruošę Omarchy!

### Naudokite laidinę arba 2.4ghz klaviatūrą!

Visiškas disko šifravimas neleis paleidimo metu įvesti slaptažodžio iš Bluetooth klaviatūros. Lygiai taip pat negalite naudoti Bluetooth klaviatūros, kad įeitumėte į PC BIOS. Jums reikės klaviatūros, kuri naudoja 2.4ghz adapterį arba laidą (kas dėl vėlinimo bet kuriuo atveju yra daug maloniau!). Aš asmeniškai dievinu [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Diegimas kitam savininkui

Jei ruošiate kompiuterį kitam žmogui — šeimos nariui, naujam darbuotojui, pirkėjui — neturėtumėte atsakinėti į asmeninius klausimus už jį. Pačiame pirmame diegimo programos ekrane (klaviatūros pasirinkimo) paspauskite `Ctrl + C` ir Omarchy pasiūlys paruošti kompiuterį kitam savininkui. Sistema įdiegiama iš karto, tačiau visa asmeninė sąranka — klaviatūros išdėstymas, naudotojo vardas, slaptažodis — atidedama iki pirmojo kompiuterio paleidimo. Diskas vis tiek pagal numatytuosius nustatymus šifruojamas, o slaptažodis, kurį naujasis savininkas pasirenka per tą pirmąjį paleidimą, tampa ir šifravimo slaptažodžiu. (Kompiuterį, kurį jau naudojote, taip pat galima perduoti be pakartotinio diegimo — žr. [kompiuterio nustatymas iš naujo](48-security.md).)

### Diegimas be dalyvavimo

ISO taip pat gali įsidiegti visiškai savarankiškai — be klaviatūros, be vedlio — kai jo konfigūracija pateikiama antrame diske. Taip Omarchy reikėtų laikyti baziniu atvaizdu VM ir kompiuterių parkams. Žr. [diegimas be dalyvavimo](51-unattended-installs.md).

### Diegimas be šifravimo

Omarchy pagal numatytuosius nustatymus diegiama su šifravimu. Tai saugus ir atsakingas pasirinkimas bet kuriam kompiuteriui, kuris gali būti pamestas ar pavogtas. Nenorite, kad kas nors, gavęs prieigą prie jūsų aparatinės įrangos, galėtų pasiekti jūsų duomenis!

Tačiau ypatingomis aplinkybėmis, pavyzdžiui, nuotoliniuose Omarchy diegimuose apsaugotuose kompiuteriuose arba vienkartiniuose diegimuose be neskelbtinų duomenų, galite norėti diegti be šifravimo. Disko formatavimo patvirtinimo ekrane galite paspausti `Ctrl + C`, kad persijungtumėte į diegimą be šifravimo.

### Kalba

Omarchy kalba 50 kalbų — tuo pačiu rinkiniu kaip omarchy.org — o numatytoji kalba yra anglų. Norėdami ją pakeisti, atidarykite Omarchy meniu ir eikite į _Setup > Region > Language_ arba terminale paleiskite `omarchy language <code>` (`omarchy language list` rodo kodus). Meniu, darbalaukis ir paties Omarchy pranešimai iš karto pakeičia kalbą, o kiekviena vėliau atidaryta programa taip pat ją perima. Jau atidarytos programos persijungia, kai jas paleidžiate iš naujo.

Kad išlaikytumėte kalbą, bet datas, laiką, skaičius, pinigus, vienetus ir popieriaus dydžius rašytumėte taip, kaip įprasta kitame regione (pavyzdžiui, anglų kalba su europietiškomis datomis ir 24 valandų laikrodžiu), pasirinkite regioną skiltyje _Setup > Region > Formats_, kur prie kiekvieno pasirinkimo rodomas pavyzdys, arba paleiskite `omarchy region <code>` (`omarchy region list` rodo kodus). _Same as language_ grąžina pačios kalbos formatus. Kaip ir kalbos keitimas, tai pasiekia vėliau atidarytas programas.

### Pagalba, jei užstrigote

Jei užstrigote, paprastai galite rasti norinčių padėti _#omarchy-help_ kanale [bendruomenės Discord](https://omarchy.org/discord).
