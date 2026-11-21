# Tombol Pintas

Kamu bisa melihat semua ikatan keyboard utama dengan `Super + K` (ikatan Tmux dengan `Super + Alt + K` dan ikatan Herdr dengan `Super + Ctrl + K`).

## Bagaimana tombol pintas disusun

Setiap tombol pintas berada di satu bidang, ditentukan oleh pengubahnya, dan setiap bidang punya satu tugas. Itulah yang membuat tombol pintas tidak kabur jadi satu, dan itu berarti kamu biasanya bisa menebak di mana sesuatu berada.

| Bidang | Apa saja yang ada di sana | Contoh |
| --- | --- | --- |
| `Super + key` | Sistemnya: jendela, workspace, tata letak, dan menu inti | `Super + Space` menu Omarchy, `Super + W` tutup jendela, `Super + F` layar penuh |
| `Super + Shift + key` | Aplikasi | `Super + Shift + B` browser, `Super + Shift + E` email, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panel dan menu sistem | `Super + Ctrl + A` audio, `Super + Ctrl + N` jaringan, `Super + Ctrl + C` menu tangkap |
| `Super + Ctrl + Alt + key` | Tindakan cepat dan pemberitahuan | `Super + Ctrl + Alt + T` tampilkan waktu, `Super + Ctrl + Alt + B` baterai, `Super + Ctrl + Alt + C` tangkapan layar |

Menambahkan `Alt` ke tombol pintas memberimu varian dari hal yang sama, tidak pernah sesuatu yang tidak terkait:

- `Super + Shift + B` membuka browser; `Super + Shift + Alt + B` membuka jendela privat
- `Super + Shift + E` membuka email; `Super + Shift + Alt + E` memulai email baru
- `Super + F` masuk layar penuh; `Super + Alt + F` masuk lebar penuh
- `Super + Ctrl + C` membuka menu tangkap; `Super + Ctrl + Alt + C` melewati menu dan mengambil tangkapan layar

Saat menambahkan tombol pintas:

1. Pilih bidang berdasarkan fungsinya, lalu pilih tombolnya.
2. Jangan pindahkan tombol pintas yang sudah ada demi memberi ruang. Cari tombol yang kosong di bidang yang tepat.
3. Hanya gunakan `Alt` untuk varian dari tombol pintas tanpanya.

Beberapa tombol pintas melanggar aturan ini karena memang nyaman. `Shift` dengan panah atau `Tab` memindahkan atau membalikkan arah, bukan membuka aplikasi, dan `Print`, tombol media, `Alt + Tab`, dan `Ctrl + Alt + Del` bekerja seperti di mana-mana. Itu pengecualian, bukan pola untuk ditiru.

Jika bawaan tidak cocok untukmu (misalnya kamu ingin `Super + Shift + S` untuk tangkapan layar seperti di Windows), ikat ulang di `~/.config/hypr/bindings.lua`.

## Navigasi

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplikasi dan semua hal lainnya)    |
| `Super + Alt + Space` | Kisi aplikasi |
| `Super + Escape` | Menu sistem (tangguhkan, mulai ulang, dll)  |
| `Super + Ctrl + L` | Kunci komputer |
| `Super + W` or `Super + Q` | Tutup jendela             |
| `Ctrl + Alt + Del` | Tutup semua jendela |
| `Super + K` | Tampilkan semua tombol pintas |
| `Super + Alt + K` | Tampilkan tombol pintas tmux |
| `Super + Ctrl + K` | Tampilkan tombol pintas herdr |
| `Super + M` | Minimalkan jendela ke dock |
| `Super + T`               | Alihkan jendela antara tiling/floating             |
| `Super + J` | Alihkan posisi jendela (horizontal/vertikal) |
| `Super + O`               | Alihkan jendela yang muncul menjadi sticky'n'floating |
| `Super + L`               | Berpindah bergiliran melalui tata letak dwindle, scrolling, dan floating |
| `Super + Alt + L`         | Berpindah bergiliran melalui tata letak dalam urutan terbalik |
| `Super + P`               | Alihkan gaya jendela pseudo (natural v stretch) |
| `Super + F`                 | Masuk layar penuh              |
| `Super + Alt + F`                 | Masuk lebar penuh              |
| `Super + Ctrl + F`                 | Masuk layar penuh di dalam jendela              |
| `Super + 1…9/0`         | Lompat ke workspace tertentu (0 adalah 10) di monitor yang difokuskan |
| `Super + Tab` | Lompat ke workspace berikutnya di monitor yang difokuskan |
| `Super + Shift + Tab` | Lompat ke workspace sebelumnya di monitor yang difokuskan |
| `Super + Ctrl + Tab` | Lompat ke workspace terdahulu di monitor yang difokuskan |
| `Super + Shift + 1…9/0` | Pindahkan jendela ke workspace di monitor yang difokuskan |
| `Super + Shift + Alt + 1…9/0` | Pindahkan jendela ke workspace di monitor yang difokuskan tanpa mengikutinya |
| `Super + S` | Alihkan scratchpad penuh |
| `Super + Alt + S` | Pindahkan jendela ke scratchpad penuh |
| `Super + Grave` | Alihkan konsol Quake |
| `Super + Shift + Grave` | Pindahkan jendela ke konsol Quake |
| `Super + Shift + Ctrl + Arrows` | Pindahkan jendela ke monitor ke arah tersebut |
| `Super + Shift + Alt + Arrows` | Pindahkan workspace ke monitor ke arah tersebut |
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
| `Super + Left Mouse` | Seret jendela ke mana-mana |
| `Super + Right Mouse` | Ubah ukuran jendela |
| `Super + Scroll Wheel` | Gulir melalui workspace di monitor yang difokuskan |
| `Super + G`               | Alihkan pengelompokan jendela      |
| `Super + Alt + G`               | Keluarkan jendela dari pengelompokan      |
| `Super + Alt + Tab`               | Berpindah bergiliran antarjendela dalam pengelompokan      |
| `Super + Alt + Shift + Tab`               | Berpindah bergiliran mundur antarjendela dalam pengelompokan      |
| `Super + Alt + Scroll Wheel` | Berpindah bergiliran antarjendela dalam pengelompokan |
| `Super + Alt + 1/2/3/4/5`               | Lompat ke jendela tertentu dalam pengelompokan      |
| `Super + Alt + Arrow`  | Pindahkan jendela ke dalam pengelompokan searah panah, termasuk yang ada di monitor di sisi tersebut |
| `Super + Ctrl + Left/Right`  | Berpindah antarjendela di dalam grup tiling |
| `Super + Ctrl + Z` | Perbesar tampilan layar (ulangi untuk perbesaran lebih lanjut) |
| `Super + Ctrl + Alt + Z` | Perkecil tampilan layar sepenuhnya |
| `Super + /` | Maju selangkah melalui opsi penskalaan monitor |
| `Super + Alt + /` | Mundur selangkah melalui opsi penskalaan monitor |
| `Alt + Tab` | Berpindah bergiliran maju melalui jendela di workspace aktif |
| `Alt + Shift + Tab` | Berpindah bergiliran mundur melalui jendela di workspace aktif |
| `Ctrl + Alt + Tab`| Berpindah fokus bergiliran maju melalui monitor |
| `Ctrl + Alt + Shift + Tab`| Berpindah fokus bergiliran mundur melalui monitor |
| `Super + I` | Ganti bahasa input (dengan lebih dari satu tata letak atau metode input) |
| `Super + Shift + I` | Ganti bahasa input kembali |

Di touchpad, usapan tiga dan empat jari mengganti workspace, memindahkan jendela, dan membuka menu serta konsol Quake; lihat [keyboard, mouse, dan trackpad](34-keyboard-mouse-trackpad.md) untuk gesturnya.

Pintasan pengubahan ukuran menggunakan tombol fisik `code:20` dan `code:21` (XKB `<AE11>` dan `<AE12>`), terlepas dari karakter yang tercetak di keyboard. Di keyboard US tombol ini adalah `-` dan `=`; di keyboard Jepang (JIS) tombol ini adalah `-` dan `^`; di keyboard Spanyol tombol ini adalah `'` dan `¡`. Di JIS, `Super + ^` adalah `Super + Equal`, sedangkan `Super + Shift + -` (yang mengetik `=`) adalah `Super + Shift + Minus`.

## Kontrol sistem

| Tombol Pintas                  | Fungsi              |
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
| `Super + Ctrl + C` | Kontrol tangkap (tangkapan layar/perekaman/pemilih) |
| `Super + Ctrl + O` | Alihkan menu |
| `Super + Ctrl + H` | Menu perangkat keras |
| `Super + Ctrl + E` | Pemilih emoji |
| `Super + Ctrl + .` | Transkode media |
| `Super + Shift + Ctrl + A` | Pilih agen AI |
| `Power` key | Menu sistem |
| `Super + Shift + Copilot` key | Menu Omarchy |

## Penyesuaian

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Kecerahan layar maksimum |
| `Shift + Brightness Down` | Kecerahan layar minimum |
| `Alt + Brightness Up/Down` | Perubahan kecerahan presisi 1% |
| `Alt + Volume Up/Down` | Perubahan volume presisi 1% |
| `Keyboard Brightness Up/Down` | Lampu latar keyboard lebih terang/lebih redup |
| `Keyboard Backlight` | Berpindah bergiliran melalui tingkat lampu latar keyboard |
| `Ctrl + Brightness Up/Down` | Lampu latar keyboard lebih terang/lebih redup, di keyboard tanpa tombolnya sendiri |
| `Mic Mute` | Bisukan mikrofon |
| `Shift + Mute` | Ganti keluaran audio |
| `Touchpad Toggle` | Nyalakan atau matikan touchpad |
| `Display` key | Berpindah bergiliran melalui tata letak workspace |
| `Alt + Play` | Trek berikutnya |
| `Alt + Shift + Play` | Trek sebelumnya |

## Meluncurkan aplikasi

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (pengelola agen) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (privat/penyamaran)    |
| `Super + Shift + F`           | Pengelola berkas    |
| `Super + Shift + Alt + F`           | Pengelola berkas di cwd terminal    |
| `Super + Shift + M`           | Musik (Spotify)    |
| `Super + Shift + Alt + M`           | Musik (cliamp)    |
| `Super + Shift + /`           | Pengelola kata sandi (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, setelah terpasang)    |
| `Super + Shift + T`           | Aktivitas (btop)    |
| `Super + Shift + N`           | Editor (Plain, atau bawaan pilihanmu)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Email ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Email baru ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Pesan (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Pesan (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Pesan (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Menulis (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (postingan baru) |
| `Super + Shift + Y`           | YouTube |

Ubah/tambah ikatan di `~/.config/hypr/bindings.lua`.

## Papan klip universal

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + A`           | Pilih semua di aplikasi yang mendukung `Ctrl + A`    |
| `Super + C`           | Salin    |
| `Super + X`           | Potong (tidak di terminal)    |
| `Super + V`           | Tempel    |
| `Super + Ctrl + V`           | Pengelola papan klip    |

Biasanya di Linux, kamu perlu `Ctrl + Shift + C/V` untuk copy'n'paste di terminal dan `Ctrl + C/V` untuk melakukannya di tempat lain. Tombol pintas papan klip terpadu Omarchy ini bekerja di mana-mana.

## Tangkap

| Tombol Pintas              | Fungsi                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Tangkapan layar                      |
| `Super + Ctrl + Alt + C`            | Tangkapan layar (tangkapan yang sama, untuk keyboard tanpa tombol Print Screen) |
| `Super + Ctrl + C` | Menu tangkap |
| `Alt + Print Screen`            | Rekaman layar                     |
| `Super + Shift + Ctrl + Alt + C` | Rekaman layar tanpa audio, melewati menu (tekan lagi untuk berhenti) |
| `Super + Print Screen` | Pemilih warna |
| `Super + Ctrl + Print Screen` | Ekstraksi teks ke papan klip |
| `Super + Alt + [` | Buat overlay webcam lebih kecil saat merekam |
| `Super + Alt + ]` | Buat overlay webcam lebih besar saat merekam |
| `Alt + Shift + L` | Salin URL saat ini dari webapp atau browser |
| `Alt + Shift + D` | Unduh video di halaman saat ini ke `~/Videos` |
| `Alt + Space` | Mulai/hentikan dikte (memerlukan _Setup > Defaults > Dictation_) |
| `Right Alt` | Tahan untuk mendikte (memerlukan _Setup > Defaults > Dictation_) |

Dengan rekaman layar, tombol pintas pertama-tama menanyakan audio mana yang kamu inginkan, lalu mulai merekam. Tekan lagi untuk berhenti. Lihat [tangkapan layar dan perekaman](12-screenshots-recording.md) untuk detailnya.

Semua opsi tangkap juga dapat diakses di bawah _Trigger > Capture_ di menu Omarchy (`Super + Space`).

## Notifikasi

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + ,` | Bertindak atas notifikasi terbaru: buka notifikasi itu atau tekan satu-satunya tombolnya, pilih dari pilihannya, atau abaikan jika tidak punya pilihan apa pun  |
| `Super + Shift + ,` | Abaikan semua notifikasi |
| `Super + Ctrl + ,` | Kendalikan notifikasi dengan keyboard  |
| `Super + Alt + ,` | Abaikan notifikasi terbaru  |
| `Super + Shift + Alt + ,` | Buka riwayat notifikasi  |
| `Super + Ctrl + Alt + ,` | Alihkan pembungkaman notifikasi  |

## Gaya

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Pilih tema baru (juga `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Pilih latar belakang tema (juga `Super + Ctrl + Space`) |
| `Super + Backspace` | Alihkan transparansi pada jendela |
| `Super + Ctrl + Backspace` | Alihkan aspek persegi jendela tunggal |

Gambar latar belakang tambahan berada di `~/.config/omarchy/backgrounds/<theme name>`. Juga tersedia melalui _Install > Style > Background_ di menu Omarchy.

Semua opsi gaya juga dapat diakses di bawah _Appearance_ di menu Omarchy (`Super + Space`).

## Pengalih

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alihkan penguncian saat idle |
| `Super + Ctrl + Delete` | Alihkan layar laptop nyala/mati |
| `Super + Ctrl + Alt + Delete` | Alihkan pencerminan layar laptop |
| `Super + Shift + Space` | Alihkan bar atas  |
| `Shift + Mute` | Beralih ke keluaran audio berikutnya |
| `Shift + Play` | Beralih ke sumber media berikutnya |
| `Super + Shift + Backspace` | Alihkan celah jendela |
| `Super + Ctrl + Alt + F` | Alihkan desktop layar penuh (bar atas + celah jendela) |

## Pengingat

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Atur pengingat  |
| `Super + Ctrl + Alt + R` | Lihat semua pengingat  |
| `Super + Ctrl + Shift + R` | Hapus semua pengingat  |

## Pemberitahuan

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Tampilkan waktu sebagai notifikasi  |
| `Super + Ctrl + Alt + B` | Tampilkan baterai sebagai notifikasi  |
| `Super + Ctrl + Alt + W` | Alihkan cuaca sebagai notifikasi  |

## Tmux

Tombol prefix adalah `Ctrl + Space` (`Ctrl + B` juga bekerja). Kamu bisa mengubah ikatan ini di `~/.config/tmux/tmux.conf`.

### Panel

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + v` | Bagi panel di samping (vertikal) |
| `Prefix + h` | Bagi panel di bawah (horizontal) |
| `Prefix + x` | Matikan panel |
| `Prefix + z` | Alihkan zoom panel (layar penuh) |
| `Alt + Enter` | Bagi panel di bawah (tanpa prefix) |
| `Alt + Shift + Enter` | Bagi panel di samping (tanpa prefix) |
| `Alt + Escape` | Matikan panel (tanpa prefix) |
| `Ctrl + Alt + Arrows` | Berpindah antar panel |
| `Ctrl + Alt + Shift + Arrows` | Ubah ukuran panel |

### Jendela

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + c` | Jendela baru |
| `Prefix + k` | Matikan jendela |
| `Prefix + r` | Ganti nama jendela |
| `Alt + 1-9` | Pergi ke jendela tertentu |
| `Alt + Arrow Left/Right` | Berpindah antarjendela |
| `Alt + Shift + Arrow Left/Right` | Pindahkan jendela ke kiri/kanan |

### Sesi

| Tombol Pintas                  | Fungsi              |
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

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + [` | Masuk mode salin |
| `v` | Mulai pemilihan (di mode salin) |
| `y` | Salin pilihan (di mode salin) |

### Umum

| Tombol Pintas                  | Fungsi              |
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

Terminal Ghostty dipasang menggunakan _Install > Terminal_ melalui menu Omarchy.

| Tombol Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Pembagian baru di bawah |
| `Ctrl + Shift + O` | Pembagian baru di samping |
| `Ctrl + Alt + Arrows` | Berpindah antarpembagian |
| `Super + Ctrl + Shift + Arrows` | Ubah ukuran pembagian sebesar 10 baris |
| `Super + Ctrl + Shift + Alt + Arrows` | Ubah ukuran pembagian sebesar 100 baris |
| `Ctrl + Shift + T` | Tab baru  |
| `Ctrl + Shift + Arrows` | Berpindah antartab |
| `Alt + Numbers` | Pergi ke tab tertentu |
| `Shift + Pg Up/Down` | Gulir riwayat |
| `Ctrl + Left mouse` | Buka tautan di browser |

## Pengelola Berkas

| Tombol Pintas              | Fungsi                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Pergi ke path                     |
| `Space`               | Pratinjau berkas (panah untuk navigasi) |
| `Alt + Up`       | Naik ke folder induk        |

## Neovim (dengan lazyvim)

### Navigasi

| Tombol Pintas                   | Fungsi                        |
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

| Tombol Pintas                   | Fungsi                        |
| ------------------------ | ------------------------------- |
| `A`                        | Tambah berkas baru di direktori induk      |
| `Shift + A`                | Tambah subdirektori baru di direktori induk    |
| `D`                        | Hapus berkas/direktori yang disorot     |
| `M`                        | Pindahkan berkas/direktori yang disorot       |
| `R`                        | Ganti nama berkas/direktori yang disorot     |
| `?`                        | Tampilkan bantuan untuk semua perintah      |

[Lihat semua tombol pintas Neovim yang dikonfigurasi oleh LazyVim](https://www.lazyvim.org/keymaps).

## Emoji Cepat

Kamu bisa menggunakan `Super + Ctrl + E` untuk menampilkan pemilih emoji lengkap yang akan menaruh pilihan di papan klip atau kamu bisa menggunakan opsi akses cepat ini.

| Tombol Pintas       | EM | Petunjuk       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | senyum      |
| `Shift + CapsLock M C` | 😂 | menangis        |
| `Shift + CapsLock M L` | 😍 | cinta       |
| `Shift + CapsLock M V` | ✌️ | kemenangan    |
| `Shift + CapsLock M H` | ❤️ | hati      |
| `Shift + CapsLock M Y` | 👍 | ya        |
| `Shift + CapsLock M N` | 👎 | tidak         |
| `Shift + CapsLock M F` | 🖕 | persetan       |
| `Shift + CapsLock M W` | 🤞 | harapan       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | cium       |
| `Shift + CapsLock M E` | 🙄 | memutar mata    |
| `Shift + CapsLock M I` | 😉 | kedip       |
| `Shift + CapsLock M P` | 🙏 | berdoa |
| `Shift + CapsLock M D` | 🤤 | ngiler      |
| `Shift + CapsLock M M` | 💰 | uang      |
| `Shift + CapsLock M X` | 🎉 | perayaan |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | bersulang      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | sapaan |
| `Shift + CapsLock M A` |💪 | lengan |
| `Shift + CapsLock M B` |🤯 | meledak |

## Pelengkapan Cepat

| Tombol Pintas       | Pelengkapan       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Namamu (seperti dimasukkan saat penyiapan)  |
| `Shift + CapsLock Space E` | Emailmu (seperti dimasukkan saat penyiapan)  |

Kamu bisa menambahkan lebih banyak milikmu sendiri dengan mengedit `~/.XCompose`, lalu menjalankan `omarchy restart xcompose` di terminal agar perubahannya diterapkan.
