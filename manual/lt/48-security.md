# Saugumas

Omarchy į saugumą žiūri itin rimtai. Tai turi būti operacinė sistema, kurią galite naudoti _Tikram Darbui_ _Tikrame Pasaulyje_. Tokioje, kurioje pametus nešiojamąjį kompiuterį tai netampa saugumo krize. Štai ką mes darome:

1. *Viso disko šifravimas įjungtas pagal numatytuosius nustatymus*: tai svarbiausias žingsnis siekiant fiziškai apsaugoti jūsų duomenis. Jei jūsų kompiuteris pametamas ar pavagiamas, duomenys yra visiškai užšifruoti naudojant standartinį LUKS (Linux Unified Key Setup). Diegimo programa leidžia to atsisakyti vienkartiniams kompiuteriams (žr. [Darbo pradžia](02-getting-started.md)); įdiegimas be šifravimo tokios apsaugos neturi, ir kiekvienas, turintis diską, gali jį perskaityti.
2. *Užkarda įjungta pagal numatytuosius nustatymus*: visas gaunamas srautas pagal numatytuosius nustatymus yra blokuojamas, su keliomis išimtimis: prievadas 53317, skirtas [LocalSend](https://localsend.org/); DNS užklausos į paties kompiuterio vardų serverį Docker tilto adresu (172.17.0.1), priimamos iš privačių adresų diapazonų, kuriuos Docker suteikia savo konteineriams; ir daugiaadresis DNS (prievadas 5353), kuris leidžia spausdintuvams ir kitiems jūsų tinklo įrenginiams rasti vieniems kitus ir taip pat skelbia ten jūsų kompiuterio vardą. Be to, užkarda išlaiko standartinius UFW leidimus ping, adreso gavimui iš jūsų maršruto parinktuvo (DHCP) ir UPnP aptikimui. Net ssh yra išjungtas, kol jo neįjungiate per _Sąranka > Saugumas > SSHD_, o tai sąrankos metu atveria 22 prievadą (su bandymų dažnio ribojimu nuo brutalios jėgos atakų). Mes netgi apribojame Docker prieigą naudodami [ufw-docker](https://github.com/chaifeng/ufw-docker) sąranką, kad jūsų konteineriai netyčia nebūtų atviri pasauliui.
3. *Arch visada turi naujausius atnaujinimus*: Arch, pagrindinis platinamasis paketas, kuriuo paremta Omarchy, yra nuolat atnaujinamas (rolling) platinamasis paketas. Tai reiškia, kad bet kuri aptikta ir bet kuriame pakete ištaisyta saugumo spraga greitai tampa prieinama įdiegti naudojant `omarchy-update`. Taip visada naudojate naujausias, saugiausias visko versijas.
4. *Omarchy prižiūri savo paketus ir veidrodį*: Omarchy pagal numatytuosius nustatymus remiasi tik paketais iš pačios Arch core/extra/multilib saugyklų ir savo pačios Omarchy Package Repository. Programinę įrangą galite diegti tiesiai iš AUR, bet bazinis įdiegimas to nedaro — tik keli pasirenkami įdiegimai, pavyzdžiui, trečiųjų šalių naršyklės, naudoja AUR.
5. *Cloudflare saugo mus nuo DDoS*: Omarchy platinimo infrastruktūra — ISO atvaizdai, Omarchy paketai, Arch veidrodis — yra apsaugota galingu Cloudflare DDoS skydu ir talpinama jų CDN. Tai užtikrina puikų pasiekiamumą.

## Slaptažodžių keitimas

Šifruotame įdiegime turite du slaptažodžius: vieną, kuris paleidimo metu atrakina diską, ir kitą, kuriuo prisijungiate ir naudojate `sudo`. Sąranka juos padaro vienodus. Abu galima pakeisti Omarchy meniu skiltyje _Atnaujinimas > Slaptažodis_ — pirmąjį per _Disko šifravimas_, antrąjį per _Naudotojas_. Keičiant disko slaptažodį pirmiausia prašoma dabartinio, todėl turėkite jį po ranka. Jei keitimas nutrūksta, vėl paleiskite _Disko šifravimas_: jis paprašys slaptažodžio, kuris dabar atrakina diską, ir užbaigs keitimą.

## Jau naudoto kompiuterio perdavimas kitam

Jei perduodate savo kompiuterį kam nors kitam, jums nereikia jo diegti iš naujo. Omarchy meniu paleiskite _Sąranka > Atkurti kompiuterį_, patvirtinimui įveskite `reset` ir perkraukite. Tai ištrina visas naudotojų paskyras ir viską, esantį `/home`, pašalina visus paketus ir sistemos pakeitimus, kuriuos atlikote po įdiegimo, ir išvalo kompiuterio tapatybę — tinklo ryšius, pagrindinio kompiuterio raktus, viską. Kas paleidžiama iš naujo, yra sąrankos vedlys iš pirmojo paleidimo, paruoštas naujam savininkui įvesti savo vardą, slaptažodį ir šifravimo slaptažodį.

Tai veikia atkuriant bazinę momentinę kopiją, kurią sukuria diegimo programa, todėl prieinama tik kompiuteriuose, įdiegtuose iš Omarchy ISO. O diske be šifravimo atkūrimas yra ištrynimas, o ne saugus išvalymas, todėl jei duomenys buvo jautrūs, verčiau atlikite švarų įdiegimą.

## Sudo be slaptažodžio

Kartais norite, kad `sudo` nustotų klausti, dažniausiai kai AI agentas už jus atlieka ilgą sistemos darbų ruožą. _Sąranka > Saugumas > Sudo be slaptažodžio_ klausia, kiek laiko leisti prieigą: **15 minučių**, **1 valanda**, **1 diena** arba **Visam laikui**. Kol prieiga aktyvi, šalia kitų meniu juostos indikatorių rodoma raudona įspėjimo piktograma. Spustelėkite ją arba vėl paleiskite komandą, kad prieigą išjungtumėte. Taip pat galite perduoti savo minučių skaičių (nuo 1 iki 1440) su `omarchy-sudo-passwordless 30` arba naudoti `omarchy-sudo-passwordless permanent`.

Laikina prieiga baigiasi automatiškai, įskaitant iš karto po pabudimo iš pristabdymo, per kurį buvo peržengtas terminas. Perkrovus kompiuterį ji baigiasi anksčiau. Nuolatinė prieiga išlieka po perkrovimų ir lieka įjungta, kol jos neišjungsite.

Omarchy nustatymų paketo atnaujinimas arba pašalinimas užbaigia bet kurį laikiną leidimą prieš pasikeičiant jo galiojimo palaikymui. Jei komanda praneša apie autorizavimo arba valymo klaidą, išspręskite ją prieš bandydami įjungti kitą leidimą; klaida nereiškia, kad prieiga be slaptažodžio yra neaktyvi.

Žvelkite į tai blaiviai: kol tai įjungta, viskas, kas veikia su jūsų naudotojo teisėmis, gali atlikti bet ką kaip root be paklausimo. Tai yra visa esmė, ir tai yra visa rizika.

## Pasirašymo raktai

Viešasis raktas, skirtas visiems ISO parašams ir Omarchy repo paketui, yra `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([patikrinti openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` pakete jis taip pat yra ir bus naudojamas sklandžiai diegti bet kokius galimus atnaujinimus.

Bet kurios ISO laidos parašą galite rasti pridėję `.sig` prie jos URL, pavyzdžiui, `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
