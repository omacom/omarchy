# Sauga

Omarchy į saugą žiūri nepaprastai rimtai. Tai turėtų būti operacinė sistema, kurią gali naudoti _Tikram Darbui_ _Tikrame Pasaulyje_. Kur nešiojamojo praradimas negali sukelti saugos ekstremalios situacijos. Štai ką mes darome:

1. *Pilno disko šifravimas privalomas*: tai svarbiausias žingsnis tavo duomenų fizinei apsaugai užtikrinti. Jei tavo kompiuteris prarastas ar pavogtas, duomenys pilnai užšifruoti naudojant standartinį LUKS (Linux Unified Key Setup).
2. *Ugniasienė pagal numatytuosius įjungta*: visas įeinantis srautas pagal numatytuosius blokuojamas, išskyrus prievadą 53317 [LocalSend](https://localsend.org/). Net ssh išjungtas, kol jo neįjungi per _Nuostatos > Sauga > SSHD_ — tai sąrankos dalyje atidaro 22 prievadą (su apsauga nuo brutalios jėgos). Net Docker prieigą užrakiname naudodami [ufw-docker](https://github.com/chaifeng/ufw-docker) sąranką, kad tavo konteineriai atsitiktinai neatsivertų pasauliui.
3. *Arch visada turi naujausius naujinimus*: Arch, pamatinis distras, ant kurio pastatyta Omarchy, yra riedantis distras. Tai reiškia, kad bet kuri saugos spraga, atrasta ir pataisyta bet kuriame pakete, greitai pasiekiama įdiegimui naudojant `omarchy-update`. Taip visada naudoji naujausias, saugiausias visko versijas.
4. *Omarchy prižiūri savus paketus ir veidrodį*: Omarchy pagal numatytuosius remiasi tik paketais iš paties Arch core/extra/multilib saugyklų ir savo Omarchy paketų saugyklos. Programinę įrangą gali įdiegti tiesiai iš AUR, bet bazinis įdiegimas to nedaro — tik keli pasirinktiniai įdiegimai, pavyzdžiui, trečiųjų šalių naršyklės, traukia iš AUR.
5. *Cloudflare saugo mus nuo DDoS*: visa Omarchy platinimo infrastruktūra — ISO, Omarchy paketai, Arch veidrodis — apsaugota už galingo Cloudflare DDoS skydo ir talpinama jų CDN. Tai suteikia puikų pasiekiamumą.

## Slaptažodžių keitimas

Užšifruotame įdiegime turi du slaptažodžius: tą, kuris įkrovos metu atrakina diską, ir tą, su kuriuo prisijungi ir `sudo`. Sąranka juos padaro vienodus. Abu galima keisti Omarchy meniu po _Atnaujinti > Slaptažodis_ — pirmąjį _Disko šifravimas_, antrąjį _Vartotojas_. Disko slaptažodžio keitimas pirmiausia paprašo dabartinio, todėl turėk jį po ranka. Jei keitimas pertraukiamas, vėl paleisk _Disko šifravimas_: jis paprašys slaptažodžio, kuris diską atrakina dabar, ir užbaigs keitimą.

## Jau naudoto kompiuterio perdavimas

Jei savo kompiuterį perduodi kam nors kitam, tau nereikia jo iš naujo įdiegti. Omarchy meniu paleisk _Nuostatos > Atstatyti kompiuterį_, patvirtinimui įrašyk `reset` ir perkrauk. Tai ištrina kiekvieną vartotojo paskyrą ir viską `/home`, išmeta visus paketus ir sistemos pakeitimus, kuriuos padarei nuo įdiegimo, ir išvalo kompiuterio tapatybę — tinklo ryšius, šeimininko raktus ir visa kita. Grįžta pirmosios įkrovos sąrankos vediklis, pasiruošęs naujam savininkui įvesti savo vardą, slaptažodį ir šifravimo slaptažodį.

Tai veikia atkuriant bazinę momentinę kopiją, kurią daro įdiegyklė, todėl prieinama tik kompiuteriuose, įdiegtuose iš Omarchy ISO. O diske be šifravimo atstatymas yra ištrynimas, o ne saugus išvalymas, todėl jei duomenys buvo jautrūs, vietoj to daryk švarų įdiegimą.

## Sudo be slaptažodžio

Kartais nori, kad `sudo` nustotų klausinėti, dažniausiai kai DI agentas už tave daro ilgą sistemos darbų atkarpą. _Nuostatos > Sauga > Sudo be slaptažodžio_ klausia, kiek laiko leisti prieigą: **15 minučių**, **1 valandą**, **1 dieną** arba **Visam laikui**. Kol prieiga aktyvi, šalia kitų meniu juostos indikatorių atsiranda raudona įspėjimo piktograma. Spustelėk ją arba vėl paleisk komandą, kad prieigą išjungtum. Taip pat gali perduoti savą minučių skaičių (nuo 1 iki 1440) su `omarchy-sudo-passwordless 30` arba naudoti `omarchy-sudo-passwordless permanent`.

Laikina prieiga pasibaigia automatiškai, įskaitant iškart po pabudimo iš pristabdymo, perėjusio terminą. Kompiuterio perkrovimas ją užbaigia anksčiau. Nuolatinė prieiga išlieka per perkrovimus ir lieka įjungta, kol ją išjungi.

Omarchy nuostatų paketo atnaujinimas ar pašalinimas užbaigia bet kurį laikiną leidimą prieš pasikeičiant jo galiojimo palaikymui. Jei komanda praneša apie autorizavimo ar valymo klaidą, išspręsk ją prieš bandydamas įjungti kitą leidimą; klaida nereiškia, kad prieiga be slaptažodžio neaktyvi.

Žiūrėk į šį aiškiomis akimis: kol jis įjungtas, viskas, kas veikia kaip tavo vartotojas, gali viską daryti kaip root be klausimo. Tai visa esmė, ir tai taip pat visa rizika.

## Pasirašymo raktai

Visų ISO parašų ir Omarchy saugyklos paketų viešas raktas yra `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([patikrinti openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paketas `omarchy/omarchy-keyring` taip pat jį turi ir bus naudojamas bet kokiems galimiems naujinimams sklandžiai išskleisti.

Bet kurio ISO leidimo parašą rasi prie URL pridėjęs .sig. Pavyzdžiui, https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
