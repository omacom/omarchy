# Soalan Lazim

### Bagaimana saya bertukar antara susun atur papan kekunci?

Sunting fail `~/.config/hypr/input.lua` anda dan tambah ini untuk bertukar antara susun atur pada `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bar akan secara automatik menunjukkan susun atur papan kekunci semasa anda sebaik sahaja anda mempunyai berbilang susun atur dikonfigurasikan (dan anda boleh mengkliknya untuk bertukar juga).

### Bagaimana saya menukar format jam kepada 12-jam?

Klik kanan jam di bar untuk berkitar melalui format biasa, termasuk yang 12-jam. Anda juga boleh menetapkan format secara langsung:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ini akan memaparkan Sunday 10:55 AM.

### Bagaimana saya menukar zon masa saya?

Jalankan _Kemas Kini > Zon Masa_ dalam menu Omarchy dan pilih dari senarai. Jika zon masa betul tetapi jam itu sendiri telah menyimpang, _Kemas Kini > Masa_ memulakan semula penyegerakan masa untuk anda.

### Bagaimana saya menukar DNS saya, berkongsi Wi-Fi saya, atau memeriksa kelajuan sambungan saya?

Semua itu berada dalam [rangkaian](35-networking.md).

### Bagaimana saya memeriksa kelajuan cakera saya?

_Pencetus > Ujian Kelajuan > Ujian Kelajuan Cakera_ mengukur kelajuan baca dan tulis langsung pada pemacu anda, atau `omarchy disk speedtest` dari terminal.

### Mengapa saya tidak boleh log masuk ke akaun Google saya dalam Chromium?

Binaan Chromium sumber terbuka biasa tidak disertakan dengan kelayakan OAuth yang diperlukan Google untuk log masuk akaun. Jalankan _Pasang > Perkhidmatan > Akaun Chromium_ dalam menu Omarchy untuk menambahnya, mulakan semula pelayar, dan log masuk akan berjaya.

### Bagaimana saya menambah pencetak?

Pencetakan disediakan dan berjalan terus selepas pemasangan, dan anda menambah setiap pencetak sendiri dari _Tetapan Cetak_ dalam pelancar aplikasi (`Super + Space`).

Pilih _Tambah_, dan berikan sedikit masa untuk mencari: pencetak yang dicucuk melalui USB, dan kebanyakan pencetak rangkaian, ditemui untuk anda. Jika pencetak anda tiada dalam senarai, pilih _Network Printer > Internet Printing Protocol (ipp)_ dan masukkan alamatnya — paparan pencetak itu sendiri atau halaman webnya akan memberitahu anda apa alamat itu, biasanya sesuatu seperti `192.168.1.50` dengan baris `ipp/print`. _Forward_ kemudian menawarkan pemacu, di mana pencetak moden berfungsi paling baik pada profil tanpa pemacu _IPP Everywhere_ dan yang lebih lama mahukan pemacu modelnya sendiri.

Klik kanan pencetak dan pilih _Tetapkan sebagai Lalai_ untuk memilih yang mana satu yang dicapai aplikasi anda dahulu, dan _Sifat_ untuk menetapkan saiz kertas, dupleks dan kualiti.

Penemuan automatik, di mana pencetak pada rangkaian muncul tanpa ditambah, dimatikan buat sementara semasa ia diolah semula, sebab itulah langkah pertama di atas adalah tanggungjawab anda dan bukannya automatik. Mencetak ke fail PDF berfungsi tanpa sebarang pencetak pun.

### Bagaimana saya menukar tempat tangkap skrin atau rakaman skrin disimpan?

Tangkap skrin yang disimpan pergi ke `~/Pictures/Screenshots` secara lalai. Untuk menggunakan direktori lain, tambahkan ini pada fail di bawah `~/.config/uwsm/env.d/` (seperti `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Anda boleh melakukan perkara yang sama untuk rakaman skrin menggunakan `OMARCHY_SCREENRECORD_DIR`.

Omasnap mencipta direktori tangkap skrinnya secara automatik. Cipta direktori rakaman skrin sendiri, kemudian mulakan semula Omarchy untuk mana-mana perubahan persekitaran berkuat kuasa.

### Bagaimana saya membuat pembesar suara + webcam berfungsi pada Apple Studio Display saya?

Anda menyangka semuanya sepatutnya berfungsi hanya dengan mencucuk USB C, tetapi malangnya itu tidak berlaku. Penyelesaian yang saya dapati untuk membuatnya berfungsi dengan boleh dipercayai ialah menggunakan [kabel WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Kemudian pembesar suara dan webcam berfungsi dengan sempurna.

Ingat bahawa anda mempunyai kawalan kecerahan terbina dalam Omarchy untuk Apple Displays (Studio dan XDR kedua-duanya) menggunakan butang kecerahan papan kekunci biasa.

### Bagaimana saya menyingkirkan semua perisian tambahan?

Jika anda tidak mahukan atur cara seperti Obsidian atau LibreOffice atau mana-mana bahan prapasang lain, anda boleh membuangnya dengan sangat mudah.

Jalankan _Buang > Pakej_ untuk melihat setiap pakej yang dipasang. Kemudian anda boleh memilih mana-mana pakej yang anda mahu buang dengan tab, dan mula membuang semua yang telah anda pilih dengan return.

Dan anda boleh menggunakan _Buang > Aplikasi Web_ dari menu Omarchy untuk membuang mana-mana aplikasi web prapasang yang anda tidak mahu.

Atau jalankan _Buang > Prapasang_ untuk menyapu keluar semua tambahan prapasang — aplikasi web, TUI, dan aplikasi pilihan — sekali gus. Hotkey yang melancarkannya hilang bersamanya, jadi anda ditinggalkan dengan slate ikatan yang bersih untuk diisi dengan milik anda sendiri dalam `~/.config/hypr/bindings.lua`.

---

Untuk ralat dan bahagian yang rosak, lihat [bahagian Penyelesaian Masalah](45-troubleshooting.md).
