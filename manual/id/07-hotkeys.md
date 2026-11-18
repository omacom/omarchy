# Pintasan Keyboard

Anda dapat melihat semua ikatan keyboard utama dengan `Super + K` (ikatan Tmux dengan `Super + Alt + K` dan ikatan Herdr dengan `Super + Ctrl + K`).

## Cara pintasan keyboard ditata

Setiap pintasan keyboard berada di satu bidang, ditentukan oleh pengubahnya, dan setiap bidang punya satu tugas. Itulah yang membuat pintasan keyboard tidak tercampur, dan itu berarti Anda biasanya bisa menebak di mana sesuatu berada.

| Bidang | Isinya | Contoh |
| --- | --- | --- |
| `Super + key` | Sistem: jendela, ruang kerja, tata letak, dan menu inti | `Super + Space` menu Omarchy, `Super + W` tutup jendela, `Super + F` layar penuh |
| `Super + Shift + key` | Aplikasi | `Super + Shift + B` browser, `Super + Shift + E` email, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panel dan menu sistem | `Super + Ctrl + A` audio, `Super + Ctrl + N` jaringan, `Super + Ctrl + C` menu tangkapan |
| `Super + Ctrl + Alt + key` | Tindakan cepat dan pemberitahuan | `Super + Ctrl + Alt + T` tampilkan waktu, `Super + Ctrl + Alt + B` baterai, `Super + Ctrl + Alt + C` tangkapan layar |

Menambahkan `Alt` ke pintasan keyboard memberi Anda varian dari hal yang sama, tidak pernah sesuatu yang tidak terkait:

- `Super + Shift + B` membuka browser; `Super + Shift + Alt + B` membuka jendela pribadi
- `Super + Shift + E` membuka email; `Super + Shift + Alt + E` memulai email baru
- `Super + F` masuk layar penuh; `Super + Alt + F` masuk lebar penuh
- `Super + Ctrl + C` membuka menu tangkapan; `Super + Ctrl + Alt + C` melewati menu dan mengambil tangkapan layar

Saat menambahkan pintasan keyboard:

1. Pilih bidang berdasarkan fungsinya, lalu pilih tombolnya.
2. Jangan pindahkan pintasan keyboard yang sudah ada untuk memberi ruang. Temukan tombol kosong di bidang yang tepat.
3. Hanya gunakan `Alt` untuk varian dari pintasan keyboard tanpanya.

Beberapa pintasan keyboard melanggar aturan ini karena praktis. `Shift` dengan panah atau `Tab` memindahkan atau membalikkan alih-alih membuka aplikasi, dan `Print`, tombol media, `Alt + Tab`, dan `Ctrl + Alt + Del` bekerja seperti di tempat lain. Itu pengecualian, bukan pola untuk ditiru.

Jika bawaan tidak cocok untuk Anda (misalnya Anda ingin `Super + Shift + S` untuk tangkapan layar seperti di Windows), ikat ulang di `~/.config/hypr/bindings.lua`.

## Navigasi

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplikasi dan segala hal lainnya)    |
| `Super + Alt + Space` | Kisi aplikasi |
| `Super + Escape` | Menu sistem (tangguhkan, mulai ulang, dll)  |
| `Super + Ctrl + L` | Kunci komputer |
| `Super + W` or `Super + Q` | Tutup jendela             |
| `Ctrl + Alt + Del` | Tutup semua jendela |
| `Super + T`               | Alihkan jendela antara mengubin/mengambang             |
| `Super + J` | Alihkan posisi jendela (horizontal/vertikal) |
| `Super + O`               | Alihkan jendela yang mencuat menjadi lengket dan mengambang |
| `Super + L`               | Putar melalui tata letak dwindle, scrolling, dan floating |
| `Super + Alt + L`         | Putar melalui tata letak secara terbalik |
| `Super + P`               | Alihkan gaya jendela pseudo (natural vs stretch) |
| `Super + F`                 | Masuk layar penuh              |
| `Super + Alt + F`                 | Masuk lebar penuh              |
| `Super + Ctrl + F`                 | Masuk layar penuh di dalam jendela              |
| `Super + 1/2/3/4`         | Lompat ke ruang kerja tertentu di monitor yang terfokus |
| `Super + Tab` | Lompat ke ruang kerja berikutnya di monitor yang terfokus |
| `Super + Shift + Tab` | Lompat ke ruang kerja sebelumnya di monitor yang terfokus |
| `Super + Ctrl + Tab` | Lompat ke ruang kerja terdahulu di monitor yang terfokus |
| `Super + Shift + 1/2/3/4` | Pindahkan jendela ke ruang kerja di monitor yang terfokus |
| `Super + Shift + Alt + 1/2/3/4` | Pindahkan jendela ke ruang kerja di monitor yang terfokus tanpa mengikutinya |
| `Super + S` | Alihkan scratchpad penuh |
| `Super + Alt + S` | Pindahkan jendela ke scratchpad penuh |
| `Super + Grave` | Alihkan konsol Quake |
| `Super + Shift + Grave` | Pindahkan jendela ke konsol Quake |
| `Super + Shift + Ctrl + Arrows` | Pindahkan jendela ke monitor ke arah tersebut |
| `Super + Shift + Alt + Arrows` | Pindahkan ruang kerja ke monitor ke arah tersebut |
| `Super + Arrow`  | Pindahkan fokus ke jendela searah panah, menyeberang ke monitor di sisi tersebut di tepi layar |
| `Super + Shift + Arrow`  | Tukar jendela dengan jendela lain searah panah, termasuk yang ada di monitor di sisi tersebut |
| `Super + Minus` | Perluas jendela ke kiri |
| `Super + Equal` | Kecilkan jendela ke kiri |
| `Super + Shift + Minus` | Kecilkan jendela ke atas |
| `Super + Shift + Equal` | Perluas jendela ke bawah |
| `Super + Alt + Minus/Equal` | Pengubahan ukuran yang sama dalam langkah lebih kecil |
| `Super + Ctrl + Minus/Equal` | Pengubahan ukuran yang sama dalam langkah lebih besar |
| `Super + Alt + Home` | Simpan lebar jendela |
| `Super + Home` | Pulihkan lebar jendela yang disimpan |
| `Super + Left Mouse` | Seret jendela |
| `Super + Right Mouse` | Ubah ukuran jendela |
| `Super + Scroll Wheel` | Gulir melalui ruang kerja di monitor yang terfokus |
| `Super + G`               | Alihkan pengelompokan jendela      |
| `Super + Alt + G`               | Keluarkan jendela dari pengelompokan      |
| `Super + Alt + Tab`               | Putar antarjendela dalam pengelompokan      |
| `Super + Alt + Shift + Tab`               | Putar mundur antarjendela dalam pengelompokan      |
| `Super + Alt + Scroll Wheel` | Putar antarjendela dalam pengelompokan |
| `Super + Alt + 1/2/3/4/5`               | Lompat ke jendela tertentu dalam pengelompokan      |
| `Super + Alt + Arrow`  | Pindahkan jendela ke dalam pengelompokan searah panah, termasuk yang ada di monitor di sisi tersebut |
| `Super + Ctrl + Left/Right`  | Berpindah antarjendela di dalam grup tiling |
| `Super + Ctrl + Z` | Perbesar tampilan layar (ulangi untuk perbesaran lebih) |
| `Super + Ctrl + Alt + Z` | Perkecil tampilan layar sepenuhnya |
| `Super + /` | Maju selangkah melalui opsi penskalaan monitor |
| `Super + Alt + /` | Mundur selangkah melalui opsi penskalaan monitor |
| `Alt + Tab` | Putar maju melalui jendela di ruang kerja aktif |
| `Alt + Shift + Tab` | Putar mundur melalui jendela di ruang kerja aktif |
| `Ctrl + Alt + Tab`| Putar fokus maju melalui monitor |
| `Ctrl + Alt + Shift + Tab`| Putar fokus mundur melalui monitor |

Pintasan pengubahan ukuran menggunakan tombol fisik `code:20` dan `code:21` (XKB `<AE11>` dan `<AE12>`), terlepas dari karakter yang tercetak di keyboard. Di keyboard US tombol ini adalah `-` dan `=`; di keyboard Jepang (JIS) tombol ini adalah `-` dan `^`; di keyboard Spanyol tombol ini adalah `'` dan `¡`. Di JIS, `Super + ^` adalah `Super + Equal`, sedangkan `Super + Shift + -` (yang mengetik `=`) adalah `Super + Shift + Minus`.

## Kontrol sistem

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel audio    |
| `Super + Ctrl + B`           | Panel Bluetooth    |
| `Super + Ctrl + N`           | Panel Wifi/jaringan    |
| `Super + Ctrl + D`           | Panel tampilan    |
| `Super + Ctrl + P`           | Panel daya    |
| `Super + Ctrl + X`           | Panel agen    |
| `Super + Ctrl + Alt + D`           | Panel kalender    |
| `Super + Ctrl + Alt + E`           | Panel jam dunia    |
| `Super + Ctrl + 1-9`           | Alihkan panel bar berdasarkan posisi    |
| `Super + Ctrl + S` | Menu berbagi (via LocalSend) |
| `Super + Ctrl + C` | Kontrol tangkapan (tangkapan layar/perekaman/pemilih) |
| `Super + Ctrl + O` | Menu alih |
| `Super + Ctrl + H` | Menu perangkat keras |
| `Super + Ctrl + E` | Pemilih emoji |
| `Super + Ctrl + .` | Transkode media |
| `Super + Shift + Ctrl + A` | Pilih agen AI |

## Penyesuaian

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Kecerahan layar maksimum |
| `Shift + Brightness Down` | Kecerahan layar minimum |
| `Alt + Brightness Up/Down` | Perubahan kecerahan 1% yang presisi |
| `Alt + Volume Up/Down` | Perubahan volume 1% yang presisi |
| `Keyboard Brightness Up/Down` | Lampu latar keyboard lebih terang/lebih redup |
| `Keyboard Backlight` | Putar tingkat lampu latar keyboard |
| `Alt + Play` | Trek berikutnya |
| `Alt + Shift + Play` | Trek sebelumnya |

## Meluncurkan aplikasi

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (pengelola agen) |
| `Super + Shift + Return`           | Browser    |
| `Super + Shift + Alt + B`           | Browser (pribadi/penyamaran)    |
| `Super + Shift + F`           | Pengelola berkas    |
| `Super + Shift + Alt + F`           | Pengelola berkas di cwd terminal    |
| `Super + Shift + M`           | Musik (Spotify)    |
| `Super + Shift + Alt + M`           | Musik (cliamp)    |
| `Super + Shift + /`           | Pengelola kata sandi (1password)    |
| `Super + Shift + Q`           | Kalkulator (Omacalc)    |
| `Super + Shift + T`           | Aktivitas (btop)    |
| `Super + Shift + N`           | Editor (Neovim)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Email ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Email baru ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Perpesanan (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Perpesanan (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Perpesanan (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Menulis (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Ubah/tambah ikatan di `~/.config/hypr/bindings.lua`.

## Papan klip universal

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + A`           | Pilih semua di aplikasi yang mendukung `Ctrl + A`    |
| `Super + C`           | Salin    |
| `Super + X`           | Potong (tidak di terminal)    |
| `Super + V`           | Tempel    |
| `Super + Ctrl + V`           | Pengelola papan klip    |

Biasanya di Linux, Anda perlu `Ctrl + Shift + C/V` untuk menyalin dan menempel di terminal dan `Ctrl + C/V` untuk melakukannya di tempat lain. Pintasan papan klip terpadu Omarchy ini bekerja di mana pun.

## Tangkapan

| Pintasan              | Fungsi                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Tangkapan layar                      |
| `Super + Ctrl + Alt + C`            | Tangkapan layar (tangkapan yang sama, untuk keyboard tanpa tombol Print Screen) |
| `Super + Ctrl + C` | Menu tangkapan |
| `Alt + Print Screen`            | Perekaman layar                     |
| `Super + Shift + Ctrl + Alt + C` | Perekaman layar tanpa audio, melewati menu (tekan lagi untuk berhenti) |
| `Super + Print Screen` | Pemilih warna |
| `Super + Ctrl + Print Screen` | Ekstraksi teks ke papan klip |
| `Super + Alt + [` | Perkecil overlay webcam saat merekam |
| `Super + Alt + ]` | Perbesar overlay webcam saat merekam |
| `Alt + Shift + L` | Salin URL saat ini dari webapp atau browser |
| `Alt + Shift + D` | Unduh video di halaman saat ini ke `~/Videos` |
| `Alt + Space` | Mulai/hentikan dikte (memerlukan _Setup > Defaults > Dictation_) |
| `Right Alt` | Tahan untuk mendikte (memerlukan _Setup > Defaults > Dictation_) |

Dengan perekaman layar, pintasan pertama-tama menanyakan audio mana yang Anda inginkan, lalu mulai merekam. Tekan lagi untuk berhenti. Lihat [tangkapan layar dan perekaman](12-screenshots-recording.md) untuk detailnya.

Semua opsi tangkapan juga dapat diakses di bawah _Trigger > Capture_ di menu Omarchy (`Super + Space`).

## Notifikasi

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + ,` | Tindak lanjuti notifikasi terbaru: buka, atau tekan satu-satunya tombolnya, pilih dari pilihannya, atau abaikan jika tidak ada  |
| `Super + Shift + ,` | Abaikan semua notifikasi |
| `Super + Ctrl + ,` | Kontrol notifikasi dengan keyboard  |
| `Super + Alt + ,` | Abaikan notifikasi terbaru  |
| `Super + Shift + Alt + ,` | Buka riwayat notifikasi  |
| `Super + Ctrl + Alt + ,` | Alihkan pembungkaman notifikasi  |

## Gaya

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Pilih tema baru (juga `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Pilih latar belakang tema (juga `Super + Ctrl + Space`) |
| `Super + Backspace` | Alihkan transparansi pada jendela |
| `Super + Ctrl + Backspace` | Alihkan aspek persegi jendela tunggal |

Gambar latar belakang tambahan berada di `~/.config/omarchy/backgrounds/<theme name>`. Juga tersedia melalui _Install > Style > Background_ di menu Omarchy.

Semua opsi gaya juga dapat diakses di bawah _Style_ di menu Omarchy (`Super + Space`).

## Pengalihan

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alihkan penguncian saat diam |
| `Super + Ctrl + Delete` | Alihkan tampilan laptop nyala/mati |
| `Super + Ctrl + Alt + Delete` | Alihkan pencerminan tampilan laptop |
| `Super + Shift + Space` | Alihkan bar atas  |
| `Shift + Mute` | Beralih ke keluaran audio berikutnya |
| `Shift + Play` | Beralih ke sumber media berikutnya |
| `Super + Shift + Backspace` | Alihkan celah jendela |
| `Super + Ctrl + Alt + F` | Alihkan desktop layar penuh (bar atas + celah jendela) |

## Pengingat

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Atur pengingat  |
| `Super + Ctrl + Alt + R` | Lihat semua pengingat  |
| `Super + Ctrl + Shift + R` | Hapus semua pengingat  |

## Pemberitahuan

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Tampilkan waktu sebagai notifikasi  |
| `Super + Ctrl + Alt + B` | Tampilkan baterai sebagai notifikasi  |
| `Super + Ctrl + Alt + W` | Alihkan cuaca sebagai notifikasi  |

## Tmux

Tombol prefix adalah `Ctrl + Space` (`Ctrl + B` juga bekerja). Anda dapat mengubah ikatan ini di `~/.config/tmux/tmux.conf`.

### Pane

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + v` | Bagi pane di samping (vertikal) |
| `Prefix + h` | Bagi pane di bawah (horizontal) |
| `Prefix + x` | Matikan pane |
| `Prefix + z` | Alihkan zoom pane (layar penuh) |
| `Alt + Enter` | Bagi pane di bawah (tanpa prefix) |
| `Alt + Shift + Enter` | Bagi pane di samping (tanpa prefix) |
| `Alt + Escape` | Matikan pane (tanpa prefix) |
| `Ctrl + Alt + Arrows` | Berpindah antar-pane |
| `Ctrl + Alt + Shift + Arrows` | Ubah ukuran pane |

### Jendela

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + c` | Jendela baru |
| `Prefix + k` | Matikan jendela |
| `Prefix + r` | Ganti nama jendela |
| `Alt + 1-9` | Pergi ke jendela tertentu |
| `Alt + Arrow Left/Right` | Berpindah antarjendela |
| `Alt + Shift + Arrow Left/Right` | Pindahkan jendela ke kiri/kanan |

### Sesi

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + C` | Sesi baru |
| `Prefix + K` | Matikan sesi |
| `Prefix + R` | Ganti nama sesi |
| `Prefix + N` | Sesi berikutnya |
| `Prefix + P` | Sesi sebelumnya |
| `Alt + Arrow Up/Down` | Berpindah antarsesi |
| `Prefix + s` | Daftar sesi |
| `Prefix + d` | Lepaskan dari sesi |

### Mode salin (gaya vi)

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + [` | Masuk mode salin |
| `v` | Mulai pemilihan (dalam mode salin) |
| `y` | Salin pilihan (dalam mode salin) |

### Umum

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + q` | Muat ulang konfigurasi |
| `Prefix + ?` | Tampilkan ikatan tombol Tmux |
| `Prefix + :` | Prompt perintah |

### Fungsi tata letak Tmux

Fungsi-fungsi ini harus dijalankan di dalam sesi Tmux.

| Perintah | Fungsi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Buat tata letak dev dengan editor, AI, dan terminal |
| `tdlm <ai> [<second_ai>]` | Buat tata letak dev per subdirektori |
| `tsl <count> <command>` | Buat tata letak swarm multi-pane |

## Terminal Ghostty

Terminal Ghostty dipasang menggunakan _Install > Terminal_ melalui menu Omarchy.

| Pintasan                  | Fungsi              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Pemisahan baru di bawah |
| `Ctrl + Shift + O` | Pemisahan baru di samping |
| `Ctrl + Alt + Arrows` | Berpindah antarpemisahan |
| `Super + Ctrl + Shift + Arrows` | Ubah ukuran pemisahan sebesar 10 baris |
| `Super + Ctrl + Shift + Alt + Arrows` | Ubah ukuran pemisahan sebesar 100 baris |
| `Ctrl + Shift + T` | Tab baru  |
| `Ctrl + Shift + Arrows` | Berpindah antartab |
| `Alt + Numbers` | Pergi ke tab tertentu |
| `Shift + Pg Up/Down` | Gulir riwayat |
| `Ctrl + Left mouse` | Buka tautan di browser |

## Pengelola Berkas

| Pintasan              | Fungsi                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Pergi ke path                     |
| `Space`               | Pratinjau berkas (panah untuk navigasi) |
| `Alt + Up`       | Naik ke folder induk        |

## Neovim (w/ lazyvim)

### Navigasi

| Pintasan                   | Fungsi                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Tampilkan opsi perintah            |
| `Space Space`              | Buka berkas melalui pencarian fuzzy      |
| `Space E`                  | Alihkan sidebar                  |
| `Space G G`                | Tampilkan kontrol git               |
| `Space S G`                | Cari isi berkas             |
| `Ctrl + W W`               | Lompat antara sidebar dan editor |
| `Ctrl + Left/right arrow`  | Ubah ukuran sidebar          |
| `Shift + H`                      | Pergi ke tab berkas kiri             |
| `Shift + L`                      | Pergi ke tab berkas kanan            |
| `Space B D`                | Tutup tab berkas                  |

### Saat di sidebar

| Pintasan                   | Fungsi                        |
| ------------------------ | ------------------------------- |
| `A`                        | Tambah berkas baru di direktori induk      |
| `Shift + A`                | Tambah subdirektori baru di direktori induk    |
| `D`                        | Hapus berkas/direktori yang disorot     |
| `M`                        | Pindahkan berkas/direktori yang disorot       |
| `R`                        | Ganti nama berkas/direktori yang disorot     |
| `?`                        | Tampilkan bantuan untuk semua perintah      |

[Lihat semua pintasan Neovim yang dikonfigurasi oleh LazyVim](https://www.lazyvim.org/keymaps).

## Emoji Cepat

Anda dapat menggunakan `Super + Ctrl + E` untuk menampilkan pemilih emoji lengkap yang akan menempatkan pilihan di papan klip atau Anda dapat menggunakan opsi akses cepat ini.

| Pintasan       | EM | Petunjuk       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | senyum      |
| `Shift + CapsLock M C` | 😂 | menangis        |
| `Shift + CapsLock M L` | 😍 | cinta       |
| `Shift + CapsLock M V` | ✌️ | kemenangan    |
| `Shift + CapsLock M H` | ❤️ | hati      |
| `Shift + CapsLock M Y` | 👍 | ya        |
| `Shift + CapsLock M N` | 👎 | tidak         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | harapan       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | cium       |
| `Shift + CapsLock M E` | 🙄 | memutar mata    |
| `Shift + CapsLock M I` | 😉 | kedip       |
| `Shift + CapsLock M P` | 🙏 | doa |
| `Shift + CapsLock M D` | 🤤 | ngiler      |
| `Shift + CapsLock M M` | 💰 | uang      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | bersulang      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | salam |
| `Shift + CapsLock M A` |💪 | lengan |
| `Shift + CapsLock M B` |🤯 | blowing |

## Penyelesaian Cepat

| Pintasan       | Penyelesaian       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Nama Anda (seperti yang dimasukkan saat penyiapan)  |
| `Shift + CapsLock Space E` | Email Anda (seperti yang dimasukkan saat penyiapan)  |

Anda dapat menambahkan lebih banyak milik Anda sendiri dengan mengedit `~/.XCompose`, lalu menjalankan `omarchy-restart-xcompose` di terminal agar perubahan diterapkan.
