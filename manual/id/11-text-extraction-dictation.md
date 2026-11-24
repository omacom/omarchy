# Ekstraksi Teks & Dikte

### Ekstraksi Teks

Tekan `Super + Ctrl + PrtScr` untuk memilih area di layar untuk ekstraksi teks. Model OCR open source tesseract kemudian akan dengan cepat mengubah pilihan tersebut menjadi teks dan menempatkannya di clipboard. Kemudian Anda cukup menekan `Super + V` untuk menempel.

Ini sangat membantu untuk mengambil alamat dari footer gambar atau nomor telepon yang tertanam di headline website.

 ![text-extraction](images/text-extraction.webp)

### Dikte

Pada instalasi baru, [Superwhisper](https://superwhisper.com/) adalah backend dikte default, menggunakan pemrosesan cloud tanpa unduhan model offline. Pilih Superwhisper, [Voxtype](https://voxtype.io/), atau [Hex](https://anoma.ly/hex/) melalui _Setup > Defaults > Dictation_ di menu Omarchy. Memilih backend akan menginstalnya jika diperlukan dan menjadikannya default untuk dikte. Voxtype memuat model bahasa Inggris dasar yang memakan ruang 150MB; ubah model dengan `voxtype setup model` dan pengaturan lainnya melalui `~/.config/voxtype/config.toml`. Superwhisper membuka pengaturannya untuk memilih pemrosesan cloud atau lokal, dan OPR menjaga aplikasi tetap diperbarui. Hex mengunduh model ucapannya yang berjalan di perangkat selama setup dan berjalan sebagai layanan pengguna `hex.service`; buka jendelanya dari ikon tray di bar atau dengan menjalankan `hex` untuk mengubah model dan pengaturan lainnya.

Anda mendikte dengan menahan `Right Alt`, atau dengan mengalihkannya menggunakan `Alt + Space`, dan teks yang didiktekan akan muncul di area input yang sedang fokus. Pintasan ini menggunakan backend yang dipilih. Right Alt juga memulai dikte saat digunakan dalam kombinasi modifier; gunakan Left Alt untuk kombinasi tersebut. Pada layout keyboard yang Right Alt-nya adalah AltGr, termasuk saat layout seperti itu adalah salah satu layout yang Anda alihkan untuk digunakan, tahan tombol tersebut sendiri sejenak untuk mendikte; AltGr yang ditekan bersamaan dengan tombol lain tetap mengetikkan karakternya. Instalasi dari sebelum `Alt + Space` menjadi default tetap mempertahankan `F9` untuk push-to-talk dan `Super + Ctrl + X` untuk mengalihkan, yang ditambahkan ke `~/.config/hypr/bindings.lua`, di mana `Super + Ctrl + X` tersebut menggantikan panel agen; hapus di sana untuk mengembalikan tombol-tombol tersebut ke aplikasi dan panel.

Pintasan yang sama berfungsi dengan setiap backend. Pilih backend Anda melalui Setup > Defaults > Dictation. Installer backend mengonfigurasinya dan menyimpan pilihan tersebut. Jalankan `omarchy default dictation` untuk melihat mana yang dipilih. Pilihan tersebut disimpan di `~/.config/omarchy/defaults/dictation`. Instalasi baru memilih Superwhisper secara otomatis.

Omarchy memuat integrasi desktop backend yang dipilih secara otomatis. Tidak diperlukan konfigurasi Superwhisper di `~/.config/hypr/`.

Binding dan skrip kustom dapat menggunakan `omarchy dictation start`, `omarchy dictation stop`, dan `omarchy dictation toggle`. Backend yang dipilih menangani perekaman dan transkripsi. Memilih Superwhisper menonaktifkan pintasan tahan bawaannya dan mengatur pengalih bawaan­nya ke `Ctrl + Alt + Space`, sehingga tetap terpisah dari tombol perekaman Omarchy. Superwhisper memerlukan setidaknya satu pintasan perekaman bawaan, dan pintasan pembatalannya tetap tersedia.

Backend tambahan dapat terintegrasi tanpa mengubah Omarchy. Sediakan file yang dapat dieksekusi bernama `omarchy-dictation-<backend>` di PATH yang menerima `start`, `stop`, dan `toggle` dan segera kembali, dengan status bukan nol saat gagal. Installernya mengonfigurasi penyedia dan memanggil `omarchy-dictation-use <backend>` setelah setup berhasil. Ini menghentikan backend sebelumnya dan menyimpan pilihan secara atomik; `stop` harus berhasil saat penyedia sedang tidak aktif atau tidak tersedia. Nama backend menggunakan huruf kecil, angka, dan tanda hubung. Sediakan `omarchy-install-dictation-<backend>` untuk setup; `omarchy default dictation <backend>` meluncurkannya. Tambahkan entri menu Defaults melalui ekstensi menu Omarchy untuk memanggil pemilih tersebut. Integrasi desktop opsional dapat ditempatkan di `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
