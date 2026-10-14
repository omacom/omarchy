# FAQ

### Bagaimana cara beralih antar tata letak keyboard?

Edit berkas `~/.config/hypr/input.lua` kamu dan tambahkan ini untuk beralih antar tata letak pada `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bilah akan otomatis menunjukkan tata letak keyboardmu saat ini begitu kamu memiliki beberapa tata letak yang dikonfigurasi (dan kamu bisa mengkliknya untuk beralih juga).

### Bagaimana cara mengubah format jam menjadi 12 jam?

Klik kanan jam di bilah untuk berputar melalui format umum, termasuk yang 12 jam. Kamu juga bisa mengatur format secara langsung:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ini akan menampilkan Sunday 10:55 AM.

### Bagaimana cara mengubah zona waktu saya?

Jalankan _Perbarui > Timezone_ di menu Omarchy dan pilih dari daftar. Jika zona waktunya benar tetapi jam itu sendiri telah bergeser, _Perbarui > Time_ memulai ulang sinkronisasi waktu untukmu.

### Bagaimana cara mengubah DNS saya, berbagi Wi-Fi saya, atau memeriksa kecepatan koneksi saya?

Semua itu ada di [jaringan](35-networking.md).

### Bagaimana cara memeriksa seberapa cepat disk saya?

_Pemicu > Uji Kecepatan > Uji Kecepatan Disk_ mengukur kecepatan baca dan tulis langsung pada drive kamu, atau `omarchy disk speedtest` dari terminal.

### Mengapa saya tidak bisa masuk ke akun Google saya di Chromium?

Build Chromium sumber terbuka biasa tidak dilengkapi dengan kredensial OAuth yang dibutuhkan Google untuk masuk akun. Jalankan _Pasang > Service > Chromium Account_ di menu Omarchy untuk menambahkannya, mulai ulang browser, dan proses masuk akan berhasil.

### Bagaimana cara menambahkan printer?

Pencetakan diatur dan berjalan sejak awal, dan kamu menambahkan setiap printer sendiri dari _Print Settings_ di peluncur aplikasi (`Super + Space`).

Pilih _Add_, dan beri waktu sejenak untuk mencari: printer yang terhubung melalui USB, dan sebagian besar printer jaringan, ditemukan untukmu. Jika milikmu tidak ada dalam daftar, pilih _Network Printer > Internet Printing Protocol (ipp)_ dan masukkan alamatnya — layar printer itu sendiri atau halaman web-nya akan memberitahumu apa itu, biasanya sesuatu seperti `192.168.1.50` dengan antrean `ipp/print`. _Forward_ lalu menawarkan driver, di mana printer modern bekerja paling baik pada profil _IPP Everywhere_ tanpa driver dan yang lebih lama menginginkan driver model itu sendiri.

Klik kanan printer dan pilih _Set as Default_ untuk memilih mana yang pertama kali dijangkau aplikasimu, dan _Properties_ untuk mengatur ukuran kertas, dupleks, dan kualitas.

Penemuan otomatis, di mana printer di jaringan muncul tanpa ditambahkan, untuk sementara dimatikan selagi dikerjakan ulang, itulah mengapa langkah pertama di atas adalah tugasmu alih-alih otomatis. Mencetak ke berkas PDF berfungsi tanpa printer apa pun.

### Bagaimana cara mengubah tempat tangkapan layar atau perekaman layar disimpan?

Tangkapan layar yang disimpan masuk ke `~/Pictures/Screenshots` secara bawaan. Untuk menggunakan direktori lain, tambahkan ini ke berkas di bawah `~/.config/uwsm/env.d/` (seperti `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Kamu bisa melakukan hal yang sama untuk perekaman layar menggunakan `OMARCHY_SCREENRECORD_DIR`.

Omasnap membuat direktori tangkapan layarnya secara otomatis. Buat direktori perekaman layar sendiri, lalu mulai ulang Omarchy agar salah satu perubahan lingkungan berlaku.

### Bagaimana cara membuat speaker + webcam berfungsi pada Apple Studio Display saya?

Kamu mungkin berpikir semuanya seharusnya berfungsi hanya dengan mencolokkan USB C, tetapi sayangnya tidak demikian. Solusi yang saya temukan untuk membuatnya berfungsi dengan andal adalah menggunakan [kabel WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Lalu speaker dan webcam berfungsi dengan sempurna.

Ingat bahwa kamu memiliki kontrol kecerahan bawaan di Omarchy untuk Apple Displays (baik Studio maupun XDR) menggunakan tombol kecerahan keyboard biasa.

### Bagaimana cara menyingkirkan semua perangkat lunak tambahan?

Jika kamu tidak menginginkan program seperti Obsidian atau LibreOffice atau hal-hal pra-pasang lainnya, kamu bisa menghapusnya dengan sangat mudah.

Jalankan _Hapus > Package_ untuk melihat setiap paket yang terpasang. Lalu kamu bisa memilih paket apa pun yang ingin kamu hapus dengan tab, dan mulai menghapus semua yang telah kamu pilih dengan return.

Dan kamu bisa menggunakan _Hapus > Web App_ dari menu Omarchy untuk menghapus aplikasi web pra-pasang apa pun yang tidak kamu inginkan.

Atau jalankan _Hapus > Preinstalls_ untuk menyapu semua tambahan pra-pasang — aplikasi web, TUI, dan aplikasi opsional — sekaligus. Hotkey yang meluncurkannya ikut hilang bersamanya, jadi kamu ditinggalkan dengan daftar binding yang bersih untuk diisi dengan milikmu sendiri di `~/.config/hypr/bindings.lua`.

---

Untuk kesalahan dan bagian yang rusak, lihat [bagian Pemecahan masalah](45-troubleshooting.md).
