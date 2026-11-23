# Игри

Omarchy не е само за _пРоДуКтИвНоСт_, а е и за забавление, а кое е по-забавно от игрите? Omarchy се предлага с цял набор от възможности за игри — Steam и RetroArch за нативна и ретро игра, Battle.net, Lutris и Heroic за магазини извън Steam, Moonlight за PC стрийминг, Xbox Cloud Gaming + NVIDIA GeForce NOW за облачен гейминг, плюс вечнозеления Minecraft.

Благодарение на невероятната работа на Valve по [слоя за съвместимост Proton](https://en.wikipedia.org/wiki/Proton_(software)) вече има десетки хиляди модерни игри, които могат да се играят на Linux. А, и знаете ли, че [Steam Deck](https://store.steampowered.com/steamdeck/) всъщност работи с Arch!

Всички инсталатори за игри се намират под _Инсталиране > Игри_ в менюто на Omarchy (`Super + Space`). Ако някога искате да отмените някой от тях, използвайте _Премахване > Игри_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris и Heroic се предлагат само на x86 машини.

## Steam

Инсталирайте [Steam](https://store.steampowered.com/), като изберете _Инсталиране > Игри > Steam_ от менюто на Omarchy (`Super + Space`).

След като го инсталирате, ще можете да стартирате Steam със `Super + Space`.

Имайте предвид, че на Steam може да са му необходими 10-20 секунди за стартиране и няма да ви покаже никаква визуална обратна връзка, че зарежда.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Инсталирайте [RetroArch](https://www.retroarch.com/), като изберете _Инсталиране > Игри > RetroArch_ от менюто на Omarchy (`Super + Space`). Предлага се с пълния набор от libretro ядра, така че всички класически системи са покрити.

RetroArch е напълно предварително конфигуриран с красивия шейдър CRT Royale за онзи перфектен ретро вид.

За да започнете:

1. Поставете BIOS файловете си в `~/Games/bios` и ROM-овете си в `~/Games/roms`.
2. Стартирайте RetroArch със `Super + Space` и въведете `retro`.
3. Сканирайте директорията `~/Games/roms` и сте готови да играете.

Можете също да дадете на любима игра отделен запис в програмата за стартиране на приложения чрез _Инсталиране > Игри > RetroArch Game Launcher_, което ви позволява да изберете ядро и ROM и да влезете направо в играта от `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Инсталирайте уеб приложението Xbox Cloud Gaming, като изберете _Инсталиране > Игри > Xbox Cloud Gaming_ от менюто на Omarchy (`Super + Space`). То е „само“ уеб приложение за услугата, но стартира бързо и работи чудесно на 1080p.

Ако вече имате Xbox Game Pass, това е солиден начин да играете Fortnite и други заглавия, които не можете да стартирате нативно на Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Инсталирайте услугата за облачен гейминг [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), като изберете _Инсталиране > Игри > NVIDIA GeForce NOW_ от менюто на Omarchy (`Super + Space`). Още един чудесен начин да играете заглавия, които не са налични нативно на Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Инсталирайте Minecraft, като изберете _Инсталиране > Игри > Minecraft_ от менюто на Omarchy (`Super + Space`).

Както при Steam, имайте предвид, че след влизане или стартиране може да мине известно време, преди да се появи следващият екран, и няма да получите никаква обратна връзка, докато чакате.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Инсталирайте поддръжка за Bluetooth Xbox контролери, като изберете _Инсталиране > Игри > Xbox Controllers_ от менюто на Omarchy (`Super + Space`). Сдвоете контролерите чрез Bluetooth (`Super + Ctrl + B`) и те ще работят във всичките ви игри. Нямате нужда от това, ако просто свързвате контролера си с кабел USB-C.

## Moonlight (стрийминг на игри от PC)

Инсталирайте [клиента Moonlight](https://github.com/moonlight-stream/moonlight-qt), като изберете _Инсталиране > Игри > Moonlight_ от менюто на Omarchy (`Super + Space`), и ще можете да стриймвате игри от Windows PC, на което работи [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Ако както вашата машина с Omarchy, така и отдалеченото PC за игри са свързани с кабел, изживяването е неразличимо от локалната игра. Вдигнете разделителната способност до нативната, задайте опресняване на 120Hz и увеличете битрейта максимално — това е най-добрият начин да играете конкурентни шутъри като Fortnite на Linux.

Можете също да превърнете машина с Omarchy в хост, като изпълните `omarchy install service sunshine`, което инсталира Sunshine и отваря портовете за стрийминг на Moonlight за вашата LAN и Tailscale.

## Battle.net

Инсталирайте [Battle.net](https://eu.shop.battle.net/en-us), като изберете _Инсталиране > Игри > Battle.net_ от менюто на Omarchy (`Super + Space`). Това ви дава заглавия като Diablo, Starcraft и World of Warcraft като самостоятелна инсталация, работеща под GE-Proton — не са ви нужни Steam, Lutris или Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows игри)

Инсталирайте [Lutris](https://lutris.net/), като изберете _Инсталиране > Игри > Lutris_ от менюто на Omarchy (`Super + Space`). Lutris е начинът да играете Windows игри от магазини като EA и Ubisoft Connect, които нямат собствен инсталатор по-горе.

Инсталацията е малко тромава и на моменти изглежда, че нищо не се случва — просто бъдете търпеливи, работи във фонов режим.

## Heroic Launcher (Epic Games)

Инсталирайте [Heroic Launcher](https://heroicgameslauncher.com/), като изберете _Инсталиране > Игри > Heroic (Epic Games)_ от менюто на Omarchy (`Super + Space`). Heroic ви позволява да стартирате заглавия от Epic Games, като OddSparks, които не разчитат на античийт — плюс игри от GOG и Amazon Prime Gaming. За съжаление, това означава без Fortnite и без Rocket League — докато Tim Sweeney не дойде на Linux, това е най-близкото, до което можете да стигнете.

Както и при Lutris, при инсталиране на игри може да се усеща бавен и тромав. Дайте му време.
