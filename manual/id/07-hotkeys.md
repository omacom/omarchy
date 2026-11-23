# Pintasan Keyboard

Anda dapat melihat semua ikatan keyboard utama dengan `Super + K` (ikatan Tmux dengan `Super + Alt + K` dan ikatan Herdr dengan `Super + Ctrl + K`).

## Cara pintasan keyboard ditata

Setiap pintasan keyboard berada pada satu bidang, ditentukan oleh pengubahnya, dan setiap bidang punya satu tugas. Itulah yang mencegah pintasan keyboard saling kabur, dan itu berarti Anda biasanya bisa menebak di mana sesuatu berada.

| Bidang | Apa yang ada di sana | Contoh |
| --- | --- | --- |
| `Super + key` | Sistem: jendela, workspace, tata letak, dan menu inti | `Super + Space` menu Omarchy, `Super + W` tutup jendela, `Super + F` layar penuh |
| `Super + Shift + key` | Aplikasi | `Super + Shift + B` browser, `Super + Shift + E` email, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panel dan menu sistem | `Super + Ctrl + A` audio, `Super + Ctrl + N` jaringan, `Super + Ctrl + C` menu tangkapan |
| `Super + Ctrl + Alt + key` | Tindakan cepat dan pemberitahuan | `Super + Ctrl + Alt + T` tampilkan waktu, `Super + Ctrl + Alt + B` baterai, `Super + Ctrl + Alt + C` tangkapan layar |

Menambahkan `Alt` ke pintasan keyboard memberi Anda varian dari hal yang sama, tidak pernah sesuatu yang tidak terkait:

- `Super + Shift + B` membuka browser; `Super + Shift + Alt + B` membuka jendela pribadi
- `Super + Shift + E` membuka email; `Super + Shift + Alt + E` memulai email baru
- `Super + F` masuk layar penuh; `Super + Alt + F` masuk lebar penuh
- `Super + Ctrl + C` membuka menu tangkapan; `Super + Ctrl + Alt + C` melewati menu dan mengambil tangkapan layar

Saat menambahkan pintasan keyboard:

1. Pilih bidang dari apa yang dilakukannya, lalu pilih tombolnya.
2. Jangan memindahkan pintasan keyboard yang sudah ada untuk memberi ruang. Temukan tombol kosong pada bidang yang tepat.
3. Hanya gunakan `Alt` untuk varian dari pintasan keyboard tanpa `Alt`.

Beberapa pintasan keyboard melanggar aturan ini karena memang nyaman. `Shift` dengan panah atau `Tab` memindahkan atau membalikkan alih-alih membuka aplikasi, dan `Print`, tombol media, `Alt + Tab`, dan `Ctrl + Alt + Del` bekerja sebagaimana di tempat lain. Itu pengecualian, bukan pola untuk ditiru.

Jika bawaan tidak cocok untuk Anda (misalnya Anda ingin `Super + Shift + S` untuk tangkapan layar seperti di Windows), ikat ulang di `~/.config/hypr/bindings.lua`.

## Navigasi

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplikasi dan segala hal lainnya)    |
| `Super + Alt + Space` | Kisi aplikasi |
| `Super + Escape` | Menu sistem (tangguhkan, mulai ulang, dll)  |
| `Super + Ctrl + L` | Kunci komputer |
| `Super + W` or `Super + Q` | Tutup jendela             |
| `Ctrl + Alt + Del` | Tutup semua jendela |
| `Super + K` | Tampilkan semua pintasan keyboard |
| `Super + Alt + K` | Tampilkan pintasan keyboard tmux |
| `Super + Ctrl + K` | Tampilkan pintasan keyboard herdr |
| `Super + M` | Minimalkan jendela ke dock |
| `Super + T`               | Alihkan jendela antara tiling/mengambang             |
| `Super + J` | Alihkan posisi jendela (horizontal/vertikal) |
| `Super + O`               | Alihkan jendela pop-out menjadi sticky'n'floating |
| `Super + L`               | Putar melalui tata letak dwindle, scrolling, dan floating |
| `Super + Alt + L`         | Putar melalui tata letak dalam urutan terbalik |
| `Super + P`               | Alihkan gaya jendela pseudo (natural v stretch) |
| `Super + F`                 | Masuk layar penuh              |
| `Super + Alt + F`                 | Masuk lebar penuh              |
| `Super + Ctrl + F`                 | Masuk layar penuh di dalam jendela              |
| `Super + 1…9/0`         | Lompat ke workspace tertentu (0 adalah 10) pada monitor yang terfokus |
| `Super + Tab` | Lompat ke workspace berikutnya pada monitor yang terfokus |
| `Super + Shift + Tab` | Lompat ke workspace sebelumnya pada monitor yang terfokus |
| `Super + Ctrl + Tab` | Lompat ke workspace terdahulu pada monitor yang terfokus |
| `Super + Shift + 1…9/0` | Pindahkan jendela ke workspace pada monitor yang terfokus |
| `Super + Shift + Alt + 1…9/0` | Pindahkan jendela ke workspace pada monitor yang terfokus tanpa mengikutinya |
| `Super + S` | Alihkan scratchpad penuh |
| `Super + Alt + S` | Pindahkan jendela ke scratchpad penuh |
| `Super + the key above Tab` (grave pada tata letak US) | Alihkan konsol Quake |
| `Super + Shift + the key above Tab` (grave pada tata letak US) | Pindahkan jendela ke konsol Quake |
| `Super + Shift + Ctrl + Arrows` | Pindahkan jendela ke monitor ke arah tersebut |
| `Super + Shift + Alt + Arrows` | Pindahkan workspace ke monitor ke arah tersebut |
| `Super + Arrow`  | Pindahkan fokus ke jendela ke arah panah, menyeberang ke monitor di sisi tersebut di tepi layar |
| `Super + Shift + Arrow`  | Tukar jendela dengan jendela lain ke arah panah, termasuk yang ada di monitor di sisi tersebut |
| `Super + Minus` | Perluas jendela ke kiri |
| `Super + Equal` | Ciutkan jendela ke kiri |
| `Super + Shift + Minus` | Ciutkan jendela ke atas |
| `Super + Shift + Equal` | Perluas jendela ke bawah |
| `Super + Alt + Minus/Equal` | Pengubahan ukuran yang sama dalam langkah lebih kecil |
| `Super + Ctrl + Minus/Equal` | Pengubahan ukuran yang sama dalam langkah lebih besar |
| `Super + Alt + Home` | Simpan lebar jendela |
| `Super + Home` | Pulihkan lebar jendela yang disimpan |
| `Super + Left Mouse` | Seret jendela ke sana kemari |
| `Super + Right Mouse` | Ubah ukuran jendela |
| `Super + Scroll Wheel` | Gulir melalui workspace pada monitor yang terfokus |
| `Super + G`               | Alihkan pengelompokan jendela      |
| `Super + Alt + G`               | Keluarkan jendela dari pengelompokan      |
| `Super + Alt + Tab`               | Putar di antara jendela dalam pengelompokan      |
| `Super + Alt + Shift + Tab`               | Putar mundur di antara jendela dalam pengelompokan      |
| `Super + Alt + Scroll Wheel` | Putar di antara jendela dalam pengelompokan |
| `Super + Alt + 1/2/3/4/5`               | Lompat ke jendela tertentu dalam pengelompokan      |
| `Super + Alt + Arrow`  | Pindahkan jendela ke dalam pengelompokan ke arah panah, termasuk yang ada di monitor di sisi tersebut |
| `Super + Ctrl + Left/Right`  | Berpindah di antara jendela di dalam grup tiling |
| `Super + Ctrl + Z` | Perbesar tampilan layar (ulangi untuk perbesaran lebih) |
| `Super + Ctrl + Alt + Z` | Perkecil tampilan layar sepenuhnya |
| `Super + /` | Maju selangkah melalui opsi penskalaan monitor |
| `Super + Alt + /` | Mundur selangkah melalui opsi penskalaan monitor |
| `Alt + Tab` | Putar maju melalui jendela pada workspace aktif |
| `Alt + Shift + Tab` | Putar mundur melalui jendela pada workspace aktif |
| `Ctrl + Alt + Tab`| Putar fokus maju melalui monitor |
| `Ctrl + Alt + Shift + Tab`| Putar fokus mundur melalui monitor |
| `Super + I` | Ganti bahasa input (dengan lebih dari satu tata letak atau metode input) |
| `Super + Shift + I` | Ganti bahasa input kembali |

Pada touchpad, usapan tiga dan empat jari mengganti workspace, memindahkan jendela, serta membuka menu dan konsol Quake; lihat [keyboard, mouse, dan trackpad](34-keyboard-mouse-trackpad.md) untuk gesturnya.

Pengubahan ukuran menggunakan dua tombol di sebelah kanan 0, apa pun yang tercetak pada keyboard Anda: `-` dan `=` pada keyboard US, `+` dan `´` pada Denmark dan Swedia, `+` dan `\` pada Norwegia, `ß` dan `´` pada Jerman, `'` dan `¡` pada Spanyol, dan `-` dan `^` pada Jepang (JIS). `Super + K` mencantumkannya sebagaimana tercetak pada keyboard Anda. Pada JIS, `Super + ^` adalah `Super + Equal`, sementara `Super + Shift + -` (yang mengetik `=`) adalah `Super + Shift + Minus`. Penskalaan monitor dan pengelola kata sandi menggunakan `/`; pada tata letak yang hanya mengetik `/` dengan Shift, seperti kebanyakan tata letak Eropa, mereka menggunakan tombol di sebelah kiri Shift kanan sebagai gantinya (`-` pada Denmark dan Jerman).

## Kontrol sistem

| Pintasan Keyboard                  | Fungsi              |
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
| `Super + Ctrl + S` | Menu berbagi (melalui LocalSend) |
| `Super + Ctrl + C` | Kontrol tangkapan (tangkapan layar/perekaman/pemilih) |
| `Super + Ctrl + O` | Alihkan menu |
| `Super + Ctrl + H` | Menu perangkat keras |
| `Super + Ctrl + E` | Pemilih emoji |
| `Super + Ctrl + .` | Transkode media |
| `Super + Shift + Ctrl + A` | Mulai agen bawaan Anda |
| `Power` key | Menu sistem |
| `Super + Shift + Copilot` key | Menu Omarchy |

## Penyesuaian

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Kecerahan layar maksimum |
| `Shift + Brightness Down` | Kecerahan layar minimum |
| `Alt + Brightness Up/Down` | Perubahan kecerahan presisi 1% |
| `Alt + Volume Up/Down` | Perubahan volume presisi 1% |
| `Keyboard Brightness Up/Down` | Lampu latar keyboard lebih terang/lebih redup |
| `Keyboard Backlight` | Putar tingkat lampu latar keyboard |
| `Ctrl + Brightness Up/Down` | Lampu latar keyboard lebih terang/lebih redup, pada keyboard tanpa tombolnya sendiri |
| `Mic Mute` | Bisukan mikrofon |
| `Shift + Mute` | Ganti output audio |
| `Touchpad Toggle` | Nyalakan atau matikan touchpad |
| `Display` key | Putar tata letak workspace |
| `Alt + Play` | Trek berikutnya |
| `Alt + Shift + Play` | Trek sebelumnya |

## Meluncurkan aplikasi

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (pengelola agen) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (pribadi/incognito)    |
| `Super + Shift + F`           | Pengelola file    |
| `Super + Shift + Alt + F`           | Pengelola file di cwd terminal    |
| `Super + Shift + M`           | Musik (Spotify)    |
| `Super + Shift + Alt + M`           | Musik (cliamp)    |
| `Super + Shift + /`           | Pengelola kata sandi (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, setelah terinstal)    |
| `Super + Shift + T`           | Aktivitas (btop)    |
| `Super + Shift + N`           | Editor (Plain, atau pilihan bawaan Anda)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Email ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Email baru ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Agen bawaan Anda, atau ChatGPT sampai Anda memilih satu |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Aplikasi pesan (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Aplikasi pesan (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Aplikasi pesan (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Menulis (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (postingan baru) |
| `Super + Shift + Y`           | YouTube |

Ubah/tambah ikatan di `~/.config/hypr/bindings.lua`.

## Clipboard universal

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + A`           | Pilih semua di aplikasi yang mendukung `Ctrl + A`    |
| `Super + C`           | Salin    |
| `Super + X`           | Potong (tidak di terminal)    |
| `Super + V`           | Tempel    |
| `Super + Ctrl + V`           | Pengelola clipboard    |

Biasanya di Linux, Anda perlu `Ctrl + Shift + C/V` untuk menyalin dan menempel di terminal dan `Ctrl + C/V` untuk melakukannya di tempat lain. Pintasan keyboard clipboard terpadu Omarchy ini bekerja di mana saja.

## Tangkapan

| Pintasan Keyboard              | Fungsi                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Tangkapan layar                      |
| `Super + Ctrl + Alt + C`            | Tangkapan layar (tangkapan yang sama, untuk keyboard tanpa tombol Print Screen) |
| `Super + Ctrl + C` | Menu tangkapan |
| `Alt + Print Screen`            | Rekaman layar                     |
| `Super + Shift + Ctrl + Alt + C` | Rekaman layar tanpa audio, melewati menu (tekan lagi untuk berhenti) |
| `Super + Print Screen` | Pemilih warna |
| `Super + Ctrl + Print Screen` | Ekstraksi teks ke clipboard |
| `Super + Alt + [` | Perkecil overlay webcam saat merekam |
| `Super + Alt + ]` | Perbesar overlay webcam saat merekam |
| `Alt + Shift + L` | Salin URL saat ini dari webapp atau browser |
| `Alt + Shift + D` | Unduh video pada halaman saat ini ke `~/Videos` |
| `Alt + Space` | Mulai/berhenti dikte (memerlukan _Setup > Defaults > Dictation_) |
| `Right Alt` | Tahan untuk mendikte (memerlukan _Setup > Defaults > Dictation_) |

Dengan perekaman layar, pintasan keyboard pertama-tama menanyakan audio mana yang Anda inginkan, lalu memulai perekaman. Tekan lagi untuk berhenti. Lihat [tangkapan layar dan perekaman](12-screenshots-recording.md) untuk detailnya.

Semua opsi tangkapan juga dapat diakses di bawah _Trigger > Capture_ di menu Omarchy (`Super + Space`).

## Notifikasi

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + ,` | Bertindak pada notifikasi terbaru: buka notifikasi tersebut atau tekan satu-satunya tombolnya, pilih dari pilihannya, atau tutup notifikasi tersebut ketika tidak ada pilihan  |
| `Super + Shift + ,` | Tutup semua notifikasi |
| `Super + Ctrl + ,` | Kendalikan notifikasi dengan keyboard  |
| `Super + Alt + ,` | Tutup notifikasi terbaru  |
| `Super + Shift + Alt + ,` | Buka riwayat notifikasi  |
| `Super + Ctrl + Alt + ,` | Alihkan pembungkaman notifikasi  |

## Gaya

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Pilih tema baru (juga `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Pilih latar belakang tema (juga `Super + Ctrl + Space`) |
| `Super + Backspace` | Alihkan transparansi pada jendela |
| `Super + Ctrl + Backspace` | Alihkan aspek persegi jendela tunggal |

Gambar latar belakang tambahan berada di `~/.config/omarchy/backgrounds/<theme name>`. Juga tersedia melalui _Install > Style > Background_ di menu Omarchy.

Semua opsi gaya juga dapat diakses di bawah _Appearance_ di menu Omarchy (`Super + Space`).

## Pengalihan

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alihkan penguncian saat idle |
| `Super + Ctrl + Delete` | Alihkan layar laptop nyala/mati |
| `Super + Ctrl + Alt + Delete` | Alihkan pencerminan layar laptop |
| `Super + Shift + Space` | Alihkan bar atas  |
| `Shift + Mute` | Beralih ke output audio berikutnya |
| `Shift + Play` | Beralih ke sumber media berikutnya |
| `Super + Shift + Backspace` | Alihkan celah jendela |
| `Super + Ctrl + Alt + F` | Alihkan desktop layar penuh (bar atas + celah jendela) |

## Pengingat

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Atur pengingat  |
| `Super + Ctrl + Alt + R` | Lihat semua pengingat  |
| `Super + Ctrl + Shift + R` | Hapus semua pengingat  |

## Pemberitahuan

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Tampilkan waktu sebagai notifikasi  |
| `Super + Ctrl + Alt + B` | Tampilkan baterai sebagai notifikasi  |
| `Super + Ctrl + Alt + W` | Alihkan cuaca sebagai notifikasi  |

## Tmux

Tombol prefix adalah `Ctrl + Space` (`Ctrl + B` juga berfungsi). Anda dapat mengubah ikatan ini di `~/.config/tmux/tmux.conf`.

### Panel

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + v` | Bagi panel di samping (vertikal) |
| `Prefix + h` | Bagi panel di bawah (horizontal) |
| `Prefix + x` | Matikan panel |
| `Prefix + z` | Alihkan zoom panel (layar penuh) |
| `Alt + Enter` | Bagi panel di bawah (tanpa prefix) |
| `Alt + Shift + Enter` | Bagi panel di samping (tanpa prefix) |
| `Alt + Escape` | Matikan panel (tanpa prefix) |
| `Ctrl + Alt + Arrows` | Berpindah di antara panel |
| `Ctrl + Alt + Shift + Arrows` | Ubah ukuran panel |

### Jendela

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + c` | Jendela baru |
| `Prefix + k` | Matikan jendela |
| `Prefix + r` | Ganti nama jendela |
| `Alt + 1-9` | Pergi ke jendela tertentu |
| `Alt + Arrow Left/Right` | Berpindah di antara jendela |
| `Alt + Shift + Arrow Left/Right` | Pindahkan jendela ke kiri/kanan |

### Sesi

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + C` | Sesi baru |
| `Prefix + K` | Matikan sesi |
| `Prefix + R` | Ganti nama sesi |
| `Prefix + N` | Sesi berikutnya |
| `Prefix + P` | Sesi sebelumnya |
| `Alt + Arrow Up/Down` | Berpindah di antara sesi |
| `Prefix + s` | Daftar sesi |
| `Prefix + d` | Lepas dari sesi |

### Mode salin (gaya vi)

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + [` | Masuk mode salin |
| `v` | Mulai pemilihan (di mode salin) |
| `y` | Salin pilihan (di mode salin) |

### Umum

| Pintasan Keyboard                  | Fungsi              |
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
| `tsl <count> <command>` | Buat tata letak swarm multi-panel |

## Terminal Ghostty

Terminal Ghostty diinstal menggunakan _Install > Terminal_ melalui menu Omarchy.

| Pintasan Keyboard                  | Fungsi              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Pembagian baru di bawah |
| `Ctrl + Shift + O` | Pembagian baru di samping |
| `Ctrl + Alt + Arrows` | Berpindah di antara pembagian |
| `Super + Ctrl + Shift + Arrows` | Ubah ukuran pembagian sebesar 10 baris |
| `Super + Ctrl + Shift + Alt + Arrows` | Ubah ukuran pembagian sebesar 100 baris |
| `Ctrl + Shift + T` | Tab baru  |
| `Ctrl + Shift + Arrows` | Berpindah di antara tab |
| `Alt + Numbers` | Pergi ke tab tertentu |
| `Shift + Pg Up/Down` | Gulir riwayat |
| `Ctrl + Left mouse` | Buka tautan di browser |

## Pengelola File

| Pintasan Keyboard              | Fungsi                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Pergi ke path                     |
| `Space`               | Pratinjau file (panah untuk navigasi) |
| `Alt + Up`       | Naik ke folder induk        |

## Neovim (w/ lazyvim)

### Navigasi

| Pintasan Keyboard                   | Fungsi                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Tampilkan opsi perintah            |
| `Space Space`              | Buka file melalui pencarian fuzzy      |
| `Space E`                  | Alihkan sidebar                  |
| `Space G G`                | Tampilkan kontrol git               |
| `Space S G`                | Cari konten file             |
| `Ctrl + W W`               | Lompat di antara sidebar dan editor |
| `Ctrl + Left/right arrow`  | Ubah ukuran sidebar          |
| `Shift + H`                      | Pergi ke tab file kiri             |
| `Shift + L`                      | Pergi ke tab file kanan            |
| `Space B D`                | Tutup tab file                  |

### Saat di sidebar

| Pintasan Keyboard                   | Fungsi                        |
| ------------------------ | ------------------------------- |
| `A`                        | Tambah file baru di direktori induk      |
| `Shift + A`                | Tambah subdirektori baru di direktori induk    |
| `D`                        | Hapus file/direktori yang disorot     |
| `M`                        | Pindahkan file/direktori yang disorot       |
| `R`                        | Ganti nama file/direktori yang disorot     |
| `?`                        | Tampilkan bantuan untuk semua perintah      |

[Lihat semua pintasan keyboard Neovim yang dikonfigurasi oleh LazyVim](https://www.lazyvim.org/keymaps).

## Emoji Cepat

Anda dapat menggunakan `Super + Ctrl + E` untuk menampilkan pemilih emoji lengkap yang akan menempatkan pilihan di clipboard atau Anda dapat menggunakan opsi akses cepat ini.

| Pintasan Keyboard       | EM | Petunjuk       |
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
| `Shift + CapsLock M K` | 😘 | ciuman       |
| `Shift + CapsLock M E` | 🙄 | memutar mata    |
| `Shift + CapsLock M I` | 😉 | kedipan       |
| `Shift + CapsLock M P` | 🙏 | berdoa |
| `Shift + CapsLock M D` | 🤤 | ngiler      |
| `Shift + CapsLock M M` | 💰 | uang      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | bersulang      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | sapaan |
| `Shift + CapsLock M A` |💪 | lengan |
| `Shift + CapsLock M B` |🤯 | meledak |

## Penyelesaian Cepat

| Pintasan Keyboard       | Penyelesaian       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Nama Anda (sebagaimana dimasukkan saat pengaturan)  |
| `Shift + CapsLock Space E` | Email Anda (sebagaimana dimasukkan saat pengaturan)  |

Anda dapat menambahkan lebih banyak milik Anda sendiri dengan mengedit `~/.XCompose`, lalu menjalankan `omarchy restart xcompose` di terminal agar perubahan diterapkan.
