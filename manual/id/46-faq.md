# FAQ

### Bagaimana cara beralih antar layout keyboard?

Edit file `~/.config/hypr/input.lua` Anda dan tambahkan ini untuk beralih antar layout pada `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bar akan secara otomatis menampilkan layout keyboard Anda saat ini setelah Anda mengonfigurasi beberapa layout (dan Anda juga bisa mengkliknya untuk beralih).

### Bagaimana cara mengubah format jam ke 12 jam?

Klik kanan jam di bar untuk menelusuri format-format yang umum, termasuk format 12 jam. Anda juga bisa mengatur formatnya secara langsung:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ini akan menampilkan Minggu 10:55 AM.

### Bagaimana cara mengubah zona waktu saya?

Jalankan _Update > Timezone_ di menu Omarchy dan pilih dari daftar. Jika zona waktunya sudah benar tetapi jamnya sendiri bergeser, _Update > Time_ akan memulai ulang sinkronisasi waktu untuk Anda.

### Bagaimana cara mengubah DNS saya, membagikan Wi-Fi saya, atau memeriksa kecepatan koneksi saya?

Semuanya ada di [jaringan](35-networking.md).

### Bagaimana cara memeriksa seberapa cepat disk saya?

_Trigger > Speed Test > Disk Speed Test_ mengukur kecepatan baca dan tulis langsung pada drive Anda, atau `omarchy disk speedtest` dari terminal.

### Bagaimana cara menambahkan printer?

Pencetakan sudah disiapkan dan berjalan langsung, dan Anda menambahkan setiap printer sendiri dari _Print Settings_ di peluncur aplikasi (`Super + Space`).

Pilih _Add_, dan beri waktu sejenak untuk mencarinya: printer yang dicolokkan melalui USB, dan sebagian besar printer jaringan, akan ditemukan untuk Anda. Jika printer Anda tidak ada dalam daftar, pilih _Network Printer > Internet Printing Protocol (ipp)_ dan masukkan alamatnya — layar printer itu sendiri atau halaman web-nya akan memberi tahu Anda alamat tersebut, biasanya sesuatu seperti `192.168.1.50` dengan antrean `ipp/print`. _Forward_ kemudian menawarkan driver, di mana printer modern bekerja paling baik pada profil driverless _IPP Everywhere_ dan printer yang lebih lama menginginkan driver modelnya sendiri.

Klik kanan printer dan pilih _Set as Default_ untuk memilih printer mana yang akan digunakan aplikasi Anda terlebih dahulu, dan _Properties_ untuk mengatur ukuran kertas, duplex, dan kualitas.

Penemuan otomatis, di mana printer di jaringan muncul tanpa ditambahkan, untuk sementara dimatikan selama fitur ini dikerjakan ulang, itulah sebabnya langkah pertama di atas menjadi tugas Anda dan bukan otomatis. Mencetak ke file PDF bekerja tanpa printer sama sekali.

### Bagaimana cara mengubah tempat tangkapan layar atau perekaman layar disimpan?

Tangkapan layar yang disimpan masuk ke `~/Pictures/Screenshots` secara default. Untuk menggunakan direktori lain, tambahkan ini ke file di bawah `~/.config/uwsm/env.d/` (seperti `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Anda bisa melakukan hal yang sama untuk perekaman layar menggunakan `OMARCHY_SCREENRECORD_DIR`.

Omasnap membuat direktori tangkapan layarnya secara otomatis. Buat sendiri direktori perekaman layar, lalu mulai ulang Omarchy agar perubahan lingkungan mana pun berlaku.

### Bagaimana cara membuat speaker + webcam berfungsi di Apple Studio Display saya?

Anda mungkin mengira semuanya seharusnya bekerja hanya dengan mencolokkan USB C, tetapi sayangnya tidak begitu. Solusi yang saya temukan agar ini bekerja dengan andal adalah menggunakan [kabel WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Kemudian speaker dan webcam bekerja dengan sempurna.

Ingat bahwa Anda memiliki kontrol kecerahan bawaan di Omarchy untuk Apple Displays (baik Studio maupun XDR) menggunakan tombol kecerahan keyboard biasa.

### Bagaimana cara menyingkirkan semua perangkat lunak tambahan?

Jika Anda tidak menginginkan program seperti Obsidian atau LibreOffice atau perangkat lunak pra-instal lainnya, Anda bisa menghapusnya dengan sangat mudah.

Jalankan _Remove > Package_ untuk melihat setiap paket yang terinstal. Kemudian Anda bisa memilih paket mana pun yang ingin Anda hapus dengan tab, dan mulai menghapus semua yang telah Anda pilih dengan return.

Dan Anda bisa menggunakan _Remove > Web App_ dari menu Omarchy untuk menghapus aplikasi web pra-instal mana pun yang tidak Anda inginkan.

Atau jalankan _Remove > Preinstalls_ untuk menyapu bersih semua ekstra pra-instal — aplikasi web, TUIs, dan aplikasi opsional — sekaligus. Hotkey yang meluncurkannya ikut hilang bersama mereka, jadi Anda ditinggalkan dengan lembaran bersih berisi binding untuk diisi dengan milik Anda sendiri di `~/.config/hypr/bindings.lua`.

---

Untuk kesalahan dan hal-hal yang rusak, lihat [bagian Pemecahan Masalah](45-troubleshooting.md).
