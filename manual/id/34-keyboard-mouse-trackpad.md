# Keyboard, Mouse, Trackpad

Hyprland memungkinkan Anda mengonfigurasi semua input Anda dengan sangat detail. Anda bisa mengubah repeat keyboard menjadi secepat supersonik atau membuat trackpad menggunakan scrolling alami. Anda mengubah semuanya di `~/.config/hypr/input.lua`, yang juga bisa Anda akses melalui _Setup > Input_ di menu Omarchy (`Super + Space`). Apa pun yang Anda atur di sana akan menggantikan default Omarchy.

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

Anda bisa [lihat semua opsi input](https://wiki.hypr.land/Configuring/Basics/Variables/#input) di wiki Hyprland untuk input.

CapsLock berfungsi sebagai Caps Lock biasa, dan `Shift + CapsLock` adalah tombol compose untuk [emoji cepat](07-hotkeys.md#quick-emojis) dan [penyelesaian cepat lainnya](07-hotkeys.md#quick-completions). Jika Anda lebih suka tombol compose berada di tempat lain, ganti `omarchy:shift_caps_compose` di `kb_options`. Misalnya, ini memindahkan tombol compose ke Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Tombol fungsi

Baris teratas keyboard laptop mengirim tombol media (volume, kecerahan, dan sebagainya) secara default, dan menahan `Fn` memberikan F1-F12; `Fn + Esc` menguncinya ke arah sebaliknya hingga Anda menekannya lagi. Kebanyakan keyboard mengingat status kunci itu sendiri. Laptop ASUS dan keyboard bergaya Apple menyerahkannya kepada Linux, yang memulainya pada tombol media setiap kali boot. Agar mereka mulai pada F1-F12 sebagai gantinya, jalankan `omarchy device keyboard toprow fnkeys` (dan `omarchy device keyboard toprow mediakeys` untuk kembali); pada beberapa laptop, perubahan ini berlaku setelah reboot. Mac Apple Silicon mempertahankan pengaturannya sendiri.

### Gestur trackpad

Geser di trackpad untuk berpindah-pindah di desktop:

| Gestur | Aksi |
| --- | --- |
| Tiga jari ke kiri / kanan | Workspace sebelumnya / berikutnya, termasuk yang kosong |
| Tiga jari ke atas | Alihkan konsol AI |
| Tiga jari ke bawah | Buka menu Omarchy |
| Empat jari ke kiri / kanan | Pindahkan jendela aktif ke workspace sebelumnya / berikutnya |
| Empat jari ke bawah | Alihkan fullscreen |

Untuk mengubah salah satunya, unset di `~/.config/hypr/input.lua` sebelum menambahkan [gestur touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) Anda sendiri, karena Hyprland tidak akan menerima dua gestur pada jumlah jari dan arah yang sama:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Untuk mematikan semua gestur Omarchy, atur `omarchy_default_gestures = false` di dekat bagian atas `~/.config/hypr/hyprland.lua`, sebelum default Omarchy dimuat.

Di laptop Dell XPS dengan touchpad haptic, Anda juga bisa mengatur kekuatan klik ke low, mid, atau high di _Trigger > Hardware > Touchpad Haptics_.

### Mengetik dalam bahasa Tionghoa, Jepang, dan bahasa lainnya

Pilih Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), atau Hong Kong (Cangjie) ketika installer menanyakan keyboard Anda. Omarchy mengonfigurasi keyboard dan mesin input yang cocok secara otomatis, termasuk selama penyiapan first-boot offline. Japanese menggunakan Mozc, Korean menggunakan Hangul two-set standar, Chinese Simplified menggunakan Pinyin, Taiwan menggunakan susunan Zhuyin standar Chewing, dan Hong Kong menggunakan Cangjie dengan bentuk karakter Hong Kong. Japanese (US keyboard) menyediakan Mozc dengan tata letak keyboard US. Tombol Hangul, Zhuyin, dan Cangjie tetap berada di posisi standarnya bahkan ketika Anda mengetik huruf Latin dengan Dvorak, Colemak, atau AZERTY. Jika Anda menambahkan Hangul atau Chewing sebelum ini, batalkan pilihan lalu pilih lagi di _Setup > Keyboard > Input Methods_ untuk memindahkan tombol-tombolnya ke sana; Omarchy tidak mengutak-atik mesin yang sudah Anda gunakan untuk mengetik.

Pengetikan dimulai dalam mode Latin. Tekan `Super + I` untuk berpindah-pindah melalui metode input yang dikonfigurasi, dan `Super + Shift + I` untuk berpindah kembali. Ketuk `Shift` sendiri untuk keluar dari metode input seperti Pinyin ke huruf Latin, dan ketuk lagi untuk kembali, sama seperti cara kerja Sogou, Microsoft Pinyin, dan macOS; `Shift` plus sebuah huruf tetap mengetik huruf kapital. Pada keyboard Jepang, 全角/半角 mengalihkan input, 変換 menyalakannya, dan 無変換 mematikannya. Dengan Korean, 한/영 beralih Hangul dan 한자 mengonversi ke Hanja, baik keyboard Anda memiliki tombol khusus maupun mengirim Right Alt dan Right Ctrl untuknya, seperti yang dilakukan banyak laptop, jadi Right Alt dan Right Ctrl bukan modifier biasa di sana; dikte dialihkan dengan Alt + Space sebagai gantinya. `Ctrl + Space` tetap tersedia untuk Tmux dan Herdr; `Shift + CapsLock` tetap menjadi tombol compose.

Indikator keyboard muncul di sebelah kanan bar ketika Anda memiliki beberapa tata letak keyboard atau metode input. Klik untuk beralih bahasa input; Japanese menampilkan あ untuk hiragana. Untuk pilihan karakter Japanese, beralihlah ke Japanese, ketik kata seperti `nihongo`, lalu tekan Space dua kali. Tekan Enter untuk menerima pilihan Anda. Jika Anda juga memiliki beberapa tata letak keyboard, klik kanan indikator untuk berpindah-pindah di antaranya.

Gunakan _Setup > Keyboard > Keyboard Inputs_ untuk memilih tata letak seperti English dan French, dari pilihan yang sama yang ditawarkan selama instalasi. Gunakan _Setup > Keyboard > Input Methods_ untuk memilih mesin komposisi mana yang aktif. Kedua pemilih terbuka di dalam menu Omarchy dengan pilihan Anda saat ini tercentang. Klik atau tekan Enter untuk mengalihkan pilihan; setiap perubahan berlaku seketika. Membatalkan pilihan metode input akan menghapusnya dari siklus tanpa meng-uninstall-nya; keyboard tetap tersedia.

Jalankan `omarchy setup keyboard` atau `omarchy setup input` untuk membuka pemilih yang sama. Untuk menambahkan satu bahasa dari command line, gunakan `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, atau `cangjie5`. Quick, Boshiamy, dan Array termasuk dalam paket yang sama dengan Cangjie dan muncul di pemilih Input Methods. Tombol peralihan kustom Anda tetap dipertahankan. Untuk tata letak atau tombol mesin alternatif, install `fcitx5-configtool` dengan `omarchy pkg add fcitx5-configtool` dan jalankan dari terminal. Memilih bahasa input tidak mengubah bahasa desktop. Memilih Japanese, Korean, atau Chinese di _Setup > Region > Language_ akan menambahkan metode inputnya ketika Anda belum memilikinya.

Gunakan `Super + I` untuk berpindah-pindah melalui metode input atau tata letak keyboard, dan `Super + Shift + I` untuk kembali ke arah sebaliknya, jadi dengan tiga yang dikonfigurasi Anda bisa bergerak di antara dua yang bersebelahan. Indikator input muncul di sebelah kanan bar hanya ketika lebih dari satu metode input atau tata letak dikonfigurasi. Binding desktop ini bekerja bersama tombol peralihan Fcitx Anda yang sudah ada; Anda bisa menggantinya di `~/.config/hypr/bindings.lua`. Mesin input dan urutan compose menggunakan layanan [Fcitx5](https://fcitx-im.org/) yang sudah berjalan di setiap sesi.

### Gunakan ALT sebagai SUPER

Pada beberapa keyboard, tidak nyaman menggunakan tombol meta utama (tombol Windows/cmd) sebagai SUPER. Anda bisa mengubahnya menjadi ALT sebagai gantinya menggunakan perubahan ini:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
