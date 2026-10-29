# Tidur sistem

Omarchy mengaktifkan gantung dan hibernasi secara lalai, tetapi jika anda menghadapi masalah dengan mana-mana satu daripadanya pada mesin anda, anda boleh mematikannya.

Pada mesin NVIDIA GB10, seperti DGX Spark dan ASUS Ascent GX10, gantung dan hibernasi dimatikan, sama seperti dalam DGX OS NVIDIA, kerana tidur belum terbukti berfungsi pada perkakasan tersebut. Togol gantung dan persediaan hibernasi tidak terpakai di situ. Untuk menghidupkan semula tidur, alih keluar `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` dengan `sudo rm`; Suspend kemudian akan kembali ke menu, dan hibernasi boleh disediakan seperti pada mesin lain. Menjalankan `sudo omarchy apply hardware --install-user "$USER"` akan meletakkan semula fail tersebut.

### Profil kuasa

Pada komputer riba, Omarchy mengingati profil kuasa anda secara berasingan untuk keadaan dipasang pada sumber kuasa dan berjalan menggunakan bateri, dan bertukar antara kedua-duanya apabila anda memasang dan mencabut palam. Secara lalai, itu bermakna performance pada AC dan balanced pada bateri.

Anda boleh melihat apa yang ditawarkan oleh mesin anda dengan `omarchy powerprofiles list`, dan menetapkan profil yang anda mahu untuk keadaan semasa anda dengan `omarchy powerprofiles set autodetect power-saver`. Untuk menetapkan keadaan yang satu lagi tanpa mencabut apa-apa palam, namakannya secara langsung: `omarchy powerprofiles set battery power-saver`. Apa sahaja yang anda pilih ialah apa yang anda akan dapat semula pada kali seterusnya anda berada dalam keadaan tersebut.

### Togol gantung

Anda menogol gantung dengan menjalankan `omarchy toggle suspend` dari terminal. Itu hanya memaparkan/menyembunyikan pilihan tersebut di bawah _System_ (atau `Super + Esc`), dan kemudian anda boleh melihat sama ada ia berfungsi secara konsisten pada sistem anda. Jika tidak, anda boleh menyembunyikannya semula dengan perintah yang sama.

### Togol hibernasi

Anda menyediakan hibernasi dengan menjalankan `omarchy hibernation setup` dari terminal. Hibernasi mencipta subvolum /swap pada pemacu but anda sebesar peruntukan RAM fizikal anda, jadi pastikan anda mempunyai banyak ruang kosong yang mencukupi. Pada mesin 32GB, anda sentiasa memerlukan 32GB+ ruang kosong untuk volum ini. Hibernasi juga memerlukan pemuat but lalai Limine.

Apabila telah disediakan, anda akan melihat pilihan hibernasi di bawah _System_ (atau `Super + Esc`), dan kemudian anda boleh melihat sama ada ia berfungsi secara konsisten pada sistem anda. Jika tidak, anda boleh mengalih keluarnya semula dengan menjalankan `omarchy hibernation remove`.
