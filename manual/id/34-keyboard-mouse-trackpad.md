# Papan Ketik, Mouse, Trackpad

Hyprland memungkinkan Anda mengonfigurasi semua input Anda dengan sangat detail. Anda dapat mengubah pengulangan papan ketik menjadi sangat cepat atau membuat trackpad menggunakan pengguliran alami. Anda mengubah semuanya di `~/.config/hypr/input.lua`, yang juga dapat Anda capai melalui _Setup > Input_ di menu Omarchy (`Super + Space`). Apa pun yang Anda atur di sana akan menggantikan default Omarchy.

Berikut contohnya:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

Anda dapat [melihat semua opsi input](https://wiki.hypr.land/Configuring/Basics/Variables/#input) di wiki Hyprland untuk input.

CapsLock berfungsi sebagai Caps Lock normal, dan `Shift + CapsLock` adalah tombol compose untuk [emoji cepat](07-hotkeys.md#quick-emojis) dan [pelengkapan cepat lainnya](07-hotkeys.md#quick-completions). Jika Anda lebih suka tombol compose berada di tempat lain, ganti `omarchy:shift_caps_compose` di `kb_options`. Misalnya, ini memindahkan tombol compose ke Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Tombol fungsi

Baris teratas pada papan ketik laptop mengirim tombol media (volume, kecerahan, dan sebagainya) secara default, dan menahan `Fn` memberikan F1-F12; `Fn + Esc` menguncinya ke cara sebaliknya hingga Anda menekannya lagi. Sebagian besar keyboard mengingat penguncian itu sendiri. Laptop ASUS dan papan ketik bergaya Apple menyerahkannya kepada Linux, yang memulainya pada tombol media setiap kali boot. Agar mereka mulai pada F1-F12, jalankan `omarchy device keyboard toprow fnkeys` (dan `omarchy device keyboard toprow mediakeys` untuk kembali); pada beberapa laptop, ini berlaku setelah reboot. Mac Apple Silicon mempertahankan pengaturannya sendiri.

### Gerakan trackpad

Gesek pada trackpad untuk berpindah di desktop:

| Gerakan | Tindakan |
| --- | --- |
| Tiga jari ke kiri / kanan | Workspace sebelumnya / berikutnya, termasuk yang kosong |
| Tiga jari ke atas | Alihkan konsol AI |
| Tiga jari ke bawah | Buka menu Omarchy |
| Empat jari ke kiri / kanan | Pindahkan jendela aktif ke workspace sebelumnya / berikutnya |
| Empat jari ke bawah | Alihkan layar penuh |

Untuk mengubah salah satunya, batalkan pengaturannya di `~/.config/hypr/input.lua` sebelum menambahkan [gerakan touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) Anda sendiri, karena Hyprland tidak akan menerima dua gerakan pada jari dan arah yang sama:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Untuk mematikan semua gerakan Omarchy, atur `omarchy_default_gestures = false` di dekat bagian atas `~/.config/hypr/hyprland.lua`, sebelum default Omarchy dimuat.

Pada laptop Dell XPS dengan touchpad haptic, Anda juga dapat mengatur kekuatan klik ke low, mid, atau high di bawah _Trigger > Hardware > Touchpad Haptics_.

### Mengetik dalam bahasa Mandarin, Jepang, dan bahasa lainnya

Pilih Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), atau Hong Kong (Cangjie) ketika installer menanyakan papan ketik Anda. Omarchy mengonfigurasi papan ketik dan mesin input yang cocok secara otomatis, termasuk selama penyiapan boot pertama offline. Japanese menggunakan Mozc, Korean menggunakan Hangul dua-set standar, Simplified Chinese menggunakan Pinyin, Taiwan menggunakan susunan Zhuyin standar dari Chewing, dan Hong Kong menggunakan Cangjie dengan bentuk karakter Hong Kong. Japanese (US keyboard) menyediakan Mozc dengan tata letak papan ketik US. Tombol Hangul, Zhuyin, dan Cangjie tetap berada di posisi standarnya bahkan ketika Anda mengetik huruf Latin dengan Dvorak, Colemak, atau AZERTY. Jika Anda menambahkan Hangul atau Chewing sebelum ini, batalkan pilihannya dan pilih kembali di bawah _Setup > Keyboard > Input Methods_ untuk memindahkan tombol-tombolnya ke sana; Omarchy membiarkan mesin yang sudah Anda pakai untuk mengetik tetap apa adanya.

Pengetikan dimulai dalam mode Latin. Tekan `Super + I` untuk berputar melalui metode input yang dikonfigurasi, dan `Super + Shift + I` untuk berputar kembali. Ketuk `Shift` sendiri untuk keluar dari metode input seperti Pinyin ke huruf Latin, dan ketuk lagi untuk kembali, seperti cara kerja Sogou, Microsoft Pinyin, dan macOS; `Shift` ditambah sebuah huruf tetap mengetik huruf kapital. Pada papan ketik Jepang, 全角/半角 mengalihkan input, 変換 mengaktifkannya, dan 無変換 mematikannya. Dengan Korean, 한/영 mengalihkan Hangul dan 한자 mengonversi menjadi Hanja, baik papan ketik Anda memiliki tombol khusus atau mengirim Right Alt dan Right Ctrl untuk tombol tersebut, seperti yang dilakukan banyak laptop, jadi Right Alt dan Right Ctrl bukan modifier biasa di sana; dikte dialihkan dengan Alt + Space sebagai gantinya. `Ctrl + Space` tetap tersedia untuk Tmux dan Herdr; `Shift + CapsLock` tetap menjadi tombol compose.

Indikator papan ketik muncul di sebelah kanan bar ketika Anda memiliki beberapa tata letak papan ketik atau metode input. Klik indikator tersebut untuk beralih bahasa input; Japanese menampilkan あ untuk hiragana. Untuk pilihan karakter Jepang, beralihlah ke Japanese, ketik kata seperti `nihongo`, lalu tekan Space dua kali. Tekan Enter untuk menerima pilihan Anda. Jika Anda juga memiliki beberapa tata letak papan ketik, klik kanan indikator untuk berputar melalui tata letak tersebut.

Gunakan _Setup > Keyboard > Keyboard Inputs_ untuk memilih tata letak seperti English dan French, dari pilihan yang sama yang ditawarkan selama instalasi. Gunakan _Setup > Keyboard > Input Methods_ untuk memilih mesin komposisi mana yang aktif. Kedua pemilih terbuka di dalam menu Omarchy dengan pilihan Anda saat ini tercentang. Klik atau tekan Enter untuk mengalihkan pilihan; setiap perubahan berlaku segera. Membatalkan pilihan metode input akan menghapusnya dari putaran tanpa menghapus instalasinya; papan ketik tetap tersedia.

Jalankan `omarchy setup keyboard` atau `omarchy setup input` untuk membuka pemilih yang sama. Untuk menambahkan satu bahasa dari baris perintah, gunakan `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, atau `cangjie5`. Quick, Boshiamy, dan Array hadir dalam paket yang sama dengan Cangjie dan muncul di pemilih Input Methods. Tombol pengalihan kustom Anda dipertahankan. Untuk tata letak atau tombol mesin alternatif, instal `fcitx5-configtool` dengan `omarchy pkg add fcitx5-configtool` dan luncurkan dari terminal. Memilih bahasa input tidak mengubah bahasa desktop. Memilih Japanese, Korean, atau Chinese di bawah _Setup > Language_ akan menambahkan metode inputnya ketika Anda belum memilikinya.

Gunakan `Super + I` untuk berputar melalui metode input atau tata letak papan ketik, dan `Super + Shift + I` untuk kembali ke arah sebaliknya, jadi dengan tiga yang dikonfigurasi Anda dapat berpindah di antara dua tetangga. Indikator input muncul di sebelah kanan bar hanya ketika lebih dari satu metode input atau tata letak dikonfigurasi. Binding desktop ini bekerja bersama tombol pengalihan Fcitx Anda yang sudah ada; Anda dapat menimpanya di `~/.config/hypr/bindings.lua`. Mesin input dan urutan compose menggunakan layanan [Fcitx5](https://fcitx-im.org/) yang sudah berjalan di setiap sesi.

### Gunakan ALT sebagai SUPER

Pada beberapa papan ketik, tidak nyaman menggunakan tombol meta utama (tombol Windows/cmd) sebagai SUPER. Anda dapat mengubahnya menjadi ALT sebagai gantinya dengan perubahan ini:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
