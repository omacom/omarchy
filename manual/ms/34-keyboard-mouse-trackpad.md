# Papan Kekunci, Tetikus, Pad Jejak

Hyprland membolehkan anda mengkonfigurasi semua input anda dengan sangat terperinci. Anda boleh menukar ulangan papan kekunci supaya sepantas supersonik atau membuat pad jejak menggunakan penatalan semula jadi. Anda menukar semuanya dalam `~/.config/hypr/input.lua`, yang juga boleh dicapai melalui _Setup > Input_ dalam menu Omarchy (`Super + Space`). Apa-apa yang anda tetapkan di sana menggantikan tetapan lalai Omarchy.

Berikut ialah satu contoh:

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

Anda boleh [lihat semua pilihan input](https://wiki.hypr.land/Configuring/Basics/Variables/#input) pada wiki Hyprland untuk input.

CapsLock berfungsi sebagai Caps Lock biasa, dan `Shift + CapsLock` ialah kekunci karang untuk [emoji pantas](07-hotkeys.md#quick-emojis) dan [pelengkapan lain](07-hotkeys.md#quick-completions). Jika anda lebih suka kekunci karang di tempat lain, gantikan `omarchy:shift_caps_compose` dalam `kb_options`. Sebagai contoh, ini memindahkan kekunci karang ke Alt Kanan:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gerak isyarat pad jejak

Leret pada pad jejak untuk bergerak di sekitar desktop:

| Gerak isyarat | Tindakan |
| --- | --- |
| Tiga jari ke kiri / kanan | Ruang kerja sebelumnya / seterusnya, termasuk yang kosong |
| Tiga jari ke atas | Togol konsol AI |
| Tiga jari ke bawah | Buka menu Omarchy |
| Empat jari ke kiri / kanan | Pindahkan tetingkap aktif ke ruang kerja sebelumnya / seterusnya |
| Empat jari ke bawah | Togol skrin penuh |

Untuk menukar salah satu daripadanya, nyahaktifkan ia dalam `~/.config/hypr/input.lua` sebelum menambah [gerak isyarat pad sentuh](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) anda sendiri, kerana Hyprland tidak akan menerima dua gerak isyarat pada jari dan arah yang sama:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Untuk mematikan semua gerak isyarat Omarchy, tetapkan `omarchy_default_gestures = false` berhampiran bahagian atas `~/.config/hypr/hyprland.lua`, sebelum tetapan lalai Omarchy dimuatkan.

Pada komputer riba Dell XPS dengan pad sentuh haptik, anda juga boleh menetapkan kekuatan klik kepada rendah, sederhana, atau tinggi di bawah _Trigger > Hardware > Touchpad Haptics_.

### Menaip dalam bahasa Cina, Jepun, dan bahasa lain

Pilih Jepun, Korea, Cina (Ringkas, Pinyin), Taiwan (Zhuyin), atau Hong Kong (Cangjie) apabila pemasang bertanya tentang papan kekunci anda. Omarchy mengkonfigurasi papan kekunci dan enjin input yang sepadan secara automatik, termasuk semasa persediaan but pertama luar talian. Jepun menggunakan Mozc, Korea menggunakan Hangul dua set standard, Cina Ringkas menggunakan Pinyin, Taiwan menggunakan susunan Zhuyin standard Chewing, dan Hong Kong menggunakan Cangjie dengan bentuk aksara Hong Kong. Jepun (papan kekunci US) menyediakan Mozc dengan susun atur papan kekunci US. Kekunci Hangul, Zhuyin, dan Cangjie kekal pada kedudukan standardnya walaupun anda menaip huruf Latin dengan Dvorak, Colemak, atau AZERTY. Jika anda telah menambah Hangul atau Chewing sebelum ini, nyahpilih dan pilih semula di bawah _Setup > Typing > Input Methods_ untuk memindahkan kekuncinya ke sana; Omarchy membiarkan sahaja enjin yang sudah anda gunakan untuk menaip.

Menaip bermula dalam mod Latin. Tekan `Super + I` untuk berkitar melalui kaedah input yang dikonfigurasi, dan `Super + Shift + I` untuk berkitar kembali. Ketik `Shift` dengan sendirinya untuk keluar daripada kaedah input seperti Pinyin kepada huruf Latin, dan ketik sekali lagi untuk kembali, seperti cara Sogou, Microsoft Pinyin, dan macOS berfungsi; `Shift` ditambah huruf masih menaip huruf besar. Pada papan kekunci Jepun, 全角/半角 menogol input, 変換 menghidupkannya, dan 無変換 mematikannya. Dengan Korea, 한/영 menukar Hangul dan 한자 menukar kepada Hanja, sama ada papan kekunci anda mempunyai kekunci khusus atau menghantar Alt Kanan dan Ctrl Kanan untuknya, seperti yang dilakukan oleh banyak komputer riba, jadi Alt Kanan dan Ctrl Kanan bukan pengubah suai biasa di sana; imlak ditogol dengan Alt + Space sebaliknya. `Ctrl + Space` kekal tersedia untuk Tmux dan Herdr; `Shift + CapsLock` kekal sebagai kekunci karang.

Penunjuk papan kekunci muncul di sebelah kanan bar apabila anda mempunyai berbilang susun atur papan kekunci atau kaedah input. Klik padanya untuk menukar bahasa input; Jepun memaparkan あ untuk hiragana. Untuk pilihan aksara Jepun, tukar kepada Jepun, taip perkataan seperti `nihongo`, kemudian tekan Space dua kali. Tekan Enter untuk menerima pilihan anda. Jika anda juga mempunyai berbilang susun atur papan kekunci, klik kanan penunjuk untuk berkitar melaluinya.

Gunakan _Setup > Typing > Keyboard Layouts_ untuk memilih susun atur seperti Inggeris dan Perancis, daripada pilihan yang sama yang ditawarkan semasa pemasangan. Gunakan _Setup > Typing > Input Methods_ untuk memilih enjin gubahan mana yang aktif. Kedua-dua pemilih dibuka di dalam menu Omarchy dengan pilihan semasa anda ditanda. Klik atau tekan Enter untuk menogol pilihan; setiap perubahan digunakan serta-merta. Menyahpilih kaedah input mengeluarkannya daripada kitaran tanpa menyahpasangnya; papan kekunci kekal tersedia.

Jalankan `omarchy setup keyboard` atau `omarchy setup input` untuk membuka pemilih yang sama. Untuk menambah satu bahasa daripada baris perintah, gunakan `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, atau `cangjie5`. Quick, Boshiamy, dan Array datang dalam pakej yang sama dengan Cangjie dan muncul dalam pemilih Input Methods. Kekunci penukaran tersuai anda dikekalkan. Untuk susun atur atau kekunci enjin alternatif, pasang `fcitx5-configtool` dengan `omarchy pkg add fcitx5-configtool` dan lancarkannya daripada terminal. Memilih bahasa input tidak menukar bahasa desktop. Memilih Jepun, Korea, atau Cina di bawah _Setup > Language_ menambah kaedah inputnya apabila anda belum mempunyainya lagi.

Gunakan `Super + I` untuk berkitar melalui kaedah input atau susun atur papan kekunci, dan `Super + Shift + I` untuk kembali ke arah bertentangan, jadi dengan tiga yang dikonfigurasi anda boleh bergerak antara dua jiran. Penunjuk input muncul di sebelah kanan bar hanya apabila lebih daripada satu kaedah input atau susun atur dikonfigurasi. Ikatan desktop ini berfungsi bersama kekunci penukaran Fcitx sedia ada anda; anda boleh mengatasinya dalam `~/.config/hypr/bindings.lua`. Enjin input dan jujukan karang menggunakan perkhidmatan [Fcitx5](https://fcitx-im.org/) yang sudah berjalan dalam setiap sesi.

### Gunakan ALT sebagai SUPER

Pada sesetengah papan kekunci, tidak mudah untuk menggunakan kekunci meta utama (kekunci Windows/cmd) sebagai SUPER. Anda boleh menukar ini kepada ALT sebaliknya menggunakan perubahan ini:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
