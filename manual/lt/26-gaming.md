# Žaidimai

Omarchy skirta ne tik _pRoDUcTiVItY_, bet ir pramogoms, o kas smagiau nei žaidimai? Omarchy pristatoma su visu žaidimų pasirinkimų rinkiniu — Steam ir RetroArch native ir retro žaidimui, Battle.net, Lutris ir Heroic ne Steam parduotuvėms, Moonlight PC srautiniam perdavimui, Xbox Cloud Gaming + NVIDIA GeForce NOW debesiui, plius niekada nesenstančiu Minecraft.

Valve neįtikėtino darbo su [proton suderinamumo sluoksniu](https://en.wikipedia.org/wiki/Proton_(software)) dėka dabar Linux galima žaisti dešimtis tūkstančių šiuolaikinių žaidimų. O, ir ar žinojai, kad [Steam Deck](https://store.steampowered.com/steamdeck/) iš tikrųjų veikia su Arch!

Visi žaidimų diegikliai gyvena Omarchy meniu skiltyje _Įdiegti > Gaming_ (`Super + Space`). Jei kada norėsi atšaukti vieną iš jų, naudok _Pašalinti > Gaming_.

## Steam

Įdiek [Steam](https://store.steampowered.com/) pasirinkdamas _Įdiegti > Gaming > Steam_ iš Omarchy meniu (`Super + Space`).

Kai jį įdiegsi, Steam galėsi paleisti su `Super + Space`.

Atmink, kad Steam gali užtrukti 10-20 sekundžių, kol pasileis, ir jis neteiks jokio vaizdinio grįžtamojo ryšio, kad kraunasi.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Įdiek [RetroArch](https://www.retroarch.com/) pasirinkdamas _Įdiegti > Gaming > RetroArch_ iš Omarchy meniu (`Super + Space`). Jis pristatomas su pilnu libretro branduolių rinkiniu, tad visos klasikinės sistemos aprėptos.

RetroArch yra pilnai iš anksto sukonfigūruotas su gražiuoju CRT Royale shader tobulai retro išvaizdai.

Kad pradėtum:

1. Numesk savo BIOS failus į `~/Games/bios`, o ROM į `~/Games/roms`.
2. Paleisk RetroArch su `Super + Space` ir įvedęs `retro`.
3. Nuskaityk katalogą `~/Games/roms` ir esi pasiruošęs žaisti.

Taip pat gali mėgstamam žaidimui suteikti atskirą įrašą programų paleidimo priemonėje su _Įdiegti > Gaming > RetroArch Game Launcher_, kuris leidžia pasirinkti branduolį ir ROM bei šokti tiesiai į žaidimą iš `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Įdiek Xbox Cloud Gaming žiniatinklio programą pasirinkdamas _Įdiegti > Gaming > Xbox Cloud Gaming_ iš Omarchy meniu (`Super + Space`). Tai "tiesiog" paslaugos žiniatinklio programa, bet ji greitai paleidžiama ir puikiai veikia 1080p.

Jei jau turi Xbox Game Pass, tai solidus būdas žaisti Fortnite ir kitus pavadinimus, kurių negali paleisti native Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Įdiek debesies žaidimų paslaugą [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) pasirinkdamas _Įdiegti > Gaming > NVIDIA GeForce NOW_ iš Omarchy meniu (`Super + Space`). Dar vienas puikus būdas žaisti pavadinimus, kurie neprieinami native Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Įdiek Minecraft pasirinkdamas _Įdiegti > Gaming > Minecraft_ iš Omarchy meniu (`Super + Space`).

Kaip ir Steam, atmink, kad po prisijungimo ar paleidimo gali užtrukti, kol pasirodys kitas ekranas, ir kol lauksi, negausi jokio grįžtamojo ryšio.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox valdikliai

Įdiek Bluetooth Xbox valdiklių palaikymą pasirinkdamas _Įdiegti > Gaming > Xbox Controllers_ iš Omarchy meniu (`Super + Space`). Suporuok valdiklius per Bluetooth (`Super + Ctrl + B`) ir jie veiks visuose tavo žaidimuose. Tau to nereikia, jei valdiklis tiesiog prijungtas USB-C laidu.

## Moonlight (žaidimų srautinis perdavimas iš PC)

[Moonlight klientas](https://github.com/moonlight-stream/moonlight-qt) pristatomas iš anksto įdiegtas su Omarchy, tad gali iškart srautiniu būdu perduoti žaidimus iš Windows PC, kuriame veikia [Sunshine](https://app.lizardbyte.dev/Sunshine/). Paleisk Moonlight per `Super + Space`.

Jei ir tavo Omarchy mašina, ir nuotolinis žaidimų PC yra laidiniai, patirtis neatskiriama nuo žaidimo vietoje. Pakelk raišką iki native, nustatyk atnaujinimą 120Hz ir maksimalų bitrate — tai geriausias būdas žaisti varžybinius šaudyklų žaidimus, pavyzdžiui, Fortnite, Linux sistemoje.

Taip pat gali Omarchy mašiną paversti šeimininke paleidęs `omarchy install service sunshine`, kuris įdiegia Sunshine ir atveria Moonlight srautinio perdavimo portus tavo LAN ir Tailscale.

## Battle.net

Įdiek [Battle.net](https://eu.shop.battle.net/en-us) pasirinkdamas _Įdiegti > Gaming > Battle.net_ iš Omarchy meniu (`Super + Space`). Tai suteikia tokius pavadinimus kaip Diablo, Starcraft ir World of Warcraft kaip savarankišką diegimą, veikiantį su GE-Proton — nereikia Steam, Lutris ar Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows žaidimai)

Įdiek [Lutris](https://lutris.net/) pasirinkdamas _Įdiegti > Gaming > Lutris_ iš Omarchy meniu (`Super + Space`). Lutris yra būdas žaisti Windows žaidimus iš parduotuvių, pavyzdžiui, EA ir Ubisoft Connect, kurios neturi savo diegiklio aukščiau.

Diegimas yra šiek tiek netobulas ir kartais atrodo, kad niekas nevyksta — tiesiog būk kantrus, tai veikia fone.

## Heroic Launcher (Epic Games)

Įdiek [Heroic Launcher](https://heroicgameslauncher.com/) pasirinkdamas _Įdiegti > Gaming > Heroic (Epic Games)_ iš Omarchy meniu (`Super + Space`). Heroic leidžia paleisti Epic Games pavadinimus, pavyzdžiui, OddSparks, kurie nesiremia anti-cheat — plius žaidimus iš GOG ir Amazon Prime Gaming. Deja, tai reiškia jokio Fortnite ir jokio Rocket League — kol Tim Sweeney neateis į Linux, tai arčiausiai, kiek galima.

Kaip ir Lutris, diegiant žaidimus jis gali atrodyti lėtas ir netobulas. Duok jam laiko.
