# ابزارهای توسعه

## ویرایشگرهای جایگزین

Omarchy در نصب‌های جدید با Plain به‌عنوان ویرایشگر پیش‌فرض عرضه می‌شود و [Neovim](https://neovim.io/) از پیش نصب شده است، اما اگر چیزی کمی متعارف‌تر و آشناتر می‌خواهید، می‌توانید منوی Omarchy (`Super + Space`) را اجرا کنید و گزینه‌های زیر _Install > Editor_ را ببینید. VSCode، Cursor، Zed، Sublime Text، Helix، Vim و Emacs در آنجا فهرست شده‌اند. اگر چیزی را که دنبالش هستید پیدا نکردید، _Install > Package_ را بررسی کنید و ببینید در یک بسته Arch نیست (و اگر نبود، _Install > AUR_ را امتحان کنید تا AUR را بررسی کنید).

ویرایشگر اصلی `vi` هم از همان ابتدا در دسترس است. برای ویرایش یک فایل در ترمینال، `vi filename` را اجرا کنید.

تطبیق تم برای `VSCode`، `Cursor`، `VSCodium` و `Helix` ارائه می‌شود.

می‌توانید ویرایشگر پیش‌فرض سراسری سیستم را در `Setup > Defaults > Editor` تنظیم کنید.

## محیط

Omarchy از راه‌اندازی مجموعه کاملی از محیط‌های توسعه از طریق بخش _Install > Development_ در منوی Omarchy (`Super + Space`) پشتیبانی می‌کند. البته _Ruby on Rails_ را پیدا خواهید کرد، اما هر سه زمان‌اجرای اصلی JavaScript (Node.js، Bun، Deno) و همچنین چارچوب‌های محبوب PHP مانند Laravel و Symfony هم هستند. آه، و Go، Rust، Python، Java، Elixir (با Phoenix)، .NET، OCaml، Zig، Clojure و Scala هم هستند. انتخاب بسیار گسترده‌ای است!

بیشتر این محیط‌ها توسط [Mise](https://mise.jdx.dev/) مدیریت می‌شوند. این ابزاری است که به شما امکان می‌دهد چند نسخه از یک زبان برنامه‌نویسی را روی یک ماشین نصب و اجرا کنید. مثل rbenv یا rvm برای Ruby یا virtualenv برای Python است، اما برای کلی محیط مختلف کار می‌کند.

مثلاً برای نصب Ruby، `mise use -g ruby` را اجرا می‌کنید، که هم Ruby را نصب می‌کند و هم آن را به‌عنوان پیش‌فرض سراسری تنظیم می‌کند. یا اگر پروژه‌تان فایل .ruby-version دارد، می‌توانید در ریشه آن پروژه فقط `mise i` را اجرا کنید.

## ابزارهای CLI از پیش نصب‌شده

`uv`، Node.js و `playwright-cli` (برای عامل‌ها تا با استفاده از Chrome نصب‌شده یک مرورگر را هدایت کنند) به‌صورت بسته نصب می‌شوند و `omarchy update` آن‌ها را در کنار بقیه سیستم به‌روز نگه می‌دارد. `ghui`، [Hunk](https://github.com/modem-dev/hunk) و CLIهای Basecamp، Cloudflare و HEY فقط با یک انتخاب در زیر _Install > CLI_ در دسترس‌اند و [عامل‌های کدنویسی](17-ai.md) در زیر _Install > AI > CLI_ قرار دارند.

mise فقط زمان‌اجراهایی را مدیریت می‌کند که از _Install > Development_ راه‌اندازی می‌کنید؛ Omarchy به‌تنهایی چیزی از طریق آن نصب نمی‌کند. `omarchy update` را اجرا کنید تا آن‌ها را همراه با بقیه Omarchy به‌روز کنید؛ نام مستعار `mup` فقط ابزارهای مدیریت‌شده با mise را به‌روز می‌کند. برای افزودن ابزار دیگری به پیکربندی خودتان، از `mise use -g <tool>` استفاده کنید.

## Docker

[Docker](https://www.docker.com/) تقریباً نیازی به معرفی ندارد. به شما امکان می‌دهد کانتینرهای ایزوله اجرا کنید و Omarchy هر آنچه برای اجرای خوب آن لازم است، از جمله خود Docker و [Docker Compose](https://docs.docker.com/compose/) را نصب می‌کند.

به‌طور پیش‌فرض کاربر شما در گروه `docker` *نیست*. آن گروه در واقع root بدون گذرواژه است — هر چیزی در آن می‌تواند `docker run -v /:/host` را اجرا کند و ماشین را در اختیار بگیرد — پس یک اسکریپت یا وابستگی سرکش که به‌عنوان شما اجرا شود، در غیر این صورت فقط یک فرمان با root فاصله داشت. بنابراین در خط فرمان Docker را با `sudo` اجرا می‌کنید (`sudo docker ps`، `sudo docker compose up`) و ابزارهای گرافیکی که با daemon صحبت می‌کنند — VM ویندوز — وقتی به آن نیاز داشته باشند، درخواست مجوز می‌کنند. اگر راحتی یک راه‌اندازی بدون گروه را می‌خواهید و این بده‌بستان را درک می‌کنید، آن را از **Setup > Security > Sudoless Docker** فعال کنید (یا `omarchy-setup-security-sudoless-docker` را اجرا کنید)، که پس از یک هشدار شما را به گروه `docker` اضافه می‌کند؛ سپس `docker` ساده و نام مستعار `d` دوباره بدون `sudo` کار می‌کنند.

می‌توانید پایگاه‌های داده رایج برای توسعه محلی در Docker را با استفاده از _Install > Development > Docker DB_ در منوی Omarchy راه‌اندازی کنید.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) همان `gh` است، برای کار با مخزن‌ها، issueها و pull requestها از ترمینال. _Setup > Git_ وقتی انتخاب می‌کنید در GitHub آنجا وارد شوید آن را نصب می‌کند، سپس `gh repo clone org/repo` یک مخزن را clone می‌کند. برای بررسی فرمان‌های آن `gh --help` را اجرا کنید.

_Install > CLI > GitHub_، GitHub CLI یعنی `gh` را همراه با `ghui`، یک رابط ترمینالی برای pull requestها، نصب می‌کند. [Lazygit](https://github.com/jesseduffield/lazygit) برای کار با خود Git از پیش نصب شده است.
