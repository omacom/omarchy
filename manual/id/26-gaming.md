# Gaming

Omarchy bukan hanya untuk _pRoDUcTiVItY_, ini juga untuk bersenang-senang, dan apa yang lebih menyenangkan daripada gaming? Omarchy dilengkapi dengan seluruh rangkaian pilihan gaming — Steam dan RetroArch untuk permainan asli dan retro, Battle.net, Lutris, dan Heroic untuk toko non-Steam, Moonlight untuk streaming PC, Xbox Cloud Gaming + NVIDIA GeForce NOW untuk cloud, ditambah Minecraft yang abadi.

Berkat kerja luar biasa Valve pada [lapisan kompatibilitas proton](https://en.wikipedia.org/wiki/Proton_(software)), sekarang ada puluhan ribu game modern yang dapat dimainkan di Linux. Oh, dan tahukah kamu bahwa [Steam Deck](https://store.steampowered.com/steamdeck/) sebenarnya menjalankan Arch!

Semua pemasang gaming berada di bawah _Pasang > Gaming_ di menu Omarchy (`Super + Space`). Jika kamu ingin membatalkan satu, gunakan _Hapus > Gaming_.

## Steam

Pasang [Steam](https://store.steampowered.com/) dengan memilih _Pasang > Gaming > Steam_ dari menu Omarchy (`Super + Space`).

Setelah kamu memasangnya, kamu akan dapat meluncurkan Steam dengan `Super + Space`.

Perhatikan bahwa Steam dapat memakan waktu 10-20 detik untuk memulai, dan itu tidak akan memberikan umpan balik visual apa pun bahwa itu sedang dimuat.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Pasang [RetroArch](https://www.retroarch.com/) dengan memilih _Pasang > Gaming > RetroArch_ dari menu Omarchy (`Super + Space`). Ini dilengkapi dengan set lengkap core libretro, jadi semua sistem klasik tercakup.

RetroArch sepenuhnya telah dikonfigurasi sebelumnya dengan shader CRT Royale yang indah untuk tampilan retro yang sempurna.

Untuk memulai:

1. Taruh berkas BIOS-mu ke `~/Games/bios` dan ROM-mu ke `~/Games/roms`.
2. Luncurkan RetroArch dengan `Super + Space` dan mengetik `retro`.
3. Pindai direktori `~/Games/roms` dan kamu siap bermain.

Kamu juga dapat memberikan game favorit entri sendiri di peluncur aplikasi dengan _Pasang > Gaming > RetroArch Game Launcher_, yang memungkinkan kamu memilih core dan ROM, dan langsung masuk ke game dari `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Pasang aplikasi web Xbox Cloud Gaming dengan memilih _Pasang > Gaming > Xbox Cloud Gaming_ dari menu Omarchy (`Super + Space`). Ini "hanya" aplikasi web untuk layanan tersebut, tetapi cepat dimulai dan berjalan bagus pada 1080p.

Jika kamu sudah memiliki Xbox Game Pass, ini adalah cara yang solid untuk memainkan Fortnite dan judul lain yang tidak dapat kamu jalankan secara asli di Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Pasang layanan cloud-gaming [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) dengan memilih _Pasang > Gaming > NVIDIA GeForce NOW_ dari menu Omarchy (`Super + Space`). Cara bagus lain untuk memainkan judul yang tidak tersedia secara asli di Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Pasang Minecraft dengan memilih _Pasang > Gaming > Minecraft_ dari menu Omarchy (`Super + Space`).

Seperti Steam, perhatikan bahwa ini dapat memakan waktu cukup lama setelah masuk atau memulai hingga layar berikutnya muncul, dan kamu tidak akan mendapatkan umpan balik apa pun saat menunggu.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Pasang dukungan untuk controller Xbox Bluetooth dengan memilih _Pasang > Gaming > Xbox Controllers_ dari menu Omarchy (`Super + Space`). Pasangkan controller melalui Bluetooth (`Super + Ctrl + B`) dan itu akan bekerja di semua gamemu. Kamu tidak membutuhkan ini jika kamu hanya menghubungkan controllermu dengan kabel USB-C.

## Moonlight (Streaming game dari PC)

[Klien Moonlight](https://github.com/moonlight-stream/moonlight-qt) sudah terpasang dengan Omarchy, jadi kamu dapat melakukan streaming game dari PC Windows yang menjalankan [Sunshine](https://app.lizardbyte.dev/Sunshine/) segera. Luncurkan Moonlight melalui `Super + Space`.

Jika mesin Omarchy-mu dan PC gaming jarak jauh keduanya terhubung dengan kabel, pengalamannya tidak dapat dibedakan dari bermain secara lokal. Naikkan resolusi ke asli, atur refresh ke 120Hz, dan maksimalkan bitrate — ini adalah cara terbaik untuk memainkan shooter kompetitif seperti Fortnite di Linux.

Kamu juga dapat mengubah mesin Omarchy menjadi host dengan menjalankan `omarchy install service sunshine`, yang memasang Sunshine dan membuka port streaming Moonlight untuk LAN dan Tailscale-mu.

## Battle.net

Pasang [Battle.net](https://eu.shop.battle.net/en-us) dengan memilih _Pasang > Gaming > Battle.net_ dari menu Omarchy (`Super + Space`). Ini memberimu judul seperti Diablo, Starcraft, dan World of Warcraft sebagai pemasangan mandiri yang berjalan di bawah GE-Proton — tidak perlu Steam, Lutris, atau Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Game Windows)

Pasang [Lutris](https://lutris.net/) dengan memilih _Pasang > Gaming > Lutris_ dari menu Omarchy (`Super + Space`). Lutris adalah cara memainkan game Windows dari toko seperti EA dan Ubisoft Connect yang tidak memiliki pemasangnya sendiri di atas.

Pemasangan sedikit janky dan terlihat seperti tidak ada yang terjadi kadang-kadang — bersabarlah, ini bekerja di latar belakang.

## Heroic Launcher (Epic Games)

Pasang [Heroic Launcher](https://heroicgameslauncher.com/) dengan memilih _Pasang > Gaming > Heroic (Epic Games)_ dari menu Omarchy (`Super + Space`). Heroic memungkinkan kamu menjalankan judul Epic Games, seperti OddSparks, yang tidak mengandalkan anti-cheat — ditambah game dari GOG dan Amazon Prime Gaming. Sayangnya, itu berarti tidak ada Fortnite dan tidak ada Rocket League — sampai Tim Sweeney datang ke Linux, ini sedekat yang bisa didapat.

Seperti Lutris, ini dapat terasa lambat dan janky saat memasang game. Beri waktu.
