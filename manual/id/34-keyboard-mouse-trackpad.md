# Keyboard, Mouse, Trackpad

Hyprland memungkinkan Anda mengonfigurasi semua input Anda secara sangat rinci. Anda dapat mengubah pengulangan keyboard menjadi sangat cepat atau membuat trackpad menggunakan natural scrolling. Anda mengubah semuanya di `~/.config/hypr/input.lua`, yang juga dapat Anda jangkau melalui _Setup > Input_ di menu Omarchy (`Super + Space`). Apa pun yang Anda tetapkan di sana menggantikan default Omarchy.

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

CapsLock bekerja sebagai Caps Lock biasa, dan `Shift + CapsLock` adalah tombol compose untuk [emoji cepat](07-hotkeys.md#quick-emojis) dan [pelengkapan lainnya](07-hotkeys.md#quick-completions). Jika Anda lebih suka tombol compose di tempat lain, ganti `omarchy:shift_caps_compose` di `kb_options`. Misalnya, ini memindahkan tombol compose ke Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gerakan trackpad

Geser di trackpad untuk bergerak di desktop:

| Gerakan | Tindakan |
| --- | --- |
| Tiga jari ke kiri / kanan | Workspace sebelumnya / berikutnya, termasuk yang kosong |
| Tiga jari ke atas | Buka/tutup konsol AI |
| Tiga jari ke bawah | Buka menu Omarchy |
| Empat jari ke kiri / kanan | Pindahkan jendela aktif ke workspace sebelumnya / berikutnya |
| Empat jari ke bawah | Buka/tutup fullscreen |

Untuk mengubah salah satunya, unset di `~/.config/hypr/input.lua` sebelum menambahkan [gerakan touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) Anda sendiri, karena Hyprland tidak akan menerima dua gerakan pada jari dan arah yang sama:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Untuk menonaktifkan semua gerakan Omarchy, tetapkan `omarchy_default_gestures = false` di dekat bagian atas `~/.config/hypr/hyprland.lua`, sebelum default Omarchy dimuat.

Di laptop Dell XPS dengan touchpad haptic, Anda juga dapat mengatur kekuatan klik ke rendah, sedang, atau tinggi di bawah _Trigger > Hardware > Touchpad Haptics_.

### Mengetik dalam bahasa Mandarin, Jepang, dan bahasa lainnya

Pilih Jepang, Korea, Mandarin (Sederhana, Pinyin), Taiwan (Zhuyin), atau Hong Kong (Cangjie) saat installer menanyakan keyboard Anda. Omarchy mengonfigurasi keyboard dan mesin input yang cocok secara otomatis, termasuk selama penyiapan pertama secara offline. Jepang menggunakan Mozc, Korea menggunakan Hangul two-set standar, Mandarin Sederhana menggunakan Pinyin, Taiwan menggunakan susunan Zhuyin standar dari Chewing, dan Hong Kong menggunakan Cangjie dengan bentuk karakter Hong Kong. Japanese (US keyboard) menyediakan Mozc dengan tata letak keyboard US. Hangul, Zhuyin, dan Cangjie tetap berada di posisi standarnya bahkan saat Anda mengetik huruf Latin dengan Dvorak, Colemak, atau AZERTY. Jika Anda menambahkan Hangul atau Chewing sebelum ini, batalkan pilihan dan pilih kembali di bawah _Setup > Typing > Input Methods_ untuk memindahkan tombol-tombolnya ke sana; Omarchy membiarkan mesin yang sudah Anda gunakan untuk mengetik tetap seperti adanya.

Mengetik dimulai dalam mode Latin. Tekan `Super + I` untuk berpindah melalui metode input yang dikonfigurasi, dan `Super + Shift + I` untuk berpindah kembali. Ketuk `Shift` sendiri untuk keluar dari metode input seperti Pinyin ke huruf Latin, dan ketuk lagi untuk kembali, seperti cara kerja Sogou, Microsoft Pinyin, dan macOS; `Shift` plus sebuah huruf tetap mengetik huruf kapital. Di keyboard Jepang, 全角/半角 mengalihkan input, 変換 mengaktifkannya, dan 無変換 menonaktifkannya. Dengan Korea, 한/영 mengalihkan Hangul dan 한자 mengonversi ke Hanja, baik keyboard Anda memiliki tombol khusus atau mengirim Right Alt dan Right Ctrl untuk itu, seperti yang dilakukan banyak laptop, jadi Right Alt dan Right Ctrl bukan modifier biasa di sana; push-to-talk dikte tetap di F9. `Ctrl + Space` tetap tersedia untuk Tmux dan Herdr; `Shift + CapsLock` tetap menjadi tombol compose.

Indikator keyboard muncul di sebelah kanan bar saat Anda memiliki beberapa tata letak keyboard atau metode input. Klik untuk beralih bahasa input; Jepang menampilkan あ untuk hiragana. Untuk pilihan karakter Jepang, beralihlah ke Jepang, ketik kata seperti `nihongo`, lalu tekan Space dua kali. Tekan Enter untuk menerima pilihan Anda. Jika Anda juga memiliki beberapa tata letak keyboard, klik kanan indikator untuk berpindah di antaranya.

Gunakan _Setup > Typing > Keyboard Layouts_ untuk memilih tata letak seperti English dan French, dari pilihan yang sama yang ditawarkan selama instalasi. Gunakan _Setup > Typing > Input Methods_ untuk memilih mesin komposisi mana yang aktif. Kedua pemilih terbuka di dalam menu Omarchy dengan pilihan Anda saat ini tercentang. Klik atau tekan Enter untuk mengalihkan pilihan; setiap perubahan langsung berlaku. Membatalkan pilihan metode input akan menghapusnya dari siklus tanpa meng-uninstall-nya; keyboard tetap tersedia.

Jalankan `omarchy setup keyboard` atau `omarchy setup input` untuk membuka pemilih yang sama. Untuk menambahkan satu bahasa dari baris perintah, gunakan `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, atau `cangjie5`. Quick, Boshiamy, dan Array disertakan dalam paket yang sama dengan Cangjie dan muncul di pemilih Input Methods. Tombol switching kustom Anda dipertahankan. Untuk tata letak atau tombol mesin alternatif, install `fcitx5-configtool` dengan `omarchy pkg add fcitx5-configtool` dan jalankan dari terminal. Memilih bahasa input tidak mengubah bahasa desktop. Memilih Jepang, Korea, atau Mandarin di bawah _Setup > Language_ menambahkan metode inputnya saat Anda belum memilikinya.

Gunakan `Super + I` untuk berpindah melalui metode input atau tata letak keyboard, dan `Super + Shift + I` untuk kembali ke arah sebaliknya, jadi dengan tiga yang dikonfigurasi Anda dapat bergerak di antara dua tetangga. Indikator input muncul di sebelah kanan bar hanya saat lebih dari satu metode input atau tata letak dikonfigurasi. Binding desktop ini bekerja bersama tombol switching Fcitx Anda yang sudah ada; Anda dapat menimpanya di `~/.config/hypr/bindings.lua`. Mesin input dan urutan compose menggunakan layanan [Fcitx5](https://fcitx-im.org/) yang sudah berjalan di setiap sesi.

### Gunakan ALT sebagai SUPER

Di beberapa keyboard, tidak nyaman menggunakan tombol meta utama (tombol Windows/cmd) sebagai SUPER. Anda dapat mengubahnya menjadi ALT sebagai gantinya menggunakan perubahan ini:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
