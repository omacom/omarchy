# Keselamatan

Omarchy mengambil keselamatan dengan sangat serius. Ini sepatutnya menjadi sistem pengendalian yang boleh anda gunakan untuk melakukan _Kerja Sebenar_ di _Dunia Sebenar_. Di mana kehilangan laptop tidak boleh membawa kepada kecemasan keselamatan. Jadi inilah apa yang kami lakukan:

1. *Penyulitan cakera penuh adalah wajib*: Ini ialah langkah paling penting untuk mengamankan perlindungan fizikal data anda. Jika komputer anda hilang atau dicuri, data disulitkan sepenuhnya menggunakan LUKS standard (Linux Unified Key Setup).
2. *Tembok api dibolehkan secara lalai*: Semua trafik masuk disekat secara lalai kecuali port 53317 untuk [LocalSend](https://localsend.org/). Malah ssh dimatikan sehingga anda menghidupkannya melalui _Persediaan > Keselamatan > SSHD_, yang membuka port 22 (had kadar terhadap brute force) sebagai sebahagian daripada persediaan. Kami malah mengunci akses Docker menggunakan persediaan [ufw-docker](https://github.com/chaifeng/ufw-docker) untuk mengelakkan kontena anda terdedah kepada dunia secara tidak sengaja.
3. *Arch sentiasa mempunyai kemas kini terkini*: Arch, distro asas yang dibina Omarchy di atasnya, ialah edaran rolling. Ini bermakna sebarang kelemahan keselamatan yang ditemui dan ditampal dalam mana-mana pakej tersedia dengan cepat untuk dipasang menggunakan `omarchy-update`. Anda sentiasa menjalankan versi terkini dan paling selamat bagi segala-galanya dengan cara itu.
4. *Omarchy mengekalkan pakej dan cerminnya sendiri*: Omarchy hanya bergantung pada pakej dari repo core/extra/multilib Arch sendiri dan Repositori Pakej Omarchy sendiri secara lalai. Anda boleh memasang perisian secara langsung dari AUR, tetapi pemasangan asas tidak — hanya beberapa pemasangan pilihan, seperti pelayar pihak ketiga, menarik dari AUR.
5. *Cloudflare melindungi kami dari DDoS*: Semua infrastruktur pengedaran Omarchy — ISO, pakej Omarchy, cermin Arch — dilindungi di sebalik perisai DDoS Cloudflare yang hebat dan dihoskan pada CDN mereka. Ini memberikan ketersediaan yang sangat baik.

## Menukar kata laluan anda

Anda mempunyai dua kata laluan pada pemasangan tersulit: yang membuka kunci pemacu semasa but, dan yang anda log masuk dan gunakan untuk `sudo`. Persediaan menjadikannya sama. Kedua-duanya boleh ditukar di bawah _Kemas Kini > Kata Laluan_ dalam menu Omarchy — _Penyulitan Pemacu_ untuk yang pertama, _Pengguna_ untuk yang kedua. Menukar kata laluan pemacu meminta yang semasa dahulu, jadi sediakan ia. Jika perubahan terganggu, jalankan _Penyulitan Pemacu_ semula: ia meminta kata laluan yang membuka kunci pemacu sekarang dan menyelesaikan perubahan.

## Menyerahkan mesin yang telah anda gunakan

Jika anda menyerahkan mesin anda kepada orang lain, anda tidak perlu memasangnya semula. Jalankan _Persediaan > Tetapkan Semula Komputer_ dalam menu Omarchy, taip `reset` untuk mengesahkan, dan but semula. Itu memadamkan setiap akaun pengguna dan segala-galanya dalam `/home`, membuang semua pakej dan perubahan sistem yang anda buat sejak pemasangan, dan membersihkan identiti mesin — sambungan rangkaian, kunci hos, dan segala-galanya. Apa yang muncul semula ialah wizard persediaan dari but pertama, sedia untuk pemilik baharunya memasukkan nama, kata laluan, dan kata laluan penyulitan mereka sendiri.

Ia berfungsi dengan memulihkan syot baseline yang diambil pemasang, jadi ia hanya tersedia pada mesin yang dipasang dari ISO Omarchy. Dan pada pemacu tanpa penyulitan, tetapan semula ialah pemadaman dan bukannya pemadaman selamat, jadi jika data itu sensitif, lakukan pemasangan baharu sebaliknya.

## Sudo tanpa kata laluan

Kadangkala anda mahu `sudo` berhenti bertanya, paling kerap apabila ejen AI melakukan kerja sistem yang panjang untuk anda. _Persediaan > Keselamatan > Sudo Tanpa Kata Laluan_ bertanya berapa lama untuk membenarkan akses: **15 minit**, **1 Jam**, **1 Hari**, atau **Kekal**. Ikon amaran merah muncul di samping penunjuk bar menu lain semasa akses aktif. Kliknya atau jalankan arahan semula untuk mematikan akses. Anda juga boleh menghantar bilangan minit anda sendiri (dari 1 hingga 1440) dengan `omarchy-sudo-passwordless 30`, atau gunakan `omarchy-sudo-passwordless permanent`.

Akses bermasa tamat tempoh secara automatik, termasuk serta-merta selepas menyambung semula dari suspend yang melintasi tarikh akhir. Memulakan semula komputer menamatkannya lebih awal. Akses kekal kekal selepas but semula dan kekal dibolehkan sehingga anda melumpuhkannya.

Mengemas kini atau membuang pakej tetapan Omarchy menamatkan sebarang pemberian sementara sebelum sokongan tamat tempohnya berubah. Jika arahan melaporkan ralat kebenaran atau pembersihan, selesaikannya sebelum cuba membenarkan pemberian lain; ralat tidak bermakna akses tanpa kata laluan tidak aktif.

Jelas tentang perkara ini: semasa ia dihidupkan, apa sahaja yang berjalan sebagai pengguna anda boleh melakukan apa sahaja sebagai root tanpa ditanya. Itulah maksudnya, dan itulah juga risikonya.

## Kekunci Tandatangan

Kekunci awam untuk semua tandatangan ISO dan pakej repo Omarchy ialah `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([sahkan di openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakej `omarchy/omarchy-keyring` mengandungi ini juga dan akan digunakan untuk melancarkan sebarang kemas kini berpotensi dengan lancar.

Anda boleh mencari tandatangan untuk mana-mana keluaran ISO dengan menambah .sig pada URL. Seperti https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
