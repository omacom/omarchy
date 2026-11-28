# Saugumas

Omarchy į saugumą žiūri nepaprastai rimtai. Tai turi būti operacinė sistema, kurią galite naudoti _Tikram darbui_ _Tikrame pasaulyje_ atlikti. Tokioje, kurioje nešiojamojo kompiuterio pametimas negali virsti saugumo krize. Štai ką mes darome:

1. *Visiškas disko šifravimas pagal numatytuosius nustatymus yra įjungtas*: tai svarbiausias žingsnis užtikrinant fizinę jūsų duomenų apsaugą. Jei jūsų kompiuteris pametamas arba pavagiamas, duomenys yra visiškai užšifruoti naudojant standartinį LUKS (Linux Unified Key Setup). Diegimo programa leidžia to atsisakyti vienkartiniams kompiuteriams (žr. [Pradžia](02-getting-started.md)); įdiegtis be šifravimo šios apsaugos neturi, ir bet kas, kas turi diską, gali jį perskaityti.
2. *Ugniasienė pagal numatytuosius nustatymus yra įjungta*: visas įeinantis srautas pagal numatytuosius nustatymus yra blokuojamas, išskyrus kelias išimtis: 53317 prievadą, skirtą [LocalSend](https://localsend.org/); DNS užklausas į paties kompiuterio vardų serverį Docker tilto adresu (172.17.0.1), priimamas iš privačių adresų diapazonų, kuriuos Docker suteikia savo konteineriams; ir daugiaadresį DNS (5353 prievadą), kuris leidžia spausdintuvams ir kitiems jūsų tinklo įrenginiams rasti vieniems kitus ir ten taip pat paskelbia jūsų kompiuterio pavadinimą. Be to, ugniasienė išlaiko standartinius UFW leidimus ping, adresui iš maršrutizatoriaus gauti (DHCP) ir UPnP aptikimui. Net ssh yra išjungtas, kol jo neįjungsite per _Sąranka > Saugumas > SSHD_: tai autorizuoja jūsų SSH raktą, išjungia prisijungimus slaptažodžiu ir tik tada atveria 22 prievadą (su dažnio ribojimu nuo brutalios jėgos atakų). Mes net apribojame Docker prieigą naudodami [ufw-docker](https://github.com/chaifeng/ufw-docker) sąranką, kad jūsų konteineriai netyčia nebūtų atverti pasauliui.
3. *Arch visada turi naujausius atnaujinimus*: Arch, bazinė distribucija, kuria remiasi Omarchy, yra nuolat atnaujinama distribucija. Tai reiškia, kad bet kuri saugos spraga, aptikta ir pataisyta bet kuriame pakete, yra greitai prieinama įdiegti naudojant `omarchy-update`. Taip jūs visada naudojate naujausias, saugiausias visko versijas.
4. *Omarchy prižiūri savo paketus ir veidrodį*: Omarchy pagal numatytuosius nustatymus remiasi tik paketais iš pačių Arch core/extra/multilib saugyklų (ARM kompiuteriuose – Arch Linux ARM, o Apple Silicon kompiuteriuose – dar ir Asahi ALARM) ir savo Omarchy Package Repository. Programinę įrangą galite įdiegti tiesiai iš AUR, bet bazinė įdiegtis to nedaro – tik kelios pasirenkamos įdiegtys, pavyzdžiui, trečiųjų šalių naršyklės, yra paimamos iš AUR.
5. *Cloudflare apsaugo mus nuo DDoS*: Omarchy platinimo infrastruktūra – ISO, Omarchy paketai, Arch veidrodis – yra apsaugota galingu Cloudflare DDoS skydu ir talpinama jų CDN. Tai užtikrina puikų pasiekiamumą.

## Slaptažodžių keitimas

Šifruotoje įdiegtyje turite du slaptažodžius: vieną, kuris paleidžiant atrakina diską, ir kitą, kuriuo prisijungiate ir naudojate `sudo`. Sąranka juos padaro vienodus. _Atnaujinimas > Slaptažodis_ Omarchy meniu pakeičia abu vienu metu, todėl jie lieka vienodi: jis paprašo dabartinio disko slaptažodžio, tada naujojo, pakeičia disko slaptažodį ir tada nustato jūsų prisijungimo slaptažodį tokį patį. Be disko šifravimo jis pakeičia tik jūsų prisijungimo slaptažodį. Jei keitimas nutrūksta, vėl paleiskite _Atnaujinimas > Slaptažodis_: jis paprašys slaptažodžio, kuris dabar atrakina diską, užbaigs keitimą ir nustatys jūsų prisijungimo slaptažodį tokį patį. Norėdami pakeisti kito užšifruoto disko slaptažodį, terminale paleiskite `omarchy-drive-password`.

## Jau naudoto kompiuterio perdavimas kitam

Jei savo kompiuterį perduodate kam nors kitam, jums nereikia jo iš naujo įdiegti. Omarchy meniu paleiskite _Pašalinimas > Gamyklinis atstatymas_, patvirtinimui įveskite `reset`, jei būsite paraginti, įveskite disko šifravimo slaptažodį ir perkraukite kompiuterį. Tai išvalo visas naudotojų paskyras ir viską, kas yra `/home`, pašalina visus paketus ir sistemos pakeitimus, kuriuos padarėte po įdiegimo, ir išvalo kompiuterio tapatybę – tinklo ryšius, pagrindinio kompiuterio raktus ir visa kita. Vėl įsijungs sąrankos vedlys iš pirmojo paleidimo, paruoštas naujam savininkui įvesti savo vardą, slaptažodį ir šifravimo slaptažodį.

Tai veikia atkuriant pradinę momentinę kopiją, kurią sukuria diegimo programa, todėl prieinama tik kompiuteriuose, įdiegtuose iš Omarchy ISO. O diske be šifravimo atstatymas yra ištrynimas, o ne saugus išvalymas, todėl jei duomenys buvo jautrūs, verčiau įdiekite sistemą iš naujo.

## Sudo be slaptažodžio

Kartais norite, kad `sudo` nustotų klausinėti, dažniausiai tada, kai dirbtinio intelekto agentas už jus ilgą laiką dirba sistemos darbus. _Sąranka > Saugumas > Sudo be slaptažodžio_ paklausia, kiek laiko leisti prieigą: **15 minučių**, **1 valanda**, **1 diena** arba **Visam laikui**. Kol prieiga yra aktyvi, šalia kitų meniu juostos indikatorių rodoma raudona įspėjimo piktograma. Spustelėkite ją arba dar kartą paleiskite komandą, kad prieigą išjungtumėte. Taip pat galite nurodyti savo minučių skaičių (nuo 1 iki 1440) naudodami `omarchy-sudo-passwordless 30` arba naudoti `omarchy-sudo-passwordless permanent`.

Laikinos prieigos galiojimas baigiasi automatiškai, taip pat ir iš karto po pabudimo iš pristabdymo, kurio metu buvo praleistas terminas. Kompiuterio perkrovimas ją nutraukia anksčiau laiko. Nuolatinė prieiga išlieka po perkrovimų ir lieka įjungta, kol jos neišjungsite.

Omarchy nustatymų paketo atnaujinimas arba pašalinimas nutraukia bet kokį laikiną leidimą prieš pasikeičiant jo galiojimo pabaigos palaikymui. Jei komanda praneša apie autorizavimo arba išvalymo klaidą, pašalinkite ją prieš bandydami įjungti kitą leidimą; klaida nereiškia, kad prieiga be slaptažodžio yra neaktyvi.

Į šitą žiūrėkite blaiviai: kol tai įjungta, viskas, kas veikia su jūsų naudotojo teisėmis, gali nieko neklausdama daryti bet ką kaip root. Tai yra visa esmė, ir tai yra ir visa rizika.

## Pasirašymo raktai

Viešasis raktas visiems ISO parašams ir Omarchy repo paketui yra `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([patikrinti openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakete `omarchy/omarchy-keyring` jis taip pat yra ir bus naudojamas visiems galimiems atnaujinimams sklandžiai paskleisti.

Bet kurio ISO leidimo parašą galite rasti prie jo URL pridėję `.sig`, pavyzdžiui, `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
