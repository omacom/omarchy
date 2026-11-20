# FAQ

### Bagaimanakah saya bertukar antara susun atur papan kekunci?

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

Bar akan memaparkan susun atur papan kekunci semasa anda secara automatik sebaik sahaja anda mempunyai berbilang susun atur yang dikonfigurasikan (dan anda juga boleh klik padanya untuk bertukar).

### Bagaimanakah saya menukar format jam kepada 12 jam?

Klik kanan jam pada bar untuk beralih antara format biasa, termasuk format 12 jam. Anda juga boleh tetapkan formatnya secara terus:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ini akan memaparkan Ahad 10:55 AM.

### Bagaimanakah saya menukar zon waktu saya?

Jalankan _Setup > Region > Timezone_ dalam menu Omarchy dan pilih daripada senarai. Jika zon waktunya betul tetapi jam itu sendiri telah lari, _Update > Time_ akan memulakan semula penyegerakan masa untuk anda.

### Bagaimanakah saya menukar DNS saya, berkongsi Wi-Fi saya, atau menyemak kelajuan sambungan saya?

Semua itu ada dalam [rangkaian](35-networking.md).

### Bagaimanakah saya menyemak kelajuan cakera saya?

_Trigger > Speed Test > Disk Speed Test_ mengukur kelajuan baca dan tulis langsung pada pemacu anda, atau `omarchy disk speedtest` daripada terminal.

### Bagaimanakah saya menambah pencetak?

Pencetakan telah disediakan dan berjalan sejak dari awal, dan anda menambah setiap pencetak sendiri daripada _Print Settings_ dalam pelancar aplikasi (`Super + Space`).

Pilih _Add_, dan berikannya seketika untuk mencari: pencetak yang disambungkan melalui USB, dan kebanyakan pencetak rangkaian, akan ditemui untuk anda. Jika pencetak anda tiada dalam senarai, pilih _Network Printer > Internet Printing Protocol (ipp)_ dan masukkan alamatnya — paparan pencetak itu sendiri atau halaman webnya akan memberitahu anda alamat tersebut, biasanya sesuatu seperti `192.168.1.50` dengan baris gilir `ipp/print`. _Forward_ kemudian menawarkan pemacu, yang mana pencetak moden berfungsi paling baik dengan profil tanpa pemacu _IPP Everywhere_ dan pencetak lama memerlukan pemacu modelnya sendiri.

Klik kanan pencetak dan pilih _Set as Default_ untuk memilih pencetak yang akan digunakan oleh aplikasi anda terlebih dahulu, dan _Properties_ untuk menetapkan saiz kertas, duplex dan kualiti.

Penemuan automatik, yang mana pencetak pada rangkaian muncul tanpa perlu ditambah, dimatikan buat sementara waktu semasa ia diolah semula, sebab itulah langkah pertama di atas perlu anda lakukan sendiri dan bukannya secara automatik. Mencetak ke fail PDF berfungsi tanpa sebarang pencetak langsung.

### Bagaimanakah saya menukar tempat tangkapan skrin atau rakaman skrin disimpan?

Tangkapan skrin yang disimpan pergi ke `~/Pictures/Screenshots` secara lalai. Untuk menggunakan direktori lain, tambahkan ini pada fail di bawah `~/.config/uwsm/env.d/` (seperti `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Anda boleh lakukan perkara yang sama untuk rakaman skrin menggunakan `OMARCHY_SCREENRECORD_DIR`.

Omasnap mencipta direktori tangkapan skrinnya secara automatik. Cipta direktori rakaman skrin itu sendiri, kemudian mulakan semula Omarchy supaya mana-mana perubahan persekitaran itu berkuat kuasa.

### Bagaimanakah saya membuatkan pembesar suara + webcam berfungsi pada Apple Studio Display saya?

Anda mungkin menyangka semuanya sepatutnya berfungsi hanya dengan menyambungkan USB C, tetapi malangnya bukan begitu. Penyelesaian yang saya temui untuk memastikan ia berfungsi dengan andal ialah menggunakan [kabel WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Kemudian pembesar suara dan webcam berfungsi dengan elok sekali.

Ingat bahawa anda mempunyai kawalan kecerahan terbina dalam dalam Omarchy untuk Apple Displays (kedua-dua Studio dan XDR) menggunakan butang kecerahan papan kekunci biasa.

### Bagaimanakah saya menyingkirkan semua perisian tambahan?

Jika anda tidak mahu program seperti Obsidian atau LibreOffice atau mana-mana perisian prapasang yang lain, anda boleh menyingkirkannya dengan sangat mudah.

Jalankan _Remove > Package_ untuk melihat setiap pakej yang dipasang. Kemudian anda boleh memilih mana-mana pakej yang anda ingin singkirkan dengan tab, dan mula menyingkirkan semua yang telah anda pilih dengan return.

Dan anda boleh menggunakan _Remove > Web App_ daripada menu Omarchy untuk menyingkirkan mana-mana aplikasi web prapasang yang anda tidak mahu.

Atau jalankan _Remove > Preinstalls_ untuk membersihkan semua tambahan prapasang — aplikasi web, TUIs, dan aplikasi pilihan — sekali gus. Kekunci pintas yang melancarkannya akan hilang bersama-samanya, jadi anda ditinggalkan dengan ikatan kosong yang bersih untuk diisi dengan ikatan anda sendiri dalam `~/.config/hypr/bindings.lua`.

---

Untuk ralat dan bahagian yang rosak, lihat [bahagian Penyelesaian Masalah](45-troubleshooting.md).
