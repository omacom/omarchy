# Papan Kekunci, Tetikus, Pad Jejak

Hyprland membolehkan anda mengkonfigurasi semua input anda dengan sangat terperinci. Anda boleh menjadikan ulangan papan kekunci sepantas supersonik atau membuat pad jejak menggunakan penatalan semula jadi. Anda mengubah semuanya dalam `~/.config/hypr/input.lua`, yang juga boleh dicapai melalui _Setup > Input_ dalam menu Omarchy (`Super + Space`). Apa-apa sahaja yang anda tetapkan di sana menggantikan tetapan lalai Omarchy.

Berikut ialah contohnya:

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

Anda boleh [lihat semua pilihan input](https://wiki.hypr.land/Configuring/Basics/Variables/#input) di wiki Hyprland untuk input.

CapsLock berfungsi sebagai Caps Lock biasa, dan `Shift + CapsLock` ialah kekunci compose untuk [emoji pantas](07-hotkeys.md#quick-emojis) dan [pelengkapan lain](07-hotkeys.md#quick-completions). Jika anda lebih suka kekunci compose di tempat lain, gantikan `omarchy:shift_caps_compose` dalam `kb_options`. Sebagai contoh, ini memindahkan kekunci compose ke Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gerak isyarat pad jejak

Anda juga boleh menghidupkan [gerak isyarat pad sentuh](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), seperti meleret dengan tiga jari untuk menukar ruang kerja:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Pada komputer riba Dell XPS dengan pad sentuh haptik, anda juga boleh menetapkan kekuatan klik kepada rendah, sederhana, atau tinggi di bawah _Trigger > Hardware > Touchpad Haptics_.

### Menaip dalam Bahasa Cina, Jepun, dan bahasa lain

Pilih Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), atau Hong Kong (Cangjie) apabila pemasang meminta papan kekunci anda. Omarchy mengkonfigurasi papan kekunci dan enjin input yang sepadan secara automatik, termasuk semasa persediaan but pertama luar talian. Japanese menggunakan Mozc, Korean menggunakan Hangul dua set standard, Simplified Chinese menggunakan Pinyin, Taiwan menggunakan susunan Zhuyin standard Chewing, dan Hong Kong menggunakan Cangjie dengan bentuk aksara Hong Kong. Japanese (US keyboard) menyediakan Mozc dengan susun atur papan kekunci US. Kekunci Hangul, Zhuyin, dan Cangjie kekal pada kedudukan standardnya walaupun anda menaip huruf Latin dengan Dvorak, Colemak, atau AZERTY. Jika anda telah menambah Hangul atau Chewing sebelum ini, nyahpilih dan pilih semula di bawah _Setup > Typing > Input Methods_ untuk memindahkan kekuncinya ke sana; Omarchy membiarkan enjin yang sudah anda gunakan untuk menaip begitu sahaja.

Menaip bermula dalam mod Latin. Tekan `Super + I` untuk mengitar kaedah input yang dikonfigurasi, dan `Super + Shift + I` untuk mengitar kembali. Ketik `Shift` bersendirian untuk keluar daripada kaedah input seperti Pinyin kepada huruf Latin, dan ketik sekali lagi untuk kembali, seperti cara Sogou, Microsoft Pinyin, dan macOS berfungsi; `Shift` campur huruf masih menaip huruf besar. Pada papan kekunci Jepun, 全角/半角 menogol input, 変換 menghidupkannya, dan 無変換 mematikannya. Dengan Korean, 한/영 menukar Hangul dan 한자 menukar kepada Hanja, sama ada papan kekunci anda mempunyai kekunci khusus atau menghantar Right Alt dan Right Ctrl untuknya, seperti yang dilakukan oleh banyak komputer riba, jadi Right Alt dan Right Ctrl bukan pengubah suai biasa di sana; tekan-untuk-cakap imlak kekal pada F9. `Ctrl + Space` kekal tersedia untuk Tmux dan Herdr; `Shift + CapsLock` kekal sebagai kekunci compose.

Penunjuk papan kekunci muncul di sebelah kanan bar apabila anda mempunyai berbilang susun atur papan kekunci atau kaedah input. Klik penunjuk itu untuk menukar bahasa input; Japanese memaparkan あ untuk hiragana. Untuk pilihan aksara Jepun, tukar kepada Japanese, taip perkataan seperti `nihongo`, kemudian tekan Space dua kali. Tekan Enter untuk menerima pilihan anda. Jika anda juga mempunyai berbilang susun atur papan kekunci, klik kanan penunjuk untuk mengitar susun atur tersebut.

Gunakan _Setup > Typing > Keyboard Layouts_ untuk memilih susun atur seperti English dan French, daripada pilihan sama yang ditawarkan semasa pemasangan. Gunakan _Setup > Typing > Input Methods_ untuk memilih enjin gubahan yang aktif. Kedua-dua pemilih dibuka di dalam menu Omarchy dengan pilihan semasa anda ditanda. Klik atau tekan Enter untuk menogol pilihan; setiap perubahan berkuat kuasa serta-merta. Menyahpilih kaedah input mengalih keluarnya daripada kitaran tanpa menyahpasangnya; papan kekunci kekal tersedia.

Jalankan `omarchy setup keyboard` atau `omarchy setup input` untuk membuka pemilih yang sama. Untuk menambah satu bahasa daripada baris perintah, gunakan `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, atau `cangjie5`. Quick, Boshiamy, dan Array disertakan dalam pakej yang sama dengan Cangjie dan muncul dalam pemilih Input Methods. Kekunci penukaran tersuai anda dikekalkan. Untuk susun atur atau kekunci enjin alternatif, pasang `fcitx5-configtool` dengan `omarchy pkg add fcitx5-configtool` dan lancarkannya dari terminal. Memilih bahasa input tidak mengubah bahasa desktop. Memilih Japanese, Korean, atau Chinese di bawah _Setup > Language_ menambah kaedah inputnya apabila anda belum mempunyai sebarang kaedah input.

Gunakan `Super + I` untuk mengitar kaedah input atau susun atur papan kekunci, dan `Super + Shift + I` untuk kembali ke arah bertentangan, jadi dengan tiga yang dikonfigurasi anda boleh bergerak antara dua jiran. Penunjuk input muncul di sebelah kanan bar hanya apabila lebih daripada satu kaedah input atau susun atur dikonfigurasi. Ikatan desktop ini berfungsi bersama kekunci penukaran Fcitx sedia ada anda; anda boleh menggantikannya dalam `~/.config/hypr/bindings.lua`. Enjin input dan jujukan compose menggunakan perkhidmatan [Fcitx5](https://fcitx-im.org/) yang sudah berjalan dalam setiap sesi.

### Gunakan ALT sebagai SUPER

Pada sesetengah papan kekunci, tidak mudah untuk menggunakan kekunci meta utama (kekunci Windows/cmd) sebagai SUPER. Anda boleh mengubahnya kepada ALT sebaliknya menggunakan perubahan ini:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
