# Keselamatan

Omarchy memandang keselamatan dengan amat serius. Ini bertujuan menjadi sistem pengendalian yang anda boleh gunakan untuk melakukan _Kerja Sebenar_ di _Dunia Sebenar_. Di mana kehilangan komputer riba tidak boleh membawa kepada kecemasan keselamatan. Jadi inilah yang kami lakukan:

1. *Penyulitan cakera penuh dihidupkan secara lalai*: Ini ialah langkah paling penting untuk menjamin perlindungan fizikal data anda. Jika komputer anda hilang atau dicuri, data disulitkan sepenuhnya menggunakan LUKS standard (Linux Unified Key Setup). Pemasang membolehkan anda memilih untuk tidak menggunakannya bagi mesin yang boleh dibuang (lihat [Bermula](02-getting-started.md)); pemasangan tanpa penyulitan tidak mempunyai perlindungan ini langsung, dan sesiapa yang memegang pemacu itu boleh membacanya.
2. *Firewall diaktifkan secara lalai*: Semua trafik masuk disekat secara lalai, dengan beberapa pengecualian: port 53317 untuk [LocalSend](https://localsend.org/); pertanyaan DNS kepada penyelesai komputer itu sendiri di alamat jambatan Docker (172.17.0.1), diterima daripada julat alamat peribadi yang Docker berikan kepada containernya; dan DNS multicast (port 5353), yang membenarkan pencetak dan peranti lain pada rangkaian anda menemui satu sama lain dan juga mengumumkan nama komputer anda di sana. Selain itu, firewall mengekalkan kebenaran standard UFW untuk ping, mendapatkan alamat daripada router anda (DHCP), dan penemuan UPnP. Malah ssh dimatikan sehingga anda menghidupkannya melalui _Setup > Security > SSHD_, yang membuka port 22 (dihadkan kadarnya terhadap brute force) sebagai sebahagian daripada persediaan. Kami malah mengunci akses Docker menggunakan persediaan [ufw-docker](https://github.com/chaifeng/ufw-docker) untuk menghalang container anda daripada terdedah secara tidak sengaja kepada dunia.
3. *Arch sentiasa mempunyai kemas kini terkini*: Arch, distro asas yang menjadi asas binaan Omarchy, ialah pengedaran rolling. Ini bermakna sebarang kerentanan keselamatan yang ditemui dan ditampal dalam mana-mana pakej akan tersedia dengan cepat untuk dipasang menggunakan `omarchy-update`. Dengan cara itu, anda sentiasa menjalankan versi terkini dan paling selamat bagi segala-galanya.
4. *Omarchy menyelenggara pakej dan mirrornya sendiri*: Omarchy hanya bergantung pada pakej daripada repositori core/extra/multilib Arch sendiri dan Omarchy Package Repository miliknya secara lalai. Anda boleh memasang perisian terus daripada AUR, tetapi pemasangan asas tidak berbuat demikian — hanya beberapa pemasangan pilihan, seperti pelayar pihak ketiga, yang mengambil daripada AUR.
5. *Cloudflare melindungi kami daripada DDoS*: Infrastruktur pengedaran Omarchy — ISO, pakej Omarchy, mirror Arch — dilindungi di sebalik perisai DDoS Cloudflare yang hebat dan dihoskan pada CDN mereka. Ini memberikan ketersediaan yang sangat baik.

## Menukar kata laluan anda

Anda mempunyai dua kata laluan pada pemasangan yang disulitkan: kata laluan yang membuka kunci pemacu semasa but, dan kata laluan yang anda gunakan untuk log masuk dan `sudo`. Persediaan menjadikannya sama. Kedua-duanya boleh ditukar di bawah _Update > Password_ dalam menu Omarchy — _Drive Encryption_ untuk yang pertama, _User_ untuk yang kedua. Menukar kata laluan pemacu akan meminta kata laluan semasa anda terlebih dahulu, jadi sediakan kata laluan itu di sisi anda. Jika perubahan terganggu, jalankan _Drive Encryption_ sekali lagi: ia akan meminta kata laluan yang membuka kunci pemacu sekarang dan menyelesaikan perubahan itu.

## Menyerahkan mesin yang telah anda gunakan

Jika anda menyerahkan mesin anda kepada orang lain, anda tidak perlu memasangnya semula. Jalankan _Remove > Factory Reset_ dalam menu Omarchy, taip `reset` untuk mengesahkan, dan but semula. Itu memadamkan setiap akaun pengguna dan segala-galanya dalam `/home`, membuang semua pakej dan perubahan sistem yang anda buat sejak pemasangan, dan mengosongkan identiti mesin — sambungan rangkaian, host keys, dan segala-galanya. Apa yang muncul semula ialah wizard persediaan daripada but pertama, bersedia untuk pemilik baharunya memasukkan nama, kata laluan, dan kata laluan penyulitan mereka sendiri.

Ia berfungsi dengan memulihkan snapshot garis asas yang diambil oleh pemasang, jadi ia hanya tersedia pada mesin yang dipasang daripada ISO Omarchy. Dan pada pemacu tanpa penyulitan, tetapan semula ialah pemadaman dan bukannya padam selamat, jadi jika data itu sensitif, lakukan pemasangan baharu sebaliknya.

## sudo Tanpa Kata Laluan

Kadangkala anda mahu `sudo` berhenti bertanya, selalunya apabila ejen AI melakukan kerja sistem yang panjang untuk anda. _Setup > Security > Passwordless Sudo_ bertanya berapa lama akses dibenarkan: **15 minit**, **1 Jam**, **1 Hari**, atau **Secara Kekal**. Ikon amaran merah muncul di sebelah penunjuk bar menu lain semasa akses aktif. Klik ikon itu atau jalankan arahan itu sekali lagi untuk mematikan akses. Anda juga boleh menghantar bilangan minit anda sendiri (daripada 1 hingga 1440) dengan `omarchy-sudo-passwordless 30`, atau gunakan `omarchy-sudo-passwordless permanent`.

Akses bermasa tamat tempoh secara automatik, termasuk sejurus selepas disambung semula daripada suspend yang telah melepasi tarikh akhir. Memulakan semula komputer menamatkannya lebih awal. Akses kekal kekal selepas but semula dan kekal diaktifkan sehingga anda melumpuhkannya.

Mengemas kini atau mengalih keluar pakej tetapan Omarchy menamatkan sebarang pemberian sementara sebelum sokongan tamat tempohnya berubah. Jika arahan itu melaporkan ralat kebenaran atau pembersihan, selesaikannya sebelum cuba mengaktifkan pemberian lain; ralat tidak bermakna akses tanpa kata laluan tidak aktif.

Sedari perkara ini dengan jelas: semasa ia dihidupkan, apa sahaja yang berjalan sebagai pengguna anda boleh melakukan apa sahaja sebagai root tanpa ditanya. Itulah tujuannya, dan itulah juga risikonya.

## Kunci Tandatangan

Kunci awam untuk semua tandatangan ISO dan pakej repo Omarchy ialah `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([sahkan di openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakej `omarchy/omarchy-keyring` turut mengandungi kunci ini dan akan digunakan untuk melancarkan sebarang kemas kini berpotensi dengan lancar.

Anda boleh mendapatkan tandatangan untuk sebarang keluaran ISO dengan menambahkan `.sig` pada URLnya, seperti `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
