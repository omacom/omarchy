# Keselamatan

Omarchy memandang keselamatan dengan amat serius. Ini bertujuan menjadi sistem pengendalian yang boleh anda gunakan untuk melakukan _Kerja Sebenar_ di _Dunia Sebenar_. Di mana kehilangan komputer riba tidak boleh membawa kepada kecemasan keselamatan. Jadi inilah yang kami lakukan:

1. *Penyulitan cakera penuh adalah wajib*: Ini langkah paling penting untuk menjamin perlindungan fizikal data anda. Jika komputer anda hilang atau dicuri, data disulitkan sepenuhnya menggunakan LUKS (Linux Unified Key Setup) standard.
2. *Firewall didayakan secara lalai*: Semua trafik masuk disekat secara lalai kecuali port 53317 untuk [LocalSend](https://localsend.org/). Malah ssh pun dimatikan sehingga anda menghidupkannya melalui _Setup > Security > SSHD_, yang membuka port 22 (dihadkan kadarnya terhadap brute force) sebagai sebahagian daripada persediaan. Kami malah mengunci akses Docker menggunakan persediaan [ufw-docker](https://github.com/chaifeng/ufw-docker) untuk menghalang container anda daripada terdedah kepada dunia secara tidak sengaja.
3. *Arch sentiasa mempunyai kemas kini terkini*: Arch, distro asas yang menjadi dasar binaan Omarchy, ialah pengedaran rolling. Ini bermakna sebarang kerentanan keselamatan yang ditemui dan ditampal dalam mana-mana pakej akan segera tersedia untuk dipasang menggunakan `omarchy-update`. Dengan cara itu anda sentiasa menjalankan versi terkini dan paling selamat bagi semuanya.
4. *Omarchy menyelenggara pakej dan mirrornya sendiri*: Secara lalai, Omarchy hanya bergantung pada pakej daripada repositori core/extra/multilib milik Arch sendiri dan Omarchy Package Repository miliknya sendiri. Anda boleh memasang perisian terus daripada AUR, tetapi pemasangan asas tidak berbuat demikian — hanya beberapa pemasangan pilihan, seperti pelayar pihak ketiga, yang mengambil daripada AUR.
5. *Cloudflare melindungi kami daripada DDoS*: Infrastruktur pengedaran Omarchy — ISO, pakej Omarchy, mirror Arch — dilindungi di sebalik perisai DDoS Cloudflare yang ampuh dan dihoskan pada CDN mereka. Ini memberikan ketersediaan yang sangat baik.

## Menukar kata laluan anda

Anda mempunyai dua kata laluan pada pemasangan tersulit: satu yang membuka kunci pemacu semasa but, dan satu yang anda gunakan untuk log masuk dan `sudo`. Setup menjadikannya sama. Kedua-duanya boleh ditukar di bawah _Update > Password_ dalam menu Omarchy — _Drive Encryption_ untuk yang pertama, _User_ untuk yang kedua. Menukar kata laluan pemacu akan meminta kata laluan semasa terlebih dahulu, jadi sediakan kata laluan itu. Jika pertukaran terganggu, jalankan _Drive Encryption_ sekali lagi: ia akan meminta kata laluan yang membuka kunci pemacu sekarang dan menyelesaikan pertukaran itu.

## Menyerahkan mesin yang telah anda gunakan

Jika anda menyerahkan mesin anda kepada orang lain, anda tidak perlu memasangnya semula. Jalankan _Setup > Reset Computer_ dalam menu Omarchy, taip `reset` untuk mengesahkan, dan but semula. Itu memadamkan setiap akaun pengguna dan semuanya dalam `/home`, membuang semua pakej dan perubahan sistem yang anda buat sejak pemasangan, dan mengosongkan identiti mesin — sambungan rangkaian, host keys, dan semuanya. Apa yang muncul semula ialah wizard persediaan daripada but pertama, bersedia untuk pemilik baharunya memasukkan nama, kata laluan, dan kata laluan penyulitan mereka sendiri.

Ia berfungsi dengan memulihkan snapshot garis asas yang diambil oleh pemasang, jadi ia hanya tersedia pada mesin yang dipasang daripada ISO Omarchy. Dan pada pemacu tanpa penyulitan, tetapan semula ialah pemadaman dan bukannya padaman selamat, jadi jika datanya sensitif, lakukan pemasangan baharu sebaliknya.

## sudo tanpa kata laluan

Kadangkala anda mahu `sudo` berhenti meminta, selalunya apabila ejen AI sedang melakukan kerja sistem yang panjang untuk anda. _Setup > Security > Passwordless Sudo_ bertanya berapa lama akses dibenarkan: **15 minit**, **1 Jam**, **1 Hari**, atau **Secara Kekal**. Ikon amaran merah muncul di sebelah penunjuk bar menu yang lain semasa akses aktif. Klik ikon itu atau jalankan arahan itu sekali lagi untuk mematikan akses. Anda juga boleh memberikan bilangan minit anda sendiri (dari 1 hingga 1440) dengan `omarchy-sudo-passwordless 30`, atau gunakan `omarchy-sudo-passwordless permanent`.

Akses bermasa tamat tempoh secara automatik, termasuk sejurus selepas disambung semula daripada suspend yang melepasi tarikh akhir. Memulakan semula komputer menamatkannya lebih awal. Akses kekal kekal selepas but semula dan kekal didayakan sehingga anda menyahdayakannya.

Mengemas kini atau mengalih keluar pakej tetapan Omarchy menamatkan sebarang pemberian sementara sebelum sokongan tamat tempohnya berubah. Jika arahan melaporkan ralat kebenaran atau pembersihan, selesaikannya sebelum cuba mendayakan pemberian lain; ralat tidak bermakna akses tanpa kata laluan tidak aktif.

Fahami perkara ini dengan jelas: semasa ia dihidupkan, apa-apa sahaja yang berjalan sebagai pengguna anda boleh melakukan apa-apa sahaja sebagai root tanpa ditanya. Itulah tujuannya, dan itulah juga risikonya.

## Kunci Tandatangan

Kunci awam untuk semua tandatangan ISO dan pakej repo Omarchy ialah `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([sahkan di openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakej `omarchy/omarchy-keyring` turut mengandungi kunci ini dan akan digunakan untuk melancarkan sebarang kemas kini berpotensi dengan lancar.

Anda boleh mendapatkan tandatangan untuk mana-mana keluaran ISO dengan menambahkan `.sig` pada URLnya, seperti `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
