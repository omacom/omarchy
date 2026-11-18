# Fungsi Shell

Omarchy dilengkapi dengan sekumpulan fungsi shell untuk menyederhanakan tugas umum dan mengenkapsulasi panggilan parameter yang berbelit-belit.

## Kompresi

- `compress [file/dir]`: Buat arsip tar.gz dari berkas/direktori.
- `decompress [file.tar.gz]`: Ekspansi berkas tar.gz.

## Drive

- `iso2sd [image.iso]`: Buat drive yang dapat di-boot pada kartu SD menggunakan berkas iso yang dirujuk dan memilih drive secara interaktif.
- `format-drive [device] [name]`: Format seluruh disk dengan satu partisi exFAT (yang juga bekerja di Windows dan macOS). Jalankan tanpa argumen untuk melihat drive yang tersedia. Hati-hati!

## Tata letak dev

Tata letak pengembangan multi-panel instan untuk tmux:

- `tdl [ai]`: Buat Tmux Dev Layout dengan editormu, agen AI, dan terminal. Gunakan alias agen, seperti `tdl c` untuk opencode atau `tdl cx` untuk Claude Code, atau berikan agen kedua untuk menjalankan keduanya, seperti `tdl c cx`.
- `tds`: Buat Tmux Dev Square dengan editor, pengamatan diff (melalui `hunk diff --watch`), terminal, dan opencode.
- `tdlm [ai]`: Buat jendela `tdl` untuk setiap subdirektori di direktori saat ini.
- `tsl [count] [command]`: Buat kawanan panel yang diubin dalam kisi, semuanya menjalankan perintah yang sama (bagus untuk agen AI).

Tata letak yang sama tersedia untuk Herdr sebagai `hdl`, `hds`, `hdlm`, dan `hsl`.

## Git worktree

- `ga [branch]`: Buat worktree dan branch baru di samping repositori saat ini dan lompat ke dalamnya.
- `gd`: Hapus worktree saat ini dan branch-nya (meminta konfirmasi terlebih dahulu).

## Pengamat Rsync

- `rsw [source] [destination]`: Mulai pengamat latar belakang yang melakukan rsync sumber ke tujuan setiap kali ada perubahan. Tujuan dapat berupa host jarak jauh, seperti `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Daftar semua pengamat aktif.
- `dsw`: Hentikan semua pengamat aktif.

## Penerusan Port SSH

Ideal untuk melakukan pengembangan web dengan hak istimewa secure-context localhost terhadap mesin jarak jauh.

- `fip`: Teruskan satu atau lebih port dari host jarak jauh ke localhost melalui SSH.
- `dip`: Putuskan satu atau lebih port yang diteruskan.
- `lip`: Daftar semua penerusan port SSH aktif.

Misalnya kamu memulai server dev pada port `3000` di mesin yang dapat diakses sebagai `nyc-dev`, kemudian kamu dapat menjalankan `fip nyc-dev 3000` untuk meneruskan port tersebut, jadi `localhost:3000` benar-benar mencapai `nyc-dev:3000`, tetapi tanpa perlu sertifikat SSL untuk membangun konteks aman yang dibutuhkan untuk menguji web socket atau semacamnya.

## Penyambungan ulang SSH

`ssh` itu sendiri dibungkus dalam fungsi yang membersihkan terminal jika koneksi mati sementara tmux, Herdr, atau editor jarak jauh telah mengklaimnya, dan kemudian secara otomatis menyambung kembali saat sesi interaktif terputus (Ctrl-C menghentikan loop percobaan ulang).
