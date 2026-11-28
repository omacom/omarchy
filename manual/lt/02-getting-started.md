# Darbo pradžia

Omarchy diegiama naudojant ISO. Galite rinktis viso disko diegimą, kuris perima visą diską, arba diegimą į laisvą vietą, kuris patalpina Omarchy į nepaskirstytą disko vietą — taip paleidžiate dvigubą įkrovą kartu su Windows arba kita OS (žr. [dvigubo paleidimo diegimą](50-dual-boot-install.md) — atminkite, kad pirmiausia Windows turėsite išjungti BitLocker). Bet kuriuo atveju diegimas pagal numatytuosius nustatymus atliekamas su pilnu šifravimu, o viso disko parinktis ištrins pasirinktą diską, todėl prieš naudodami jau naudojamą diską būtinai pasidarykite atsarginę kopiją!

Apple Silicon Mac kompiuteryje diegiate iš macOS, be jokio ISO ar USB atmintinės. Žr. [Omarchy, skirtą Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

Pirmiausia [atsisiųskite Omarchy ISO](https://omarchy.org/), įrašykite jį į USB atmintinę (naudokite [Rufus](https://rufus.ie/) Windows sistemoje, [balenaEtcher](https://etcher.balena.io/) Mac kompiuteryje arba [caligula](https://github.com/ifd3f/caligula) Linux sistemoje) ir paleiskite kompiuterį iš atmintinės.

_BIOS turite išjungti Secure Boot ir / arba TPM. Turite juos išjungti, kad galėtumėte įdiegti Omarchy. Tai Microsoft saugumo schemos, skirtos Windows ir su Microsoft susijusioms Linux distribucijoms._

Tada atsakykite į konfigūracijos klausimus ir patvirtinkite juos taip:

 ![install-config](images/install-config.webp)

Tada pasirinkite diegimui skirtą diską, atsiloškite ir stebėkite diegimo šou. Greičiausiuose šiuolaikiniuose kompiuteriuose tai gali būti atlikta greičiau nei per minutę, bet net ir senesniame kompiuteryje tai neturėtų užtrukti ilgiau nei 5 minutes.

 ![install-done](images/install-done.webp)

Dabar esate pasiruošę Omarchy!

### Naudokite laidinę arba 2.4ghz klaviatūrą!

Viso disko šifravimas neleis paleidimo metu įvesti slaptažodžio naudojant Bluetooth klaviatūrą. Lygiai taip pat, kaip negalite naudoti Bluetooth klaviatūros, kad patektumėte į BIOS asmeniniame kompiuteryje. Jums reikės klaviatūros, kuri naudoja 2.4ghz raktą arba kabelį (kas vėlavimo požiūriu vis tiek yra daug maloniau!). Man asmeniškai labai patinka [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Diegimas kitam savininkui

Jei rengiate kompiuterį kitam žmogui — šeimos nariui, naujam darbuotojui, pirkėjui — neturėtumėte atsakinėti į asmeninius klausimus jo vardu. Pačiame pirmame diegimo programos ekrane (klaviatūros pasirinkime) paspauskite `Ctrl + C` ir Omarchy vietoj to pasiūlys paruošti kompiuterį kitam savininkui. Sistema įdiegiama iš karto, bet visa asmeninė sąranka — klaviatūros išdėstymas, naudotojo vardas, slaptažodis — atidedama, kol kompiuteris bus paleistas pirmą kartą. Diskas pagal numatytuosius nustatymus vis tiek šifruojamas, o slaptažodis, kurį naujasis savininkas pasirenka per tą pirmąjį paleidimą, tampa ir šifravimo slaptažodžiu. (Kompiuterį, kurį jau naudojote, taip pat galima perduoti be pakartotinio diegimo — žr. [kompiuterio atstatymą](48-security.md).)

### Neprižiūrimi diegimai

ISO taip pat gali įsidiegti visiškai savarankiškai — be klaviatūros, be vedlio — kai jam konfigūracija pateikiama antrame diske. Taip Omarchy galima laikyti baziniu atvaizdu, skirtu VM ir kompiuterių parkams. Žr. [neprižiūrimus diegimus](51-unattended-installs.md).

### Diegimai be šifravimo

Omarchy pagal numatytuosius nustatymus diegiama su šifravimu. Tai saugus, atsakingas pasirinkimas bet kuriam kompiuteriui, kuris gali būti pamestas ar pavogtas. Nenorite, kad kas nors, gavęs prieigą prie jūsų aparatinės įrangos, galėtų pasiekti jūsų duomenis!

Tačiau ypatingomis aplinkybėmis, pavyzdžiui, diegiant Omarchy nuotoliniu būdu apsaugotuose kompiuteriuose arba atliekant vienkartinius diegimus be jautrių duomenų, galite norėti diegti be šifravimo. Disko formatavimo patvirtinime galite paspausti `Ctrl + C`, kad persijungtumėte į diegimą be šifravimo.

### Kalba

Omarchy kalba 50 kalbų — tuo pačiu rinkiniu kaip omarchy.org — o anglų kalba yra numatytoji. Norėdami ją pakeisti, atidarykite Omarchy meniu ir eikite į _Setup > Region > Language_ arba terminale paleiskite `omarchy language <code>` (`omarchy language list` rodo kodus). Meniu, darbalaukis ir paties Omarchy pranešimai iš karto pakeičia kalbą, o kiekviena vėliau atidaryta programa taip pat ją perima. Jau atidarytos programos persijungia, kai jas paleidžiate iš naujo.

Kad išlaikytumėte kalbą, bet datas, laikus, skaičius, pinigus, vienetus ir popieriaus dydžius rašytumėte taip, kaip tai daro kitas regionas (tarkime, anglų kalba su europietiškomis datomis ir 24 valandų laikrodžiu), pasirinkite regioną skiltyje _Setup > Region > Formats_, kur prie kiekvieno pasirinkimo rodomas pavyzdys, arba paleiskite `omarchy region formats <code>` (`omarchy region formats list` rodo kodus). _Same as language_ grąžina pačios kalbos formatus. Kaip ir kalbos pakeitimas, tai pasiekia programas, kurias atidarote vėliau.

### Pagalba, jei užstrigote

Jei užstrigsite, paprastai galite rasti ką nors, norintį padėti, _#omarchy-help_ kanale [bendruomenės Discord](https://omarchy.org/discord) serveryje.
