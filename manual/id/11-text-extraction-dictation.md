# Ekstraksi Teks & Dikte

### Ekstraksi Teks

Tekan `Super + Ctrl + PrtScr` untuk memilih wilayah di layar untuk ekstraksi teks. Model OCR sumber terbuka tesseract kemudian akan dengan cepat mengonversi pilihan itu menjadi teks dan menempatkannya di papan klip. Kemudian Anda hanya perlu menekan `Super + V` untuk menempel.

Ini sangat membantu untuk mengambil alamat dari kaki gambar atau nomor telepon yang tertanam dalam judul situs web.

 ![text-extraction](images/text-extraction.webp)

### Dikte

Pada pemasangan baru, [Superwhisper](https://superwhisper.com/) adalah backend dikte bawaan, menggunakan pemrosesan awan tanpa pengunduhan model luring. Pilih Superwhisper atau [Voxtype](https://voxtype.io/) melalui _Pengaturan > Bawaan > Dikte_ dalam menu Omarchy. Memilih backend memasangnya jika diperlukan dan menjadikannya bawaan untuk dikte. Voxtype memuat model dasar bahasa Inggris yang berukuran 150MB; ubah model dengan `voxtype setup model` dan pengaturan lain melalui `~/.config/voxtype/config.toml`. Superwhisper membuka pengaturannya untuk memilih pemrosesan awan atau lokal, dan OPR menjaga aplikasi tetap diperbarui.

Anda mendikte dengan menahan `Right Alt` atau `F9`, atau dengan mengalihkan dengan `Super + Ctrl + X`, dan teks yang didiktekan akan muncul di area masukan yang fokus. Pintasan ini menggunakan backend terpilih. Right Alt juga memulai dikte ketika digunakan dalam akor modifier; gunakan Left Alt untuk akor tersebut. Pada tata letak keyboard di mana Right Alt adalah AltGr, gunakan `F9` untuk menjaga AltGr tetap tersedia untuk mengetik.

Pintasan yang sama berfungsi dengan kedua backend. Pilih backend Anda melalui Pengaturan > Bawaan > Dikte. Pemasang backend mengkonfigurasinya dan menyimpan pilihan. Jalankan `omarchy default dictation` untuk melihat mana yang dipilih. Pilihan disimpan dalam `~/.config/omarchy/defaults/dictation`. Pemasangan baru memilih Superwhisper secara otomatis.

Omarchy memuat integrasi desktop backend terpilih secara otomatis. Tidak ada konfigurasi Superwhisper yang diperlukan dalam `~/.config/hypr/`.

Binding dan skrip kustom dapat menggunakan `omarchy dictation start`, `omarchy dictation stop`, dan `omarchy dictation toggle`. Backend terpilih menangani perekaman dan transkripsi. Memilih Superwhisper menonaktifkan pintasan tahan aslinya dan mengatur alih asli ke `Alt + Space`, menjaganya tetap terpisah dari tombol perekaman Omarchy. Superwhisper memerlukan setidaknya satu pintasan perekaman asli, dan pintasan pembatalannya tetap tersedia.

Backend tambahan dapat terintegrasi tanpa mengubah Omarchy. Sediakan berkas yang dapat dieksekusi bernama `omarchy-dictation-<backend>` pada PATH yang menerima `start`, `stop`, dan `toggle` dan kembali dengan segera, dengan status bukan nol pada kegagalan. Pemasangnya mengkonfigurasi penyedia dan memanggil `omarchy-dictation-use <backend>` setelah penyiapan berhasil. Ini menghentikan backend sebelumnya dan menyimpan pilihan secara atomik; `stop` harus berhasil ketika penyedia menganggur atau tidak tersedia. Nama backend menggunakan huruf kecil, digit, dan tanda hubung. Sediakan `omarchy-install-dictation-<backend>` untuk penyiapan; `omarchy default dictation <backend>` meluncurkannya. Tambahkan entri menu Bawaan melalui ekstensi menu Omarchy untuk memanggil pemilih itu. Integrasi desktop opsional dapat tinggal dalam `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
