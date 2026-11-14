# Гејминг

Omarchy није само за _pRoDUcTiVItY_, ту је и за забаву, а има ли нешто забавније од гејминга? Omarchy долази са читавим пакетом опција за гејминг — Steam и RetroArch за изворно и ретро играње, Battle.net, Lutris и Heroic за продавнице изван Steam-а, Moonlight за стримовање са PC-ја, Xbox Cloud Gaming + NVIDIA GeForce NOW за клауд, плус увек актуелни Minecraft.

Захваљујући невероватном раду компаније Valve на [Proton слоју за компатибилност](https://en.wikipedia.org/wiki/Proton_(software)), сада на Linux-у може да се игра на десетине хиљада модерних игара. Ах, да, да ли сте знали да [Steam Deck](https://store.steampowered.com/steamdeck/) заправо покреће Arch!

Сви инсталатери за гејминг налазе се под _Инсталирај > Гејминг_ у Omarchy менију (`Super + Space`). Ако икада пожелите да поништите неки од њих, користите _Уклони > Гејминг_.

## Steam

Инсталирајте [Steam](https://store.steampowered.com/) тако што ћете у Omarchy менију (`Super + Space`) изабрати _Инсталирај > Гејминг > Steam_.

Након што га инсталирате, Steam ћете моћи да покренете помоћу `Super + Space`.

Имајте на уму да покретање Steam-а може да потраје 10-20 секунди и да неће бити никаквог визуелног показатеља да се учитава.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Инсталирајте [RetroArch](https://www.retroarch.com/) тако што ћете у Omarchy менију (`Super + Space`) изабрати _Инсталирај > Гејминг > RetroArch_. Долази са комплетним скупом libretro језгара, тако да су сви класични системи покривени.

RetroArch је у потпуности унапред подешен са прелепим CRT Royale шејдером за тај савршени ретро изглед.

Да бисте почели:

1. Убаците своје BIOS фајлове у `~/Games/bios`, а своје ROM-ове у `~/Games/roms`.
2. Покрените RetroArch помоћу `Super + Space` и куцањем `retro`.
3. Скенирајте директоријум `~/Games/roms` и спремни сте за играње.

Омиљеној игри можете дати и посебан унос у покретачу апликација помоћу _Инсталирај > Гејминг > RetroArch Game Launcher_, што вам омогућава да изаберете језгро и ROM и да право из `Super + Space` ускочите у игру.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Инсталирајте веб апликацију Xbox Cloud Gaming тако што ћете у Omarchy менију (`Super + Space`) изабрати _Инсталирај > Гејминг > Xbox Cloud Gaming_. То је „само” веб апликација за тај сервис, али се брзо покреће и одлично ради у 1080p.

Ако већ имате Xbox Game Pass, ово је солидан начин да играте Fortnite и друге наслове које не можете изворно да покренете на Linux-у.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Инсталирајте сервис за клауд гејминг [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) тако што ћете у Omarchy менију (`Super + Space`) изабрати _Инсталирај > Гејминг > NVIDIA GeForce NOW_. Још један одличан начин да играте наслове који нису доступни изворно на Linux-у.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Инсталирајте Minecraft тако што ћете у Omarchy менију (`Super + Space`) изабрати _Инсталирај > Гејминг > Minecraft_.

Као и Steam, имајте на уму да након пријављивања или покретања може да прође неко време док се не појави следећи екран и да док чекате нећете добити никакву повратну информацију.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox контролери

Инсталирајте подршку за Bluetooth Xbox контролере тако што ћете у Omarchy менију (`Super + Space`) изабрати _Инсталирај > Гејминг > Xbox Controllers_. Упарите контролере преко Bluetooth-а (`Super + Ctrl + B`) и радиће у свим вашим играма. Ово вам не треба ако контролер једноставно повезујете USB-C каблом.

## Moonlight (Стримовање игара са PC-ја)

Инсталирајте [Moonlight клијент](https://github.com/moonlight-stream/moonlight-qt) тако што ћете у Omarchy менију (`Super + Space`) изабрати _Инсталирај > Гејминг > Moonlight_, и моћи ћете да стримујете игре са Windows PC-ја на ком ради [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Ако су и ваша Omarchy машина и удаљени гејминг PC повезани каблом, искуство се не разликује од локалног играња. Подигните резолуцију на изворну, подесите освежавање на 120Hz и појачајте битрејт до максимума — ово је најбољи начин да на Linux-у играте такмичарске пуцачине као што је Fortnite.

Omarchy машину можете претворити и у домаћина покретањем `omarchy install service sunshine`, што инсталира Sunshine и отвара Moonlight портове за стримовање за ваш LAN и Tailscale.

## Battle.net

Инсталирајте [Battle.net](https://eu.shop.battle.net/en-us) тако што ћете у Omarchy менију (`Super + Space`) изабрати _Инсталирај > Гејминг > Battle.net_. Ово вам доноси наслове као што су Diablo, Starcraft и World of Warcraft као самосталну инсталацију која ради под GE-Proton — без потребе за Steam-ом, Lutris-ом или Heroic-ом.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows игре)

Инсталирајте [Lutris](https://lutris.net/) тако што ћете у Omarchy менију (`Super + Space`) изабрати _Инсталирај > Гејминг > Lutris_. Lutris је начин да играте Windows игре из продавница као што су EA и Ubisoft Connect, које горе немају сопствени инсталатер.

Инсталација је мало незграпна и понекад изгледа као да се ништа не дешава — само будите стрпљиви, ради се у позадини.

## Heroic Launcher (Epic Games)

Инсталирајте [Heroic Launcher](https://heroicgameslauncher.com/) тако што ћете у Omarchy менију (`Super + Space`) изабрати _Инсталирај > Гејминг > Heroic (Epic Games)_. Heroic вам омогућава да покрећете Epic Games наслове, као што је OddSparks, који се не ослањају на anti-cheat — плус игре са GOG-а и Amazon Prime Gaming-а. Нажалост, то значи да нема Fortnite-а и нема Rocket League-а — док Tim Sweeney не дође на Linux, ово је најближе што можете да приђете.

Као и Lutris, док инсталира игре може да делује споро и незграпно. Дајте му времена.
