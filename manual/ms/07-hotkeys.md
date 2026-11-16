# Kekunci Pintas

Anda boleh melihat semua ikatan papan kekunci utama dengan `Super + K` (ikatan Tmux dengan `Super + Alt + K` dan ikatan Herdr dengan `Super + Ctrl + K`).

## Cara kekunci pintas disusun

Setiap kekunci pintas berada pada satu satah, ditetapkan oleh pengubahsuainya, dan setiap satah mempunyai satu tugas. Itulah yang menghalang kekunci pintas daripada bercampur aduk, dan ini bermakna anda biasanya boleh meneka di mana sesuatu itu berada.

| Satah | Apa yang berada di sana | Contoh |
| --- | --- | --- |
| `Super + key` | Sistem: tetingkap, ruang kerja, susun atur, dan menu teras | `Super + Space` menu Omarchy, `Super + W` tutup tetingkap, `Super + F` skrin penuh |
| `Super + Shift + key` | Aplikasi | `Super + Shift + B` pelayar, `Super + Shift + E` e-mel, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panel dan menu sistem | `Super + Ctrl + A` audio, `Super + Ctrl + N` rangkaian, `Super + Ctrl + C` menu tangkapan |
| `Super + Ctrl + Alt + key` | Tindakan pantas dan notis | `Super + Ctrl + Alt + T` tunjuk masa, `Super + Ctrl + Alt + B` bateri, `Super + Ctrl + Alt + C` tangkapan skrin |

Menambah `Alt` pada kekunci pintas memberi anda varian bagi perkara yang sama, tidak sekali-kali sesuatu yang tidak berkaitan:

- `Super + Shift + B` membuka pelayar; `Super + Shift + Alt + B` membuka tetingkap peribadi
- `Super + Shift + E` membuka e-mel; `Super + Shift + Alt + E` memulakan e-mel baharu
- `Super + F` memaparkan skrin penuh; `Super + Alt + F` memaparkan lebar penuh
- `Super + Ctrl + C` membuka menu tangkapan; `Super + Ctrl + Alt + C` melangkau menu dan mengambil tangkapan skrin

Apabila menambah kekunci pintas:

1. Pilih satah berdasarkan fungsinya, kemudian pilih kekunci.
2. Jangan alihkan kekunci pintas sedia ada untuk memberi ruang. Cari kekunci kosong pada satah yang betul.
3. Hanya gunakan `Alt` untuk varian kekunci pintas tanpanya.

Beberapa kekunci pintas melanggar peraturan ini kerana ia mudah digunakan. `Shift` dengan anak panah atau `Tab` mengalih atau mengundurkan dan bukannya membuka aplikasi, dan `Print`, kekunci media, `Alt + Tab`, dan `Ctrl + Alt + Del` berfungsi seperti di tempat lain. Ia pengecualian, bukan corak untuk ditiru.

Jika tetapan lalai tidak sesuai dengan anda (contohnya anda mahukan `Super + Shift + S` untuk tangkapan skrin seperti di Windows), ikat semula dalam `~/.config/hypr/bindings.lua`.

## Navigasi

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplikasi dan segala-galanya)    |
| `Super + Alt + Space` | Grid aplikasi |
| `Super + Escape` | Menu sistem (gantung, mulakan semula, dsb.)  |
| `Super + Ctrl + L` | Kunci komputer |
| `Super + W` or `Super + Q` | Tutup tetingkap             |
| `Ctrl + Alt + Del` | Tutup semua tetingkap |
| `Super + T`               | Togol tetingkap antara jubin/terapung             |
| `Super + J` | Togol kedudukan tetingkap (mendatar/menegak) |
| `Super + O`               | Togol tetingkap timbul menjadi sticky'n'floating |
| `Super + L`               | Kitar melalui susun atur dwindle, scrolling, dan floating |
| `Super + Alt + L`         | Kitar melalui susun atur secara terbalik |
| `Super + P`               | Togol gaya tetingkap pseudo (natural lwn stretch) |
| `Super + F`                 | Papar skrin penuh              |
| `Super + Alt + F`                 | Papar lebar penuh              |
| `Super + Ctrl + F`                 | Papar skrin penuh di dalam tetingkap              |
| `Super + 1/2/3/4`         | Lompat ke ruang kerja tertentu pada monitor yang difokuskan |
| `Super + Tab` | Lompat ke ruang kerja seterusnya pada monitor yang difokuskan |
| `Super + Shift + Tab` | Lompat ke ruang kerja sebelumnya pada monitor yang difokuskan |
| `Super + Ctrl + Tab` | Lompat ke ruang kerja terdahulu pada monitor yang difokuskan |
| `Super + Shift + 1/2/3/4` | Alih tetingkap ke ruang kerja pada monitor yang difokuskan |
| `Super + Shift + Alt + 1/2/3/4` | Alih tetingkap ke ruang kerja pada monitor yang difokuskan tanpa mengikutinya |
| `Super + S` | Togol scratchpad penuh |
| `Super + Alt + S` | Alih tetingkap ke scratchpad penuh |
| `Super + Grave` | Togol konsol Quake |
| `Super + Shift + Grave` | Alih tetingkap ke konsol Quake |
| `Super + Shift + Ctrl + Arrows` | Alih tetingkap ke monitor ke arah tersebut |
| `Super + Shift + Alt + Arrows` | Alih ruang kerja ke monitor ke arah tersebut |
| `Super + Arrow`  | Alih fokus ke tetingkap ke arah anak panah, melintasi ke monitor di sisi tersebut di tepi skrin |
| `Super + Shift + Arrow`  | Tukar tetingkap dengan tetingkap lain ke arah anak panah, termasuk yang berada pada monitor di sisi tersebut |
| `Super + Minus` | Kembangkan tetingkap ke kiri |
| `Super + Equal` | Kecilkan tetingkap ke kiri |
| `Super + Shift + Minus` | Kecilkan tetingkap ke atas |
| `Super + Shift + Equal` | Kembangkan tetingkap ke bawah |
| `Super + Alt + Minus/Equal` | Pengubahan saiz yang sama dalam langkah lebih kecil |
| `Super + Ctrl + Minus/Equal` | Pengubahan saiz yang sama dalam langkah lebih besar |
| `Super + Alt + Home` | Simpan lebar tetingkap |
| `Super + Home` | Pulihkan lebar tetingkap yang disimpan |
| `Super + Left Mouse` | Seret tetingkap ke sekeliling |
| `Super + Right Mouse` | Ubah saiz tetingkap |
| `Super + Scroll Wheel` | Tatal melalui ruang kerja pada monitor yang difokuskan |
| `Super + G`               | Togol pengumpulan tetingkap      |
| `Super + Alt + G`               | Alih tetingkap keluar daripada pengumpulan      |
| `Super + Alt + Tab`               | Kitar antara tetingkap dalam pengumpulan      |
| `Super + Alt + Shift + Tab`               | Kitar ke belakang antara tetingkap dalam pengumpulan      |
| `Super + Alt + Scroll Wheel` | Kitar antara tetingkap dalam pengumpulan |
| `Super + Alt + 1/2/3/4/5`               | Lompat ke tetingkap tertentu dalam pengumpulan      |
| `Super + Alt + Arrow`  | Alih tetingkap ke dalam pengumpulan ke arah anak panah, termasuk yang berada pada monitor di sisi tersebut |
| `Super + Ctrl + Left/Right`  | Bergerak antara tetingkap di dalam kumpulan jubin |
| `Super + Ctrl + Z` | Zum masuk pada skrin (ulang untuk zum lebih banyak) |
| `Super + Ctrl + Alt + Z` | Zum keluar sepenuhnya daripada skrin |
| `Super + /` | Maju selangkah melalui pilihan penskalaan monitor |
| `Super + Alt + /` | Undur selangkah melalui pilihan penskalaan monitor |
| `Alt + Tab` | Kitar ke hadapan melalui tetingkap pada ruang kerja aktif |
| `Alt + Shift + Tab` | Kitar ke belakang melalui tetingkap pada ruang kerja aktif |
| `Ctrl + Alt + Tab`| Kitar fokus ke hadapan melalui monitor |
| `Ctrl + Alt + Shift + Tab`| Kitar fokus ke belakang melalui monitor |

Pintasan ubah saiz menggunakan kekunci fizikal `code:20` dan `code:21` (XKB `<AE11>` dan `<AE12>`), tanpa mengira aksara yang tercetak pada papan kekunci. Pada papan kekunci US kekunci ini ialah `-` dan `=`; pada papan kekunci Jepun (JIS) ia ialah `-` dan `^`; pada papan kekunci Sepanyol ia ialah `'` dan `¡`. Pada JIS, `Super + ^` ialah `Super + Equal`, manakala `Super + Shift + -` (yang menaip `=`) ialah `Super + Shift + Minus`.

## Kawalan sistem

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel audio    |
| `Super + Ctrl + B`           | Panel Bluetooth    |
| `Super + Ctrl + N`           | Panel Wifi/rangkaian    |
| `Super + Ctrl + D`           | Panel paparan    |
| `Super + Ctrl + P`           | Panel kuasa    |
| `Super + Ctrl + X`           | Panel ejen    |
| `Super + Ctrl + Alt + D`           | Panel kalendar    |
| `Super + Ctrl + Alt + E`           | Panel jam dunia    |
| `Super + Ctrl + 1-9`           | Togol panel bar mengikut kedudukan    |
| `Super + Ctrl + S` | Menu kongsi (melalui LocalSend) |
| `Super + Ctrl + C` | Kawalan tangkapan (tangkapan skrin/-rakaman/pemilih) |
| `Super + Ctrl + O` | Menu togol |
| `Super + Ctrl + H` | Menu perkakasan |
| `Super + Ctrl + E` | Pemilih emoji |
| `Super + Ctrl + .` | Transkod media |
| `Super + Shift + Ctrl + A` | Pilih ejen AI |

## Pelarasan

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Kecerahan skrin maksimum |
| `Shift + Brightness Down` | Kecerahan skrin minimum |
| `Alt + Brightness Up/Down` | Perubahan kecerahan tepat 1% |
| `Alt + Volume Up/Down` | Perubahan volum tepat 1% |
| `Keyboard Brightness Up/Down` | Lampu latar papan kekunci lebih terang/malap |
| `Keyboard Backlight` | Kitar tahap lampu latar papan kekunci |
| `Alt + Play` | Trek seterusnya |
| `Alt + Shift + Play` | Trek sebelumnya |

## Melancarkan aplikasi

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (pengurus ejen) |
| `Super + Shift + Return`           | Pelayar    |
| `Super + Shift + Alt + B`           | Pelayar (peribadi/inkognito)    |
| `Super + Shift + F`           | Pengurus fail    |
| `Super + Shift + Alt + F`           | Pengurus fail dalam cwd terminal    |
| `Super + Shift + M`           | Muzik (Spotify)    |
| `Super + Shift + Alt + M`           | Muzik (cliamp)    |
| `Super + Shift + /`           | Pengurus kata laluan (1password)    |
| `Super + Shift + Q`           | Kalkulator (Omacalc)    |
| `Super + Shift + T`           | Aktiviti (btop)    |
| `Super + Shift + N`           | Editor (Neovim)  |
| `Super + Shift + C`           | Kalendar ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mel ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | E-mel baharu ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Pemesejan (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Pemesejan (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Pemesejan (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Penulisan (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Tukar/tambah ikatan dalam `~/.config/hypr/bindings.lua`.

## Papan keratan universal

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + A`           | Pilih semua dalam aplikasi yang menyokong `Ctrl + A`    |
| `Super + C`           | Salin    |
| `Super + X`           | Potong (bukan dalam terminal)    |
| `Super + V`           | Tampal    |
| `Super + Ctrl + V`           | Pengurus papan keratan    |

Biasanya di Linux, anda memerlukan `Ctrl + Shift + C/V` untuk salin dan tampal dalam terminal dan `Ctrl + C/V` untuk melakukannya di tempat lain. Kekunci pintas papan keratan bersepadu Omarchy ini berfungsi di mana-mana.

## Tangkapan

| Kekunci Pintas              | Fungsi                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Tangkapan skrin                      |
| `Super + Ctrl + Alt + C`            | Tangkapan skrin (tangkapan yang sama, untuk papan kekunci tanpa kekunci Print Screen) |
| `Super + Ctrl + C` | Menu tangkapan |
| `Alt + Print Screen`            | Rakaman skrin                     |
| `Super + Print Screen` | Pemilih warna |
| `Super + Ctrl + Print Screen` | Pengekstrakan teks ke papan keratan |
| `Super + Alt + [` | Kecilkan tindanan webcam semasa merakam |
| `Super + Alt + ]` | Besarkan tindanan webcam semasa merakam |
| `Alt + Shift + L` | Salin URL semasa daripada webapp atau pelayar |
| `Alt + Shift + D` | Muat turun video pada halaman semasa ke `~/Videos` |
| `Alt + Space` | Mula/hentikan imlak (memerlukan _Setup > Defaults > Dictation_) |
| `Right Alt` | Tahan untuk mengimlak (memerlukan _Setup > Defaults > Dictation_) |

Dengan rakaman skrin, kekunci pintas mula-mula bertanya audio mana yang anda mahukan, kemudian mula merakam. Tekannya lagi untuk berhenti. Lihat [tangkapan skrin dan rakaman](12-screenshots-recording.md) untuk butirannya.

Semua pilihan tangkapan juga boleh diakses di bawah _Trigger > Capture_ dalam menu Omarchy (`Super + Space`).

## Pemberitahuan

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + ,` | Bertindak pada pemberitahuan terkini: bukanya atau tekan satu-satunya butangnya, pilih daripada pilihannya, atau abaikannya apabila ia tiada pilihan  |
| `Super + Shift + ,` | Abaikan semua pemberitahuan |
| `Super + Ctrl + ,` | Kawal pemberitahuan dengan papan kekunci  |
| `Super + Alt + ,` | Abaikan pemberitahuan terkini  |
| `Super + Shift + Alt + ,` | Buka sejarah pemberitahuan  |
| `Super + Ctrl + Alt + ,` | Togol senyapkan pemberitahuan  |

## Gaya

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Pilih tema baharu (juga `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Pilih latar belakang tema (juga `Super + Ctrl + Space`) |
| `Super + Backspace` | Togol ketelusan pada tetingkap |
| `Super + Ctrl + Backspace` | Togol aspek segi empat sama tetingkap tunggal |

Imej latar belakang tambahan berada dalam `~/.config/omarchy/backgrounds/<theme name>`. Juga tersedia melalui _Install > Style > Background_ dalam menu Omarchy.

Semua pilihan gaya juga boleh diakses di bawah _Style_ dalam menu Omarchy (`Super + Space`).

## Togol

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Togol penguncian semasa melahu |
| `Super + Ctrl + Delete` | Togol paparan komputer riba hidup/mati |
| `Super + Ctrl + Alt + Delete` | Togol pencerminan paparan komputer riba |
| `Super + Shift + Space` | Togol bar atas  |
| `Shift + Mute` | Tukar ke output audio seterusnya |
| `Shift + Play` | Tukar ke sumber media seterusnya |
| `Super + Shift + Backspace` | Togol jurang tetingkap |
| `Super + Ctrl + Alt + F` | Togol desktop skrin penuh (bar atas + jurang tetingkap) |

## Peringatan

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Tetapkan peringatan  |
| `Super + Ctrl + Alt + R` | Lihat semua peringatan  |
| `Super + Ctrl + Shift + R` | Kosongkan semua peringatan  |

## Notis

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Tunjukkan masa sebagai pemberitahuan  |
| `Super + Ctrl + Alt + B` | Tunjukkan bateri sebagai pemberitahuan  |
| `Super + Ctrl + Alt + W` | Togol cuaca sebagai pemberitahuan  |

## Tmux

Kekunci awalan ialah `Ctrl + Space` (`Ctrl + B` juga berfungsi). Anda boleh menukar ikatan ini dalam `~/.config/tmux/tmux.conf`.

### Anak tetingkap

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + v` | Belah anak tetingkap di sebelah (menegak) |
| `Prefix + h` | Belah anak tetingkap di bawah (mendatar) |
| `Prefix + x` | Matikan anak tetingkap |
| `Prefix + z` | Togol zum anak tetingkap (skrin penuh) |
| `Alt + Enter` | Belah anak tetingkap di bawah (tanpa awalan) |
| `Alt + Shift + Enter` | Belah anak tetingkap di sebelah (tanpa awalan) |
| `Alt + Escape` | Matikan anak tetingkap (tanpa awalan) |
| `Ctrl + Alt + Arrows` | Bergerak antara anak tetingkap |
| `Ctrl + Alt + Shift + Arrows` | Ubah saiz anak tetingkap |

### Tetingkap

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + c` | Tetingkap baharu |
| `Prefix + k` | Matikan tetingkap |
| `Prefix + r` | Namakan semula tetingkap |
| `Alt + 1-9` | Pergi ke tetingkap tertentu |
| `Alt + Arrow Left/Right` | Bergerak antara tetingkap |
| `Alt + Shift + Arrow Left/Right` | Alih tetingkap ke kiri/kanan |

### Sesi

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + C` | Sesi baharu |
| `Prefix + K` | Matikan sesi |
| `Prefix + R` | Namakan semula sesi |
| `Prefix + N` | Sesi seterusnya |
| `Prefix + P` | Sesi sebelumnya |
| `Alt + Arrow Up/Down` | Bergerak antara sesi |
| `Prefix + s` | Senaraikan sesi |
| `Prefix + d` | Pisahkan daripada sesi |

### Mod salin (gaya vi)

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + [` | Masuk mod salin |
| `v` | Mula pemilihan (dalam mod salin) |
| `y` | Salin pemilihan (dalam mod salin) |

### Umum

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Prefix + q` | Muat semula konfigurasi |
| `Prefix + ?` | Tunjukkan ikatan kekunci Tmux |
| `Prefix + :` | Gesaan arahan |

### Fungsi susun atur Tmux

Fungsi ini mesti dijalankan di dalam sesi Tmux.

| Arahan | Fungsi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Cipta susun atur dev dengan editor, AI, dan terminal |
| `tdlm <ai> [<second_ai>]` | Cipta susun atur dev bagi setiap subdirektori |
| `tsl <count> <command>` | Cipta susun atur swarm berbilang anak tetingkap |

## Terminal Ghostty

Terminal Ghostty dipasang menggunakan _Install > Terminal_ melalui menu Omarchy.

| Kekunci Pintas                  | Fungsi              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Belahan baharu di bawah |
| `Ctrl + Shift + O` | Belahan baharu di sebelah |
| `Ctrl + Alt + Arrows` | Bergerak antara belahan |
| `Super + Ctrl + Shift + Arrows` | Ubah saiz belahan sebanyak 10 baris |
| `Super + Ctrl + Shift + Alt + Arrows` | Ubah saiz belahan sebanyak 100 baris |
| `Ctrl + Shift + T` | Tab baharu  |
| `Ctrl + Shift + Arrows` | Bergerak antara tab |
| `Alt + Numbers` | Pergi ke tab tertentu |
| `Shift + Pg Up/Down` | Tatal sejarah |
| `Ctrl + Left mouse` | Buka pautan dalam pelayar |

## Pengurus Fail

| Kekunci Pintas              | Fungsi                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Pergi ke laluan                     |
| `Space`               | Pratonton fail (anak panah untuk navigasi) |
| `Alt + Up`       | Naik ke folder induk        |

## Neovim (dengan lazyvim)

### Navigasi

| Kekunci Pintas                   | Fungsi                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Tunjukkan pilihan arahan            |
| `Space Space`              | Buka fail melalui carian kabur      |
| `Space E`                  | Togol bar sisi                  |
| `Space G G`                | Tunjukkan kawalan git               |
| `Space S G`                | Cari kandungan fail             |
| `Ctrl + W W`               | Lompat antara bar sisi dan editor |
| `Ctrl + Left/right arrow`  | Tukar saiz bar sisi          |
| `Shift + H`                      | Pergi ke tab fail kiri             |
| `Shift + L`                      | Pergi ke tab fail kanan            |
| `Space B D`                | Tutup tab fail                  |

### Semasa dalam bar sisi

| Kekunci Pintas                   | Fungsi                        |
| ------------------------ | ------------------------------- |
| `A`                        | Tambah fail baharu dalam direktori induk      |
| `Shift + A`                | Tambah subdirektori baharu dalam direktori induk    |
| `D`                        | Padam fail/direktori yang diserlahkan     |
| `M`                        | Alih fail/direktori yang diserlahkan       |
| `R`                        | Namakan semula fail/direktori yang diserlahkan     |
| `?`                        | Tunjukkan bantuan untuk semua arahan      |

[Lihat semua kekunci pintas Neovim yang dikonfigurasikan oleh LazyVim](https://www.lazyvim.org/keymaps).

## Emoji Pantas

Anda boleh menggunakan `Super + Ctrl + E` untuk menunjukkan pemilih emoji lengkap yang akan meletakkan pilihan pada papan keratan atau anda boleh menggunakan pilihan akses pantas ini.

| Kekunci Pintas       | EM | Petunjuk       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | senyum      |
| `Shift + CapsLock M C` | 😂 | menangis        |
| `Shift + CapsLock M L` | 😍 | cinta       |
| `Shift + CapsLock M V` | ✌️ | kemenangan    |
| `Shift + CapsLock M H` | ❤️ | hati      |
| `Shift + CapsLock M Y` | 👍 | ya        |
| `Shift + CapsLock M N` | 👎 | tidak         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | hajat       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | cium       |
| `Shift + CapsLock M E` | 🙄 | putar mata    |
| `Shift + CapsLock M I` | 😉 | kenyit mata       |
| `Shift + CapsLock M P` | 🙏 | doa |
| `Shift + CapsLock M D` | 🤤 | air liur meleleh      |
| `Shift + CapsLock M M` | 💰 | wang      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | bersulang      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | sapaan |
| `Shift + CapsLock M A` |💪 | lengan |
| `Shift + CapsLock M B` |🤯 | meletup |

## Pelengkapan Pantas

| Kekunci Pintas       | Pelengkapan       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Nama anda (seperti yang dimasukkan semasa persediaan)  |
| `Shift + CapsLock Space E` | E-mel anda (seperti yang dimasukkan semasa persediaan)  |

Anda boleh menambah lebih banyak sendiri dengan mengedit `~/.XCompose`, kemudian menjalankan `omarchy-restart-xcompose` dalam terminal supaya perubahan diambil.
