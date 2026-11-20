# Tidur sistem

Omarchy mengaktifkan tangguh dan hibernasi secara lalai, tetapi jika anda mengalami masalah dengan mana-mana satu daripadanya pada mesin anda, anda boleh mematikannya.

Pada mesin NVIDIA GB10, seperti DGX Spark dan ASUS Ascent GX10, tangguh dan hibernasi dimatikan, sama seperti dalam DGX OS NVIDIA, kerana tidur belum terbukti berfungsi pada perkakasan itu lagi. Begitu juga dengan ASUS Zenbook A16 (UX3607OA), di mana tangguh belum meletakkan cip tidur sepenuhnya dan boleh tersangkut semalaman. Togol tangguh dan persediaan hibernasi tidak terpakai di sana. Untuk menghidupkan semula tidur, buang `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` dengan `sudo rm`; Suspend kemudian kembali ke menu, dan hibernasi boleh disediakan seperti pada mesin lain. Menjalankan `sudo omarchy apply hardware --install-user "$USER"` meletakkan semula fail itu.

### Profil kuasa

Pada komputer riba, Omarchy mengingati profil kuasa anda secara berasingan untuk keadaan dipalamkan dan berjalan menggunakan bateri, dan bertukar antara kedua-duanya apabila anda memalam dan mencabut palam. Secara lalai, itu bermakna prestasi pada AC dan seimbang pada bateri.

Anda boleh melihat apa yang ditawarkan oleh mesin anda dengan `omarchy powerprofiles list`, dan tetapkan profil yang anda mahu untuk keadaan semasa anda dengan `omarchy powerprofiles set autodetect power-saver`. Untuk menetapkan keadaan yang satu lagi tanpa mencabut apa-apa, namakannya secara langsung: `omarchy powerprofiles set battery power-saver`. Apa sahaja yang anda pilih ialah apa yang anda akan dapat semula pada kali seterusnya anda berada dalam keadaan itu.

### Togol tangguh

Anda menogol tangguh dengan menjalankan `omarchy toggle suspend` dari terminal. Itu hanya memaparkan/menyembunyikan pilihan di bawah _Sistem_ (atau `Super + Esc`), dan kemudian anda boleh melihat sama ada ia berfungsi secara konsisten pada sistem anda. Jika tidak, anda boleh menyembunyikannya semula dengan arahan yang sama.

### Togol hibernasi

Anda menyediakan hibernasi dengan menjalankan `omarchy hibernation setup` dari terminal. Hibernasi mencipta subvolum /swap pada pemacu but anda sebesar peruntukan RAM fizikal anda, jadi pastikan anda mempunyai banyak ruang kosong. Pada mesin 32GB, anda sentiasa memerlukan 32GB+ ruang kosong untuk volum ini. Hibernasi juga memerlukan pemuat but Limine lalai.

Apabila telah disediakan, anda akan melihat pilihan hibernate di bawah _Sistem_ (atau `Super + Esc`), dan kemudian anda boleh melihat sama ada ia berfungsi secara konsisten pada sistem anda. Jika tidak, anda boleh membuangnya semula dengan menjalankan `omarchy hibernation remove`.
