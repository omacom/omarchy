# Tidur sistem

Omarchy membolehkan suspend dan hibernasi secara lalai, tetapi jika anda menghadapi masalah dengan mana-mana satu daripadanya pada mesin anda, anda boleh mematikannya.

### Profil kuasa

Pada laptop, Omarchy mengingati profil kuasa anda secara berasingan untuk keadaan dipasang pada kuasa dan berjalan menggunakan bateri, dan bertukar antara kedua-duanya apabila anda mencucuk dan mencabut. Secara lalai, itu bermakna prestasi pada AC dan seimbang pada bateri.

Anda boleh melihat apa yang ditawarkan mesin anda dengan `omarchy powerprofiles list`, dan menetapkan profil yang anda mahukan untuk keadaan semasa anda dengan `omarchy powerprofiles set autodetect power-saver`. Untuk menetapkan keadaan yang satu lagi tanpa mencabut apa-apa, namakannya secara langsung: `omarchy powerprofiles set battery power-saver`. Apa sahaja yang anda pilih ialah apa yang anda akan dapat semula pada kali seterusnya anda berada dalam keadaan itu.

### Togol suspend

Anda menogol suspend dengan menjalankan `omarchy toggle suspend` dari terminal. Itu hanya mendedahkan/menyembunyikan pilihan di bawah _Sistem_ (atau `Super + Esc`), dan kemudian anda boleh melihat sama ada ia berfungsi secara konsisten pada sistem anda. Jika tidak, anda boleh menyembunyikannya semula dengan arahan yang sama.

### Togol hibernasi

Anda menyediakan hibernasi dengan menjalankan `omarchy hibernation setup` dari terminal. Hibernasi mencipta subvolume /swap pada pemacu but anda sebesar peruntukan RAM fizikal anda, jadi pastikan anda mempunyai banyak ruang lebih. Pada mesin 32GB, anda sentiasa memerlukan 32GB+ ruang kosong untuk volume ini. Hibernasi juga memerlukan pemuat but Limine lalai.

Apabila sudah disediakan, anda akan melihat pilihan hibernasi di bawah _Sistem_ (atau `Super + Esc`), dan kemudian anda boleh melihat sama ada ia berfungsi secara konsisten pada sistem anda. Jika tidak, anda boleh membuangnya semula dengan menjalankan `omarchy hibernation remove`.
