# Tidur sistem

Omarchy mendayakan mod tangguh secara lalai, dan hibernasi setelah ia disediakan, tetapi jika anda menghadapi masalah dengan mana-mana satu daripadanya pada mesin anda, anda boleh mematikannya.

Pada mesin NVIDIA GB10, seperti DGX Spark dan ASUS Ascent GX10, mod tangguh dan hibernasi dimatikan, seperti dalam DGX OS oleh NVIDIA, kerana mod tidur belum terbukti berfungsi pada perkakasan tersebut lagi. Perkara yang sama berlaku untuk ASUS Zenbook A16 (UX3607OA), di mana mod tangguh belum meletakkan cip sepenuhnya ke mod tidur dan boleh tergantung semalaman. Togol tangguh dan persediaan hibernasi tidak terpakai di sana. Untuk menghidupkan semula mod tidur, alih keluar `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` dengan `sudo rm`; Tangguh kemudian akan kembali ke menu, dan hibernasi boleh disediakan seperti pada mesin lain. Menjalankan `sudo omarchy apply hardware --install-user "$USER"` akan meletakkan semula fail tersebut.

### Profil kuasa

Pada komputer riba, Omarchy mengingati profil kuasa anda secara berasingan untuk keadaan dipalamkan dan berjalan menggunakan bateri, dan bertukar antara kedua-duanya apabila anda memalam dan mencabut palam. Secara lalai, ini bermakna prestasi pada AC dan seimbang pada bateri.

Anda boleh melihat apa yang ditawarkan oleh mesin anda dengan `omarchy powerprofiles list`, dan menetapkan yang anda mahu untuk keadaan semasa anda dengan `omarchy powerprofiles set autodetect power-saver`. Untuk menetapkan keadaan yang satu lagi tanpa mencabut apa-apa palam, namakannya secara langsung: `omarchy powerprofiles set battery power-saver`. Apa sahaja yang anda pilih adalah apa yang anda akan dapat semula pada kali seterusnya anda berada dalam keadaan tersebut.

### Togol mod tangguh

Anda menogol mod tangguh dengan menjalankan `omarchy toggle suspend` dari terminal. Itu hanya menunjukkan/menyembunyikan pilihan di bawah _Sistem_ (atau `Super + Esc`), dan kemudian anda boleh melihat sama ada ia berfungsi secara konsisten pada sistem anda. Jika tidak, anda boleh menyembunyikannya semula dengan perintah yang sama.

### Togol hibernasi

Anda menyediakan hibernasi dengan menjalankan `omarchy hibernation setup` dari terminal (ia tidak tersedia pada Mac Apple Silicon). Hibernasi mencipta subvolum /swap pada pemacu but anda sebesar peruntukan RAM fizikal anda, jadi pastikan anda mempunyai banyak ruang kosong. Pada mesin 32GB, anda akan sentiasa memerlukan 32GB+ ruang kosong untuk volum ini. Hibernasi juga memerlukan pemuat but Limine lalai.

Apabila telah disediakan, anda akan melihat pilihan hibernasi di bawah _Sistem_ (atau `Super + Esc`), dan kemudian anda boleh melihat sama ada ia berfungsi secara konsisten pada sistem anda. Jika tidak, anda boleh mengalih keluarnya semula dengan menjalankan `omarchy hibernation remove`.
