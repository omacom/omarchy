# Keyboard, Mouse, Trackpad

Hyprland memungkinkan Anda mengonfigurasi semua input Anda secara sangat terperinci. Anda dapat mengubah pengulangan keyboard menjadi secepat kilat atau membuat trackpad menggunakan pengguliran alami. Anda mengubah semuanya di `~/.config/hypr/input.lua`, yang juga dapat Anda jangkau melalui _Setup > Input_ di menu Omarchy (`Super + Space`). Apa pun yang Anda atur di sana menggantikan default Omarchy.

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

CapsLock berfungsi sebagai Caps Lock biasa, dan `Shift + CapsLock` adalah tombol compose untuk [emoji cepat](07-hotkeys.md#quick-emojis) dan [penyelesaian cepat lainnya](07-hotkeys.md#quick-completions). Jika Anda lebih suka tombol compose berada di tempat lain, ganti `omarchy:shift_caps_compose` di `kb_options`. Misalnya, ini memindahkan tombol compose ke Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestur trackpad

Anda juga dapat mengaktifkan [gestur touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), seperti menggeser dengan tiga jari untuk berpindah workspace:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Pada laptop Dell XPS dengan touchpad haptic, Anda juga dapat mengatur kekuatan klik ke low, mid, atau high di bawah _Trigger > Hardware > Touchpad Haptics_.

### Mengetik dalam bahasa Mandarin, Jepang, dan bahasa lainnya

Pilih Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), atau Hong Kong (Cangjie) saat installer menanyakan keyboard Anda. Omarchy mengonfigurasi keyboard dan mesin input yang cocok secara otomatis, termasuk selama penyiapan offline saat boot pertama. Japanese menggunakan Mozc, Korean menggunakan Hangul two-set standar, Simplified Chinese menggunakan Pinyin, Taiwan menggunakan susunan Zhuyin standar dari Chewing, dan Hong Kong menggunakan Cangjie dengan bentuk karakter Hong Kong. Japanese (US keyboard) menyediakan Mozc dengan tata letak keyboard US. Tombol Hangul, Zhuyin, dan Cangjie tetap berada di posisi standarnya bahkan saat Anda mengetik huruf Latin dengan Dvorak, Colemak, atau AZERTY. Jika Anda menambahkan Hangul atau Chewing sebelum ini, batalkan pilihannya lalu pilih kembali di bawah _Setup > Typing > Input Methods_ untuk memindahkan tombol-tombolnya ke sana; Omarchy membiarkan mesin yang sudah Anda gunakan untuk mengetik apa adanya.

Pengetikan dimulai dalam mode Latin. Tekan `Super + I` untuk beralih bergiliran melalui metode input yang telah dikonfigurasi, dan `Super + Shift + I` untuk beralih kembali. Ketuk `Shift` sendiri untuk keluar dari metode input seperti Pinyin ke huruf Latin, dan ketuk lagi untuk kembali, seperti cara kerja Sogou, Microsoft Pinyin, dan macOS; `Shift` ditambah sebuah huruf tetap mengetik huruf kapital. Pada keyboard Japanese, 全角/半角 mengalihkan input, 変換 mengaktifkannya, dan 無変換 menonaktifkannya. Dengan Korean, 한/영 beralih ke Hangul dan 한자 mengonversi ke Hanja, baik keyboard Anda memiliki tombol khusus maupun mengirim Right Alt dan Right Ctrl untuk tombol-tombol tersebut, seperti yang dilakukan banyak laptop, jadi Right Alt dan Right Ctrl bukan modifier biasa di sana; push-to-talk dikte tetap berada di F9. `Ctrl + Space` tetap tersedia untuk Tmux dan Herdr; `Shift + CapsLock` tetap menjadi tombol compose.

Indikator keyboard muncul di sebelah kanan bar saat Anda memiliki beberapa tata letak keyboard atau metode input. Klik indikator tersebut untuk beralih bahasa input; Japanese menampilkan あ untuk hiragana. Untuk pilihan karakter Japanese, beralihlah ke Japanese, ketik kata seperti `nihongo`, lalu tekan Space dua kali. Tekan Enter untuk menerima pilihan Anda. Jika Anda juga memiliki beberapa tata letak keyboard, klik kanan indikator tersebut untuk beralih bergiliran di antara tata letak tersebut.

Gunakan _Setup > Typing > Keyboard Layouts_ untuk memilih tata letak seperti English dan French, dari pilihan yang sama yang ditawarkan selama instalasi. Gunakan _Setup > Typing > Input Methods_ untuk memilih mesin komposisi mana yang aktif. Kedua pemilih terbuka di dalam menu Omarchy dengan pilihan Anda saat ini dalam keadaan tercentang. Klik atau tekan Enter untuk mengalihkan sebuah pilihan; setiap perubahan langsung berlaku. Membatalkan pilihan sebuah metode input akan menghapusnya dari siklus tanpa menghapus instalasinya; keyboard tetap tersedia.

Jalankan `omarchy setup keyboard` atau `omarchy setup input` untuk membuka pemilih yang sama. Untuk menambahkan satu bahasa dari baris perintah, gunakan `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, atau `cangjie5`. Quick, Boshiamy, dan Array hadir dalam paket yang sama dengan Cangjie dan muncul di pemilih Input Methods. Tombol peralihan kustom Anda tetap dipertahankan. Untuk tata letak atau tombol mesin alternatif, instal `fcitx5-configtool` dengan `omarchy pkg add fcitx5-configtool` dan jalankan dari terminal. Memilih bahasa input tidak mengubah bahasa desktop. Memilih Japanese, Korean, atau Chinese di bawah _Setup > Language_ akan menambahkan metode inputnya saat Anda belum memilikinya.

Gunakan `Super + I` untuk beralih bergiliran melalui metode input atau tata letak keyboard, dan `Super + Shift + I` untuk kembali ke arah sebaliknya, jadi dengan tiga yang dikonfigurasi Anda dapat berpindah di antara dua tetangga. Indikator input muncul di sebelah kanan bar hanya saat lebih dari satu metode input atau tata letak dikonfigurasi. Binding desktop ini bekerja bersama tombol peralihan Fcitx Anda yang sudah ada; Anda dapat menimpanya di `~/.config/hypr/bindings.lua`. Mesin input dan urutan compose menggunakan layanan [Fcitx5](https://fcitx-im.org/) yang sudah berjalan di setiap sesi.

### Gunakan ALT sebagai SUPER

Pada beberapa keyboard, tidak nyaman menggunakan tombol meta utama (tombol Windows/cmd) sebagai SUPER. Anda dapat mengubahnya menjadi ALT sebagai gantinya menggunakan perubahan ini:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
