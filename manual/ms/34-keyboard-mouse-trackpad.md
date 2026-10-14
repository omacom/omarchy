# Papan Kekunci, Tetikus, Pad Jejak

Hyprland membolehkan anda mengkonfigurasi semua input anda dengan terperinci. Anda boleh menjadikan ulangan papan kekunci sangat pantas atau menjadikan pad sentuh menggunakan penatalan semula jadi. Anda mengubah semuanya dalam `~/.config/hypr/input.lua`, yang juga boleh anda capai melalui _Persediaan > Input_ dalam menu Omarchy (`Super + Space`). Apa-apa yang anda tetapkan di sana menggantikan lalai Omarchy.

Berikut ialah contoh:

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

Anda boleh [melihat semua pilihan input](https://wiki.hypr.land/Configuring/Basics/Variables/#input) di wiki Hyprland untuk input.

CapsLock berfungsi sebagai Caps Lock biasa, dan `Shift + CapsLock` ialah kekunci compose untuk [emoji pantas](07-hotkeys.md#quick-emojis) dan [pelengkapan lain](07-hotkeys.md#quick-completions). Jika anda lebih suka kekunci compose di tempat lain, gantikan `omarchy:shift_caps_compose` dalam `kb_options`. Contohnya, ini memindahkan kekunci compose ke Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gerak isyarat pad sentuh

Anda juga boleh menghidupkan [gerak isyarat pad sentuh](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), seperti leret dengan tiga jari untuk menukar ruang kerja:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Pada komputer riba Dell XPS dengan pad sentuh haptik, anda juga boleh menetapkan kekuatan klik kepada rendah, sederhana, atau tinggi di bawah _Pencetus > Perkakasan > Haptik Pad Sentuh_.

### Menaip dalam bahasa Cina, Jepun, dan bahasa lain

Pilih Jepun, Korea, Cina (Permudah, Pinyin), atau Cina (Tradisional, Zhuyin) apabila pemasang meminta papan kekunci anda. Omarchy mengkonfigurasi papan kekunci dan enjin input yang sepadan secara automatik, termasuk semasa persediaan but pertama di luar talian. Jepun menggunakan Mozc, Korea menggunakan Hangul dua set standard, Cina Permudah menggunakan Pinyin, dan Cina Tradisional menggunakan susunan Zhuyin standard Chewing. Japanese (US keyboard) menyediakan Mozc dengan susun atur papan kekunci US.

Penaipan bermula dalam mod Latin. Tekan `Super + I` untuk berkitar merentasi kaedah input yang dikonfigurasikan, dan `Super + Shift + I` untuk berkitar balik. Ketik `Shift` sendiri untuk keluar daripada kaedah input seperti Pinyin kepada huruf Latin, dan ketik sekali lagi untuk kembali, seperti cara Sogou, Microsoft Pinyin, dan macOS berfungsi; `Shift` tambah huruf masih menaip huruf besar. Pada papan kekunci Jepun, 全角/半角 menogol input, 変換 menghidupkannya, dan 無変換 mematikannya. Pada susun atur papan kekunci Korea, kekunci 한/영 dan 한자 khusus menukar Hangul dan menukar kepada Hanja. `Ctrl + Space` kekal tersedia untuk Tmux dan Herdr; `Shift + CapsLock` kekal sebagai kekunci compose.

Penunjuk papan kekunci muncul di sebelah kanan bar apabila anda mempunyai berbilang susun atur papan kekunci atau kaedah input. Klik untuk menukar bahasa input; bahasa Jepun memaparkan あ untuk hiragana. Untuk pilihan aksara Jepun, tukar kepada Jepun, taip perkataan seperti `nihongo`, kemudian tekan Space dua kali. Tekan Enter untuk menerima pilihan anda. Jika anda juga mempunyai berbilang susun atur papan kekunci, klik kanan penunjuk untuk berkitar untuk susun atur itu.

Gunakan _Persediaan > Penaipan > Susun Atur Papan Kekunci_ untuk memilih susun atur seperti Bahasa Inggeris dan Bahasa Perancis, daripada pilihan yang sama yang ditawarkan semasa pemasangan. Gunakan _Persediaan > Penaipan > Kaedah Input_ untuk memilih enjin karangan mana yang aktif. Kedua-dua pemilih dibuka di dalam menu Omarchy dengan pilihan semasa anda ditandakan. Klik atau tekan Enter untuk menogol pilihan; setiap perubahan berkuat kuasa serta-merta. Menyahpilih kaedah input membuangnya daripada kitaran tanpa menyahpasangnya; papan kekunci kekal tersedia.

Jalankan `omarchy setup keyboard` atau `omarchy setup input` untuk membuka pemilih yang sama. Untuk menambah satu bahasa daripada baris perintah, gunakan `omarchy setup input mozc`, `hangul`, `pinyin`, atau `chewing`. Kekunci pertukaran tersuai anda dikekalkan. Untuk susun atur enjin alternatif atau kekunci, pasang `fcitx5-configtool` dengan `omarchy pkg add fcitx5-configtool` dan lancarkannya daripada terminal. Memilih bahasa input tidak mengubah bahasa desktop.

Gunakan `Super + I` untuk berkitar merentasi kaedah input atau susun atur papan kekunci, dan `Super + Shift + I` untuk ke arah lain, jadi dengan tiga dikonfigurasikan anda boleh bergerak antara dua jiran. Penunjuk input muncul di sebelah kanan bar hanya apabila lebih daripada satu kaedah input atau susun atur dikonfigurasikan. Ikatan desktop ini berfungsi seiring dengan kekunci pertukaran Fcitx sedia ada anda; anda boleh mengatasinya dalam `~/.config/hypr/bindings.lua`. Enjin input dan jujukan compose menggunakan perkhidmatan [Fcitx5](https://fcitx-im.org/) yang sudah berjalan dalam setiap sesi.

### Gunakan ALT sebagai SUPER

Pada sesetengah papan kekunci, tidak mudah untuk menggunakan kekunci meta utama (kekunci Windows/cmd) sebagai SUPER. Anda boleh mengubahnya menjadi ALT sebaliknya menggunakan perubahan ini:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
