# VM Windows

Omarchy menawarkan cara mudah untuk menjalankan Windows melalui VM Docker pada mesin x86_64. Anda boleh memasangnya menggunakan _Install > Windows_ daripada menu Omarchy (`Super + Space`).

Mesin anda memerlukan virtualisasi KVM untuk ini, dan kebanyakan mesin memang menyokongnya — tetapi ia kadangkala dimatikan dalam BIOS, dan pemasang akan memberitahu anda jika itu keadaannya. Anda juga akan memerlukan ruang cakera: sebanyak mana yang anda berikan kepada Windows, ditambah kira-kira 10GB untuk imej itu sendiri.

Pemasang akan bertanya berapa banyak RAM, berapa banyak teras CPU, dan berapa banyak cakera yang hendak diserahkan (64GB atau lebih ialah had minimum yang masuk akal), kemudian nama pengguna dan kata laluan Windows. Biarkan kosong dan anda akan mendapat `docker` / `admin`. Muat turun mengambil masa yang agak lama — 10-15 minit adalah biasa — dan anda boleh mengikuti kemajuannya dalam pelayar di `http://127.0.0.1:8006`. Pelayar akan meminta nama pengguna dan kata laluan yang sama sebelum membuka konsol.

 ![windows-vm](images/windows-vm.webp)

## Menggunakannya

Setelah dipasang, lancarkan _Windows_ daripada pelancar aplikasi. Itu akan memulakan VM jika ia belum berjalan dan menyambungkan anda melalui RDP, skrin penuh. Berikan masa 15-30 saat untuk permulaan sejuk.

Sesi RDP membawa bunyi, mikrofon anda, dan papan klip kongsi, jadi menyalin teks antara Linux dan Windows berfungsi begitu sahaja. Peleraian mengikut tetingkap anda, dan Omarchy menyalurkan penskalaan paparan anda melaluinya, jadi ia bukan paparan kabur yang bersepah pada skrin HiDPI.

Apabila anda menutup tetingkap RDP, VM akan dimatikan secara automatik. Jika anda lebih suka membiarkannya berjalan — contohnya ada sesuatu yang sedang bekerja di dalamnya — lancarkannya dengan `omarchy windows vm launch --keep-alive` sebaliknya.

Kawalan selebihnya berada pada arahan yang sama:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Berkongsi fail

Direktori `~/Windows` dalam direktori utama anda dikongsi secara automatik dengan VM. Letakkan fail di sana jika anda mahu fail tersebut boleh dicapai oleh Windows. VM tidak mempunyai akses kepada mana-mana bahagian lain sistem fail anda, jadi anda selamat daripada apa-apa yang jahat di pihak Windows. Cakera mayanya sendiri tersedia di `~/.windows`.

Laluan utama yang biasa itu kekal pada sistem failnya sendiri. Ia juga boleh menjadi symlink kepada direktori milik anda, yang berguna apabila cakera maya berada pada pemacu yang lebih besar. Pemasang mengukur ruang kosong pada sistem fail yang sebenarnya mengandungi `~/.windows`, bukan semestinya sistem fail yang mengandungi direktori utama anda.

Kekalkan laluan cakera dan laluan kongsi sebagai direktori yang berasingan dan tidak bertindih. Pembuangan dengan sengaja mengosongkan direktori cakera tetapi mengekalkan direktori kongsi. Sejurus sebelum pemadaman, Omarchy melakukan pemeriksaan pembendungan berbatas dan enggan membuang apa-apa jika pemeriksaan itu tamat masa atau tidak dapat membuktikan kedua-dua pepohon itu berasingan.

Sebelum VM bermula, Omarchy membuka dan menyemat kedua-dua direktori itu, kemudian bind-mount inode direktori yang tepat itu pada sauh peribadi per pengguna di bawah `/var/lib/omarchy/windows/mounts`. Docker hanya melihat sauh yang dilindungi root itu. Ini mengekalkan lokasi cakera tersuai sambil menghalang proses lain yang berjalan sebagai anda daripada menukar laluan yang telah diperiksa sebelum bekas istimewa itu menggunakannya. Direktori cakera dan direktori kongsi sedia ada diketatkan kepada mod `0700` semasa penghijrahan supaya akaun setempat lain tidak boleh menyemak imbas kandungannya.

Port VM diikat pada localhost sahaja, jadi tiada apa pada rangkaian anda yang boleh mencapai mesin Windows itu. Konsol web juga memerlukan nama pengguna dan kata laluan Windows yang dikonfigurasikan, menghalang akaun setempat lain daripada mengendalikan VM melalui port 8006.

## Had dan pelesenan

Tiada passthrough GPU dengan persediaan ini, jadi ia tidak sesuai untuk permainan atau penyuntingan video. Ia cara yang bagus untuk menjalankan Microsoft Office atau apa-apa lagi yang benar-benar mesti anda ada.

Versi yang dipasang ialah Windows 11 Pro, belum diaktifkan. Anda memerlukan kunci lesen anda sendiri untuk menggunakan ciri yang berpagar.

Jika komputer ini disertakan dengan Windows, kunci OEM masih berada dalam firmware walaupun selepas memasang Omarchy. Cetaknya dengan `omarchy windows key`. Kunci itu terikat pada mesin ini — ia akan mengaktifkan Windows yang dipasang semula pada perkakasan ini, tetapi selalunya tidak akan mengaktifkan VM.

Anda boleh menukar peruntukan sumber kemudian dengan menjalankan `omarchy windows vm install` dalam terminal, yang menulis semula konfigurasi VM daripada jawapan anda. Fail compose itu sendiri kini berada di `/var/lib/omarchy/windows/docker-compose.yml` dan dimiliki oleh root — itu sengaja, supaya proses yang berjalan sebagai anda tidak boleh menulis semulanya dan menyebabkan bring-up istimewa melekapkan keseluruhan cakera anda ke dalam bekas. Jika anda perlu menyuntingnya dengan tangan (contohnya untuk melekapkan peranti USB), suntingnya dengan `sudo` dan lihat semua pilihan pada [projek Dockur Windows](https://github.com/dockur/windows).

Untuk membuang keseluruhannya, gunakan _Remove > Windows_ daripada menu Omarchy. Itu memadamkan cakera VM dalam `~/.windows` dan semua yang dipasang di dalam Windows, jadi salin apa-apa yang anda perlukan keluar dari VM terlebih dahulu. Folder kongsi `~/Windows` anda dibiarkan sahaja.
