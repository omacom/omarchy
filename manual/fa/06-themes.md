# تم‌ها

Omarchy با بیست‌وسه تم زیبا می‌آید. می‌توانید از طریق _ظاهر > تم_ در منوی Omarchy (`Super + Space`) بین آن‌ها انتخاب کنید یا با `Super + Ctrl + T` مستقیم به انتخاب‌گر تم بروید.

هر تم به دسکتاپ، ترمینال، neovim، صفحهٔ فعالیت (btop)، مرورگرتان (Chrome، Chromium، Edge یا Brave) و کل پوستهٔ Omarchy سبک می‌دهد: نوار بالایی، منو، اعلان‌ها، OSD و صفحهٔ قفل. (برای Obsidian، باید تم Omarchy را به‌صورت دستی از طریق _ظاهر > تم‌ها_ داخل خود برنامه انتخاب کنید).

تم‌ها مجموعه‌ای از تصاویر پس‌زمینه دارند که می‌توانید با استفاده از `Super + Ctrl + W` بین آن‌ها انتخاب کنید.

می‌توانید تم‌های بیشتری را در [صفحهٔ تم‌های اضافی](https://omarchy.org/themes/) پیدا کنید یا حتی [تم خودتان را بسازید](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### آیکون‌های برنامه

آیکون‌های لانچر برنامه و داک با رنگ‌های تم شما کشیده می‌شوند، پس همراه با آن تغییر می‌کنند. آن‌ها از یک مجموعه آیکون می‌آیند که آن را جدا از تم، در بخش _ظاهر > آیکون‌ها_، از پیش‌نمایش‌های هر مجموعه و به همان شیوه‌ای که تم انتخاب می‌کنید، انتخاب می‌کنید:

- _Papercraft_ پیش‌فرض است: همهٔ چیزهایی که نصب‌شده می‌آیند، با یک سبک کشیده شده‌اند. برنامه‌هایی که با لوگوشان شناخته می‌شوند، مثل Chrome، HEY یا YouTube، شکلشان را حفظ می‌کنند و رنگ‌های تم را به خود می‌گیرند.
- _Arcade_ همان برنامه‌ها را به‌صورت هنر پیکسلی ۸ بیتی می‌کشد، همان‌طور که یک کنسول بازی قدیمی می‌کشید.
- _Original_ هر برنامه را با آیکونی نشان می‌دهد که سازنده‌اش به آن داده است.

می‌توانید مجموعه آیکونی را که شخص دیگری ساخته است با _نصب > سبک > آیکون‌ها_ (یا `omarchy icons install <git url>`) نصب کنید، و دوباره آن را در بخش _حذف > آیکون‌ها_ حذف کنید. _به‌روزرسانی > آیکون‌های اضافی_ آخرین نسخهٔ مجموعه‌هایی را که نصب کرده‌اید دریافت می‌کند.

برای ساختن مجموعهٔ خودتان، آیکون‌هایتان را در `~/.config/omarchy/icons/<name>/` بگذارید، برای هر برنامه یک فایل، که بر اساس خط `Icon=` فایل `.desktop` آن برنامه نام‌گذاری شده باشد. فایلی که به `.svg` ختم می‌شود همان‌طور که هست نشان داده می‌شود. فایلی که به `.svg.tpl` ختم می‌شود با رنگ‌های تم کشیده می‌شود: هرجا که رنگ قرار می‌گیرد `{{ icon_main }}`، `{{ icon_mark }}`، `{{ icon_paper }}`، `{{ icon_body }}`، `{{ icon_edge }}`، `{{ icon_ink }}` یا `{{ icon_shadow }}` بنویسید. مجموعهٔ پیش‌فرض در `/usr/share/omarchy/icons/papercraft/` جای خوبی برای شروع کردن از روی آن است. یک `preview.png` اضافه کنید تا مجموعه‌تان در انتخاب‌گر نشان داده شود؛ بدون آن، Omarchy پیش‌نمایشی را از آیکون‌هایتان می‌کشد. برای تغییر یک آیکون منفرد از مجموعهٔ پیش‌فرض، نسخهٔ خودتان را در `~/.config/omarchy/icons/papercraft/` بگذارید.

### بوت و ورود

صفحه‌ای که هنگام روشن شدن کامپیوتر رمز درایوتان را می‌خواهد و صفحهٔ ورود هم از تم پیروی می‌کنند. هر بار که تم‌ها را عوض می‌کنید، آن‌ها پس‌زمینه، متن، رنگ تأکیدی و رنگ‌های قرمز آن را می‌گیرند، پس طرح جداگانه‌ای برای باز کردن قفل وجود ندارد که انتخاب کنید. در مک‌های Apple Silicon، صفحهٔ رمز درایو هر تمی که باشد، ظاهر پیش‌فرض Omarchy را حفظ می‌کند.
