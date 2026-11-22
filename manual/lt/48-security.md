# Saugumas

Omarchy į saugumą žiūri itin rimtai. Tai turi būti operacinė sistema, kurią galite naudoti _Tikram darbui_ _Tikrame pasaulyje_. Kur praradus nešiojamąjį kompiuterį negali kilti saugumo krizė. Taigi štai ką darome:

1. *Viso disko šifravimas įjungtas pagal numatytuosius nustatymus*: Tai svarbiausias žingsnis siekiant užtikrinti fizinę jūsų duomenų apsaugą. Jei jūsų kompiuteris pametamas arba pavagiamas, duomenys yra visiškai užšifruoti naudojant standartinį LUKS (Linux Unified Key Setup). Diegimo programa leidžia to atsisakyti kompiuteriams, kurių negaila (žr. [Darbo pradžia](02-getting-started.md)); įdiegtis be šifravimo neturi jokios šios apsaugos, ir kiekvienas, turintis diską, gali jį perskaityti.
2. *Ugniasienė įjungta pagal numatytuosius nustatymus*: Visas gaunamas srautas pagal numatytuosius nustatymus yra blokuojamas, su keliomis išimtimis: prievadas 53317, skirtas [LocalSend](https://localsend.org/); DNS užklausos į paties kompiuterio resolverį Docker tilto adresu (172.17.0.1), priimamos iš privačių adresų diapazonų, kuriuos Docker suteikia savo konteineriams; ir daugiaadresis DNS (prievadas 5353), kuris leidžia spausdintuvams ir kitiems jūsų tinklo įrenginiams rasti vieniems kitus ir taip pat ten paskelbia jūsų kompiuterio pavadinimą. Be šių, ugniasienė išlaiko standartinius UFW leidimus ping, adresui iš jūsų maršrutizatoriaus gauti (DHCP) ir UPnP aptikimui. Net ssh yra išjungtas, kol jo neįjungsite per _Sąranka > Saugumas > SSHD_, o tai autorizuoja jūsų SSH raktą, išjungia prisijungimą slaptažodžiu ir tik tada atidaro 22 prievadą (su spartos ribojimu prieš brutalios jėgos atakas). Mes netgi apribojame Docker prieigą naudodami [ufw-docker](https://github.com/chaifeng/ufw-docker) sąranką, kad jūsų konteineriai netyčia nebūtų atviri pasauliui.
3. *Arch visada turi naujausius atnaujinimus*: Arch, pagrindinė distribucija, kuria remiasi Omarchy, yra slenkančio leidimo distribucija. Tai reiškia, kad bet kuris saugumo pažeidžiamumas, aptiktas ir ištaisytas bet kuriame pakete, greitai tampa prieinamas įdiegti naudojant `omarchy-update`. Taip visada naudojate naujausias, saugiausias visko versijas.
4. *Omarchy prižiūri savo paketus ir veidrodį*: Omarchy pagal numatytuosius nustatymus remiasi tik paketais iš pačios Arch core/extra/multilib saugyklų (ARM kompiuteriuose – Arch Linux ARM, o Apple Silicon – dar ir Asahi ALARM) ir savo Omarchy Package Repository. Programinę įrangą galite įdiegti tiesiogiai iš AUR, tačiau bazinė įdiegtis to nedaro – tik keli pasirenkami diegimai, pavyzdžiui, trečiųjų šalių naršyklės, naudoja AUR.
5. *Cloudflare saugo mus nuo DDoS*: Omarchy platinimo infrastruktūra – ISO, Omarchy paketai, Arch veidrodis – yra apsaugota už tvirto Cloudflare DDoS skydo ir talpinama jų CDN. Tai užtikrina puikų prieinamumą.

## Slaptažodžių keitimas

Šifruotoje įdiegtyje turite du slaptažodžius: vieną, kuris atrakina diską įkrovos metu, ir kitą, kuriuo prisijungiate ir naudojate `sudo`. Sąranka nustato juos vienodus. Abu galima pakeisti Omarchy meniu skiltyje _Atnaujinimas > Slaptažodis_ – _Disko šifravimas_ pirmajam, _Naudotojas_ antrajam. Keičiant disko slaptažodį pirmiausia prašoma dabartinio, todėl turėkite jį po ranka. Jei keitimas nutrūksta, dar kartą paleiskite _Disko šifravimas_: bus paprašyta slaptažodžio, kuriuo dabar atrakinamas diskas, ir keitimas bus užbaigtas.

## Jau naudoto kompiuterio perdavimas

Jei perduodate savo kompiuterį kam nors kitam, jums nereikia jo įdiegti iš naujo. Paleiskite _Šalinimas > Gamyklinis atstatymas_ Omarchy meniu, įveskite `reset`, kad patvirtintumėte, įveskite disko šifravimo slaptažodį, jei prašoma, ir paleiskite iš naujo. Tai ištrina kiekvieną naudotojo paskyrą ir viską, kas yra `/home`, pašalina visus paketus ir sistemos pakeitimus, kuriuos atlikote po įdiegimo, ir išvalo kompiuterio tapatybę – tinklo ryšius, pagrindinio kompiuterio raktus ir viską. Kas pasileidžia iš naujo, tai sąrankos vedlys iš pirmosios įkrovos, pasirengęs naujajam savininkui įvesti savo vardą, slaptažodį ir šifravimo slaptažodį.

Tai veikia atkuriant bazinę momentinę kopiją, kurią sukuria diegimo programa, todėl prieinama tik kompiuteriuose, įdiegtuose iš Omarchy ISO. O diske be šifravimo atstatymas yra ištrynimas, o ne saugus ištrynimas, todėl, jei duomenys buvo jautrūs, vietoj to atlikite naują įdiegimą.

## Sudo be slaptažodžio

Kartais norite, kad `sudo` nustotų klausti, dažniausiai kai AI agentas už jus atlieka ilgą sistemos darbo ruožą. _Sąranka > Saugumas > Sudo be slaptažodžio_ klausia, kiek laiko leisti prieigą: **15 minučių**, **1 Hour**, **1 Day** arba **Nuolat**. Kol prieiga aktyvi, šalia kitų meniu juostos indikatorių atsiranda raudona įspėjimo piktograma. Spustelėkite ją arba dar kartą paleiskite komandą, kad išjungtumėte prieigą. Taip pat galite nurodyti savo minučių skaičių (nuo 1 iki 1440) naudodami `omarchy-sudo-passwordless 30` arba naudoti `omarchy-sudo-passwordless permanent`.

Laikina prieiga baigiasi automatiškai, taip pat iškart po grįžimo iš pristabdymo, kuris peržengė terminą. Kompiuterio paleidimas iš naujo ją užbaigia anksčiau laiko. Nuolatinė prieiga išlieka po perkrovimų ir lieka įjungta, kol jos neišjungsite.

Omarchy nustatymų paketo atnaujinimas arba pašalinimas užbaigia bet kurį laikiną leidimą prieš pasikeičiant jo galiojimo pabaigos palaikymui. Jei komanda praneša apie autorizacijos arba išvalymo klaidą, išspręskite ją prieš bandydami įjungti kitą leidimą; klaida nereiškia, kad prieiga be slaptažodžio yra neaktyvi.

Žvelkite į tai blaiviai: kol tai įjungta, viskas, kas veikia kaip jūsų naudotojas, gali daryti bet ką kaip root, neklausdama. Tai ir yra visa esmė, ir tai taip pat yra visa rizika.

## Pasirašymo raktai

Viešasis raktas, skirtas visiems ISO parašams ir Omarchy saugyklos paketui, yra `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([patikrinkite openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakete `omarchy/omarchy-keyring` taip pat yra šis raktas, ir jis bus naudojamas sklandžiai įdiegiant bet kuriuos galimus atnaujinimus.

Bet kurio ISO leidimo parašą galite rasti pridėję `.sig` prie jo URL, pavyzdžiui, `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
