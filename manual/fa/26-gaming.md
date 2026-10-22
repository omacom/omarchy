# بازی

Omarchy فقط برای _بهره‌وری_ نیست، برای خوش‌گذرانی هم هست، و چه چیزی سرگرم‌کننده‌تر از بازی؟ Omarchy با مجموعه کاملی از گزینه‌های بازی ارائه می‌شود — Steam و RetroArch برای بازی بومی و رترو، Battle.net، Lutris و Heroic برای فروشگاه‌های غیر Steam، Moonlight برای جریانی کردن از رایانه، Xbox Cloud Gaming + NVIDIA GeForce NOW برای ابر، به‌علاوه Minecraft همیشه‌سبز.

به لطف کار باورنکردنی Valve روی [لایه سازگاری proton](https://en.wikipedia.org/wiki/Proton_(software))، اکنون ده‌ها هزار بازی مدرن قابل بازی روی لینوکس وجود دارد. آه، و آیا می‌دانستید که [Steam Deck](https://store.steampowered.com/steamdeck/) در واقع Arch را اجرا می‌کند!

همه نصاب‌های بازی زیر _نصب > Gaming_ در منوی Omarchy (`Super + Space`) زندگی می‌کنند. اگر هر وقت خواستید یکی را لغو کنید، از _حذف > Gaming_ استفاده کنید.

## Steam

[Steam](https://store.steampowered.com/) را با انتخاب _نصب > Gaming > Steam_ از منوی Omarchy (`Super + Space`) نصب کنید.

پس از نصب آن، می‌توانید Steam را با `Super + Space` اجرا کنید.

توجه داشته باشید که Steam می‌تواند ۱۰-۲۰ ثانیه طول بکشد تا شروع شود، و هیچ بازخورد بصری‌ای مبنی بر بارگذاری ارائه نمی‌دهد.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

[RetroArch](https://www.retroarch.com/) را با انتخاب _نصب > Gaming > RetroArch_ از منوی Omarchy (`Super + Space`) نصب کنید. با مجموعه کامل هسته‌های libretro ارائه می‌شود، پس همه سیستم‌های کلاسیک پوشش داده شده‌اند.

RetroArch کاملاً با شیدر زیبای CRT Royale برای آن ظاهر رتروی کامل از پیش پیکربندی شده است.

برای راه افتادن:

1. فایل‌های BIOS خود را در `~/Games/bios` و ROMهای خود را در `~/Games/roms` بیندازید.
2. RetroArch را با `Super + Space` و تایپ `retro` اجرا کنید.
3. پوشه `~/Games/roms` را اسکن کنید و آماده بازی هستید.

همچنین می‌توانید به یک بازی مورد علاقه ورودی خودش را در اجراکننده برنامه با _نصب > Gaming > RetroArch Game Launcher_ بدهید، که به شما اجازه می‌دهد یک هسته و یک ROM انتخاب کنید، و مستقیم از `Super + Space` وارد بازی شوید.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

برنامه وب Xbox Cloud Gaming را با انتخاب _نصب > Gaming > Xbox Cloud Gaming_ از منوی Omarchy (`Super + Space`) نصب کنید. این «فقط» یک برنامه وب برای این خدمت است، اما سریع شروع می‌شود و در 1080p عالی اجرا می‌شود.

اگر از قبل Xbox Game Pass دارید، این راهی محکم برای بازی Fortnite و عناوین دیگری است که نمی‌توانید به‌صورت بومی روی لینوکس اجرا کنید.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

خدمت بازی ابری [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) را با انتخاب _نصب > Gaming > NVIDIA GeForce NOW_ از منوی Omarchy (`Super + Space`) نصب کنید. راه عالی دیگری برای بازی عناوینی که به‌صورت بومی روی لینوکس در دسترس نیستند.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Minecraft را با انتخاب _نصب > Gaming > Minecraft_ از منوی Omarchy (`Super + Space`) نصب کنید.

مانند Steam، توجه داشته باشید که پس از ورود یا شروع، می‌تواند مدتی طول بکشد تا صفحه بعدی ظاهر شود، و در حالی که منتظر هستید هیچ بازخوردی نمی‌گیرید.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## دسته‌های Xbox

پشتیبانی از دسته‌های بلوتوث Xbox را با انتخاب _نصب > Gaming > Xbox Controllers_ از منوی Omarchy (`Super + Space`) نصب کنید. دسته‌ها را از طریق بلوتوث (`Super + Ctrl + B`) جفت کنید و در همه بازی‌های شما کار می‌کنند. اگر فقط دسته خود را با یک کابل USB-C وصل می‌کنید به این نیاز ندارید.

## Moonlight (جریانی کردن بازی از یک رایانه)

[کلاینت Moonlight](https://github.com/moonlight-stream/moonlight-qt) با Omarchy از پیش نصب شده است، پس می‌توانید بازی‌ها را از یک رایانه Windows که [Sunshine](https://app.lizardbyte.dev/Sunshine/) را اجرا می‌کند بلافاصله جریانی کنید. Moonlight را از طریق `Super + Space` اجرا کنید.

اگر هم دستگاه Omarchy شما و هم رایانه بازی راه دور سیمی باشند، تجربه از بازی محلی غیرقابل تشخیص است. وضوح را به بومی بالا ببرید، نرخ تازه‌سازی را روی 120Hz تنظیم کنید، و بیت‌ریت را به حداکثر برسانید — این بهترین راه برای بازی شوترهای رقابتی مانند Fortnite روی لینوکس است.

همچنین می‌توانید یک دستگاه Omarchy را با اجرای `omarchy install service sunshine` به میزبان تبدیل کنید، که Sunshine را نصب می‌کند و پورت‌های جریانی Moonlight را برای LAN و Tailscale شما باز می‌کند.

## Battle.net

[Battle.net](https://eu.shop.battle.net/en-us) را با انتخاب _نصب > Gaming > Battle.net_ از منوی Omarchy (`Super + Space`) نصب کنید. این عناوینی مانند Diablo، Starcraft و World of Warcraft را به‌صورت یک نصب مستقل در حال اجرا زیر GE-Proton به شما می‌دهد — نیازی به Steam، Lutris یا Heroic نیست.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (بازی‌های Windows)

[Lutris](https://lutris.net/) را با انتخاب _نصب > Gaming > Lutris_ از منوی Omarchy (`Super + Space`) نصب کنید. Lutris راه بازی بازی‌های Windows از فروشگاه‌هایی مانند EA و Ubisoft Connect است که نصاب خودشان را در بالا ندارند.

نصب کمی خراب است و گاهی به نظر می‌رسد هیچ اتفاقی نمی‌افتد — فقط صبور باشید، در پس‌زمینه کار می‌کند.

## Heroic Launcher (Epic Games)

[Heroic Launcher](https://heroicgameslauncher.com/) را با انتخاب _نصب > Gaming > Heroic (Epic Games)_ از منوی Omarchy (`Super + Space`) نصب کنید. Heroic به شما اجازه می‌دهد عناوین Epic Games، مانند OddSparks، که به ضدتقلب متکی نیستند اجرا کنید — به‌علاوه بازی‌ها از GOG و Amazon Prime Gaming. متأسفانه، این یعنی نه Fortnite و نه Rocket League — تا وقتی Tim Sweeney به لینوکس بیاید، این نزدیک‌ترین چیزی است که می‌شود.

مانند Lutris، هنگام نصب بازی‌ها می‌تواند کند و خراب احساس شود. به آن وقت بدهید.
