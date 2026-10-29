# Terminal

[Foot](https://codeberg.org/dnkl/foot) adalah terminal bawaan untuk Omarchy. Ia cepat, ringan, dan kompatibel bahkan dengan komputer lama. Namun, ia tidak mendukung tab atau pemisahan asli.

Jika Anda menggunakan Tmux, Anda mungkin tidak keberatan, tetapi jika tidak, kami sepenuhnya mendukung _Alacritty_, _Ghostty_, dan _Kitty_ sebagai opsi juga. Pilih preferensi Anda di bawah _Pasang > Terminal_ dalam menu Omarchy.

Anda memulai terminal baru menggunakan `Super + Return`. (Binding ini akan secara otomatis menunjuk ke Terminal mana pun yang telah Anda pasang melalui _Pasang > Terminal_, dan Anda dapat beralih di antara terminal yang dipasang di bawah _Pengaturan > Bawaan > Terminal_.)

## Tmux

Tmux menyediakan antarmuka yang konsisten dan dapat diprogram untuk pane, jendela (alias tab), dan sesi yang dapat dilanjutkan terlepas dari terminal Anda. Ia bahkan bekerja pada host jarak jauh, sehingga ketika Anda melakukan SSH ke server, Anda dapat menggunakan pendekatan yang sama.

Anda memulai sesi Tmux baru di terminal baru menggunakan `Super + Alt + Return`, dan karena Tmux adalah proses yang persisten, Anda dapat melanjutkan sesi Anda bahkan jika Anda menutup terminal itu. Cukup tekan `Ctrl + Space` (disebut tombol awalan) lalu `s` untuk melihat semua sesi aktif Anda.

Omarchy dikirim dengan konfigurasi Tmux yang dioptimalkan secara ergonomis, yang memiliki banyak keybinding untuk dipelajari, jadi simpan [lembar contekan](07-hotkeys.md#tmux) di dekat Anda.

## Fungsi tata letak Tmux

Karena Tmux dapat diprogram, kita dapat menggunakan fungsi untuk membuat tata letak. Omarchy dikirim dengan empat fungsi berbeda untuk tata letak pengembang umum.

`tdl [agent]` memulai antarmuka seperti IDE tiga arah dengan `$EDITOR` di sebelah kiri, agen AI pilihan Anda di sebelah kanan (seperti `c` untuk opencode atau `cx` untuk Claude atau `codex` untuk OpenAI), dan kemudian terminal di bagian bawah.

Jadi `tdl c` akan memulai ini (atau hanya `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Anda juga dapat memulai agen kedua dengan `tdl c cx` (opencode + claude) (atau hanya `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Ada juga `tds`, yang memulai persegi empat arah dengan editor kiri atas, pemantau diff langsung kanan atas, terminal kiri bawah, dan opencode kanan bawah.

Anda juga dapat memulai konfigurasi tata letak ini untuk setiap subdirektori dalam direktori saat ini menggunakan `tdlm [agent]`, lalu menavigasi menggunakan `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Terakhir, Anda dapat memulai kawanan agen menggunakan `tsl [panes] [command]`. Jadi `tsl 4 c` akan memberi Anda kisi empat arah agen opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
