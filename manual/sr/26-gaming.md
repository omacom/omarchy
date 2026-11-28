# Гејминг

Omarchy није само за _pRoDUcTiVItY_, већ је и за забаву, а шта је забавније од гејминга? Omarchy долази са читавим пакетом опција за гејминг — Steam и RetroArch за изворно и ретро играње, Battle.net, Lutris и Heroic за продавнице које нису Steam, Moonlight за стримовање са PC-ја, Xbox Cloud Gaming + NVIDIA GeForce NOW за облак, плус вечно присутни Minecraft.

Захваљујући невероватном раду компаније Valve на [Proton слоју за компатибилност](https://en.wikipedia.org/wiki/Proton_(software)), сада постоје десетине хиљада модерних игара које се могу играти на Linux-у. Ох, и да ли сте знали да [Steam Deck](https://store.steampowered.com/steamdeck/) заправо покреће Arch!

Сви инсталери за гејминг налазе се под _Install > Gaming_ у Omarchy менију (`Super + Space`). Ако икада пожелите да поништите неки од њих, користите _Remove > Gaming_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris и Heroic нуде се само на x86 машинама.

## Steam

Инсталирајте [Steam](https://store.steampowered.com/) тако што ћете изабрати _Install > Gaming > Steam_ из Omarchy менија (`Super + Space`).

Након што га инсталирате, моћи ћете да покренете Steam помоћу `Super + Space`.

Имајте на уму да Steam-у може бити потребно 10-20 секунди да се покрене и да неће пружити никакву визуелну повратну информацију да се учитава.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Инсталирајте [RetroArch](https://www.retroarch.com/) тако што ћете изабрати _Install > Gaming > RetroArch_ из Omarchy менија (`Super + Space`). Долази са комплетним скупом libretro језгара, тако да су сви класични системи покривени.

RetroArch је у потпуности унапред конфигурисан са прелепим CRT Royale шејдером за тај савршени ретро изглед.

Да бисте почели:

1. Убаците своје BIOS датотеке у `~/Games/bios`, а своје ROM-ове у `~/Games/roms`.
2. Покрените RetroArch помоћу `Super + Space` и укуцајте `retro`.
3. Скенирајте директоријум `~/Games/roms` и спремни сте за играње.

Омиљеној игри можете дати и сопствени унос у покретачу апликација помоћу _Install > Gaming > RetroArch Game Launcher_, што вам омогућава да изаберете језгро и ROM и да скочите право у игру из `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Инсталирајте веб апликацију Xbox Cloud Gaming тако што ћете изабрати _Install > Gaming > Xbox Cloud Gaming_ из Omarchy менија (`Super + Space`). То је „само” веб апликација за тај сервис, али се брзо покреће и одлично ради у 1080p.

Ако већ имате Xbox Game Pass, ово је солидан начин да играте Fortnite и друге наслове које не можете изворно да покренете на Linux-у.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Инсталирајте сервис за гејминг у облаку [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) тако што ћете изабрати _Install > Gaming > NVIDIA GeForce NOW_ из Omarchy менија (`Super + Space`). Још један одличан начин да играте наслове који нису доступни изворно на Linux-у.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Инсталирајте Minecraft тако што ћете изабрати _Install > Gaming > Minecraft_ из Omarchy менија (`Super + Space`).

Као и Steam, имајте на уму да након пријављивања или покретања може проћи неко време док се не појави следећи екран и да нећете добити никакву повратну информацију док чекате.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox контролери

Инсталирајте подршку за Bluetooth Xbox контролере тако што ћете изабрати _Install > Gaming > Xbox Controllers_ из Omarchy менија (`Super + Space`). Упарите контролере преко Bluetooth-а (`Super + Ctrl + B`) и радиће у свим вашим играма. Ово вам не треба ако контролер једноставно повезујете жицом помоћу USB-C кабла.

## Moonlight (стримовање игара са PC-ја)

Инсталирајте [Moonlight клијент](https://github.com/moonlight-stream/moonlight-qt) тако што ћете изабрати _Install > Gaming > Moonlight_ из Omarchy менија (`Super + Space`) и можете да стримујете игре са Windows PC-ја на коме ради [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Ако су и ваша Omarchy машина и удаљени гејминг PC повезани жицом, искуство се не разликује од играња локално. Подигните резолуцију на изворну, подесите освежавање на 120Hz и максимизирајте битрејт — ово је најбољи начин да играте такмичарске пуцачине као што је Fortnite на Linux-у.

Omarchy машину можете претворити и у хост покретањем `omarchy install service sunshine`, што инсталира Sunshine и отвара портове за Moonlight стримовање за ваш LAN и Tailscale.

## Battle.net

Инсталирајте [Battle.net](https://eu.shop.battle.net/en-us) тако што ћете изабрати _Install > Gaming > Battle.net_ из Omarchy менија (`Super + Space`). То вам даје наслове као што су Diablo, Starcraft и World of Warcraft као самосталну инсталацију која ради под GE-Proton-ом — није потребан Steam, Lutris ни Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows игре)

Инсталирајте [Lutris](https://lutris.net/) тако што ћете изабрати _Install > Gaming > Lutris_ из Omarchy менија (`Super + Space`). Lutris је начин да играте Windows игре из продавница као што су EA и Ubisoft Connect које изнад немају сопствени инсталатер.

Инсталација је мало незграпна и понекад изгледа као да се ништа не дешава — само будите стрпљиви, ради у позадини.

## Heroic Launcher (Epic Games)

Инсталирајте [Heroic Launcher](https://heroicgameslauncher.com/) тако што ћете изабрати _Install > Gaming > Heroic (Epic Games)_ из Omarchy менија (`Super + Space`). Heroic вам омогућава да покрећете Epic Games наслове, као што је OddSparks, који се не ослањају на anti-cheat — плус игре са GOG-а и Amazon Prime Gaming-а. Нажалост, то значи да нема Fortnite-а и нема Rocket League-а — док Tim Sweeney не дође на Linux, ово је најближе што можете да приђете.

Као и Lutris, може деловати споро и незграпно док инсталира игре. Дајте му времена.
