# Ігри

Omarchy не лише для _пРОдУкТиВнОсТі_, він і для розваг, а що веселіше за ігри? Omarchy постачається з цілим набором ігрових можливостей — Steam і RetroArch для нативної та ретро-гри, Battle.net, Lutris і Heroic для крамниць поза Steam, Moonlight для стрімінгу з ПК, Xbox Cloud Gaming + NVIDIA GeForce NOW для хмари, а також вічнозелений Minecraft.

Завдяки неймовірній праці Valve над [шаром сумісності proton](https://en.wikipedia.org/wiki/Proton_(software)) тепер на Linux грабельні десятки тисяч сучасних ігор. О, а чи знали ви, що [Steam Deck](https://store.steampowered.com/steamdeck/) насправді працює на Arch!

Усі інсталятори ігор живуть у розділі _Встановити > Ігри_ в меню Omarchy (`Super + Space`). Якщо колись забажаєте скасувати одне з цього, скористайтеся _Видалити > Ігри_.

## Steam

Встановлюйте [Steam](https://store.steampowered.com/), вибравши _Встановити > Ігри > Steam_ у меню Omarchy (`Super + Space`).

Після встановлення ви зможете запускати Steam натисканням `Super + Space`.

Зауважте, що Steam може запускатися 10–20 секунд і не даватиме жодного візуального зворотного звʼязку про те, що завантажується.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Встановлюйте [RetroArch](https://www.retroarch.com/), вибравши _Встановити > Ігри > RetroArch_ у меню Omarchy (`Super + Space`). Він постачається з повним набором ядер libretro, тож усі класичні системи покриті.

RetroArch повністю заздалегідь налаштований із гарним шейдером CRT Royale для того самого досконалого ретро-вигляду.

Щоб почати:

1. Покладіть ваші файли BIOS у `~/Games/bios`, а ваші ROM-и — у `~/Games/roms`.
2. Запустіть RetroArch натисканням `Super + Space` і набиранням `retro`.
3. Проскануйте каталог `~/Games/roms` — і ви готові грати.

Ви також можете дати улюбленій грі власний запис у запускачі застосунків через _Встановити > Ігри > RetroArch Game Launcher_, що дозволяє вибрати ядро та ROM і стрибнути просто в гру з `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Встановлюйте вебзастосунок Xbox Cloud Gaming, вибравши _Встановити > Ігри > Xbox Cloud Gaming_ у меню Omarchy (`Super + Space`). Це «лише» вебзастосунок для служби, але він швидко запускається й чудово працює в 1080p.

Якщо у вас уже є Xbox Game Pass, це гідний спосіб грати у Fortnite та інші ігри, які не запустити нативно на Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Встановлюйте хмарно-ігрову службу [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), вибравши _Встановити > Ігри > NVIDIA GeForce NOW_ у меню Omarchy (`Super + Space`). Ще один чудовий спосіб грати в ігри, недоступні нативно на Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Встановлюйте Minecraft, вибравши _Встановити > Ігри > Minecraft_ у меню Omarchy (`Super + Space`).

Як і зі Steam, зауважте, що після входу чи запуску може минути якийсь час, перш ніж зʼявиться наступний екран, і жодного зворотного звʼязку під час очікування ви не отримаєте.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Контролери Xbox

Встановлюйте підтримку Bluetooth-контролерів Xbox, вибравши _Встановити > Ігри > Контролери Xbox_ у меню Omarchy (`Super + Space`). Спарюйте контролери через Bluetooth (`Super + Ctrl + B`) — і вони працюватимуть у всіх ваших іграх. Вам це не треба, якщо ви просто підʼєднуєте контролер кабелем USB-C.

## Moonlight (стрімити ігри з ПК)

[Клієнт Moonlight](https://github.com/moonlight-stream/moonlight-qt) постачається встановленим разом з Omarchy, тож ви можете одразу стрімити ігри з ПК на Windows, де працює [Sunshine](https://app.lizardbyte.dev/Sunshine/). Запускайте Moonlight через `Super + Space`.

Якщо і ваша машина з Omarchy, і віддалений ігровий ПК підʼєднані проводами, досвід не відрізнити від локальної гри. Підкрутіть роздільну здатність до нативної, встановіть оновлення на 120Hz і викрутіть бітрейт на максимум — це найкращий спосіб грати в змагальні шутери на кшталт Fortnite на Linux.

Ви також можете перетворити машину з Omarchy на хост, виконавши `omarchy install service sunshine`, що встановить Sunshine і відкриє порти стрімінгу Moonlight для вашої LAN і Tailscale.

## Battle.net

Встановлюйте [Battle.net](https://eu.shop.battle.net/en-us), вибравши _Встановити > Ігри > Battle.net_ у меню Omarchy (`Super + Space`). Це дає вам ігри на кшталт Diablo, Starcraft і World of Warcraft як окрему інсталяцію, що працює під GE-Proton, — Steam, Lutris чи Heroic не потрібні.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (ігри для Windows)

Встановлюйте [Lutris](https://lutris.net/), вибравши _Встановити > Ігри > Lutris_ у меню Omarchy (`Super + Space`). Lutris — це спосіб грати у Windows-ігри з крамниць на кшталт EA та Ubisoft Connect, у яких немає власного інсталятора вище.

Встановлення трохи криве і часом виглядає так, ніби нічого не відбувається, — просто майте терпіння, воно працює у фоні.

## Heroic Launcher (Epic Games)

Встановлюйте [Heroic Launcher](https://heroicgameslauncher.com/), вибравши _Встановити > Ігри > Heroic (Epic Games)_ у меню Omarchy (`Super + Space`). Heroic дозволяє запускати ігри Epic Games, на кшталт OddSparks, які не спираються на античит, — а також ігри з GOG та Amazon Prime Gaming. На жаль, це означає, що Fortnite і Rocket League не буде — доки Тім Свіні не прийде на Linux, це найближче з можливого.

Як і Lutris, під час встановлення ігор він може здаватися повільним і кривим. Дайте йому час.
