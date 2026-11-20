# Žaidimai

Omarchy skirta ne tik _pRoDuKtYvUmUi_, ji skirta ir pramogai, o kas gali būti smagiau už žaidimus? Omarchy pateikiama su visu žaidimų parinkčių rinkiniu — Steam ir RetroArch vietiniams ir retro žaidimams, Battle.net, Lutris ir Heroic ne Steam parduotuvėms, Moonlight žaidimų srautiniam perdavimui iš kompiuterio, Xbox Cloud Gaming + NVIDIA GeForce NOW debesijos žaidimams ir dar visada aktualus Minecraft.

Valve nuostabaus darbo su [Proton suderinamumo sluoksniu](https://en.wikipedia.org/wiki/Proton_(software)) dėka dabar Linux sistemoje galima žaisti dešimtis tūkstančių šiuolaikinių žaidimų. O, ir ar žinojote, kad [Steam Deck](https://store.steampowered.com/steamdeck/) iš tikrųjų veikia su Arch!

Visi žaidimų diegimo įrankiai yra Omarchy meniu skiltyje _Install > Gaming_ (`Super + Space`). Jei kada nors norėsite kurį nors atšaukti, naudokite _Remove > Gaming_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris ir Heroic siūlomi tik x86 kompiuteriams.

## Steam

Įdiekite [Steam](https://store.steampowered.com/) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Steam_.

Įdiegę galėsite paleisti Steam paspaudę `Super + Space`.

Atkreipkite dėmesį, kad Steam paleidimas gali užtrukti 10-20 sekundžių ir ji nepateiks jokio vaizdinio atsako, kad kraunasi.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Įdiekite [RetroArch](https://www.retroarch.com/) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > RetroArch_. Ji pateikiama su visu libretro branduolių rinkiniu, todėl apimamos visos klasikinės sistemos.

RetroArch iš anksto visiškai sukonfigūruota su gražiu CRT Royale shader, kad retro išvaizda būtų tobula.

Norėdami pradėti:

1. Įkelkite savo BIOS failus į `~/Games/bios`, o ROM failus — į `~/Games/roms`.
2. Paleiskite RetroArch paspaudę `Super + Space` ir įvedę `retro`.
3. Nuskaitykite `~/Games/roms` katalogą ir būsite pasirengę žaisti.

Mėgstamam žaidimui taip pat galite sukurti atskirą įrašą programų paleidyklėje naudodami _Install > Gaming > RetroArch Game Launcher_, kuri leidžia pasirinkti branduolį ir ROM ir iškart pereiti į žaidimą paspaudus `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Įdiekite Xbox Cloud Gaming žiniatinklio programą Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Xbox Cloud Gaming_. Tai „tiesiog“ šios paslaugos žiniatinklio programa, bet ji greitai paleidžiama ir puikiai veikia 1080p raiška.

Jei jau turite Xbox Game Pass, tai tvirtas būdas žaisti Fortnite ir kitus žaidimus, kurių negalite paleisti vietiškai Linux sistemoje.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Įdiekite debesijos žaidimų paslaugą [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > NVIDIA GeForce NOW_. Dar vienas puikus būdas žaisti žaidimus, kurių nėra vietiškai Linux sistemoje.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Įdiekite Minecraft Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Minecraft_.

Kaip ir Steam atveju, atkreipkite dėmesį, kad prisijungus arba paleidus gali praeiti šiek tiek laiko, kol pasirodys kitas ekranas, ir laukdami negausite jokio atsako.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox valdikliai

Įdiekite Bluetooth Xbox valdiklių palaikymą Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Xbox Controllers_. Suporuokite valdiklius per Bluetooth (`Super + Ctrl + B`) ir jie veiks visuose jūsų žaidimuose. Jums to nereikia, jei valdiklį tiesiog prijungiate USB-C kabeliu.

## Moonlight (žaidimų srautinis perdavimas iš kompiuterio)

Įdiekite [Moonlight klientą](https://github.com/moonlight-stream/moonlight-qt) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Moonlight_ ir galėsite srautiniu būdu perduoti žaidimus iš Windows kompiuterio, kuriame veikia [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Jei ir jūsų Omarchy kompiuteris, ir nuotolinis žaidimų kompiuteris yra prijungti kabeliu, patirtis bus neatskiriama nuo žaidimo vietiškai. Padidinkite raišką iki vietinės, nustatykite atnaujinimo dažnį į 120Hz ir maksimaliai padidinkite bitų spartą — tai geriausias būdas žaisti konkurencingas šaudykles, tokias kaip Fortnite, Linux sistemoje.

Omarchy kompiuterį taip pat galite paversti pagrindiniu kompiuteriu paleidę `omarchy install service sunshine`, kuri įdiegia Sunshine ir atidaro Moonlight srautinio perdavimo prievadus jūsų LAN ir Tailscale.

## Battle.net

Įdiekite [Battle.net](https://eu.shop.battle.net/en-us) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Battle.net_. Taip gausite tokius žaidimus kaip Diablo, Starcraft ir World of Warcraft kaip atskirą diegimą, veikiantį su GE-Proton — Steam, Lutris ar Heroic nereikia.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows žaidimai)

Įdiekite [Lutris](https://lutris.net/) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Lutris_. Lutris yra būdas žaisti Windows žaidimus iš tokių parduotuvių kaip EA ir Ubisoft Connect, kurios neturi savo diegimo programos aukščiau.

Diegimas yra šiek tiek gremėzdiškas ir kartais atrodo, kad nieko nevyksta — tiesiog būkite kantrūs, jis veikia fone.

## Heroic Launcher (Epic Games)

Įdiekite [Heroic Launcher](https://heroicgameslauncher.com/) Omarchy meniu (`Super + Space`) pasirinkdami _Install > Gaming > Heroic (Epic Games)_. Heroic leidžia paleisti Epic Games žaidimus, tokius kaip OddSparks, kurie nesiremia apsauga nuo sukčiavimo — ir dar žaidimus iš GOG ir Amazon Prime Gaming. Deja, tai reiškia, kad nebus Fortnite ir nebus Rocket League — kol Tim Sweeney neateis į Linux, tai yra arčiausiai, kiek galima priartėti.

Kaip ir Lutris atveju, diegiant žaidimus ji gali atrodyti lėta ir gremėzdiška. Skirkite jai laiko.
