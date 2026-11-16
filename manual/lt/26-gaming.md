# Žaidimai

Omarchy skirta ne tik _pRoDUcTiVItY_, bet ir pramogoms, o kas smagiau už žaidimus? Omarchy pateikiama su visu žaidimų parinkčių rinkiniu — Steam ir RetroArch vietiniams ir retro žaidimams, Battle.net, Lutris ir Heroic parduotuvėms ne Steam, Moonlight transliavimui iš PC, Xbox Cloud Gaming + NVIDIA GeForce NOW debesies žaidimams ir dar amžinai žaliuojantis Minecraft.

Valve atlikto neįtikėtino darbo su [Proton suderinamumo sluoksniu](https://en.wikipedia.org/wiki/Proton_(software)) dėka Linux sistemoje dabar galima žaisti dešimtis tūkstančių šiuolaikinių žaidimų. O, ir ar žinojote, kad [Steam Deck](https://store.steampowered.com/steamdeck/) iš tikrųjų veikia su Arch!

Visi žaidimų diegimo įrankiai yra Omarchy meniu skiltyje _Install > Gaming_ (`Super + Space`). Jei kada nors norėsite kurį nors iš jų atšaukti, naudokite _Remove > Gaming_.

## Steam

Įdiekite [Steam](https://store.steampowered.com/) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Steam_.

Įdiegę galėsite paleisti Steam paspaudę `Super + Space`.

Atkreipkite dėmesį, kad Steam paleidimas gali užtrukti 10-20 sekundžių ir ji nerodys jokio vaizdinio signalo, kad kraunasi.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Įdiekite [RetroArch](https://www.retroarch.com/) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > RetroArch_. Ji pateikiama su visu libretro branduolių rinkiniu, taigi palaikomos visos klasikinės sistemos.

RetroArch yra visiškai iš anksto sukonfigūruota su gražiuoju CRT Royale šeideriu, kad tas tobulas retro vaizdas būtų pasiektas.

Norėdami pradėti:

1. Įkelkite BIOS failus į `~/Games/bios`, o ROM failus į `~/Games/roms`.
2. Paleiskite RetroArch paspaudę `Super + Space` ir įvedę `retro`.
3. Nuskaitykite `~/Games/roms` katalogą ir galite žaisti.

Mėgstamiausiam žaidimui taip pat galite suteikti atskirą įrašą programų paleidyklėje naudodami _Install > Gaming > RetroArch Game Launcher_ — tai leis pasirinkti branduolį ir ROM ir iškart pereiti į žaidimą paspaudus `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Įdiekite Xbox Cloud Gaming žiniatinklio programą Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Xbox Cloud Gaming_. Tai „tik“ paslaugos žiniatinklio programa, bet ji greitai paleidžiama ir puikiai veikia 1080p raiška.

Jei jau turite Xbox Game Pass, tai tvirtas būdas žaisti Fortnite ir kitus žaidimus, kurių negalite paleisti vietiškai Linux sistemoje.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Įdiekite debesies žaidimų paslaugą [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > NVIDIA GeForce NOW_. Tai dar vienas puikus būdas žaisti žaidimus, kurių nėra vietiškai Linux sistemoje.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Įdiekite Minecraft Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Minecraft_.

Kaip ir Steam atveju, atkreipkite dėmesį, kad prisijungus ar paleidus gali praeiti šiek tiek laiko, kol pasirodys kitas ekranas, ir laukdami negausite jokio signalo.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox valdikliai

Įdiekite Bluetooth Xbox valdiklių palaikymą Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Xbox Controllers_. Suporuokite valdiklius per Bluetooth (`Super + Ctrl + B`) ir jie veiks visuose jūsų žaidimuose. To nereikia, jei valdiklį tiesiog prijungiate USB-C kabeliu.

## Moonlight (žaidimų transliavimas iš PC)

Įdiekite [Moonlight klientą](https://github.com/moonlight-stream/moonlight-qt) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Moonlight_ ir galėsite transliuoti žaidimus iš Windows PC, kuriame veikia [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Jei tiek jūsų Omarchy kompiuteris, tiek nuotolinis žaidimų PC yra prijungti kabeliu, potyris bus neatskiriamas nuo žaidimo vietoje. Padidinkite raišką iki vietinės, nustatykite atnaujinimo dažnį į 120Hz ir padidinkite bitų srautą iki maksimumo — tai geriausias būdas Linux sistemoje žaisti varžybines šaudyklės, tokias kaip Fortnite.

Omarchy kompiuterį taip pat galite paversti pagrindiniu kompiuteriu paleidę `omarchy install service sunshine` — tai įdiegs Sunshine ir atvers Moonlight transliavimo prievadus jūsų LAN ir Tailscale tinklams.

## Battle.net

Įdiekite [Battle.net](https://eu.shop.battle.net/en-us) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Battle.net_. Taip gausite tokius žaidimus kaip Diablo, Starcraft ir World of Warcraft kaip atskirą diegimą, veikiantį su GE-Proton — nereikia nei Steam, nei Lutris, nei Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows žaidimai)

Įdiekite [Lutris](https://lutris.net/) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Lutris_. Lutris — tai būdas žaisti Windows žaidimus iš tokių parduotuvių kaip EA ir Ubisoft Connect, kurios neturi savo pirmiau paminėto diegimo įrankio.

Diegimas vyksta šiek tiek kreivai ir kartais atrodo, kad nieko nevyksta — tiesiog būkite kantrūs, jis veikia fone.

## Heroic Launcher (Epic Games)

Įdiekite [Heroic Launcher](https://heroicgameslauncher.com/) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Heroic (Epic Games)_. Heroic leidžia paleisti Epic Games žaidimus, tokius kaip OddSparks, kurie nepriklauso nuo anti-cheat — taip pat žaidimus iš GOG ir Amazon Prime Gaming. Deja, tai reiškia jokio Fortnite ir jokio Rocket League — kol Tim Sweeney neateis į Linux, tai yra artimiausia, ką gausime.

Kaip ir Lutris, diegiant žaidimus jis gali atrodyti lėtas ir kreivas. Duokite jam laiko.
