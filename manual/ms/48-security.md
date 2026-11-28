# Keselamatan

Omarchy memandang keselamatan dengan amat serius. Sistem pengendalian ini dicipta untuk anda gunakan bagi melakukan _Real Work_ dalam _Real World_. Di mana kehilangan komputer riba tidak akan membawa kepada kecemasan keselamatan. Jadi inilah yang kami lakukan:

1. *Penyulitan cakera penuh dihidupkan secara lalai*: Ini langkah paling penting untuk menjamin perlindungan fizikal data anda. Jika komputer anda hilang atau dicuri, data tersebut disulitkan sepenuhnya menggunakan LUKS standard (Linux Unified Key Setup). Pemasang membolehkan anda memilih untuk tidak menggunakannya bagi mesin pakai buang (lihat [Langkah permulaan](02-getting-started.md)); pemasangan tanpa penyulitan tidak mempunyai sebarang perlindungan ini, dan sesiapa yang memegang pemacu itu boleh membacanya.
2. *Firewall diaktifkan secara lalai*: Semua trafik masuk disekat secara lalai, dengan beberapa pengecualian: port 53317 untuk [LocalSend](https://localsend.org/); pertanyaan DNS kepada pelayan penyelesaian komputer itu sendiri pada alamat jambatan Docker (172.17.0.1), yang diterima daripada julat alamat peribadi yang diberikan Docker kepada containernya; dan DNS multicast (port 5353), yang membolehkan pencetak dan peranti lain pada rangkaian anda saling mencari dan juga mengumumkan nama komputer anda di sana. Selain itu, firewall mengekalkan kebenaran standard UFW untuk ping, mendapatkan alamat daripada router anda (DHCP), dan penemuan UPnP. Malah ssh pun dimatikan sehingga anda menghidupkannya melalui _Setup > Security > SSHD_, yang membenarkan kunci SSH anda, mematikan log masuk kata laluan, dan hanya selepas itu membuka port 22 (dihadkan kadarnya bagi menentang brute force). Kami malah mengunci akses Docker menggunakan persediaan [ufw-docker](https://github.com/chaifeng/ufw-docker) untuk menghalang container anda daripada terdedah secara tidak sengaja kepada dunia.
3. *Arch sentiasa mempunyai kemas kini terkini*: Arch, distro asas yang menjadi dasar binaan Omarchy, ialah pengedaran rolling. Ini bermakna sebarang kelemahan keselamatan yang ditemui dan ditampal dalam mana-mana pakej akan segera tersedia untuk dipasang menggunakan `omarchy-update`. Dengan cara itu anda sentiasa menjalankan versi terkini dan paling selamat bagi segala-galanya.
4. *Omarchy menyelenggarakan pakej dan mirrornya sendiri*: Secara lalai, Omarchy hanya bergantung pada pakej daripada repositori core/extra/multilib milik Arch sendiri (repositori Arch Linux ARM pada mesin ARM, ditambah Asahi ALARM pada Apple Silicon) dan Omarchy Package Repository miliknya sendiri. Anda boleh memasang perisian terus daripada AUR, tetapi pemasangan asas tidak berbuat demikian — hanya beberapa pemasangan pilihan, seperti pelayar pihak ketiga, yang mengambil daripada AUR.
5. *Cloudflare melindungi kami daripada DDoS*: Infrastruktur pengedaran Omarchy — ISO, pakej Omarchy, mirror Arch — dilindungi di sebalik perisai DDoS Cloudflare yang hebat dan dihoskan pada CDN mereka. Ini memberikan ketersediaan yang sangat baik.

## Menukar kata laluan anda

Anda mempunyai dua kata laluan pada pemasangan yang disulitkan: satu yang membuka kunci pemacu semasa but, dan satu yang anda gunakan untuk log masuk dan `sudo`. Persediaan menjadikannya sama. _Update > Password_ dalam menu Omarchy menukar kedua-duanya sekali gus, supaya ia kekal sama: ia meminta kata laluan pemacu semasa, kemudian kata laluan baharu, menukar kata laluan pemacu dan kemudian menetapkan kata laluan log masuk anda supaya sepadan. Tanpa penyulitan pemacu, ia hanya menukar kata laluan log masuk anda. Jika sesuatu perubahan terganggu, jalankan semula _Update > Password_: ia meminta kata laluan yang membuka kunci pemacu sekarang, menyelesaikan perubahan itu, dan menetapkan kata laluan log masuk anda kepadanya. Untuk menukar kata laluan bagi pemacu tersulit yang lain, jalankan `omarchy-drive-password` dalam terminal.

## Menyerahkan mesin yang telah anda gunakan

Jika anda menyerahkan mesin anda kepada orang lain, anda tidak perlu memasangnya semula. Jalankan _Remove > Factory Reset_ dalam menu Omarchy, taip `reset` untuk mengesahkan, masukkan kata laluan penyulitan pemacu anda jika diminta, dan but semula. Itu akan memadam setiap akaun pengguna dan segala-galanya dalam `/home`, membuang semua pakej dan perubahan sistem yang anda buat sejak pemasangan, dan mengosongkan identiti mesin — sambungan rangkaian, kunci hos, dan semuanya. Apa yang muncul semula ialah wizard persediaan daripada but pertama, bersedia untuk pemilik baharunya memasukkan nama, kata laluan, dan kata laluan penyulitan mereka sendiri.

Ia berfungsi dengan memulihkan snapshot asas yang diambil oleh pemasang, jadi ia hanya tersedia pada mesin yang dipasang daripada ISO Omarchy. Dan pada pemacu tanpa penyulitan, tetapan semula ialah pemadaman dan bukannya padam selamat, jadi jika data itu sensitif, lakukan pemasangan baharu sebaliknya.

## Sudo tanpa kata laluan

Kadangkala anda mahu `sudo` berhenti meminta, paling kerap apabila ejen AI melakukan kerja sistem yang panjang untuk anda. _Setup > Security > Passwordless Sudo_ bertanya berapa lama akses dibenarkan: **15 minit**, **1 Jam**, **1 Hari**, atau **Secara Kekal**. Ikon amaran merah muncul di sebelah penunjuk bar menu yang lain semasa akses aktif. Klik ikon itu atau jalankan semula arahan tersebut untuk mematikan akses. Anda juga boleh memberikan bilangan minit anda sendiri (dari 1 hingga 1440) dengan `omarchy-sudo-passwordless 30`, atau gunakan `omarchy-sudo-passwordless permanent`.

Akses bermasa tamat tempoh secara automatik, termasuk sejurus selepas disambung semula daripada suspend yang telah melepasi tarikh akhir. Memulakan semula komputer akan menamatkannya lebih awal. Akses kekal kekal selepas but semula dan kekal diaktifkan sehingga anda mematikannya.

Mengemas kini atau mengalih keluar pakej tetapan Omarchy akan menamatkan sebarang pemberian sementara sebelum sokongan tamat tempohnya berubah. Jika arahan itu melaporkan ralat kebenaran atau pembersihan, selesaikannya sebelum cuba mengaktifkan pemberian lain; ralat tidak bermakna akses tanpa kata laluan tidak aktif.

Fahami perkara ini dengan jelas: semasa ia hidup, apa sahaja yang berjalan sebagai pengguna anda boleh melakukan apa sahaja sebagai root tanpa ditanya. Itulah keseluruhan tujuannya, dan itulah juga keseluruhan risikonya.

## Kunci Tandatangan

Kunci awam untuk semua tandatangan ISO dan pakej repo Omarchy ialah `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([sahkan di openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakej `omarchy/omarchy-keyring` turut mengandungi kunci ini dan akan digunakan untuk melancarkan sebarang kemas kini yang berpotensi dengan lancar.

Anda boleh mendapatkan tandatangan bagi mana-mana keluaran ISO dengan menambahkan `.sig` pada URLnya, seperti `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
