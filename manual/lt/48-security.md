# Saugumas

Omarchy labai rimtai žiūri į saugumą. Tai turi būti operacinė sistema, kurią galite naudoti _Realiam darbui_ _Realiame pasaulyje_. Kur nešiojamojo kompiuterio praradimas negali virsti saugumo ekstremalia situacija. Taigi štai ką mes darome:

1. *Viso disko šifravimas yra privalomas*: Tai svarbiausias žingsnis siekiant užtikrinti fizinę jūsų duomenų apsaugą. Jei jūsų kompiuteris pasimeta arba yra pavagiamas, duomenys yra visiškai užšifruoti naudojant standartinį LUKS (Linux Unified Key Setup).
2. *Ugniasienė įjungta pagal numatytuosius nustatymus*: Visas įeinantis srautas pagal numatytuosius nustatymus yra blokuojamas, išskyrus 53317 prievadą [LocalSend](https://localsend.org/). Net ssh yra išjungtas, kol jo neįjungiate per _Sąranka > Saugumas > SSHD_, kuris kaip sąrankos dalis atidaro 22 prievadą (su greičio ribojimu prieš brute force atakas). Mes netgi apribojame Docker prieigą naudodami [ufw-docker](https://github.com/chaifeng/ufw-docker) sąranką, kad jūsų konteineriai netyčia nebūtų pasiekiami iš viso pasaulio.
3. *Arch visada turi naujausius atnaujinimus*: Arch, bazinė distribucija, ant kurios pastatyta Omarchy, yra nuolat atnaujinama (rolling) distribucija. Tai reiškia, kad bet koks aptiktas ir pataisytas saugumo pažeidžiamumas bet kuriame pakete greitai tampa pasiekiamas diegimui naudojant `omarchy-update`. Taip visada naudojate naujausias, saugiausias visko versijas.
4. *Omarchy prižiūri savo paketus ir veidrodį*: Omarchy pagal numatytuosius nustatymus remiasi tik paketais iš pačios Arch core/extra/multilib saugyklų ir savo Omarchy Package Repository. Programinę įrangą galite diegti tiesiai iš AUR, tačiau bazinis diegimas to nedaro — tik keli pasirenkami diegimai, pavyzdžiui, trečiųjų šalių naršyklės, siunčiasi iš AUR.
5. *Cloudflare saugo mus nuo DDoS*: Omarchy platinimo infrastruktūra — ISO failai, Omarchy paketai, Arch veidrodis — yra apsaugota už tvirto Cloudflare DDoS skydo ir talpinama jų CDN. Tai užtikrina puikų pasiekiamumą.

## Slaptažodžių keitimas

Užšifruotame diegime turite du slaptažodžius: vieną, kuris paleidžiant atrakina diską, ir vieną, kuriuo prisijungiate ir naudojate `sudo`. Sąranka padaro juos vienodus. Abu galima pakeisti Omarchy meniu skiltyje _Atnaujinimas > Slaptažodis_ — _Disko šifravimas_ pirmajam, _Vartotojas_ antrajam. Keičiant disko slaptažodį, pirmiausia prašoma dabartinio, todėl turėkite jį po ranka. Jei keitimas nutrūksta, dar kartą paleiskite _Disko šifravimas_: bus paprašyta slaptažodžio, kuris dabar atrakina diską, ir keitimas bus užbaigtas.

## Jau naudoto kompiuterio perdavimas kitam

Jei perduodate savo kompiuterį kam nors kitam, jums nereikia jo diegti iš naujo. Omarchy meniu paleiskite _Sąranka > Atkurti kompiuterį_, patvirtinimui įveskite `reset` ir perkraukite. Tai ištrina kiekvieną vartotojo paskyrą ir viską, kas yra `/home`, pašalina visus paketus ir sistemos pakeitimus, kuriuos atlikote po diegimo, ir išvalo kompiuterio tapatybę — tinklo ryšius, pagrindinio kompiuterio raktus ir viską. Tai, kas pasileis iš naujo, bus sąrankos vedlys iš pirmojo paleidimo, paruoštas naujam savininkui įvesti savo vardą, slaptažodį ir šifravimo slaptažodį.

Tai veikia atkuriant bazinį momentinį atvaizdą, kurį sukuria diegimo programa, todėl tai pasiekiama tik kompiuteriuose, įdiegtuose iš Omarchy ISO. O diske be šifravimo atkūrimas yra ištrynimas, o ne saugus išvalymas, todėl jei duomenys buvo jautrūs, vietoj to atlikite naują diegimą.

## Sudo be slaptažodžio

Kartais norite, kad `sudo` nustotų klausinėti, dažniausiai kai AI agentas už jus atlieka ilgą ruožą sistemos darbo. _Sąranka > Saugumas > Sudo be slaptažodžio_ klausia, kiek laiko leisti prieigą: **15 minučių**, **1 valanda**, **1 diena** arba **Visam laikui**. Kol prieiga aktyvi, šalia kitų meniu juostos indikatorių atsiranda raudona įspėjimo piktograma. Spustelėkite ją arba dar kartą paleiskite komandą, kad prieigą išjungtumėte. Taip pat galite nurodyti savo minučių skaičių (nuo 1 iki 1440) su `omarchy-sudo-passwordless 30` arba naudoti `omarchy-sudo-passwordless permanent`.

Laikina prieiga baigiasi automatiškai, įskaitant iškart po atnaujinimo iš sustabdymo, kuris peržengė terminą. Kompiuterio paleidimas iš naujo ją nutraukia anksčiau laiko. Nuolatinė prieiga išlieka po perkrovimų ir lieka įjungta, kol ją išjungsite.

Atnaujinant arba pašalinant Omarchy nustatymų paketą, bet koks laikinas leidimas nutraukiamas anksčiau, nei pasikeičia jo galiojimo pabaigos palaikymas. Jei komanda praneša apie autorizavimo arba valymo klaidą, išspręskite ją prieš bandydami įjungti kitą leidimą; klaida nereiškia, kad prieiga be slaptažodžio yra neaktyvi.

Būkite dėl šito blaiviai vertinantys: kol tai įjungta, bet kas, kas veikia kaip jūsų vartotojas, gali daryti bet ką kaip root, ir niekas neklaus. Tai yra visa esmė, ir tai taip pat yra visa rizika.

## Pasirašymo raktai

Viešasis raktas visiems ISO parašams ir Omarchy repo paketams yra `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([patikrinti openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakete `omarchy/omarchy-keyring` šis raktas taip pat yra ir bus naudojamas sklandžiai diegti bet kokius galimus atnaujinimus.

Bet kurio ISO leidimo parašą galite rasti pridėję .sig prie URL. Pavyzdžiui, https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
