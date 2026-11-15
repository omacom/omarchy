# تم‌ها

Omarchy با بیست‌ودو تم زیبا همراه است. می‌توانید از طریق _ظاهر > تم_ در منوی Omarchy (`Super + Space`) بین آن‌ها انتخاب کنید یا با `Super + Ctrl + T` مستقیم به انتخابگر تم بروید.

هر تم به دسکتاپ، ترمینال، neovim، صفحه فعالیت (btop)، Chromium و تمام پوسته Omarchy سبک می‌دهد: نوار بالا، منو، اعلان‌ها، OSD و صفحه قفل. (برای Obsidian، باید تم Omarchy را به‌صورت دستی از طریق _ظاهر > تم‌ها_ در داخل برنامه انتخاب کنید).

تم‌ها مجموعه‌ای از تصاویر پس‌زمینه دارند که می‌توانید با استفاده از `Super + Ctrl + W` بین آن‌ها انتخاب کنید.

می‌توانید تم‌های حتی بیشتری را در [صفحه تم‌های اضافی](https://omarchy.org/themes/) پیدا کنید یا حتی [تم خودتان را بسازید](43-making-your-own-theme.md).

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

### آیکون‌های برنامه

آیکون‌ها در لانچر برنامه و داک با رنگ‌های تم شما کشیده می‌شوند، پس همراه با آن تغییر می‌کنند. آن‌ها از یک مجموعه آیکون می‌آیند که آن را جدا از تم، در بخش _ظاهر > آیکون‌ها_ انتخاب می‌کنید:

- _Papercraft_ پیش‌فرض است: هر چیزی که نصب شده، با یک سبک کشیده شده است. برنامه‌هایی که با لوگویشان شناخته می‌شوند، مثل Chrome، HEY یا YouTube، شکل خود را حفظ می‌کنند و رنگ‌های تم را به خود می‌گیرند.
- _Arcade_ همان برنامه‌ها را به‌صورت هنر پیکسلی 8-bit کشیده است، همان‌طور که یک کنسول بازی قدیمی می‌کشید.
- _Original_ هر برنامه را با آیکونی نشان می‌دهد که سازنده‌اش به آن داده است.

می‌توانید یک مجموعه آیکون ساخته‌شده توسط شخص دیگری را با _نصب > سبک > آیکون‌ها_ (یا `omarchy icons install <git url>`) نصب کنید و دوباره آن را در بخش _حذف > آیکون‌ها_ حذف کنید. _به‌روزرسانی > آیکون‌های اضافی_ آخرین نسخه از مجموعه‌هایی را که نصب کرده‌اید دریافت می‌کند.

برای ساختن مجموعه خودتان، آیکون‌هایتان را در `~/.config/omarchy/icons/<name>/` بگذارید، برای هر برنامه یک فایل، با نامی برگرفته از خط `Icon=` در فایل `.desktop` آن برنامه. فایلی که به `.svg` ختم می‌شود همان‌طور که هست نشان داده می‌شود. فایلی که به `.svg.tpl` ختم می‌شود با رنگ‌های تم کشیده می‌شود: هر جا که یک رنگ قرار می‌گیرد، `{{ icon_main }}`، `{{ icon_mark }}`، `{{ icon_paper }}`، `{{ icon_body }}`، `{{ icon_edge }}`، `{{ icon_ink }}` یا `{{ icon_shadow }}` بنویسید. مجموعه پیش‌فرض در `/usr/share/omarchy/icons/papercraft/` نقطه شروع خوبی برای کار است. برای تغییر یک آیکون تکی از مجموعه پیش‌فرض، نسخه خودتان را در `~/.config/omarchy/icons/papercraft/` بگذارید.

### طرح‌های بازکردن قفل

تم‌ها همچنین می‌توانند یک طرح سفارشی برای بازکردن قفل داشته باشند که برای فرایند رمزگشایی هنگام بوت استفاده می‌شود. می‌توانید یکی از آن‌ها را در بخش _ظاهر > بازکردن قفل_ انتخاب کنید. آن‌ها این‌طور به نظر می‌رسند:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
