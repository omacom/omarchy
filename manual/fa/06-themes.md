# تم‌ها

Omarchy با بیست‌ودو تم زیبا همراه است. می‌توانید از طریق _ظاهر > تم_ در منوی Omarchy (`Super + Space`) بین آن‌ها انتخاب کنید یا با `Super + Ctrl + T` مستقیم به انتخاب‌گر تم بروید.

هر تم به دسکتاپ، ترمینال، neovim، صفحه‌ی فعالیت (btop)، Chromium و کل پوسته‌ی Omarchy سبک می‌دهد: نوار بالا، منو، اعلان‌ها، OSD و صفحه‌ی قفل. (برای Obsidian، باید تم Omarchy را به‌صورت دستی از طریق _ظاهر > تم‌ها_ داخل خود برنامه انتخاب کنید).

تم‌ها مجموعه‌ای از تصاویر پس‌زمینه دارند که می‌توانید با `Super + Ctrl + W` بین آن‌ها انتخاب کنید.

می‌توانید تم‌های بیشتری را در [صفحه‌ی تم‌های اضافی](https://omarchy.org/themes/) پیدا کنید یا حتی [تم خودتان را بسازید](43-making-your-own-theme.md).

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

آیکون‌های موجود در اجراکننده‌ی برنامه و داک با رنگ‌های تم شما کشیده می‌شوند، پس همراه با آن تغییر می‌کنند. آن‌ها از یک مجموعه آیکون می‌آیند که آن را جدا از تم، از _ظاهر > آیکون‌ها_ و از روی پیش‌نمایش هر مجموعه انتخاب می‌کنید، درست همان‌طور که یک تم انتخاب می‌کنید:

- _Papercraft_ پیش‌فرض است: همه‌ی چیزهایی که نصب‌شده می‌آیند، با یک سبک واحد کشیده شده‌اند. برنامه‌هایی که با لوگوی‌شان شناخته می‌شوند، مثل Chrome، HEY یا YouTube، شکل آن را حفظ می‌کنند و رنگ‌های تم را به خود می‌گیرند.
- _Arcade_ همان برنامه‌ها را به‌صورت هنر پیکسلی 8-bit می‌کشد، همان‌طور که یک کنسول بازی قدیمی می‌کشید.
- _Original_ هر برنامه را با آیکونی نشان می‌دهد که سازنده‌اش به آن داده است.

می‌توانید یک مجموعه آیکون را که شخص دیگری ساخته است با _نصب > سبک > آیکون‌ها_ (یا `omarchy icons install <git url>`) نصب کنید و دوباره آن را از _حذف > آیکون‌ها_ حذف کنید. _به‌روزرسانی > آیکون‌های اضافی_ تازه‌ترین نسخه‌ی مجموعه‌هایی را که نصب کرده‌اید دریافت می‌کند.

برای ساختن مجموعه‌ی خودتان، آیکون‌های‌تان را در `~/.config/omarchy/icons/<name>/` بگذارید، برای هر برنامه یک فایل، با نامی برگرفته از خط `Icon=` در فایل `.desktop` آن برنامه. فایلی که به `.svg` ختم شود همان‌طور که هست نشان داده می‌شود. فایلی که به `.svg.tpl` ختم شود با رنگ‌های تم کشیده می‌شود: هر جا که یک رنگ قرار می‌گیرد `{{ icon_main }}`، `{{ icon_mark }}`، `{{ icon_paper }}`، `{{ icon_body }}`، `{{ icon_edge }}`، `{{ icon_ink }}` یا `{{ icon_shadow }}` بنویسید. مجموعه‌ی پیش‌فرض در `/usr/share/omarchy/icons/papercraft/` جای خوبی برای شروع است. یک `preview.png` اضافه کنید تا مجموعه‌تان در انتخاب‌گر نشان داده شود؛ بدون آن، Omarchy یک پیش‌نمایش از روی آیکون‌های شما می‌کشد. برای تغییر یک آیکون منفرد از مجموعه‌ی پیش‌فرض، نسخه‌ی خودتان را در `~/.config/omarchy/icons/papercraft/` بگذارید.

### بازگشایی‌ها

تم‌ها همچنین می‌توانند یک طرح بازگشایی سفارشی داشته باشند که برای فرایند رمزگشایی هنگام بوت استفاده می‌شود. می‌توانید یکی از آن‌ها را از _ظاهر > بازگشایی_ انتخاب کنید. آن‌ها این‌طوری‌اند:

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
