# Fungsi Shell

Omarchy dilengkapi dengan set fungsi shell untuk memudahkan tugas biasa dan merangkumkan panggilan parameter yang berbelit.

## Pemampatan

- `compress [file/dir]`: Cipta arkib tar.gz daripada fail/dir.
- `decompress [file.tar.gz]`: Kembangkan fail tar.gz.

## Pemacu

- `iso2sd [image.iso]`: Cipta pemacu boleh but pada kad SD menggunakan fail iso yang dirujuk dan memilih pemacu secara interaktif.
- `format-drive [device] [name]`: Format keseluruhan cakera dengan satu partition exFAT (yang juga berfungsi pada Windows dan macOS). Jalankan tanpa argumen untuk melihat pemacu yang tersedia. Berhati-hati!

## Susun atur dev

Susun atur pembangunan berbilang anak tetingkap segera untuk tmux:

- `tdl [ai]`: Cipta Susun Atur Dev Tmux dengan penyunting anda, ejen AI, dan terminal. Gunakan alias ejen, seperti `tdl c` untuk opencode atau `tdl cx` untuk Claude Code, atau berikan ejen kedua untuk menjalankan kedua-duanya, seperti `tdl c cx`.
- `tds`: Cipta Tmux Dev Square dengan penyunting, pemerhatian diff (melalui `hunk diff --watch`), terminal, dan opencode.
- `tdlm [ai]`: Cipta tetingkap `tdl` untuk setiap subdirektori dalam direktori semasa.
- `tsl [count] [command]`: Cipta sekumpulan anak tetingkap berjubin dalam grid, semuanya menjalankan perintah yang sama (hebat untuk ejen AI).

Susun atur yang sama tersedia untuk Herdr sebagai `hdl`, `hds`, `hdlm`, dan `hsl`.

## Pokok kerja Git

- `ga [branch]`: Cipta pokok kerja dan cabang baharu bersebelahan repositori semasa dan lompat ke dalamnya.
- `gd`: Buang pokok kerja semasa dan cabangnya (meminta pengesahan dahulu).

## Pemerhati Rsync

- `rsw [source] [destination]`: Mulakan pemerhati latar yang menyegerak rsync sumber ke destinasi setiap kali apa-apa berubah. Destinasi boleh jadi hos jauh, seperti `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Senaraikan semua pemerhati aktif.
- `dsw`: Hentikan semua pemerhati aktif.

## Pemajuan Port SSH

Sesuai untuk melakukan pembangunan web dengan keistimewaan konteks selamat localhost terhadap mesin jauh.

- `fip`: Maju satu atau lebih port daripada hos jauh ke localhost melalui SSH.
- `dip`: Putuskan satu atau lebih port yang dimajukan.
- `lip`: Senaraikan semua pemajuan port SSH aktif.

Katakan anda memulakan pelayan dev pada port `3000` pada mesin yang boleh diakses sebagai `nyc-dev`, kemudian anda boleh menjalankan `fip nyc-dev 3000` untuk memajukan port itu, supaya `localhost:3000` sebenarnya mencapai `nyc-dev:3000`, tetapi tanpa memerlukan sijil SSL untuk mewujudkan konteks selamat yang diperlukan untuk menguji soket web atau seumpamanya.

## Penyambungan semula SSH

`ssh` itu sendiri dibalut dalam fungsi yang membersihkan terminal jika sambungan terputus semasa tmux, Herdr, atau penyunting jauh telah mengambilnya, dan kemudian menyambung semula secara automatik apabila sesi interaktif terputus (Ctrl-C menghentikan gelung cuba semula).
