# Keselamatan

Omarchy memandang keselamatan dengan amat serius. Sistem pengendalian ini bertujuan untuk digunakan bagi melakukan _Kerja Sebenar_ dalam _Dunia Sebenar_. Kehilangan komputer riba tidak sepatutnya membawa kepada kecemasan keselamatan. Jadi inilah yang kami lakukan:

1. *Penyulitan cakera penuh dihidupkan secara lalai*: Ini ialah langkah paling penting untuk melindungi data anda secara fizikal. Jika komputer anda hilang atau dicuri, data tersebut disulitkan sepenuhnya menggunakan LUKS (Linux Unified Key Setup) standard. Pemasang membenarkan anda memilih untuk tidak menggunakannya bagi mesin pakai buang (lihat [Langkah permulaan](02-getting-started.md)); pemasangan tanpa penyulitan tidak mempunyai perlindungan ini sama sekali, dan sesiapa yang memegang pemacu itu boleh membacanya.
2. *Tembok api diaktifkan secara lalai*: Semua trafik masuk disekat secara lalai, dengan beberapa pengecualian: port 53317 untuk [LocalSend](https://localsend.org/); pertanyaan DNS kepada peleraian komputer itu sendiri di alamat jambatan Docker (172.17.0.1), diterima daripada julat alamat peribadi yang diberikan Docker kepada bekasnya; dan DNS multicast (port 5353), yang membolehkan pencetak dan peranti lain pada rangkaian anda saling mencari dan juga mengumumkan nama komputer anda di situ. Selain itu, tembok api mengekalkan keizinan standard UFW untuk ping, mendapatkan alamat daripada penghala anda (DHCP), dan penemuan UPnP. Malah ssh dimatikan sehingga anda menghidupkannya melalui _Persediaan > Keselamatan > SSHD_, yang membuka port 22 (dihadkan kadarnya terhadap serangan brute force) sebagai sebahagian daripada persediaan. Kami juga mengunci akses Docker menggunakan persediaan [ufw-docker](https://github.com/chaifeng/ufw-docker) untuk menghalang bekas anda daripada terdedah kepada dunia secara tidak sengaja.
3. *Arch sentiasa mempunyai kemas kini terkini*: Arch, distro asas yang menjadi asas binaan Omarchy, ialah pengedaran bergulir. Ini bermakna sebarang kerentanan keselamatan yang ditemui dan ditampal dalam mana-mana pakej akan tersedia dengan cepat untuk dipasang menggunakan `omarchy-update`. Dengan cara itu, anda sentiasa menjalankan versi terkini dan paling selamat bagi segala-galanya.
4. *Omarchy menyelenggara pakej dan cerminnya sendiri*: Secara lalai, Omarchy hanya bergantung pada pakej daripada repositori core/extra/multilib milik Arch sendiri dan Omarchy Package Repository miliknya sendiri. Anda boleh memasang perisian terus daripada AUR, tetapi pemasangan asas tidak berbuat demikian — hanya beberapa pemasangan pilihan, seperti pelayar pihak ketiga, yang mengambil pakej daripada AUR.
5. *Cloudflare melindungi kami daripada DDoS*: Infrastruktur pengedaran Omarchy — ISO, pakej Omarchy, cermin Arch — dilindungi di sebalik perisai DDoS Cloudflare yang ampuh dan dihoskan pada CDN mereka. Ini memberikan ketersediaan yang sangat baik.

## Menukar kata laluan anda

Anda mempunyai dua kata laluan pada pemasangan yang disulitkan: satu yang membuka kunci pemacu semasa but, dan satu yang anda gunakan untuk log masuk dan `sudo`. Persediaan menjadikannya sama. Kedua-duanya boleh ditukar di bawah _Kemas Kini > Kata Laluan_ dalam menu Omarchy — _Penyulitan Pemacu_ untuk yang pertama, _Pengguna_ untuk yang kedua. Menukar kata laluan pemacu akan meminta kata laluan semasa terlebih dahulu, jadi pastikan ia ada di tangan. Jika perubahan terganggu, jalankan _Penyulitan Pemacu_ sekali lagi: ia akan meminta kata laluan yang membuka kunci pemacu pada masa ini dan menyudahkan perubahan tersebut.

## Menyerahkan mesin yang telah anda gunakan

Jika anda menyerahkan mesin anda kepada orang lain, anda tidak perlu memasangnya semula. Jalankan _Persediaan > Tetapkan Semula Komputer_ dalam menu Omarchy, taip `reset` untuk mengesahkan, dan but semula. Tindakan itu memadamkan setiap akaun pengguna dan segala-galanya dalam `/home`, membuang semua pakej dan perubahan sistem yang anda buat sejak pemasangan, dan mengosongkan identiti mesin — sambungan rangkaian, kunci hos, dan segala-galanya. Apa yang muncul semula ialah wizard persediaan daripada but pertama, bersedia untuk pemilik baharunya memasukkan nama, kata laluan, dan kata laluan penyulitan mereka sendiri.

Ia berfungsi dengan memulihkan snapshot garis asas yang diambil oleh pemasang, jadi ia hanya tersedia pada mesin yang dipasang daripada ISO Omarchy. Dan pada pemacu tanpa penyulitan, tetapan semula ialah pemadaman dan bukannya padam selamat, jadi jika data itu sensitif, lakukan pemasangan baharu sebaliknya.

## sudo tanpa kata laluan

Kadangkala anda mahu `sudo` berhenti bertanya, selalunya apabila ejen AI melakukan kerja sistem yang panjang untuk anda. _Persediaan > Keselamatan > Sudo Tanpa Kata Laluan_ bertanya berapa lama akses dibenarkan: **15 minit**, **1 Jam**, **1 Hari**, atau **Secara Kekal**. Ikon amaran merah muncul di sebelah penunjuk bar menu yang lain semasa akses aktif. Klik ikon itu atau jalankan arahan itu sekali lagi untuk mematikan akses. Anda juga boleh memberikan bilangan minit anda sendiri (dari 1 hingga 1440) dengan `omarchy-sudo-passwordless 30`, atau gunakan `omarchy-sudo-passwordless permanent`.

Akses bermasa tamat tempoh secara automatik, termasuk serta-merta selepas disambung semula daripada penggantungan yang melepasi tarikh akhir. Memulakan semula komputer menamatkannya lebih awal. Akses kekal kekal selepas but semula dan kekal diaktifkan sehingga anda melumpuhkannya.

Mengemas kini atau mengalih keluar pakej tetapan Omarchy menamatkan sebarang pemberian sementara sebelum sokongan tamat tempohnya berubah. Jika arahan melaporkan ralat kebenaran atau pembersihan, selesaikannya sebelum cuba mengaktifkan pemberian lain; ralat tidak bermakna akses tanpa kata laluan tidak aktif.

Fahami perkara ini dengan jelas: semasa ia dihidupkan, apa sahaja yang berjalan sebagai pengguna anda boleh melakukan apa sahaja sebagai root tanpa ditanya. Itulah tujuannya, dan itulah juga risikonya.

## Kunci Tandatangan

Kunci awam untuk semua tandatangan ISO dan pakej repo Omarchy ialah `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([sahkan di openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakej `omarchy/omarchy-keyring` turut mengandungi kunci ini dan akan digunakan untuk melancarkan sebarang kemas kini yang berpotensi dengan lancar.

Anda boleh mendapatkan tandatangan untuk mana-mana keluaran ISO dengan menambahkan `.sig` pada URL-nya, seperti `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
