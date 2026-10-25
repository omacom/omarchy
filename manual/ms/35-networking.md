# Rangkaian

Rangkaian dalam Omarchy dikendalikan oleh NetworkManager, dan anda mengawalnya daripada ikon rangkaian dalam [bar atas](05-the-top-bar.md) atau dengan `Super + Ctrl + N`.

Panel itu mengimbas rangkaian Wi-Fi, menunjukkan kekuatan isyarat, dan menyambung. Ethernet tidak memerlukan apa-apa langsung — cucuk sahaja dan ia berfungsi. Jika anda lebih suka kekal dalam terminal, `nmtui` memberikan anda kawalan yang sama, dan terdapat juga kumpulan arahan `omarchy network`.

## Berkongsi Wi-Fi anda

Daripada membacakan kata laluan yang panjang dengan kuat, jalankan _Setup > Network > QR Code_ semasa anda berada pada Wi-Fi. Itu meletakkan kod QR pada skrin yang boleh diimbas oleh mana-mana kamera telefon untuk menyertainya. Ia salah satu perkara yang akan anda gunakan lebih daripada yang anda jangkakan sebaik sahaja anda tahu ia ada di situ.

Jika anda benar-benar memerlukan kata laluan itu sendiri, `omarchy network password <interface>` mencetaknya.

## DNS

Omarchy menggunakan apa jua DNS yang diberikan oleh rangkaian anda melalui DHCP. Anda boleh menggantikannya untuk seluruh mesin di bawah _Setup > Network > DNS_, di mana Cloudflare dan Google hanya satu klik sahaja. Pilih _Custom_ untuk menaip pelayan anda sendiri.

Dari terminal, `omarchy dns` mencetak pembekal semasa dan `omarchy dns Cloudflare` menetapkan satu.

## Menetapkan jalur Wi-Fi

Jika penghala anda meletakkan 2.4GHz, 5GHz, dan 6GHz pada nama rangkaian yang sama, komputer riba anda kadangkala akan berpaut pada yang perlahan. `omarchy network band` menunjukkan jalur mana yang anda gunakan, dan `omarchy network band 5` menetapkannya. Gunakan `auto` untuk membiarkannya memilih semula.

Ini menetapkan jalur dan bukannya titik akses tertentu, jadi anda kekal merayau antara AP seperti biasa.

## Seberapa pantas ia?

_Trigger > Speed Test > Network Speed Test_ mengukur kelajuan naik dan turun sebenar anda dengan sepasang dail. Dari terminal ia adalah `omarchy network speedtest down` atau `up`. (Terdapat ujian kelajuan cakera yang terletak di sebelahnya dalam menu itu, jika anda menanda aras kesesakan yang satu lagi.)

## Tembok api

Tembok api dihidupkan secara lalai dan menyekat semua trafik masuk, dengan satu pengecualian: port 53317, supaya [LocalSend](22-guis.md) berfungsi terus sebaik sahaja digunakan.

SSH dimatikan sehingga anda menghidupkannya dengan _Setup > Security > SSHD_, yang memulakan daemon, membuka port 22 dengan pengehadan kadar terhadap serangan brute force, dan membenarkan satu kunci. Docker juga dikunci, supaya kontena tidak boleh secara tidak sengaja mendedahkan diri mereka kepada dunia. Lihat [keselamatan](48-security.md) untuk cerita penuhnya.

## Tailscale

[Tailscale](https://tailscale.com/) ialah VPN mesh yang menjadikan capaian kepada semua komputer dan pelayan anda melalui internet mudah dan selamat. Pasangnya dengan _Install > Service > Tailscale_.

Itu memberikan anda panel Tailscale dalam bar, yang menyambung dan memutuskan tailnet, menukar akaun, dan memilih nod keluar — mesin anda sendiri dan wilayah Mullvad kedua-duanya muncul dalam senarai. Ia juga melayari mesin anda, dan di situlah Taildrop berada: pilih satu mesin dan tekan `s` untuk menghantar fail kepadanya, atau `c`, `n`, dan `d` untuk menyalin IP, nama, atau nama DNS penuhnya. Setara terminalnya ialah `omarchy tailscale send <machine> [file...]`, dan fail yang dihantar kepada anda tiba dalam `~/Downloads` secara automatik. Pemberitahuan yang mengumumkan ketibaan menunggu sehingga anda mengkliknya untuk membuka atau menutupnya, supaya fail yang muncul semasa anda tiada di mesin masih ada untuk dijawab apabila anda kembali.

Memasangnya juga menambah aplikasi web untuk konsol pentadbir Tailscale.

## Apabila ia berhenti berfungsi

Sebelum but semula, cuba mulakan semula bahagian yang bermasalah itu sendiri. _Update > Hardware_ mempunyai Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat semula salah satu daripadanya menyelesaikan kebanyakan situasi "ia berfungsi lima minit yang lalu". Lihat [penyelesaian masalah](45-troubleshooting.md).
