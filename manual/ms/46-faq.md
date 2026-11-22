# Soalan Lazim

### Bagaimanakah cara saya bertukar antara susun atur papan kekunci?

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

Bar akan memaparkan susun atur papan kekunci semasa anda secara automatik sebaik sahaja anda mengkonfigurasi berbilang susun atur (dan anda juga boleh mengkliknya untuk bertukar).

### Bagaimanakah cara saya menukar format jam kepada 12 jam?

Klik kanan pada jam dalam bar untuk beralih melalui format-format biasa, termasuk format 12 jam. Anda juga boleh menetapkan format tersebut secara langsung:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ini akan memaparkan Ahad 10:55 AM.

### Bagaimanakah cara saya menukar zon waktu saya?

Jalankan _Setup > Region > Timezone_ dalam menu Omarchy dan pilih daripada senarai. Jika zon waktu sudah betul tetapi jam itu sendiri telah menyimpang, _Update > Time_ akan memulakan semula penyegerakan masa untuk anda.

### Bagaimanakah cara saya menukar DNS saya, berkongsi Wi-Fi saya, atau menyemak kelajuan sambungan saya?

Semua itu ada dalam [rangkaian](35-networking.md).

### Bagaimanakah cara saya menyemak kelajuan cakera saya?

_Trigger > Speed Test > Disk Speed Test_ mengukur kelajuan baca dan tulis langsung pada pemacu anda, atau `omarchy disk speedtest` daripada terminal.

### Bagaimanakah cara saya menambah pencetak?

Pencetakan telah disediakan dan berjalan terus sebaik sahaja digunakan, dan anda menambah setiap pencetak sendiri daripada _Print Settings_ dalam pelancar aplikasi (`Super + Alt + Space`).

Pilih _Add_, dan berikannya seketika untuk mencari: pencetak yang dipasang melalui USB, dan kebanyakan pencetak rangkaian, akan ditemui untuk anda. Jika pencetak anda tiada dalam senarai, pilih _Network Printer > Internet Printing Protocol (ipp)_ dan masukkan alamatnya — paparan pencetak itu sendiri atau halaman webnya akan memberitahu anda apa alamat tersebut, biasanya sesuatu seperti `192.168.1.50` dengan baris gilir `ipp/print`. _Forward_ kemudian akan menawarkan pemacu, di mana pencetak moden berfungsi paling baik pada profil tanpa pemacu _IPP Everywhere_ dan pencetak yang lebih lama memerlukan pemacu modelnya sendiri.

Klik kanan pada pencetak dan pilih _Set as Default_ untuk memilih pencetak yang akan digunakan oleh aplikasi anda terlebih dahulu, dan _Properties_ untuk menetapkan saiz kertas, dupleks dan kualiti.

Penemuan automatik, di mana pencetak pada rangkaian muncul tanpa ditambah, dimatikan buat sementara waktu semasa ia diolah semula, itulah sebabnya langkah pertama di atas perlu dilakukan oleh anda dan bukan secara automatik. Mencetak ke fail PDF berfungsi tanpa sebarang pencetak langsung.

### Bagaimanakah cara saya menukar tempat tangkapan skrin atau rakaman skrin disimpan?

Tangkapan skrin yang disimpan pergi ke `~/Pictures/Screenshots` secara lalai. Untuk menggunakan direktori lain, tambahkan ini pada fail di bawah `~/.config/uwsm/env.d/` (seperti `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Anda boleh melakukan perkara yang sama untuk rakaman skrin menggunakan `OMARCHY_SCREENRECORD_DIR`.

Omasnap mencipta direktori tangkapan skrinnya secara automatik. Cipta direktori rakaman skrin sendiri, kemudian mulakan semula Omarchy supaya mana-mana perubahan persekitaran berkuat kuasa.

### Bagaimanakah cara saya memastikan pembesar suara + kamera web berfungsi pada Apple Studio Display saya?

Anda mungkin menyangka semuanya akan berfungsi hanya dengan memasang USB C, tetapi malangnya bukan begitu. Penyelesaian yang saya temui untuk menjadikannya berfungsi dengan pasti ialah menggunakan [kabel WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Kemudian pembesar suara dan kamera web berfungsi dengan sempurna.

Ingat bahawa anda mempunyai kawalan kecerahan terbina dalam dalam Omarchy untuk Apple Displays (kedua-dua Studio dan XDR) menggunakan butang kecerahan papan kekunci biasa.

### Bagaimanakah cara saya menyingkirkan semua perisian tambahan?

Jika anda tidak mahu program seperti Obsidian atau LibreOffice atau mana-mana perisian prapasang yang lain, anda boleh menyingkirkannya dengan sangat mudah.

Jalankan _Remove > Package_ untuk melihat setiap pakej yang dipasang. Kemudian anda boleh memilih mana-mana pakej yang anda ingin singkirkan dengan tab, dan mula menyingkirkan semua yang telah anda pilih dengan return.

Dan anda boleh menggunakan _Remove > Web App_ daripada menu Omarchy untuk menyingkirkan mana-mana aplikasi web prapasang yang anda tidak mahu.

Atau jalankan _Remove > Preinstalls_ untuk menyapu keluar semua tambahan prapasang — aplikasi web, TUI, dan aplikasi pilihan — sekali gus. Kekunci pintas yang melancarkannya turut hilang bersamanya, jadi anda tinggal dengan senarai ikatan yang bersih untuk diisi dengan ikatan anda sendiri dalam `~/.config/hypr/bindings.lua`.

---

Untuk ralat dan perkara yang rosak, lihat [bahagian Penyelesaian Masalah](45-troubleshooting.md).
