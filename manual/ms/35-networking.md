# Rangkaian

Rangkaian dalam Omarchy dikendalikan oleh NetworkManager, dan anda mengawalnya daripada ikon rangkaian di [bar atas](05-the-top-bar.md) atau dengan `Super + Ctrl + N`.

Panel itu mengimbas rangkaian Wi-Fi, menunjukkan kekuatan isyarat, dan menyambung. Ethernet tidak memerlukan apa-apa langsung — cucuk sahaja dan ia terus berfungsi. Jika anda lebih suka kekal di terminal, `nmtui` memberikan kawalan yang sama kepada anda, dan terdapat juga kumpulan arahan `omarchy network`.

## Berkongsi Wi-Fi anda

Daripada membacakan kata laluan yang panjang dengan kuat, jalankan _Setup > Network > QR Code_ semasa anda berada di Wi-Fi. Itu meletakkan kod QR pada skrin yang boleh diimbas oleh mana-mana kamera telefon untuk menyertai. Ia salah satu perkara yang akan anda gunakan lebih kerap daripada yang anda sangka sebaik sahaja anda tahu ia ada di situ.

Jika anda benar-benar memerlukan kata laluannya sendiri, `omarchy network password <interface>` mencetaknya.

## DNS

Omarchy menggunakan apa sahaja DNS yang diberikan oleh rangkaian anda melalui DHCP. Anda boleh menggantikannya untuk keseluruhan mesin di bawah _Setup > Network > DNS_, di mana Cloudflare dan Google hanya satu klik sahaja. Pilih _Custom_ untuk menaip pelayan anda sendiri.

Dari terminal, `omarchy dns` mencetak pembekal semasa dan `omarchy dns Cloudflare` menetapkan satu.

## Menetapkan jalur Wi-Fi

Jika penghala anda meletakkan 2.4GHz, 5GHz, dan 6GHz pada nama rangkaian yang sama, laptop anda kadangkala akan berdegil kekal pada yang perlahan. `omarchy network band` menunjukkan jalur mana yang anda gunakan, dan `omarchy network band 5` menetapkannya. Gunakan `auto` untuk membiarkannya memilih semula.

Ini menetapkan jalur dan bukannya titik akses tertentu, jadi anda terus merayau antara AP seperti biasa.

## Seberapa pantaskah ia?

_Trigger > Speed Test > Network Speed Test_ mengukur kelajuan naik dan turun sebenar anda dengan sepasang dail. Dari terminal, ia ialah `omarchy network speedtest down` atau `up`. Ia mengukur terhadap perkhidmatan Omarchy sendiri dan hanya mengira pemindahan ujiannya. Muat turun lain boleh bersaing untuk lebar jalur, tetapi ia tidak ditambahkan pada keputusan ujian kelajuan. (Ada ujian kelajuan cakera bersebelahan dengannya dalam menu itu, jika anda menanda aras kesesakan yang satu lagi.)

## Firewall

Firewall dihidupkan secara lalai dan menyekat semua trafik masuk, dengan satu pengecualian: port 53317, supaya [LocalSend](22-guis.md) berfungsi terus sebaik sahaja dipasang.

SSH dimatikan sehingga anda menghidupkannya dengan _Setup > Security > SSHD_, yang memulakan daemon, membuka port 22 dengan had kadar terhadap brute force, dan membenarkan satu kunci. Docker juga dikunci, supaya kontena tidak boleh secara tidak sengaja mendedahkan diri mereka kepada dunia. Lihat [keselamatan](48-security.md) untuk cerita penuhnya.

## Tailscale

[Tailscale](https://tailscale.com/) ialah VPN mesh yang menjadikan capaian ke semua komputer dan pelayan anda melalui internet mudah dan selamat. Pasangnya dengan _Install > Service > Tailscale_.

Itu memberikan anda panel Tailscale di bar, yang menyambung dan memutuskan tailnet, menukar akaun, dan memilih nod keluar — mesin anda sendiri dan wilayah Mullvad kedua-duanya muncul dalam senarai. Ia juga menyemak imbas mesin anda, dan di situlah Taildrop berada: pilih satu mesin dan tekan `s` untuk menghantar fail kepadanya, atau `c`, `n`, dan `d` untuk menyalin IP, nama, atau nama DNS penuhnya. Arahan terminal yang setara ialah `omarchy tailscale send <machine> [file...]`, dan fail yang dihantar kepada anda tiba di `~/Downloads` secara automatik. Pemberitahuan yang mengumumkan ketibaan menunggu sehingga anda mengkliknya untuk dibuka atau menutupnya, supaya fail yang tiba semasa anda tiada di mesin masih ada untuk dibalas apabila anda kembali.

Memasangnya juga menambah aplikasi web untuk konsol pentadbir Tailscale.

## Apabila ia berhenti berfungsi

Sebelum but semula, cuba mulakan semula bahagian yang bermasalah itu sahaja. _Update > Hardware_ mempunyai Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat semula salah satu daripadanya menyelesaikan kebanyakan situasi "ia berfungsi lima minit lepas". Lihat [penyelesaian masalah](45-troubleshooting.md).
