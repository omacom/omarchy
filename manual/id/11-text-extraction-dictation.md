# Ekstraksi Teks & Dikte

### Ekstraksi Teks

Tekan `Super + Ctrl + PrtScr` untuk memilih wilayah di layar untuk ekstraksi teks. Model OCR open source tesseract kemudian akan dengan cepat mengubah pilihan tersebut menjadi teks dan menempatkannya di clipboard. Lalu Anda cukup menekan `Super + V` untuk menempel.

Ini sangat membantu untuk mengambil alamat dari footer gambar atau nomor telepon yang tertanam di headline situs web.

 ![text-extraction](images/text-extraction.webp)

### Dikte

Pada instalasi baru, [Superwhisper](https://superwhisper.com/) adalah backend dikte default, yang menggunakan pemrosesan cloud tanpa unduhan model offline. Pilih Superwhisper atau [Voxtype](https://voxtype.io/) melalui _Setup > Defaults > Dictation_ di menu Omarchy. Memilih backend akan menginstalnya jika diperlukan dan menjadikannya default untuk dikte. Voxtype memuat model bahasa Inggris dasar yang memakan ruang 150MB; ubah model dengan `voxtype setup model` dan pengaturan lainnya melalui `~/.config/voxtype/config.toml`. Superwhisper membuka pengaturannya untuk memilih pemrosesan cloud atau lokal, dan OPR menjaga aplikasi tetap diperbarui.

Anda mendikte dengan menahan `Right Alt`, atau dengan mengaktifkan/menonaktifkannya dengan `Alt + Space`, dan teks yang didiktekan akan muncul di area input yang sedang fokus. Pintasan ini menggunakan backend yang dipilih. Right Alt juga memulai dikte ketika digunakan dalam kombinasi modifier; gunakan Left Alt untuk kombinasi tersebut. Pada tata letak keyboard di mana Right Alt adalah AltGr, gunakan `Alt + Space` agar AltGr tetap tersedia untuk mengetik. Instalasi dari sebelum Alt + Space menjadi default tetap mempertahankan `F9` untuk push-to-talk dan `Super + Ctrl + X` untuk mengaktifkan/menonaktifkan, yang ditambahkan ke `~/.config/hypr/bindings.lua`; hapus di sana untuk mengembalikan tombol-tombol tersebut ke aplikasi.

Pintasan yang sama berfungsi dengan backend mana pun. Pilih backend Anda melalui Setup > Defaults > Dictation. Penginstal backend mengonfigurasinya dan menyimpan pilihan tersebut. Jalankan `omarchy default dictation` untuk melihat mana yang dipilih. Pilihan tersebut disimpan di `~/.config/omarchy/defaults/dictation`. Instalasi baru memilih Superwhisper secara otomatis.

Omarchy memuat integrasi desktop backend yang dipilih secara otomatis. Tidak diperlukan konfigurasi Superwhisper di `~/.config/hypr/`.

Binding dan skrip kustom dapat menggunakan `omarchy dictation start`, `omarchy dictation stop`, dan `omarchy dictation toggle`. Backend yang dipilih menangani perekaman dan transkripsi. Memilih Superwhisper menonaktifkan pintasan tahan bawaannya dan mengatur pengalih bawaan menjadi `Ctrl + Alt + Space`, sehingga tetap terpisah dari tombol perekaman Omarchy. Superwhisper memerlukan setidaknya satu pintasan perekaman bawaan, dan pintasan pembatalannya tetap tersedia.

Backend tambahan dapat terintegrasi tanpa mengubah Omarchy. Sediakan executable bernama `omarchy-dictation-<backend>` di PATH yang menerima `start`, `stop`, dan `toggle` dan segera kembali, dengan status bukan nol saat gagal. Penginstalnya mengonfigurasi provider dan memanggil `omarchy-dictation-use <backend>` setelah penyiapan berhasil. Ini menghentikan backend sebelumnya dan menyimpan pilihan secara atomik; `stop` harus berhasil ketika provider sedang idle atau tidak tersedia. Nama backend menggunakan huruf kecil, digit, dan tanda hubung. Sediakan `omarchy-install-dictation-<backend>` untuk penyiapan; `omarchy default dictation <backend>` meluncurkannya. Tambahkan entri menu Defaults melalui ekstensi menu Omarchy untuk memanggil pemilih tersebut. Integrasi desktop opsional dapat berada di `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
