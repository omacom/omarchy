# Pengekstrakan Teks & Dikte

### Pengekstrakan Teks

Tekan `Super + Ctrl + PrtScr` untuk memilih kawasan pada skrin bagi pengekstrakan teks. Model OCR sumber terbuka tesseract kemudiannya akan menukar pilihan itu menjadi teks dengan cepat dan meletakkannya pada papan keratan. Kemudian anda hanya perlu tekan `Super + V` untuk menampal.

Ini sangat membantu untuk mengambil alamat daripada pengaki imej atau nombor telefon yang terbenam dalam tajuk utama laman web.

 ![text-extraction](images/text-extraction.webp)

### Dikte

Pada pemasangan baharu, [Superwhisper](https://superwhisper.com/) ialah backend dikte lalai, yang menggunakan pemprosesan awan tanpa muat turun model luar talian. Pilih Superwhisper, [Voxtype](https://voxtype.io/), atau [Hex](https://anoma.ly/hex/) melalui _Setup > Defaults > Dictation_ dalam menu Omarchy. Memilih backend akan memasangnya jika perlu dan menjadikannya lalai untuk dikte. Voxtype memuatkan model asas bahasa Inggeris yang mengambil ruang 150MB; tukar model dengan `voxtype setup model` dan tetapan lain melalui `~/.config/voxtype/config.toml`. Superwhisper membuka tetapannya untuk memilih pemprosesan awan atau setempat, dan OPR memastikan aplikasi itu sentiasa dikemas kini. Hex memuat turun model pertuturan pada perantinya semasa persediaan dan berjalan sebagai perkhidmatan pengguna `hex.service`; buka tetingkapnya daripada ikon dulang bar atau dengan menjalankan `hex` untuk menukar model dan tetapan lain.

Anda mendikte dengan menahan `Right Alt`, atau dengan menogol menggunakan `Alt + Space`, dan teks yang didikte akan muncul di kawasan input yang difokuskan. Pintasan ini menggunakan backend yang dipilih. Right Alt juga memulakan dikte apabila digunakan dalam kord pengubah; gunakan Left Alt untuk kord tersebut. Pada susun atur papan kekunci yang Right Alt ialah AltGr, termasuk apabila susun atur sebegitu ialah susun atur yang anda beralih kepadanya, tahan kekunci itu bersendirian seketika untuk mendikte; AltGr yang ditekan bersama kekunci lain masih menaip aksaranya. Pemasangan dari sebelum Alt + Space menjadi lalai mengekalkan `F9` untuk tekan-untuk-cakap dan `Super + Ctrl + X` untuk menogol, yang ditambahkan pada `~/.config/hypr/bindings.lua`, di mana `Super + Ctrl + X` itu mengambil tempat panel ejen; alih keluar kedua-duanya di sana untuk mengembalikan kekunci tersebut kepada aplikasi dan panel.

Pintasan yang sama berfungsi dengan setiap backend. Pilih backend anda melalui Setup > Defaults > Dictation. Pemasang backend mengkonfigurasikannya dan menyimpan pilihan tersebut. Jalankan `omarchy default dictation` untuk melihat backend yang mana satu dipilih. Pilihan itu disimpan dalam `~/.config/omarchy/defaults/dictation`. Pemasangan baharu memilih Superwhisper secara automatik.

Omarchy memuatkan integrasi desktop backend yang dipilih secara automatik. Tiada konfigurasi Superwhisper diperlukan dalam `~/.config/hypr/`.

Ikatan tersuai dan skrip boleh menggunakan `omarchy dictation start`, `omarchy dictation stop`, dan `omarchy dictation toggle`. Backend yang dipilih mengendalikan rakaman dan transkripsi. Memilih Superwhisper melumpuhkan pintasan tahan aslinya dan menetapkan togol aslinya kepada `Ctrl + Alt + Space`, memastikannya berasingan daripada kekunci rakaman Omarchy. Superwhisper memerlukan sekurang-kurangnya satu pintasan rakaman asli, dan pintasan pembatalannya kekal tersedia.

Backend tambahan boleh berintegrasi tanpa mengubah Omarchy. Sediakan fail boleh laksana bernama `omarchy-dictation-<backend>` pada PATH yang menerima `start`, `stop`, dan `toggle` dan kembali dengan segera, dengan status bukan sifar apabila gagal. Pemasangnya mengkonfigurasikan penyedia dan memanggil `omarchy-dictation-use <backend>` selepas persediaan berjaya. Ini menghentikan backend sebelumnya dan menyimpan pilihan secara atomik; `stop` mesti berjaya apabila penyedia melahu atau tidak tersedia. Nama backend menggunakan huruf kecil, digit, dan sempang. Sediakan `omarchy-install-dictation-<backend>` untuk persediaan; `omarchy default dictation <backend>` melancarkannya. Tambahkan entri menu Defaults melalui sambungan menu Omarchy untuk memanggil pemilih tersebut. Integrasi desktop pilihan boleh berada dalam `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
