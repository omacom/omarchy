# Soalan Lazim

### Bagaimana cara saya bertukar antara susun atur papan kekunci?

Edit fail `~/.config/hypr/input.lua` anda dan tambahkan ini untuk bertukar antara susun atur pada `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bar akan memaparkan susun atur papan kekunci semasa anda secara automatik sebaik sahaja anda mengkonfigurasikan berbilang susun atur (dan anda juga boleh mengkliknya untuk bertukar).

### Bagaimana cara saya menukar format jam kepada 12 jam?

Klik kanan jam pada bar untuk beralih antara format yang biasa, termasuk format 12 jam. Anda juga boleh menetapkan format secara terus:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ini akan memaparkan Ahad 10:55 AM.

### Bagaimana cara saya menukar zon masa saya?

Jalankan _Kemas Kini > Zon Masa_ dalam menu Omarchy dan pilih daripada senarai. Jika zon masa sudah betul tetapi jam itu sendiri telah tersasar, _Kemas Kini > Masa_ memulakan semula penyegerakan masa untuk anda.

### Bagaimana cara saya menukar DNS saya, berkongsi Wi-Fi saya, atau menyemak kelajuan sambungan saya?

Semua itu ada dalam [rangkaian](35-networking.md).

### Bagaimana cara saya menyemak kelajuan cakera saya?

_Pencetus > Ujian Kelajuan > Ujian Kelajuan Cakera_ mengukur kelajuan baca dan tulis langsung pada pemacu anda, atau `omarchy disk speedtest` daripada terminal.

### Bagaimana cara saya menambah pencetak?

Pencetakan telah disediakan dan berjalan terus dari awal, dan anda menambahkan setiap pencetak sendiri daripada _Tetapan Cetakan_ dalam pelancar aplikasi (`Super + Space`).

Pilih _Tambah_, dan berikannya sedikit masa untuk mencari: pencetak yang dipasang melalui USB, dan kebanyakan pencetak rangkaian, akan ditemui untuk anda. Jika pencetak anda tiada dalam senarai, pilih _Pencetak Rangkaian > Internet Printing Protocol (ipp)_ dan masukkan alamatnya — paparan pencetak itu sendiri atau halaman webnya akan memberitahu anda apa alamat itu, biasanya sesuatu seperti `192.168.1.50` dengan baris gilir `ipp/print`. _Seterusnya_ kemudian menawarkan pemacu, di mana pencetak moden berfungsi paling baik pada profil tanpa pemacu _IPP Everywhere_ dan pencetak yang lebih lama memerlukan pemacu modelnya sendiri.

Klik kanan pencetak dan pilih _Tetapkan sebagai Lalai_ untuk memilih pencetak yang digunakan dahulu oleh aplikasi anda, dan _Sifat_ untuk menetapkan saiz kertas, dupleks dan kualiti.

Penemuan automatik, di mana pencetak pada rangkaian muncul tanpa ditambahkan, dimatikan buat sementara waktu sementara ia diolah semula, itulah sebabnya langkah pertama di atas perlu anda lakukan sendiri dan bukannya automatik. Mencetak ke fail PDF berfungsi tanpa sebarang pencetak langsung.

### Bagaimana cara saya menukar tempat tangkapan skrin atau rakaman skrin disimpan?

Tangkapan skrin yang disimpan pergi ke `~/Pictures/Screenshots` secara lalai. Untuk menggunakan direktori lain, tambahkan ini pada fail di bawah `~/.config/uwsm/env.d/` (seperti `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Anda boleh melakukan perkara yang sama untuk rakaman skrin menggunakan `OMARCHY_SCREENRECORD_DIR`.

Omasnap mencipta direktori tangkapan skrinnya secara automatik. Cipta direktori rakaman skrin sendiri, kemudian mulakan semula Omarchy supaya mana-mana perubahan persekitaran berkuat kuasa.

### Bagaimana cara saya memastikan pembesar suara + kamera web berfungsi pada Apple Studio Display saya?

Anda mungkin menyangka semuanya sepatutnya berfungsi hanya dengan memasang USB C, tetapi malangnya bukan begitu. Penyelesaian yang saya temui untuk memastikannya berfungsi dengan boleh dipercayai ialah menggunakan [kabel WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Kemudian pembesar suara dan kamera web berfungsi dengan sempurna.

Ingat bahawa anda mempunyai kawalan kecerahan terbina dalam dalam Omarchy untuk Apple Displays (kedua-dua Studio dan XDR) menggunakan butang kecerahan papan kekunci biasa.

### Bagaimana cara saya menyingkirkan semua perisian tambahan?

Jika anda tidak mahu program seperti Obsidian atau LibreOffice atau mana-mana bahan prapasang yang lain, anda boleh menyingkirkannya dengan sangat mudah.

Jalankan _Buang > Pakej_ untuk melihat setiap pakej yang dipasang. Kemudian anda boleh memilih mana-mana pakej yang ingin anda buang dengan tab, dan mulakan pembuangan semua yang telah anda pilih dengan return.

Dan anda boleh menggunakan _Buang > Aplikasi Web_ daripada menu Omarchy untuk membuang mana-mana aplikasi web prapasang yang anda tidak mahu.

Atau jalankan _Buang > Prapasang_ untuk menyapu keluar semua tambahan prapasang — aplikasi web, TUI, dan aplikasi pilihan — sekali gus. Kekunci pintas yang melancarkannya hilang bersamanya, jadi anda ditinggalkan dengan himpunan pengikatan yang bersih untuk diisi dengan milik anda sendiri dalam `~/.config/hypr/bindings.lua`.

---

Untuk ralat dan bahagian yang rosak, lihat [bahagian Penyelesaian Masalah](45-troubleshooting.md).
