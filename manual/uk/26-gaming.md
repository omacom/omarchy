# Ігри

Omarchy створений не лише для _пРоДуКтИвНоСтІ_, а й для розваг, а що може бути веселішим за ігри? Omarchy постачається з цілим набором ігрових можливостей — Steam і RetroArch для нативних і ретро-ігор, Battle.net, Lutris і Heroic для магазинів поза Steam, Moonlight для стримінгу з PC, Xbox Cloud Gaming + NVIDIA GeForce NOW для хмарних ігор, а також вічний Minecraft.

Завдяки неймовірній роботі Valve над [шаром сумісності Proton](https://en.wikipedia.org/wiki/Proton_(software)) тепер на Linux доступні десятки тисяч сучасних ігор, у які можна грати. О, а ви знали, що [Steam Deck](https://store.steampowered.com/steamdeck/) насправді працює на Arch!

Усі інсталятори ігор розташовані в розділі _Install > Gaming_ меню Omarchy (`Super + Space`). Якщо колись захочете скасувати один із них, скористайтеся _Remove > Gaming_.

## Steam

Встановіть [Steam](https://store.steampowered.com/), вибравши _Install > Gaming > Steam_ у меню Omarchy (`Super + Space`).

Після встановлення ви зможете запускати Steam за допомогою `Super + Space`.

Зверніть увагу, що Steam може запускатися 10-20 секунд і не надаватиме жодного візуального зворотного зв'язку про те, що він завантажується.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Встановіть [RetroArch](https://www.retroarch.com/), вибравши _Install > Gaming > RetroArch_ у меню Omarchy (`Super + Space`). Він постачається з повним набором ядер libretro, тож усі класичні системи підтримуються.

RetroArch повністю попередньо налаштований із прекрасним шейдером CRT Royale для ідеального ретро-вигляду.

Щоб розпочати:

1. Помістіть файли BIOS у `~/Games/bios`, а ROM — у `~/Games/roms`.
2. Запустіть RetroArch за допомогою `Super + Space` і введіть `retro`.
3. Проскануйте каталог `~/Games/roms` — і ви готові грати.

Ви також можете створити для улюбленої гри окремий запис у засобі запуску застосунків за допомогою _Install > Gaming > RetroArch Game Launcher_, який дає змогу вибрати ядро та ROM і одразу перейти до гри з `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Встановіть вебзастосунок Xbox Cloud Gaming, вибравши _Install > Gaming > Xbox Cloud Gaming_ у меню Omarchy (`Super + Space`). Це «лише» вебзастосунок для сервісу, але він швидко запускається і чудово працює у 1080p.

Якщо у вас уже є Xbox Game Pass, це надійний спосіб грати у Fortnite та інші ігри, які не можна запустити нативно на Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Встановіть хмарний ігровий сервіс [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), вибравши _Install > Gaming > NVIDIA GeForce NOW_ у меню Omarchy (`Super + Space`). Ще один чудовий спосіб грати в ігри, недоступні нативно на Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Встановіть Minecraft, вибравши _Install > Gaming > Minecraft_ у меню Omarchy (`Super + Space`).

Як і у випадку зі Steam, зверніть увагу, що після входу або запуску може минути деякий час, перш ніж з'явиться наступний екран, і під час очікування ви не отримуватимете жодного зворотного зв'язку.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Встановіть підтримку Bluetooth-контролерів Xbox, вибравши _Install > Gaming > Xbox Controllers_ у меню Omarchy (`Super + Space`). З'єднайте контролери через Bluetooth (`Super + Ctrl + B`), і вони працюватимуть у всіх ваших іграх. Вам це не потрібно, якщо ви просто підключаєте контролер напряму кабелем USB-C.

## Moonlight (стримінг ігор із PC)

Встановіть [клієнт Moonlight](https://github.com/moonlight-stream/moonlight-qt), вибравши _Install > Gaming > Moonlight_ у меню Omarchy (`Super + Space`), і ви зможете транслювати ігри з PC під керуванням Windows, на якому запущено [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Якщо і ваш комп'ютер з Omarchy, і віддалений ігровий PC підключені дротовим з'єднанням, враження будуть невідрізненні від локальної гри. Виставте роздільну здатність до рідної, встановіть частоту оновлення 120Hz і максимальний бітрейт — це найкращий спосіб грати в змагальні шутери на кшталт Fortnite на Linux.

Ви також можете перетворити комп'ютер з Omarchy на хост, виконавши `omarchy install service sunshine`, що встановить Sunshine і відкриє порти стримінгу Moonlight для вашої LAN і Tailscale.

## Battle.net

Встановіть [Battle.net](https://eu.shop.battle.net/en-us), вибравши _Install > Gaming > Battle.net_ у меню Omarchy (`Super + Space`). Це дасть вам такі ігри, як Diablo, Starcraft і World of Warcraft, у вигляді окремого встановлення, що працює під GE-Proton — без потреби у Steam, Lutris чи Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (ігри для Windows)

Встановіть [Lutris](https://lutris.net/), вибравши _Install > Gaming > Lutris_ у меню Omarchy (`Super + Space`). Lutris — це спосіб грати в ігри для Windows із магазинів на кшталт EA та Ubisoft Connect, які не мають власного інсталятора вище.

Встановлення трохи кострубате, і часом здається, ніби нічого не відбувається, — просто майте терпіння, усе працює у фоновому режимі.

## Heroic Launcher (Epic Games)

Встановіть [Heroic Launcher](https://heroicgameslauncher.com/), вибравши _Install > Gaming > Heroic (Epic Games)_ у меню Omarchy (`Super + Space`). Heroic дає змогу запускати ігри Epic Games, як-от OddSparks, які не покладаються на античит, — а також ігри з GOG та Amazon Prime Gaming. На жаль, це означає жодного Fortnite і жодного Rocket League — доки Tim Sweeney не прийде на Linux, це максимум, на що можна розраховувати.

Як і Lutris, під час встановлення ігор він може здаватися повільним і кострубатим. Дайте йому час.
