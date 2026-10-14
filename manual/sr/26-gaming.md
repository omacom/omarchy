# Игре

Omarchy није само за _pRoDUcTiVItY_, већ и за забаву, а шта је забавније од игара? Omarchy долази са целим пакетом опција за игре — Steam и RetroArch за изворно и ретро играње, Battle.net, Lutris и Heroic за продавнице које нису Steam, Moonlight за стриминг са PC-ја, Xbox Cloud Gaming + NVIDIA GeForce NOW за облак, плус вечни Minecraft.

Захваљујући невероватном раду компаније Valve на [слоју компатибилности proton](https://en.wikipedia.org/wiki/Proton_(software)), сада постоје десетине хиљада модерних игривих игара на Linux-у. А, и да ли сте знали да [Steam Deck](https://store.steampowered.com/steamdeck/) заправо покреће Arch!

Сви инсталатери за игре живе под _Инсталирај > Gaming_ у Omarchy менију (`Super + Space`). Ако икада желите да поништите неки, користите _Уклони > Gaming_.

## Steam

Инсталирајте [Steam](https://store.steampowered.com/) избором _Инсталирај > Gaming > Steam_ из Omarchy менија (`Super + Space`).

Након што га инсталирате, моћи ћете да покренете Steam помоћу `Super + Space`.

Имајте у виду да Steam-у може требати 10-20 секунди да се покрене и да неће пружити никакву визуелну повратну информацију да се учитава.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Инсталирајте [RetroArch](https://www.retroarch.com/) избором _Инсталирај > Gaming > RetroArch_ из Omarchy менија (`Super + Space`). Долази са пуним сетом libretro језгара, па су сви класични системи покривени.

RetroArch је у потпуности унапред конфигурисан лепим CRT Royale шејдером за савршен ретро изглед.

За почетак:

1. Ставите BIOS датотеке у `~/Games/bios`, а ROM-ове у `~/Games/roms`.
2. Покрените RetroArch помоћу `Super + Space` и куцањем `retro`.
3. Скенирајте директоријум `~/Games/roms` и спремни сте за игру.

Омиљеној игри можете дати и сопствени унос у покретачу апликација помоћу _Инсталирај > Gaming > RetroArch Game Launcher_, што вам омогућава да изаберете језгро и ROM и скочите директно у игру из `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Инсталирајте веб апликацију Xbox Cloud Gaming избором _Инсталирај > Gaming > Xbox Cloud Gaming_ из Omarchy менија (`Super + Space`). То је „само“ веб апликација за сервис, али се брзо покреће и одлично ради у 1080p.

Ако већ имате Xbox Game Pass, ово је солидан начин да играте Fortnite и друге наслове које не можете изворно покренути на Linux-у.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Инсталирајте сервис за игре у облаку [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) избором _Инсталирај > Gaming > NVIDIA GeForce NOW_ из Omarchy менија (`Super + Space`). Још један одличан начин да играте наслове који нису доступни изворно на Linux-у.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Инсталирајте Minecraft избором _Инсталирај > Gaming > Minecraft_ из Omarchy менија (`Super + Space`).

Као и Steam, имајте у виду да након пријаве или покретања може проћи неко време пре него што се појави следећи екран и да нећете добити никакву повратну информацију док чекате.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox контролери

Инсталирајте подршку за Bluetooth Xbox контролере избором _Инсталирај > Gaming > Xbox Controllers_ из Omarchy менија (`Super + Space`). Упарите контролере преко Bluetooth-а (`Super + Ctrl + B`) и радиће у свим вашим играма. Ово вам не треба ако контролер само повезујете USB-C каблом.

## Moonlight (стриминг игара са PC-ја)

[Moonlight клијент](https://github.com/moonlight-stream/moonlight-qt) долази унапред инсталиран са Omarchy-јем, па одмах можете стримовати игре са Windows PC-ја који покреће [Sunshine](https://app.lizardbyte.dev/Sunshine/). Покрените Moonlight преко `Super + Space`.

Ако су и ваша Omarchy машина и удаљени PC за игре повезани каблом, искуство се не разликује од локалног играња. Подигните резолуцију на изворну, подесите освежавање на 120Hz и максимално повећајте битрејт — ово је најбољи начин да играте такмичарске шутере попут Fortnite-а на Linux-у.

Omarchy машину можете претворити и у хоста покретањем `omarchy install service sunshine`, што инсталира Sunshine и отвара Moonlight портове за стриминг за ваш LAN и Tailscale.

## Battle.net

Инсталирајте [Battle.net](https://eu.shop.battle.net/en-us) избором _Инсталирај > Gaming > Battle.net_ из Omarchy менија (`Super + Space`). Ово вам даје наслове попут Diablo, Starcraft и World of Warcraft као самосталну инсталацију која ради под GE-Proton-ом — Steam, Lutris или Heroic нису потребни.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows игре)

Инсталирајте [Lutris](https://lutris.net/) избором _Инсталирај > Gaming > Lutris_ из Omarchy менија (`Super + Space`). Lutris је начин да играте Windows игре из продавница попут EA и Ubisoft Connect које немају сопствени инсталатер изнад.

Инсталација је помало несигурна и понекад изгледа као да се ништа не дешава — само будите стрпљиви, ради у позадини.

## Heroic Launcher (Epic Games)

Инсталирајте [Heroic Launcher](https://heroicgameslauncher.com/) избором _Инсталирај > Gaming > Heroic (Epic Games)_ из Omarchy менија (`Super + Space`). Heroic вам омогућава да покрећете Epic Games наслове, попут OddSparks, који се не ослањају на anti-cheat — плус игре са GOG-а и Amazon Prime Gaming-а. Нажалост, то значи без Fortnite-а и без Rocket League-а — док Tim Sweeney не дође на Linux, ово је најближе што се може.

Као и Lutris, може деловати споро и несигурно током инсталације игара. Дајте му времена.
