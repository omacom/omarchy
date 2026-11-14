# بازی

Omarchy فقط برای _pRoDUcTiVItY_ نیست، برای سرگرمی هم هست، و چه چیزی سرگرم‌کننده‌تر از بازی کردن است؟ Omarchy با مجموعهٔ کاملی از گزینه‌های بازی عرضه می‌شود — Steam و RetroArch برای بازی‌های بومی و رترو، Battle.net و Lutris و Heroic برای فروشگاه‌های غیر Steam، Moonlight برای استریم از رایانهٔ شخصی، Xbox Cloud Gaming + NVIDIA GeForce NOW برای بازی ابری، به‌علاوهٔ Minecraft همیشه‌سبز.

به لطف کار فوق‌العادهٔ Valve روی [لایهٔ سازگاری Proton](https://en.wikipedia.org/wiki/Proton_(software))، حالا ده‌ها هزار بازی مدرن قابل‌بازی روی Linux وجود دارد. اوه، و می‌دانستید که [Steam Deck](https://store.steampowered.com/steamdeck/) در واقع Arch را اجرا می‌کند!

همهٔ نصب‌کننده‌های بازی زیر _Install > Gaming_ در منوی Omarchy (`Super + Space`) قرار دارند. اگر خواستید یکی را حذف کنید، از _Remove > Gaming_ استفاده کنید.

## Steam

[Steam](https://store.steampowered.com/) را با انتخاب _Install > Gaming > Steam_ از منوی Omarchy (`Super + Space`) نصب کنید.

بعد از نصب آن، می‌توانید Steam را با `Super + Space` اجرا کنید.

توجه داشته باشید که راه‌اندازی Steam ممکن است ۱۰ تا ۲۰ ثانیه طول بکشد و هیچ بازخورد بصری‌ای مبنی بر در حال بارگذاری بودن آن ارائه نمی‌دهد.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

[RetroArch](https://www.retroarch.com/) را با انتخاب _Install > Gaming > RetroArch_ از منوی Omarchy (`Super + Space`) نصب کنید. همراه با مجموعهٔ کامل هسته‌های libretro عرضه می‌شود، پس همهٔ سیستم‌های کلاسیک پوشش داده شده‌اند.

RetroArch کاملاً از پیش با شیدر زیبای CRT Royale پیکربندی شده است تا آن ظاهر رتروی بی‌نقص را داشته باشد.

برای شروع:

1. فایل‌های BIOS خود را در `~/Games/bios` و ROMهای خود را در `~/Games/roms` قرار دهید.
2. RetroArch را با `Super + Space` اجرا کنید و `retro` را تایپ کنید.
3. دایرکتوری `~/Games/roms` را اسکن کنید و آمادهٔ بازی هستید.

همچنین می‌توانید با _Install > Gaming > RetroArch Game Launcher_ به یک بازی مورد علاقه ورودی اختصاصی خودش را در لانچر برنامه بدهید، که به شما امکان می‌دهد یک هسته و یک ROM انتخاب کنید و مستقیماً از `Super + Space` وارد بازی شوید.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

وب‌اپ Xbox Cloud Gaming را با انتخاب _Install > Gaming > Xbox Cloud Gaming_ از منوی Omarchy (`Super + Space`) نصب کنید. این «فقط» یک وب‌اپ برای این سرویس است، اما سریع راه می‌افتد و در 1080p عالی اجرا می‌شود.

اگر از قبل Xbox Game Pass دارید، این راه مطمئنی برای بازی Fortnite و عناوین دیگری است که نمی‌توانید به‌صورت بومی روی Linux اجرا کنید.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

سرویس بازی ابری [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) را با انتخاب _Install > Gaming > NVIDIA GeForce NOW_ از منوی Omarchy (`Super + Space`) نصب کنید. راه عالی دیگری برای بازی عناوینی که به‌صورت بومی روی Linux در دسترس نیستند.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Minecraft را با انتخاب _Install > Gaming > Minecraft_ از منوی Omarchy (`Super + Space`) نصب کنید.

مثل Steam، توجه داشته باشید که بعد از ورود یا راه‌اندازی، ممکن است مدتی طول بکشد تا صفحهٔ بعدی ظاهر شود و در حین انتظار هیچ بازخوردی دریافت نخواهید کرد.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## کنترلرهای Xbox

پشتیبانی از کنترلرهای Bluetooth Xbox را با انتخاب _Install > Gaming > Xbox Controllers_ از منوی Omarchy (`Super + Space`) نصب کنید. کنترلرها را از طریق Bluetooth (`Super + Ctrl + B`) جفت کنید و در همهٔ بازی‌هایتان کار خواهند کرد. اگر کنترلر خود را فقط با کابل USB-C سیم‌کشی می‌کنید، به این نیاز ندارید.

## Moonlight (استریم بازی از رایانهٔ شخصی)

[کلاینت Moonlight](https://github.com/moonlight-stream/moonlight-qt) را با انتخاب _Install > Gaming > Moonlight_ از منوی Omarchy (`Super + Space`) نصب کنید، و می‌توانید بازی‌ها را از یک رایانهٔ شخصی Windows که [Sunshine](https://app.lizardbyte.dev/Sunshine/) را اجرا می‌کند استریم کنید.

اگر هم دستگاه Omarchy شما و هم رایانهٔ شخصی بازی از راه دور سیم‌کشی شده باشند، تجربه غیرقابل‌تشخیص از بازی محلی است. وضوح را تا حد بومی بالا ببرید، نرخ تازه‌سازی را روی 120Hz تنظیم کنید و نرخ بیت را به حداکثر برسانید — این بهترین راه برای بازی شوترهای رقابتی مانند Fortnite روی Linux است.

همچنین می‌توانید با اجرای `omarchy install service sunshine` یک دستگاه Omarchy را به میزبان تبدیل کنید، که Sunshine را نصب می‌کند و پورت‌های استریم Moonlight را برای LAN و Tailscale شما باز می‌کند.

## Battle.net

[Battle.net](https://eu.shop.battle.net/en-us) را با انتخاب _Install > Gaming > Battle.net_ از منوی Omarchy (`Super + Space`) نصب کنید. این به شما عناوینی مانند Diablo و Starcraft و World of Warcraft را به‌صورت نصب مستقل که زیر GE-Proton اجرا می‌شود می‌دهد — نیازی به Steam یا Lutris یا Heroic نیست.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (بازی‌های Windows)

[Lutris](https://lutris.net/) را با انتخاب _Install > Gaming > Lutris_ از منوی Omarchy (`Super + Space`) نصب کنید. Lutris راه بازی کردن بازی‌های Windows از فروشگاه‌هایی مانند EA و Ubisoft Connect است که نصب‌کنندهٔ اختصاصی خودشان را در بالا ندارند.

نصب کمی ناجور است و گاهی به نظر می‌رسد هیچ اتفاقی نمی‌افتد — فقط صبور باشید، در پس‌زمینه در حال کار است.

## Heroic Launcher (Epic Games)

[Heroic Launcher](https://heroicgameslauncher.com/) را با انتخاب _Install > Gaming > Heroic (Epic Games)_ از منوی Omarchy (`Super + Space`) نصب کنید. Heroic به شما امکان می‌دهد عناوین Epic Games، مانند OddSparks، که به ضدتقلب متکی نیستند را اجرا کنید — به‌علاوهٔ بازی‌هایی از GOG و Amazon Prime Gaming. متأسفانه، این یعنی نه Fortnite و نه Rocket League — تا وقتی Tim Sweeney به Linux نیاید، این نزدیک‌ترین چیزی است که می‌توانید داشته باشید.

مانند Lutris، هنگام نصب بازی‌ها می‌تواند کند و ناجور احساس شود. به آن زمان بدهید.
