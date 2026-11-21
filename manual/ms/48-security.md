# Keselamatan

Omarchy mengambil keselamatan dengan amat serius. Ini bertujuan menjadi sebuah sistem pengendalian yang boleh anda gunakan untuk melakukan _Kerja Sebenar_ di _Dunia Sebenar_. Di mana kehilangan sebuah komputer riba tidak boleh membawa kepada kecemasan keselamatan. Jadi inilah yang kami lakukan:

1. *Penyulitan cakera penuh dihidupkan secara lalai*: Ini langkah paling penting untuk menjamin perlindungan fizikal data anda. Jika komputer anda hilang atau dicuri, data tersebut disulitkan sepenuhnya menggunakan LUKS (Linux Unified Key Setup) yang standard. Pemasang membenarkan anda untuk tidak menggunakannya bagi mesin pakai buang (lihat [Bermula](02-getting-started.md)); sebuah pemasangan tanpa penyulitan tidak mempunyai sebarang perlindungan ini, dan sesiapa yang memegang pemacu itu boleh membacanya.
2. *Firewall diaktifkan secara lalai*: Semua trafik masuk disekat secara lalai, dengan beberapa pengecualian: port 53317 untuk [LocalSend](https://localsend.org/); pertanyaan DNS kepada penyelesai komputer itu sendiri pada alamat jambatan Docker (172.17.0.1), yang diterima daripada julat alamat peribadi yang Docker berikan kepada containernya; dan DNS multicast (port 5353), yang membenarkan pencetak dan peranti lain pada rangkaian anda untuk menemui satu sama lain serta turut mengumumkan nama komputer anda di sana. Selain itu, firewall mengekalkan kebenaran standard UFW untuk ping, mendapatkan alamat daripada router anda (DHCP), dan penemuan UPnP. Malah ssh dimatikan sehingga anda menghidupkannya melalui _Setup > Security > SSHD_, yang membenarkan kunci SSH anda, mematikan log masuk menggunakan kata laluan, dan hanya selepas itu membuka port 22 (dihadkan kadarnya terhadap brute force). Kami malah mengunci akses Docker menggunakan persediaan [ufw-docker](https://github.com/chaifeng/ufw-docker) untuk menghalang container anda daripada terdedah kepada dunia secara tidak sengaja.
3. *Arch sentiasa mempunyai kemas kini terkini*: Arch, distro asas yang menjadi tunjang binaan Omarchy, ialah sebuah pengedaran rolling. Ini bermakna sebarang kerentanan keselamatan yang ditemui dan ditampal dalam mana-mana pakej akan segera tersedia untuk dipasang menggunakan `omarchy-update`. Dengan cara itu, anda sentiasa menjalankan versi terkini dan paling selamat bagi segala-galanya.
4. *Omarchy menyelenggara pakej dan mirrornya sendiri*: Omarchy hanya bergantung pada pakej daripada repositori core/extra/multilib Arch sendiri (Arch Linux ARM pada mesin ARM, serta Asahi ALARM pada Apple Silicon) dan Omarchy Package Repository miliknya sendiri secara lalai. Anda boleh memasang perisian terus daripada AUR, tetapi pemasangan asas tidak berbuat demikian — hanya beberapa pemasangan pilihan, seperti pelayar pihak ketiga, yang mengambil daripada AUR.
5. *Cloudflare melindungi kami daripada DDoS*: Infrastruktur pengedaran Omarchy — ISO, pakej Omarchy, mirror Arch — dilindungi di sebalik perisai DDoS Cloudflare yang kukuh dan dihoskan pada CDN mereka. Ini memberikan ketersediaan yang sangat hebat.

## Menukar kata laluan anda

Anda mempunyai dua kata laluan pada sebuah pemasangan yang disulitkan: satu yang membuka kunci pemacu semasa boot, dan satu lagi yang anda gunakan untuk log masuk dan `sudo`. Setup menjadikan kedua-duanya sama. Kedua-duanya boleh ditukar di bawah _Update > Password_ dalam menu Omarchy — _Drive Encryption_ untuk yang pertama, _User_ untuk yang kedua. Menukar kata laluan pemacu akan meminta kata laluan semasa terlebih dahulu, jadi sediakan ia di tangan. Jika pertukaran terganggu, jalankan _Drive Encryption_ sekali lagi: ia akan meminta kata laluan yang membuka kunci pemacu sekarang dan menyelesaikan pertukaran tersebut.

## Menyerahkan mesin yang telah anda gunakan

Jika anda menyerahkan mesin anda kepada orang lain, anda tidak perlu memasangnya semula. Jalankan _Remove > Factory Reset_ dalam menu Omarchy, taip `reset` untuk mengesahkan, masukkan kata laluan penyulitan pemacu anda jika diminta, dan reboot. Itu akan memadam setiap akaun pengguna dan segala-galanya dalam `/home`, membuang semua pakej dan perubahan sistem yang telah anda buat sejak pemasangan, serta membersihkan identiti mesin — sambungan rangkaian, kunci hos, dan segala-galanya. Apa yang muncul semula ialah wizard persediaan daripada boot pertama, sedia untuk pemilik baharunya memasukkan nama, kata laluan, dan kata laluan penyulitan mereka sendiri.

Ia berfungsi dengan memulihkan snapshot asas yang diambil oleh pemasang, jadi ia hanya tersedia pada mesin yang dipasang daripada ISO Omarchy. Dan pada sebuah pemacu tanpa penyulitan, reset ialah pemadaman dan bukannya padam selamat, jadi jika data tersebut sensitif, lakukan pemasangan baharu sebaliknya.

## sudo tanpa kata laluan

Kadangkala anda mahu `sudo` berhenti meminta, selalunya apabila sebuah ejen AI sedang melakukan kerja sistem yang panjang untuk anda. _Setup > Security > Passwordless Sudo_ bertanya berapa lama akses dibenarkan: **15 minutes**, **1 Hour**, **1 Day**, atau **Permanently**. Sebuah ikon amaran merah muncul di sebelah penunjuk bar menu yang lain semasa akses aktif. Klik ikon tersebut atau jalankan arahan itu sekali lagi untuk mematikan akses. Anda juga boleh memberikan bilangan minit anda sendiri (daripada 1 hingga 1440) dengan `omarchy-sudo-passwordless 30`, atau gunakan `omarchy-sudo-passwordless permanent`.

Akses bermasa tamat tempoh secara automatik, termasuk serta-merta selepas menyambung semula daripada suspend yang telah melepasi tarikh akhir. Memulakan semula komputer menamatkannya lebih awal. Akses kekal kekal selepas reboot dan kekal diaktifkan sehingga anda mematikannya.

Mengemas kini atau mengalih keluar pakej tetapan Omarchy menamatkan sebarang pemberian sementara sebelum sokongan tamat tempohnya berubah. Jika arahan tersebut melaporkan ralat kebenaran atau pembersihan, selesaikannya sebelum cuba mengaktifkan pemberian lain; sesuatu ralat tidak bermakna akses tanpa kata laluan tidak aktif.

Buka mata tentang perkara ini: semasa ia dihidupkan, apa sahaja yang berjalan sebagai pengguna anda boleh melakukan apa sahaja sebagai root tanpa ditanya. Itulah tujuan sebenarnya, dan itulah juga risiko sebenarnya.

## Kunci Tandatangan

Kunci awam untuk semua tandatangan ISO dan pakej repo Omarchy ialah `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([sahkan di openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakej `omarchy/omarchy-keyring` turut mengandungi kunci ini dan akan digunakan untuk melancarkan sebarang kemas kini yang berpotensi dengan lancar.

Anda boleh menemui tandatangan untuk mana-mana keluaran ISO dengan menambah `.sig` pada URLnya, seperti `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
