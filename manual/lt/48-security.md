# Saugumas

Omarchy į saugumą žiūri itin rimtai. Tai turi būti operacinė sistema, kurią galite naudoti tikram darbui tikrame pasaulyje. Kur nešiojamojo kompiuterio praradimas negali virsti saugumo krize. Štai ką mes darome:

1. *Viso disko šifravimas įjungtas pagal numatytuosius nustatymus*: Tai svarbiausias žingsnis siekiant užtikrinti fizinę jūsų duomenų apsaugą. Jei jūsų kompiuteris pametamas arba pavagiamas, duomenys yra visiškai užšifruoti naudojant standartinį LUKS (Linux Unified Key Setup). Diegimo programa leidžia to atsisakyti vienkartiniams kompiuteriams (žr. [Pradžia](02-getting-started.md)); diegimas be šifravimo tokios apsaugos neturi, ir bet kas, kas turi diską, gali jį perskaityti.
2. *Ugniasienė įjungta pagal numatytuosius nustatymus*: Visas gaunamas srautas pagal numatytuosius nustatymus yra blokuojamas, su keliomis išimtimis: prievadas 53317, skirtas [LocalSend](https://localsend.org/); DNS užklausos į kompiuterio nuosavą sprendiklį Docker tilto adresu (172.17.0.1), priimamos iš privačių adresų diapazonų, kuriuos Docker suteikia savo konteineriams; ir multicast DNS (prievadas 5353), kuris leidžia spausdintuvams ir kitiems jūsų tinklo įrenginiams rasti vieniems kitus ir ten taip pat praneša jūsų kompiuterio vardą. Be jų, ugniasienė išlaiko standartinius UFW leidimus, skirtus ping, adreso gavimui iš maršruto parinktuvo (DHCP) ir UPnP aptikimui. Net ssh yra išjungtas, kol jo neįjungiate per _Setup > Security > SSHD_, kas kaip sąrankos dalis atidaro 22 prievadą (su spartos ribojimu prieš brute force atakas). Mes netgi apribojame Docker prieigą naudodami [ufw-docker](https://github.com/chaifeng/ufw-docker) sąranką, kad jūsų konteineriai netyčia nebūtų atskleisti pasauliui.
3. *Arch visada turi naujausius atnaujinimus*: Arch, pagrindinė distribucija, ant kurios pastatyta Omarchy, yra slenkančių atnaujinimų distribucija. Tai reiškia, kad bet koks saugumo pažeidžiamumas, kuris aptinkamas ir ištaisomas bet kuriame pakete, greitai tampa prieinamas diegimui naudojant `omarchy-update`. Taip jūs visada naudojate naujausias, saugiausias visko versijas.
4. *Omarchy prižiūri savo paketus ir veidrodį*: Omarchy pagal numatytuosius nustatymus remiasi tik paketais iš Arch nuosavų core/extra/multilib saugyklų ir iš savo Omarchy Package Repository. Programinę įrangą galite įdiegti tiesiogiai iš AUR, bet bazinis diegimas to nedaro — iš AUR ima tik keli pasirenkami diegimai, pavyzdžiui, trečiųjų šalių naršyklės.
5. *Cloudflare saugo mus nuo DDoS*: Omarchy platinimo infrastruktūra — ISO atvaizdai, Omarchy paketai, Arch veidrodis — yra apsaugota už galingo Cloudflare DDoS skydo ir talpinama jų CDN. Tai užtikrina puikų prieinamumą.

## Slaptažodžių keitimas

Užšifruotame diegime turite du slaptažodžius: vieną, kuris atrakina diską įkrovos metu, ir kitą, kuriuo prisijungiate ir kurį naudojate su `sudo`. Sąranka juos nustato tokius pačius. Abu galima pakeisti Omarchy meniu skiltyje _Update > Password_ — _Drive Encryption_ pirmajam, _User_ antrajam. Keičiant disko slaptažodį pirmiausia prašoma dabartinio, todėl turėkite jį po ranka. Jei keitimas nutrūksta, paleiskite _Drive Encryption_ dar kartą: jis paprašys slaptažodžio, kuris dabar atrakina diską, ir užbaigs keitimą.

## Jau naudoto kompiuterio perdavimas kitam

Jei perduodate savo kompiuterį kam nors kitam, jums nereikia jo diegti iš naujo. Paleiskite _Remove > Factory Reset_ Omarchy meniu, įveskite `reset` patvirtinimui ir perkraukite. Tai ištrina kiekvieną vartotojo paskyrą ir viską, kas yra `/home`, pašalina visus paketus ir sistemos pakeitimus, kuriuos atlikote po diegimo, ir išvalo kompiuterio tapatybę — tinklo ryšius, pagrindinio kompiuterio raktus ir viską. Tai, kas pasileidžia, yra pirmosios įkrovos sąrankos vedlys, pasiruošęs naujajam savininkui įvesti savo vardą, slaptažodį ir šifravimo slaptažodį.

Tai veikia atkuriant bazinę momentinę kopiją, kurią sukuria diegimo programa, todėl tai prieinama tik kompiuteriuose, įdiegtuose iš Omarchy ISO. O diske be šifravimo atstatymas yra ištrynimas, o ne saugus išvalymas, todėl jei duomenys buvo jautrūs, vietoj to atlikite naują diegimą.

## Sudo be slaptažodžio

Kartais norite, kad `sudo` nustotų klausinėti, dažniausiai kai AI agentas už jus atlieka ilgą sistemos darbo atkarpą. _Setup > Security > Passwordless Sudo_ klausia, kiek laiko leisti prieigą: **15 minučių**, **1 valanda**, **1 diena** arba **Visam laikui**. Kol prieiga aktyvi, šalia kitų meniu juostos indikatorių rodoma raudona įspėjimo piktograma. Spustelėkite ją arba paleiskite komandą dar kartą, kad išjungtumėte prieigą. Taip pat galite nurodyti savo minučių skaičių (nuo 1 iki 1440) su `omarchy-sudo-passwordless 30` arba naudoti `omarchy-sudo-passwordless permanent`.

Laikina prieiga baigiasi automatiškai, įskaitant iškart po atnaujinimo iš sustabdymo, kuris peržengė terminą. Kompiuterio perkrovimas ją užbaigia anksčiau laiko. Nuolatinė prieiga išlieka po perkrovimų ir lieka įjungta, kol jos neišjungsite.

Omarchy nustatymų paketo atnaujinimas arba pašalinimas užbaigia bet kokį laikiną suteikimą, kol pasikeis jo galiojimo pabaigos palaikymas. Jei komanda praneša apie autorizacijos arba valymo klaidą, išspręskite ją prieš bandydami įjungti kitą suteikimą; klaida nereiškia, kad prieiga be slaptažodžio yra neaktyvi.

Žiūrėkite į tai blaiviai: kol tai įjungta, bet kas, kas veikia kaip jūsų vartotojas, gali daryti bet ką kaip root, nieko neklausdamas. Tai yra visa esmė, ir tai yra visa rizika.

## Pasirašymo raktai

Visų ISO parašų ir Omarchy repo paketo viešasis raktas yra `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([patikrinti openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakete `omarchy/omarchy-keyring` šis raktas taip pat yra ir bus naudojamas sklandžiai diegti bet kokius galimus atnaujinimus.

Bet kurio ISO leidimo parašą galite rasti prie jo URL pridėję `.sig`, pavyzdžiui, `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
