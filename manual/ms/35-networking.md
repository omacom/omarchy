# Rangkaian

Rangkaian dalam Omarchy diuruskan oleh NetworkManager, dan anda mengawalnya dari ikon rangkaian di [bar atas](05-the-top-bar.md) atau dengan `Super + Ctrl + W`.

Panel itu mengimbas rangkaian Wi-Fi, menunjukkan kekuatan isyarat, dan menyambung. Ethernet tidak memerlukan apa-apa langsung — cucuk sahaja dan ia berfungsi. Jika anda lebih selesa kekal di terminal, `nmtui` memberikan kawalan yang sama, dan terdapat juga kumpulan arahan `omarchy network`.

## Berkongsi Wi-Fi anda

Daripada membaca kata laluan yang panjang dengan kuat, jalankan _Persediaan > Rangkaian > Kod QR_ semasa anda menggunakan Wi-Fi. Itu memaparkan kod QR pada skrin yang boleh diimbas oleh mana-mana kamera telefon untuk menyertai rangkaian. Ini salah satu perkara yang akan anda gunakan lebih kerap daripada jangkaan sebaik sahaja anda tahu ia wujud.

Jika anda benar-benar memerlukan kata laluan itu sendiri, `omarchy network password <interface>` akan mencetaknya.

## DNS

Omarchy menggunakan DNS apa sahaja yang diberikan rangkaian anda melalui DHCP. Anda boleh mengatasi tetapan itu untuk seluruh mesin di bawah _Persediaan > Rangkaian > DNS_, di mana Cloudflare dan Google hanya satu klik sahaja. Pilih _Tersuai_ untuk menaip pelayan anda sendiri.

Dari terminal, `omarchy dns` mencetak pembekal semasa dan `omarchy dns Cloudflare` menetapkan satu pembekal.

## Memaku jalur Wi-Fi

Jika penghala anda meletakkan 2.4GHz, 5GHz, dan 6GHz pada nama rangkaian yang sama, laptop anda kadangkala akan berpegang pada jalur yang perlahan. `omarchy network band` menunjukkan jalur yang sedang anda gunakan, dan `omarchy network band 5` akan memakunya. Gunakan `auto` untuk membiarkannya memilih semula.

Ini memaku jalur dan bukannya titik akses tertentu, jadi anda terus bergerak antara AP seperti biasa.

## Berapa lajukah ia?

_Pencetus > Ujian Kelajuan > Ujian Kelajuan Rangkaian_ mengukur kelajuan naik dan turun sebenar anda dengan sepasang dail. Dari terminal, arahannya ialah `omarchy network speedtest down` atau `up`. (Terdapat ujian kelajuan cakera di sebelahnya dalam menu itu, jika anda sedang menguji kesesakan yang satu lagi.)

## Tembok api

Tembok api dihidupkan secara lalai dan menyekat semua trafik masuk, dengan satu pengecualian: port 53317, supaya [LocalSend](22-guis.md) berfungsi terus selepas pemasangan.

SSH dimatikan sehingga anda menghidupkannya dengan _Persediaan > Keselamatan > SSHD_, yang memulakan daemon, membuka port 22 dengan had kadar terhadap serangan brute force, dan membenarkan satu kekunci. Docker juga dikunci, jadi kontena tidak boleh mendedahkan diri mereka kepada dunia secara tidak sengaja. Lihat [keselamatan](48-security.md) untuk cerita penuh.

## Tailscale

[Tailscale](https://tailscale.com/) ialah VPN mesh yang memudahkan dan mengamankan capaian kepada semua komputer dan pelayan anda melalui internet. Pasangnya dengan _Pasang > Perkhidmatan > Tailscale_.

Itu memberikan anda panel Tailscale di bar, yang menyambung dan memutuskan tailnet, menukar akaun, dan memilih nod keluar — mesin anda sendiri dan rantau Mullvad kedua-duanya muncul dalam senarai. Ia juga menyemak imbas mesin anda, dan di situlah Taildrop berada: pilih satu mesin dan tekan `s` untuk menghantar fail kepadanya, atau `c`, `n`, dan `d` untuk menyalin IP, nama, atau nama DNS penuhnya. Setara di terminal ialah `omarchy tailscale send <machine> [file...]`, dan fail yang dihantar kepada anda akan tiba di `~/Downloads` secara automatik. Pemberitahuan yang mengumumkan ketibaan akan menunggu sehingga anda mengklik untuk membukanya atau menutupnya, jadi fail yang tiba semasa anda tiada di mesin masih ada untuk dijawab apabila anda kembali.

Memasangnya juga menambah aplikasi web untuk konsol pentadbir Tailscale.

## Apabila ia berhenti berfungsi

Sebelum but semula, cuba mulakan semula bahagian yang bermasalah itu sahaja. _Kemas Kini > Perkakasan_ mempunyai Wi-Fi, Bluetooth, Audio, dan Pad Sentuh, dan memuat semula salah satu daripadanya menyelesaikan kebanyakan situasi "ia berfungsi lima minit yang lalu". Lihat [penyelesaian masalah](45-troubleshooting.md).
