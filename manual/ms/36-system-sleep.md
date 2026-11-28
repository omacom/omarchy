# Tidur sistem

Omarchy mengaktifkan suspend secara lalai, dan hibernation sebaik sahaja ia disediakan, tetapi jika anda menghadapi masalah dengan mana-mana satu daripadanya pada mesin anda, anda boleh mematikannya.

Pada mesin NVIDIA GB10, seperti DGX Spark dan ASUS Ascent GX10, suspend dan hibernation dimatikan, sama seperti dalam DGX OS NVIDIA, kerana tidur belum terbukti berfungsi pada perkakasan tersebut lagi. Togol suspend dan persediaan hibernation tidak terpakai di sana. Untuk menghidupkan semula tidur, alih keluar `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` dengan `sudo rm`; Suspend kemudian akan kembali ke menu, dan hibernation boleh disediakan seperti pada mesin lain. Menjalankan `sudo omarchy apply hardware --install-user "$USER"` akan meletakkan semula fail tersebut.

### Profil kuasa

Pada komputer riba, Omarchy mengingati profil kuasa anda secara berasingan untuk keadaan dipasang pada kuasa dan berjalan menggunakan bateri, dan bertukar antara kedua-duanya apabila anda memasang dan mencabut plag. Secara lalai, itu bermakna performance pada AC dan balanced pada bateri.

Anda boleh melihat apa yang ditawarkan oleh mesin anda dengan `omarchy powerprofiles list`, dan tetapkan yang anda mahu untuk keadaan anda sekarang dengan `omarchy powerprofiles set autodetect power-saver`. Untuk menetapkan keadaan yang satu lagi tanpa mencabut apa-apa, namakannya secara langsung: `omarchy powerprofiles set battery power-saver`. Apa sahaja yang anda pilih ialah apa yang anda akan dapat semula pada kali seterusnya anda berada dalam keadaan tersebut.

### Togol suspend

Anda menogol suspend dengan menjalankan `omarchy toggle suspend` dari terminal. Itu hanya memaparkan/menyembunyikan pilihan di bawah _System_ (atau `Super + Esc`), dan kemudian anda boleh melihat sama ada ia berfungsi secara konsisten pada sistem anda. Jika tidak, anda boleh menyembunyikannya semula dengan arahan yang sama.

### Togol hibernation

Anda menyediakan hibernation dengan menjalankan `omarchy hibernation setup` dari terminal (ia tidak tersedia pada Mac Apple Silicon). Hibernation mencipta subvolum /swap pada pemacu but anda sebesar peruntukan RAM fizikal anda, jadi pastikan anda mempunyai banyak ruang untuk dikosongkan. Pada mesin 32GB, anda akan sentiasa memerlukan ruang kosong 32GB+ untuk volum ini. Hibernation juga memerlukan pemuat but Limine lalai.

Apabila sudah disediakan, anda akan melihat pilihan hibernate di bawah _System_ (atau `Super + Esc`), dan kemudian anda boleh melihat sama ada ia berfungsi secara konsisten pada sistem anda. Jika tidak, anda boleh mengalih keluarnya semula dengan menjalankan `omarchy hibernation remove`.
