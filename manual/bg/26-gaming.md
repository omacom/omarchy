# Игри

Omarchy не е само за _пРоДуКтИвНоСт_, той е и за забавление, а какво е по-забавно от игрите? Omarchy идва с цял набор от опции за игри — Steam и RetroArch за нативни и ретро игри, Battle.net, Lutris и Heroic за магазини извън Steam, Moonlight за стрийминг от PC, Xbox Cloud Gaming + NVIDIA GeForce NOW за облак, плюс вечнозеления Minecraft.

Благодарение на невероятната работа на Valve по [слоя за съвместимост Proton](https://en.wikipedia.org/wiki/Proton_(software)), сега има десетки хиляди играеми съвременни игри на Linux. О, и знаехте ли, че [Steam Deck](https://store.steampowered.com/steamdeck/) всъщност работи с Arch!

Всички инсталатори за игри живеят в _Инсталирай > Gaming_ в менюто на Omarchy (`Super + Space`). Ако някога искате да отмените някой от тях, използвайте _Премахни > Gaming_.

## Steam

Инсталирайте [Steam](https://store.steampowered.com/), като изберете _Инсталирай > Gaming > Steam_ от менюто на Omarchy (`Super + Space`).

След като го инсталирате, ще можете да стартирате Steam със `Super + Space`.

Обърнете внимание, че стартирането на Steam може да отнеме 10-20 секунди и той няма да предоставя никаква визуална обратна връзка, че се зарежда.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Инсталирайте [RetroArch](https://www.retroarch.com/), като изберете _Инсталирай > Gaming > RetroArch_ от менюто на Omarchy (`Super + Space`). Той идва с пълния набор от libretro ядра, така че всички класически системи са покрити.

RetroArch е напълно предварително конфигуриран с красивия шейдър CRT Royale за този перфектен ретро вид.

За да започнете:

1. Поставете BIOS файловете си в `~/Games/bios`, а ROM файловете си в `~/Games/roms`.
2. Стартирайте RetroArch със `Super + Space` и въведете `retro`.
3. Сканирайте директорията `~/Games/roms` и сте готови да играете.

Можете също да дадете на любима игра собствена позиция в стартера на приложения с _Инсталирай > Gaming > RetroArch Game Launcher_, който ви позволява да изберете ядро и ROM и да прескочите директно в играта от `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Инсталирайте уеб приложението Xbox Cloud Gaming, като изберете _Инсталирай > Gaming > Xbox Cloud Gaming_ от менюто на Omarchy (`Super + Space`). То е „само“ уеб приложение за услугата, но стартира бързо и работи чудесно при 1080p.

Ако вече имате Xbox Game Pass, това е солиден начин да играете Fortnite и други заглавия, които не можете да стартирате нативно на Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Инсталирайте услугата за облачни игри [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), като изберете _Инсталирай > Gaming > NVIDIA GeForce NOW_ от менюто на Omarchy (`Super + Space`). Още един чудесен начин да играете заглавия, които не са налични нативно на Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Инсталирайте Minecraft, като изберете _Инсталирай > Gaming > Minecraft_ от менюто на Omarchy (`Super + Space`).

Подобно на Steam, обърнете внимание, че може да отнеме известно време след влизане или стартиране, преди да се появи следващият екран, и няма да получавате никаква обратна връзка, докато чакате.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox контролери

Инсталирайте поддръжка за Bluetooth Xbox контролери, като изберете _Инсталирай > Gaming > Xbox Controllers_ от менюто на Omarchy (`Super + Space`). Сдвоете контролерите през Bluetooth (`Super + Ctrl + B`) и те ще работят във всичките ви игри. Не ви трябва това, ако просто свързвате контролера си с USB-C кабел.

## Moonlight (Стрийминг на игри от PC)

[Клиентът Moonlight](https://github.com/moonlight-stream/moonlight-qt) идва предварително инсталиран с Omarchy, така че можете веднага да стриймвате игри от Windows PC, работещ със [Sunshine](https://app.lizardbyte.dev/Sunshine/). Стартирайте Moonlight чрез `Super + Space`.

Ако и машината ви с Omarchy, и отдалеченото PC за игри са свързани с кабел, изживяването е неразличимо от локална игра. Увеличете разделителната способност до нативната, задайте опресняването на 120Hz и максималния битрейт — това е най-добрият начин да играете състезателни шутъри като Fortnite на Linux.

Можете също да превърнете машина с Omarchy в хост, като стартирате `omarchy install service sunshine`, което инсталира Sunshine и отваря портовете за стрийминг на Moonlight за вашата LAN и Tailscale.

## Battle.net

Инсталирайте [Battle.net](https://eu.shop.battle.net/en-us), като изберете _Инсталирай > Gaming > Battle.net_ от менюто на Omarchy (`Super + Space`). Това ви дава заглавия като Diablo, Starcraft и World of Warcraft като самостоятелна инсталация, работеща под GE-Proton — не са нужни Steam, Lutris или Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows игри)

Инсталирайте [Lutris](https://lutris.net/), като изберете _Инсталирай > Gaming > Lutris_ от менюто на Omarchy (`Super + Space`). Lutris е начинът да играете Windows игри от магазини като EA и Ubisoft Connect, които нямат свой собствен инсталатор по-горе.

Инсталацията е малко тромава и понякога изглежда, че нищо не се случва — просто бъдете търпеливи, той работи във фонов режим.

## Heroic Launcher (Epic Games)

Инсталирайте [Heroic Launcher](https://heroicgameslauncher.com/), като изберете _Инсталирай > Gaming > Heroic (Epic Games)_ от менюто на Omarchy (`Super + Space`). Heroic ви позволява да стартирате заглавия на Epic Games, като OddSparks, които не разчитат на anti-cheat — плюс игри от GOG и Amazon Prime Gaming. За съжаление това означава без Fortnite и без Rocket League — докато Tim Sweeney не дойде на Linux, това е най-близкото възможно.

Подобно на Lutris, той може да се усеща бавен и тромав при инсталиране на игри. Дайте му време.
