# Ігри

Omarchy — не лише для _pRoDUcTiVItY_, а й для розваг, а що може бути веселішим за ігри? Omarchy постачається з цілим набором ігрових можливостей — Steam і RetroArch для нативної та ретрогри, Battle.net, Lutris і Heroic для магазинів поза Steam, Moonlight для потокової передачі з ПК, Xbox Cloud Gaming + NVIDIA GeForce NOW для хмарних ігор, а також вічнозелений Minecraft.

Завдяки неймовірній роботі Valve над [шаром сумісності Proton](https://en.wikipedia.org/wiki/Proton_(software)) тепер на Linux можна грати в десятки тисяч сучасних ігор. О, а чи знали ви, що [Steam Deck](https://store.steampowered.com/steamdeck/) насправді працює на Arch!

Усі інсталятори ігор розташовані в розділі _Встановлення > Ігри_ в меню Omarchy (`Super + Space`). Якщо ви коли-небудь захочете скасувати одне з них, скористайтеся _Видалити > Ігри_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris і Heroic пропонуються лише на машинах x86.

## Steam

Встановіть [Steam](https://store.steampowered.com/), вибравши _Встановлення > Ігри > Steam_ у меню Omarchy (`Super + Space`).

Після встановлення ви зможете запускати Steam за допомогою `Super + Space`.

Зверніть увагу, що запуск Steam може тривати 10-20 секунд, і він не надаватиме жодного візуального зворотного зв'язку про те, що завантажується.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Встановіть [RetroArch](https://www.retroarch.com/), вибравши _Встановлення > Ігри > RetroArch_ у меню Omarchy (`Super + Space`). Він постачається з повним набором ядер libretro, тож усі класичні системи покриті.

RetroArch повністю попередньо налаштований із красивим шейдером CRT Royale для того самого ідеального ретровгляду.

Щоб почати:

1. Скиньте ваші файли BIOS у `~/Games/bios`, а ваші ROM — у `~/Games/roms`.
2. Запустіть RetroArch за допомогою `Super + Space` і введіть `retro`.
3. Проскануйте каталог `~/Games/roms`, і ви готові грати.

Ви також можете дати улюбленій грі власний запис у засобі запуску програм за допомогою _Встановлення > Ігри > RetroArch Game Launcher_, який дозволяє вибрати ядро та ROM і одразу перейти до гри з `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Встановіть вебзастосунок Xbox Cloud Gaming, вибравши _Встановлення > Ігри > Xbox Cloud Gaming_ у меню Omarchy (`Super + Space`). Це «просто» вебзастосунок для сервісу, але він швидко запускається і чудово працює при 1080p.

Якщо у вас уже є Xbox Game Pass, це надійний спосіб грати у Fortnite та інші ігри, які ви не можете запускати нативно на Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Встановіть хмарний ігровий сервіс [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), вибравши _Встановлення > Ігри > NVIDIA GeForce NOW_ у меню Omarchy (`Super + Space`). Ще один чудовий спосіб грати в ігри, які недоступні нативно на Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Встановіть Minecraft, вибравши _Встановлення > Ігри > Minecraft_ у меню Omarchy (`Super + Space`).

Як і у випадку зі Steam, зверніть увагу, що після входу або запуску може минути деякий час, перш ніж з'явиться наступний екран, і ви не отримаєте жодного зворотного зв'язку, поки чекаєте.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Контролери Xbox

Встановіть підтримку Bluetooth-контролерів Xbox, вибравши _Встановлення > Ігри > Контролери Xbox_ у меню Omarchy (`Super + Space`). З'єднайте контролери через Bluetooth (`Super + Ctrl + B`), і вони працюватимуть у всіх ваших іграх. Вам це не потрібно, якщо ви просто під'єднуєте контролер дротом за допомогою кабелю USB-C.

## Moonlight (Потокова передача ігор з ПК)

Встановіть [клієнт Moonlight](https://github.com/moonlight-stream/moonlight-qt), вибравши _Встановлення > Ігри > Moonlight_ у меню Omarchy (`Super + Space`), і ви зможете транслювати ігри з ПК на Windows, на якому працює [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Якщо і ваша машина Omarchy, і віддалений ігровий ПК під'єднані дротом, досвід буде невідрізнити від локальної гри. Підвищіть роздільну здатність до нативної, встановіть частоту оновлення 120Hz і максимальний бітрейт — це найкращий спосіб грати в змагальні шутери, як-от Fortnite, на Linux.

Ви також можете перетворити машину Omarchy на хост, запустивши `omarchy install service sunshine`, що встановлює Sunshine і відкриває порти потокової передачі Moonlight для вашої LAN і Tailscale.

## Battle.net

Встановіть [Battle.net](https://eu.shop.battle.net/en-us), вибравши _Встановлення > Ігри > Battle.net_ у меню Omarchy (`Super + Space`). Це дає вам такі ігри, як Diablo, Starcraft і World of Warcraft, як окрему інсталяцію, що працює під GE-Proton — без потреби в Steam, Lutris або Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Ігри для Windows)

Встановіть [Lutris](https://lutris.net/), вибравши _Встановлення > Ігри > Lutris_ у меню Omarchy (`Super + Space`). Lutris — це спосіб грати в ігри для Windows з магазинів, як-от EA і Ubisoft Connect, які не мають власного інсталятора вище.

Встановлення трохи незграбне і часом виглядає так, ніби нічого не відбувається — просто будьте терплячими, воно працює у фоновому режимі.

## Heroic Launcher (Epic Games)

Встановіть [Heroic Launcher](https://heroicgameslauncher.com/), вибравши _Встановлення > Ігри > Heroic (Epic Games)_ у меню Omarchy (`Super + Space`). Heroic дозволяє запускати ігри Epic Games, як-от OddSparks, які не покладаються на античит — плюс ігри з GOG і Amazon Prime Gaming. На жаль, це означає жодного Fortnite і жодного Rocket League — доки Tim Sweeney не прийде на Linux, це найближче, що можна отримати.

Як і Lutris, він може здаватися повільним і незграбним під час встановлення ігор. Дайте йому час.
