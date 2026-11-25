# Syot kilat sistem

Kami mencipta syot kilat secara automatik pada setiap kemas kini Omarchy, tetapi jika anda mahu mencipta sendiri, anda boleh menggunakan `omarchy-snapshot create`.

Cara anda but dan memulihkan syot kilat bergantung pada pemuat but yang digunakan mesin anda semasa bermula. Pemasangan UEFI baharu menggunakan systemd-boot; pemasangan lama dan mesin BIOS menggunakan Limine. `omarchy-boot-backend` memberitahu anda yang mana satu anda gunakan.

## Dengan systemd-boot

Pilih _System > Snapshots_ dalam menu Omarchy dan pilih syot kilat yang anda mahu but masuk. Mesin akan dimulakan semula ke dalamnya sekali. Atau tahan Space semasa mesin bermula untuk melihat menu but, di mana setiap syot kilat disenaraikan dengan yang terbaharu dahulu bersama versi Omarchy dan tarikhnya.

Syot kilat dibut dengan lapisan sementara di atasnya, jadi anda boleh menggunakannya seperti biasa, tetapi apa-apa yang anda ubah akan hilang pada but semula seterusnya. Untuk mengekalkannya, jadikannya sistem anda: klik pemberitahuan yang muncul apabila anda log masuk, pilih _System > Snapshots > Restore This Snapshot_, atau jalankan `omarchy-snapshot restore`. Pemulihan berlaku semasa mesin dimulakan semula. Sistem seperti sebelum ini kekal dalam menu but sebagai _Before restore_, dan `omarchy-snapshot restore backup` memulihkannya kembali.

Dari terminal:

- `omarchy-snapshot list` menyenaraikan syot kilat yang anda boleh but;
- `omarchy-snapshot boot 12` memulakan semula ke dalam syot kilat 12 sekali;
- `omarchy-snapshot restore 12` menjadikan syot kilat 12 sebagai sistem pada permulaan semula seterusnya, dan `omarchy-snapshot restore --cancel` membatalkan keputusan itu sebelum permulaan semula tersebut.

## Dengan Limine

Untuk but dan memulihkan syot kilat, anda memilihnya daripada pemuat but Limine. Menu but kekal tersembunyi secara lalai, jadi tekan sebarang kekunci sebaik sahaja Limine bermula untuk memaparkannya.

Dari skrin itu, pilih syot kilat yang anda mahu but masuk berdasarkan tarikh dan versi. Versi Omarchy pada masa syot kilat itu boleh dilihat di sudut kiri bawah.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Apabila anda tiba di dalamnya, satu pemberitahuan akan muncul memberitahu anda bahawa anda berada dalam syot kilat yang boleh dibut dan jika anda mengkliknya, proses pemulihan akan bermula. Sebagai alternatif, anda boleh menggunakan `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Apa yang diliputi oleh pemulihan

Pemulihan mengembalikan sistem fail root anda, tetapi bukan `/home` anda. Jadi ia berkesan untuk membatalkan kemas kini sistem yang rosak, tetapi bukan untuk memulihkan fail peribadi yang hilang.

Ini juga bermakna direktori `~/.config` anda kekal seperti sedia ada. Jadi jika anda kembali kepada versi terdahulu pustaka atau aplikasi yang menyimpan fail konfigurasi dalam format baharu, anda perlu menyelesaikannya secara manual.

Perkara yang sama terpakai pada rekod Omarchy sendiri tentang migrasi mana yang telah dijalankan: ia berada dalam direktori rumah anda, jadi ia kekal selepas pemulihan. Migrasi yang dijalankan selepas syot kilat diambil kekal ditanda sebagai selesai, walaupun perubahan yang dibuatnya pada sistem fail root telah dibatalkan, dan `omarchy update` seterusnya tidak akan menjalankannya lagi. Jadi jika anda mengemas kini semula selepas pemulihan dan sesuatu yang telah disediakan oleh kemas kini terdahulu masih tiada, itulah kemungkinan sebabnya.
