# Гейминг

Omarchy не е само за _пРоДуКтИвНоСт_, а и за забавление, а кое е по-забавно от гейминга? Omarchy идва с цял набор от възможности за игри — Steam и RetroArch за нативни и ретро игри, Battle.net, Lutris и Heroic за магазини извън Steam, Moonlight за стрийминг от PC, Xbox Cloud Gaming + NVIDIA GeForce NOW за облачен гейминг, плюс вечнозеления Minecraft.

Благодарение на невероятната работа на Valve по [слоя за съвместимост Proton](https://en.wikipedia.org/wiki/Proton_(software)), вече има десетки хиляди модерни игри, които могат да се играят на Linux. О, и знаехте ли, че [Steam Deck](https://store.steampowered.com/steamdeck/) всъщност работи с Arch!

Всички инсталатори за игри се намират под _Инсталиране > Гейминг_ в менюто на Omarchy (`Super + Space`). Ако някога поискате да отмените някой от тях, използвайте _Премахване > Гейминг_.

## Steam

Инсталирайте [Steam](https://store.steampowered.com/) като изберете _Инсталиране > Гейминг > Steam_ от менюто на Omarchy (`Super + Space`).

След като го инсталирате, ще можете да стартирате Steam с `Super + Space`.

Имайте предвид, че на Steam може да му отнеме 10-20 секунди да стартира и няма да ви покаже никаква визуална обратна връзка, че зарежда.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Инсталирайте [RetroArch](https://www.retroarch.com/) като изберете _Инсталиране > Гейминг > RetroArch_ от менюто на Omarchy (`Super + Space`). Идва с пълния комплект libretro ядра, така че всички класически системи са покрити.

RetroArch идва напълно предварително конфигуриран с красивия CRT Royale шейдър за онзи перфектен ретро вид.

За да започнете:

1. Поставете BIOS файловете си в `~/Games/bios`, а ROM-овете си в `~/Games/roms`.
2. Стартирайте RetroArch с `Super + Space` и като напишете `retro`.
3. Сканирайте директорията `~/Games/roms` и сте готови за игра.

Можете също да дадете на любима игра отделен запис в стартера за приложения с _Инсталиране > Гейминг > RetroArch Game Launcher_, което ви позволява да изберете ядро и ROM и да скочите направо в играта от `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Инсталирайте уеб приложението Xbox Cloud Gaming като изберете _Инсталиране > Гейминг > Xbox Cloud Gaming_ от менюто на Omarchy (`Super + Space`). То е „само“ уеб приложение за услугата, но стартира бързо и работи чудесно при 1080p.

Ако вече имате Xbox Game Pass, това е стабилен начин да играете Fortnite и други заглавия, които не можете да стартирате нативно на Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Инсталирайте облачната гейминг услуга [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) като изберете _Инсталиране > Гейминг > NVIDIA GeForce NOW_ от менюто на Omarchy (`Super + Space`). Още един чудесен начин да играете заглавия, които не са налични нативно на Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Инсталирайте Minecraft като изберете _Инсталиране > Гейминг > Minecraft_ от менюто на Omarchy (`Super + Space`).

Като при Steam, имайте предвид, че може да отнеме известно време след влизане или стартиране, преди да се появи следващият екран, и няма да получите никаква обратна връзка, докато чакате.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox контролери

Инсталирайте поддръжка за Bluetooth Xbox контролери като изберете _Инсталиране > Гейминг > Xbox Controllers_ от менюто на Omarchy (`Super + Space`). Сдвоете контролерите чрез Bluetooth (`Super + Ctrl + B`) и те ще работят във всичките ви игри. Това не ви е нужно, ако просто свързвате контролера директно с USB-C кабел.

## Moonlight (Стрийминг на игри от PC)

Инсталирайте [клиента Moonlight](https://github.com/moonlight-stream/moonlight-qt) като изберете _Инсталиране > Гейминг > Moonlight_ от менюто на Omarchy (`Super + Space`) и можете да стриймвате игри от Windows PC, на което работи [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Ако и вашата Omarchy машина, и отдалеченото гейминг PC са свързани с кабел, изживяването е неразличимо от локална игра. Вдигнете разделителната способност до нативната, задайте опресняването на 120Hz и увеличете битрейта до максимум — това е най-добрият начин да играете състезателни шутъри като Fortnite на Linux.

Можете също да превърнете Omarchy машина в хост като изпълните `omarchy install service sunshine`, което инсталира Sunshine и отваря портовете за стрийминг на Moonlight за вашата LAN и Tailscale мрежа.

## Battle.net

Инсталирайте [Battle.net](https://eu.shop.battle.net/en-us) като изберете _Инсталиране > Гейминг > Battle.net_ от менюто на Omarchy (`Super + Space`). Това ви дава заглавия като Diablo, Starcraft и World of Warcraft като самостоятелна инсталация, работеща под GE-Proton — без да са нужни Steam, Lutris или Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows игри)

Инсталирайте [Lutris](https://lutris.net/) като изберете _Инсталиране > Гейминг > Lutris_ от менюто на Omarchy (`Super + Space`). Lutris е начинът да играете Windows игри от магазини като EA и Ubisoft Connect, които нямат собствен инсталатор по-горе.

Инсталацията е малко тромава и понякога изглежда, сякаш нищо не се случва — просто бъдете търпеливи, работи във фонов режим.

## Heroic Launcher (Epic Games)

Инсталирайте [Heroic Launcher](https://heroicgameslauncher.com/) като изберете _Инсталиране > Гейминг > Heroic (Epic Games)_ от менюто на Omarchy (`Super + Space`). Heroic ви позволява да стартирате заглавия от Epic Games, като OddSparks, които не разчитат на античийт — плюс игри от GOG и Amazon Prime Gaming. За съжаление това означава без Fortnite и без Rocket League — докато Tim Sweeney не дойде на Linux, това е най-близкото, което можем да получим.

Като при Lutris, може да се усеща бавно и тромаво, докато инсталира игри. Дайте му време.
