# Saugumas

Omarchy į saugumą žiūri itin rimtai. Tai turi būti operacinė sistema, kurią galite naudoti _Tikram darbui_ _Tikrame pasaulyje_. Kur nešiojamojo kompiuterio praradimas negali virsti saugumo krize. Taigi štai ką darome:

1. *Viso disko šifravimas yra privalomas*: Tai svarbiausias žingsnis siekiant fiziškai apsaugoti jūsų duomenis. Jei jūsų kompiuteris pametamas arba pavagiamas, duomenys yra visiškai užšifruoti naudojant standartinį LUKS (Linux Unified Key Setup).
2. *Ugniasienė įjungta pagal numatytuosius nustatymus*: Visas gaunamas srautas pagal numatytuosius nustatymus yra blokuojamas, išskyrus 53317 prievadą, skirtą [LocalSend](https://localsend.org/). Net ssh yra išjungtas, kol jo neįjungiate per _Setup > Security > SSHD_, o tai kaip sąrankos dalis atidaro 22 prievadą (su bandymų dažnio ribojimu, siekiant apsisaugoti nuo brute force atakų). Mes net apribojame Docker prieigą naudodami [ufw-docker](https://github.com/chaifeng/ufw-docker) sąranką, kad jūsų konteineriai netyčia nebūtų atviri pasauliui.
3. *Arch visada turi naujausius atnaujinimus*: Arch, pagrindinė distribucija, kuria remiasi Omarchy, yra nuolat atnaujinama distribucija. Tai reiškia, kad bet koks saugumo pažeidžiamumas, kuris aptinkamas ir pataisomas bet kuriame pakete, greitai tampa prieinamas įdiegti naudojant `omarchy-update`. Taip visada naudojate naujausias, saugiausias visko versijas.
4. *Omarchy prižiūri savo paketus ir veidrodį*: Omarchy pagal numatytuosius nustatymus remiasi tik paketais iš pačios Arch core/extra/multilib saugyklų ir savo Omarchy Package Repository. Programinę įrangą galite įdiegti tiesiai iš AUR, bet bazinis įdiegimas to nedaro — tik keli pasirenkami įdiegimai, pavyzdžiui, trečiųjų šalių naršyklės, naudoja AUR.
5. *Cloudflare saugo mus nuo DDoS*: Omarchy platinimo infrastruktūra — ISO atvaizdai, Omarchy paketai, Arch veidrodis — yra apsaugota už galingo Cloudflare DDoS skydo ir talpinama jų CDN. Tai užtikrina puikų prieinamumą.

## Slaptažodžių keitimas

Šifruotame įdiegime turite du slaptažodžius: vieną, kuris paleidžiant kompiuterį atrakina diską, ir kitą, kuriuo prisijungiate ir naudojate `sudo`. Sąrankos metu jie nustatomi vienodi. Abu galima pakeisti Omarchy meniu skiltyje _Update > Password_ — pirmąjį pasirinkus _Drive Encryption_, antrąjį — _User_. Keičiant disko slaptažodį, pirmiausia prašoma įvesti dabartinį, todėl turėkite jį po ranka. Jei keitimas nutrūksta, dar kartą paleiskite _Drive Encryption_: bus paprašyta slaptažodžio, kuris dabar atrakina diską, ir keitimas bus užbaigtas.

## Jau naudoto kompiuterio perdavimas kitam asmeniui

Jei perduodate savo kompiuterį kam nors kitam, jums nereikia jo įdiegti iš naujo. Omarchy meniu paleiskite _Setup > Reset Computer_, patvirtinimui įveskite `reset` ir paleiskite kompiuterį iš naujo. Tai ištrina visas naudotojų paskyras ir viską, kas yra `/home`, pašalina visus paketus ir sistemos pakeitimus, kuriuos atlikote nuo įdiegimo, ir išvalo kompiuterio tapatybę — tinklo ryšius, host raktus ir visa kita. Paleidus iš naujo pasirodys pirmojo paleidimo sąrankos vedlys, kuriame naujasis savininkas galės įvesti savo vardą, slaptažodį ir šifravimo slaptažodį.

Tai veikia atkuriant bazinę momentinę kopiją, kurią padaro diegimo programa, todėl ši funkcija prieinama tik kompiuteriuose, įdiegtuose iš Omarchy ISO. O diske be šifravimo atstatymas yra ištrynimas, o ne saugus išvalymas, todėl, jei duomenys buvo neskelbtini, vietoj to atlikite naują įdiegimą.

## sudo be slaptažodžio

Kartais norisi, kad `sudo` nustotų prašyti slaptažodžio, dažniausiai kai AI agentas už jus ilgai atlieka sistemos darbus. _Setup > Security > Passwordless Sudo_ klausia, kiek laiko leisti prieigą: **15 minučių**, **1 valanda**, **1 diena** arba **Visam laikui**. Kol prieiga aktyvi, šalia kitų meniu juostos indikatorių rodoma raudona įspėjimo piktograma. Spustelėkite ją arba dar kartą paleiskite komandą, kad prieigą išjungtumėte. Taip pat galite nurodyti savo minučių skaičių (nuo 1 iki 1440) naudodami `omarchy-sudo-passwordless 30` arba naudoti `omarchy-sudo-passwordless permanent`.

Laikina prieiga baigiasi automatiškai, taip pat iš karto po pabudimo iš pristabdymo, kurio metu buvo peržengtas terminas. Kompiuterio paleidimas iš naujo ją užbaigia anksčiau laiko. Nuolatinė prieiga išlieka po perkrovimų ir lieka įjungta, kol ją išjungsite.

Omarchy nustatymų paketo atnaujinimas arba pašalinimas užbaigia bet kokį laikiną leidimą dar prieš pasikeičiant jo galiojimo pabaigos palaikymui. Jei komanda praneša apie autorizavimo arba išvalymo klaidą, išspręskite ją prieš bandydami įjungti kitą leidimą; klaida nereiškia, kad prieiga be slaptažodžio yra neaktyvi.

Žiūrėkite į tai blaiviai: kol ši funkcija įjungta, viskas, kas veikia jūsų naudotojo teisėmis, gali be klausimų daryti bet ką kaip root. Tai ir yra visa esmė, ir kartu — visa rizika.

## Pasirašymo raktai

Viešasis raktas visiems ISO parašams ir Omarchy repo paketams yra `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([patikrinkite openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakete `omarchy/omarchy-keyring` šis raktas taip pat yra, ir jis bus naudojamas sklandžiai išleidžiant bet kokius galimus atnaujinimus.

Bet kurio ISO leidimo parašą galite rasti prie jo URL pridėję `.sig`, pavyzdžiui, `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
