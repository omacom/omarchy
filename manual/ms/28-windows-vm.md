# VM Windows

Omarchy menawarkan cara mudah untuk menjalankan Windows melalui VM Docker. Anda boleh memasangnya menggunakan _Pasang > Windows_ daripada menu Omarchy (`Super + Space`).

Mesin anda memerlukan virtualisasi KVM untuk ini, yang kebanyakannya ada — tetapi kadangkala ia dimatikan dalam BIOS, dan pemasang akan memberitahu anda jika itu berlaku. Anda juga akan mahu ruang cakera: apa-apa yang anda beri kepada Windows, ditambah kira-kira 10GB untuk imej itu sendiri.

Pemasang bertanya berapa banyak RAM, berapa teras CPU, dan berapa cakera untuk diserahkan (64GB atau lebih adalah lantai yang munasabah), kemudian untuk nama pengguna dan kata laluan Windows. Biarkan kosong dan anda akan dapat `docker` / `admin`. Muat turun mengambil masa — 10-15 minit adalah normal — dan anda boleh mengikuti kemajuan dalam pelayar di `http://127.0.0.1:8006`. Pelayar meminta nama pengguna dan kata laluan yang sama sebelum membuka konsol.

 ![windows-vm](images/windows-vm.webp)

## Menggunakannya

Setelah dipasang, lancarkan _Windows_ daripada pelancar aplikasi. Itu memulakan VM jika belum berjalan dan menyambungkan anda melalui RDP, skrin penuh. Beri 15-30 saat pada permulaan sejuk.

Sesi RDP membawa bunyi, mikrofon anda, dan papan keratan yang dikongsi, jadi menyalin teks antara Linux dan Windows berfungsi sahaja. Resolusi mengikut tetingkap anda, dan Omarchy menghantar penskalaan paparan anda melaluinya, supaya ia bukan kekaburan yang teruk pada skrin HiDPI.

Apabila anda menutup tetingkap RDP, VM dimatikan secara automatik. Jika anda lebih suka membiarkannya berjalan — katakan anda ada sesuatu yang sedang berfungsi di sana — lancarkannya dengan `omarchy windows vm launch --keep-alive` sebaliknya.

Kawalan selebihnya ada pada perintah yang sama:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Berkongsi fail

Direktori `~/Windows` dalam direktori rumah anda dikongsi secara automatik dengan VM. Letakkan fail di sana jika anda mahu ia boleh diakses oleh Windows. VM tiada akses kepada mana-mana bahagian lain sistem fail anda, jadi anda selamat daripada apa-apa yang jahat di pihak Windows. Cakera maya sendiri tersedia di `~/.windows`.

Laluan rumah yang biasa itu kekal pada sistem fail sendiri. Ia juga boleh jadi symlink ke direktori yang anda miliki, yang berguna apabila cakera maya berada pada pemacu yang lebih besar. Pemasang mengukur ruang lapang pada sistem fail yang sebenarnya mengandungi `~/.windows`, tidak semestinya sistem fail yang mengandungi direktori rumah anda.

Kekalkan laluan cakera dan kongsi sebagai direktori berasingan yang tidak bertindih. Pembuangan dengan sengaja mengosongkan direktori cakera tetapi mengekalkan direktori kongsi. Betul-betul sebelum pemadaman, Omarchy melakukan semakan pembendungan terhad dan menolak untuk membuang apa-apa jika semakan itu tamat masa atau tidak dapat membuktikan kedua-dua pokok berasingan.

Sebelum VM bermula, Omarchy membuka dan menyerakkan kedua-dua direktori itu, kemudian bind-mount inode direktori tepat ke sauh per pengguna peribadi di bawah `/var/lib/omarchy/windows/mounts`. Docker hanya melihat sauh dilindungi root itu. Ini mengekalkan lokasi cakera tersuai sambil menghalang proses lain yang berjalan sebagai anda daripada menukar laluan yang telah disemak sebelum container berkeistimewaan menggunakannya. Direktori cakera dan kongsi sedia ada diketatkan kepada mod `0700` semasa migrasi supaya akaun tempatan lain tidak boleh menyemak kandungannya.

Port VM terikat kepada localhost sahaja, jadi tiada apa pada rangkaian anda boleh mencapai mesin Windows. Konsol web juga memerlukan nama pengguna dan kata laluan Windows yang dikonfigurasikan, menghalang akaun tempatan lain daripada memacu VM melalui port 8006.

## Had dan perlesenan

Tiada passthrough GPU dengan persediaan ini, jadi ia tidak sesuai untuk permainan atau penyuntingan video. Ia adalah cara yang hebat untuk menjalankan Microsoft Office atau apa-apa sahaja yang anda mesti ada.

Versi yang dipasang ialah Windows 11 Pro, tidak diaktifkan. Anda memerlukan kunci lesen anda sendiri untuk menggunakan ciri berpagar.

Jika komputer ini dihantar bersama Windows, kunci OEM masih berada dalam perisian tegar walaupun selepas memasang Omarchy. Cetaknya dengan `omarchy windows key`. Kunci itu terikat pada mesin ini — ia akan mengaktifkan Windows yang dipasang semula pada perkakasan ini, tetapi biasanya ia tidak akan mengaktifkan VM.

Anda boleh mengubah peruntukan sumber kemudian dengan menjalankan semula `omarchy-windows-vm install`, yang menulis semula konfigurasi VM daripada jawapan anda. Fail compose itu sendiri kini berada di `/var/lib/omarchy/windows/docker-compose.yml` dan dimiliki oleh root — itu disengajakan, supaya proses yang berjalan sebagai anda tidak boleh menulisnya semula dan meminta bring-up berkeistimewaan melekapkan seluruh cakera anda ke dalam container. Jika anda perlu menyuntingnya dengan tangan (contohnya untuk melekap peranti USB), suntingnya dengan `sudo` dan lihat semua pilihan pada [projek Dockur Windows](https://github.com/dockur/windows).

Untuk menyingkirkan keseluruhannya, gunakan _Buang > Windows_ daripada menu Omarchy. Itu memadam cakera VM dan semua datanya, jadi pastikan apa-apa yang anda sayang sudah keluar daripada `~/Windows` dahulu.
