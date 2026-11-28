# FAQ

### Bagaimana cara beralih antara tata letak keyboard?

Edit file `~/.config/hypr/input.lua` Anda dan tambahkan ini untuk beralih antara tata letak dengan `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bilah akan otomatis menampilkan tata letak keyboard Anda saat ini setelah Anda mengonfigurasi beberapa tata letak (dan Anda juga bisa mengekliknya untuk beralih).

### Bagaimana cara mengubah format jam ke 12-jam?

Klik kanan jam di bilah untuk bergantian melalui format yang umum, termasuk format 12-jam. Anda juga bisa mengatur formatnya langsung:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ini akan menampilkan Minggu 10:55 AM.

### Bagaimana cara mengubah zona waktu saya?

Jalankan _Setup > Region > Timezone_ di menu Omarchy dan pilih dari daftar. Jika zona waktunya sudah benar tetapi jamnya sendiri sudah bergeser, _Update > Time_ memulai ulang sinkronisasi waktu untuk Anda.

### Bagaimana cara mengubah DNS saya, membagikan Wi-Fi saya, atau memeriksa kecepatan koneksi saya?

Semua itu ada di [jaringan](35-networking.md).

### Bagaimana cara memeriksa seberapa cepat disk saya?

_Trigger > Speed Test > Disk Speed Test_ mengukur kecepatan baca dan tulis langsung di drive Anda, atau `omarchy disk speedtest` dari terminal.

### Bagaimana cara menambahkan printer?

Pencetakan sudah disiapkan dan berjalan sejak awal, dan Anda menambahkan setiap printer sendiri dari _Print Settings_ di peluncur aplikasi (`Super + Alt + Space`).

Pilih _Add_, dan beri waktu sejenak untuk mencari: printer yang terhubung melalui USB, dan sebagian besar printer jaringan, akan ditemukan untuk Anda. Jika printer Anda tidak ada dalam daftar, pilih _Network Printer > Internet Printing Protocol (ipp)_ dan masukkan alamatnya — layar printer itu sendiri atau halaman webnya akan memberi tahu Anda apa alamat itu, biasanya sesuatu seperti `192.168.1.50` dengan antrean `ipp/print`. _Forward_ kemudian menawarkan driver, di mana printer modern bekerja paling baik dengan profil tanpa driver _IPP Everywhere_ dan printer yang lebih lama memerlukan driver bawaan modelnya sendiri.

Klik kanan printer dan pilih _Set as Default_ untuk memilih printer mana yang akan digunakan aplikasi Anda terlebih dahulu, dan _Properties_ untuk mengatur ukuran kertas, duplex, dan kualitas.

Penemuan otomatis, di mana printer di jaringan muncul tanpa ditambahkan, untuk sementara dimatikan selama fitur ini dikerjakan ulang, itulah mengapa langkah pertama di atas harus Anda lakukan sendiri, bukan otomatis. Mencetak ke file PDF bisa dilakukan tanpa printer sama sekali.

### Bagaimana cara mengubah lokasi penyimpanan tangkapan layar atau rekaman layar?

Tangkapan layar yang disimpan masuk ke `~/Pictures/Screenshots` secara default. Untuk menggunakan direktori lain, tambahkan ini ke file di bawah `~/.config/uwsm/env.d/` (seperti `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Anda bisa melakukan hal yang sama untuk rekaman layar menggunakan `OMARCHY_SCREENRECORD_DIR`.

Omasnap membuat direktori tangkapan layarnya secara otomatis. Buat direktori rekaman layar sendiri, lalu mulai ulang Omarchy agar salah satu perubahan lingkungan itu berlaku.

### Bagaimana cara membuat speaker + webcam berfungsi di Apple Studio Display saya?

Anda mungkin mengira semuanya akan langsung bekerja hanya dengan mencolokkan USB C, tetapi sayangnya tidak begitu. Solusi yang saya temukan agar ini bekerja dengan andal adalah menggunakan [kabel WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Setelah itu speaker dan webcam bekerja dengan sempurna.

Ingat bahwa Anda memiliki kontrol kecerahan bawaan di Omarchy untuk Apple Displays (baik Studio maupun XDR) menggunakan tombol kecerahan keyboard biasa.

### Bagaimana cara menyingkirkan semua perangkat lunak tambahan?

Jika Anda tidak menginginkan program seperti Obsidian atau LibreOffice atau perangkat lunak prainstal lainnya, Anda bisa menghapusnya dengan sangat mudah.

Jalankan _Remove > Package_ untuk melihat setiap paket yang terpasang. Lalu Anda bisa memilih paket apa pun yang ingin Anda hapus dengan tab, dan mulai menghapus semua yang telah Anda pilih dengan return.

Dan Anda bisa menggunakan _Remove > Web App_ dari menu Omarchy untuk menghapus aplikasi web prainstal yang tidak Anda inginkan.

Atau jalankan _Remove > Preinstalls_ untuk menyapu bersih semua tambahan prainstal — aplikasi web, TUIs, dan aplikasi opsional — sekaligus. Hotkey yang meluncurkannya ikut hilang bersama mereka, jadi Anda hanya menyisakan deretan binding yang bersih untuk diisi dengan binding Anda sendiri di `~/.config/hypr/bindings.lua`.

---

Untuk error dan hal-hal yang rusak, lihat [bagian Troubleshooting](45-troubleshooting.md).
