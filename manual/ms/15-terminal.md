# Terminal

[Foot](https://codeberg.org/dnkl/foot) ialah terminal lalai untuk Omarchy. Ia pantas, ringan, dan serasi walaupun dengan komputer lama. Walau bagaimanapun, ia tidak menyokong tab atau pisahan asal.

Jika anda menggunakan Tmux, anda mungkin tidak kisah, tetapi jika tidak, kami menyokong sepenuhnya _Alacritty_, _Ghostty_, dan _Kitty_ sebagai pilihan juga. Pilih keutamaan anda di bawah _Pasang > Terminal_ dalam menu Omarchy.

Anda memulakan terminal baharu menggunakan `Super + Return`. (Ikatan ini secara automatik akan menuding kepada mana-mana Terminal yang telah anda Pasang melalui _Pasang > Terminal_, dan anda boleh bertukar antara terminal yang dipasang di bawah _Persediaan > Lalai > Terminal_.)

## Tmux

Tmux menyediakan antara muka yang konsisten dan boleh diprogramkan untuk anak tetingkap, tetingkap (aka tab), dan sesi yang boleh disambung semula tanpa mengira terminal anda. Ia malah berfungsi pada hos jauh, jadi apabila anda melakukan SSH ke pelayan, anda boleh menggunakan pendekatan yang sama.

Anda memulakan sesi Tmux baharu dalam terminal baharu menggunakan `Super + Alt + Return`, dan kerana Tmux ialah proses yang berterusan, anda boleh menyambung semula sesi anda walaupun anda menutup terminal itu. Hanya tekan `Ctrl + Space` (dipanggil kekunci awalan) kemudian `s` untuk melihat semua sesi aktif anda.

Omarchy dihantar dengan konfigurasi Tmux yang dioptimumkan secara ergonomik, yang mempunyai banyak Ikatan Kekunci untuk dipelajari, jadi kekalkan [helaian tipu berguna](07-hotkeys.md#tmux).

## Fungsi susun atur Tmux

Kerana Tmux boleh diprogramkan, kita boleh menggunakan fungsi untuk mencipta susun atur. Omarchy dihantar dengan empat fungsi berbeza untuk susun atur pembangun biasa.

`tdl [agent]` memulakan antara muka seperti IDE pisahan tiga hala dengan `$EDITOR` di sebelah kiri, Ejen AI pilihan anda di sebelah kanan (seperti `c` untuk opencode atau `cx` untuk Claude atau `codex` untuk OpenAI), dan kemudian terminal di bahagian bawah.

Jadi `tdl c` akan memulakan ini (atau hanya `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Anda juga boleh memulakan Ejen kedua dengan `tdl c cx` (opencode + claude) (atau hanya `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Terdapat juga `tds`, yang memulakan segi empat sama empat hala dengan penyunting di kiri atas, pemerhati perbezaan langsung di kanan atas, terminal di kiri bawah, dan opencode di kanan bawah.

Anda juga boleh memulakan konfigurasi susun atur ini untuk setiap subdirektori dalam direktori semasa menggunakan `tdlm [agent]`, kemudian menavigasi menggunakan `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Akhir sekali, anda boleh memulakan kawanan Ejen menggunakan `tsl [panes] [command]`. Jadi `tsl 4 c` akan memberi anda grid empat hala Ejen opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
