# بازی

Omarchy فقط برای _بهره‌وری_ نیست، برای تفریح هم هست، و چه چیزی از بازی مفرح‌تر است؟ Omarchy با مجموعه کاملی از گزینه‌های بازی عرضه می‌شود — Steam و RetroArch برای بازی بومی و رترو، Battle.net، Lutris و Heroic برای فروشگاه‌های غیر Steam، Moonlight برای استریم از PC، Xbox Cloud Gaming + NVIDIA GeForce NOW برای بازی ابری، به‌علاوه Minecraft همیشه‌سبز.

به لطف کار باورنکردنی Valve روی [لایه سازگاری Proton](https://en.wikipedia.org/wiki/Proton_(software))، حالا ده‌ها هزار بازی مدرن قابل بازی روی لینوکس وجود دارد. اوه، و می‌دانستید که [Steam Deck](https://store.steampowered.com/steamdeck/) در واقع Arch را اجرا می‌کند!

همه نصب‌کننده‌های بازی زیر _Install > Gaming_ در منوی Omarchy (`Super + Space`) قرار دارند. اگر زمانی خواستید یکی را حذف کنید، از _Remove > Gaming_ استفاده کنید. Minecraft، NVIDIA GeForce NOW، Battle.net، Lutris و Heroic فقط روی ماشین‌های x86 ارائه می‌شوند.

## Steam

[Steam](https://store.steampowered.com/) را با انتخاب _Install > Gaming > Steam_ از منوی Omarchy (`Super + Space`) نصب کنید.

پس از نصب آن، می‌توانید Steam را با `Super + Space` اجرا کنید.

توجه داشته باشید که راه‌اندازی Steam ممکن است ۱۰-۲۰ ثانیه طول بکشد، و هیچ بازخورد بصری مبنی بر در حال بارگذاری بودن آن ارائه نمی‌دهد.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

[RetroArch](https://www.retroarch.com/) را با انتخاب _Install > Gaming > RetroArch_ از منوی Omarchy (`Super + Space`) نصب کنید. همراه با مجموعه کامل هسته‌های libretro عرضه می‌شود، پس همه سیستم‌های کلاسیک پوشش داده شده‌اند.

RetroArch از پیش به‌طور کامل با شیدر زیبای CRT Royale پیکربندی شده است تا آن ظاهر رتروی بی‌نقص را داشته باشد.

برای شروع:

1. فایل‌های BIOS خود را در `~/Games/bios` و ROMهای خود را در `~/Games/roms` بیندازید.
2. RetroArch را با `Super + Space` اجرا کنید و `retro` را تایپ کنید.
3. پوشه `~/Games/roms` را اسکن کنید و آماده بازی هستید.

همچنین می‌توانید به یک بازی موردعلاقه ورودی مخصوص خودش را در لانچر برنامه بدهید با _Install > Gaming > RetroArch Game Launcher_، که به شما اجازه می‌دهد یک هسته و یک ROM انتخاب کنید، و مستقیم از `Super + Space` وارد بازی شوید.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

وب‌اپ Xbox Cloud Gaming را با انتخاب _Install > Gaming > Xbox Cloud Gaming_ از منوی Omarchy (`Super + Space`) نصب کنید. این «فقط» یک وب‌اپ برای این سرویس است، اما سریع شروع می‌شود و در 1080p عالی اجرا می‌شود.

اگر از قبل Xbox Game Pass دارید، این روش خوبی برای بازی Fortnite و عناوین دیگری است که نمی‌توانید به‌صورت بومی روی لینوکس اجرا کنید.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

سرویس بازی ابری [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) را با انتخاب _Install > Gaming > NVIDIA GeForce NOW_ از منوی Omarchy (`Super + Space`) نصب کنید. روش عالی دیگری برای بازی عناوینی که به‌صورت بومی روی لینوکس در دسترس نیستند.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Minecraft را با انتخاب _Install > Gaming > Minecraft_ از منوی Omarchy (`Super + Space`) نصب کنید.

مانند Steam، توجه داشته باشید که پس از ورود یا راه‌اندازی ممکن است مدتی طول بکشد تا صفحه بعدی ظاهر شود، و در حین انتظار هیچ بازخوردی دریافت نخواهید کرد.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

پشتیبانی از کنترلرهای Bluetooth Xbox را با انتخاب _Install > Gaming > Xbox Controllers_ از منوی Omarchy (`Super + Space`) نصب کنید. کنترلرها را از طریق Bluetooth (`Super + Ctrl + B`) جفت کنید و در همه بازی‌هایتان کار خواهند کرد. اگر کنترلرتان را فقط با کابل USB-C سیم‌کشی می‌کنید، به این نیاز ندارید.

## Moonlight (استریم بازی از یک PC)

[کلاینت Moonlight](https://github.com/moonlight-stream/moonlight-qt) را با انتخاب _Install > Gaming > Moonlight_ از منوی Omarchy (`Super + Space`) نصب کنید، و می‌توانید بازی‌ها را از یک PC ویندوزی که [Sunshine](https://app.lizardbyte.dev/Sunshine/) را اجرا می‌کند استریم کنید.

اگر هم ماشین Omarchy شما و هم PC بازی راه‌دور سیم‌کشی شده باشند، تجربه غیرقابل تشخیص از بازی محلی است. وضوح را تا حد بومی بالا ببرید، نرخ نوسازی را روی 120Hz تنظیم کنید، و بیت‌ریت را به حداکثر برسانید — این بهترین روش برای بازی شوترهای رقابتی مانند Fortnite روی لینوکس است.

همچنین می‌توانید با اجرای `omarchy install service sunshine` یک ماشین Omarchy را به میزبان تبدیل کنید، که Sunshine را نصب می‌کند و پورت‌های استریم Moonlight را برای LAN و Tailscale شما باز می‌کند.

## Battle.net

[Battle.net](https://eu.shop.battle.net/en-us) را با انتخاب _Install > Gaming > Battle.net_ از منوی Omarchy (`Super + Space`) نصب کنید. این عناوینی مانند Diablo، Starcraft و World of Warcraft را به‌صورت نصبی مستقل که زیر GE-Proton اجرا می‌شود در اختیارتان می‌گذارد — بدون نیاز به Steam، Lutris یا Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (بازی‌های Windows)

[Lutris](https://lutris.net/) را با انتخاب _Install > Gaming > Lutris_ از منوی Omarchy (`Super + Space`) نصب کنید. Lutris روش بازی بازی‌های Windows از فروشگاه‌هایی مانند EA و Ubisoft Connect است که نصب‌کننده مخصوص خودشان را در بالا ندارند.

نصب کمی ناجور است و گاهی به نظر می‌رسد هیچ اتفاقی نمی‌افتد — فقط صبور باشید، در پس‌زمینه در حال کار است.

## Heroic Launcher (Epic Games)

[Heroic Launcher](https://heroicgameslauncher.com/) را با انتخاب _Install > Gaming > Heroic (Epic Games)_ از منوی Omarchy (`Super + Space`) نصب کنید. Heroic به شما اجازه می‌دهد عناوین Epic Games، مانند OddSparks، را که به ضدتقلب متکی نیستند اجرا کنید — به‌علاوه بازی‌های GOG و Amazon Prime Gaming. متأسفانه، این یعنی نه Fortnite و نه Rocket League — تا وقتی Tim Sweeney به لینوکس نیاید، این نزدیک‌ترین چیزی است که به آن می‌رسیم.

مانند Lutris، هنگام نصب بازی‌ها ممکن است کند و ناجور به نظر برسد. به آن وقت بدهید.
