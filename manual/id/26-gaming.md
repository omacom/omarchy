# Gaming

Omarchy bukan cuma untuk _pRoDUkTiViTaS_, tapi juga untuk bersenang-senang, dan apa yang lebih menyenangkan daripada gaming? Omarchy dilengkapi dengan rangkaian lengkap pilihan gaming — Steam dan RetroArch untuk bermain secara native dan retro, Battle.net, Lutris, dan Heroic untuk toko non-Steam, Moonlight untuk streaming PC, Xbox Cloud Gaming + NVIDIA GeForce NOW untuk cloud, plus Minecraft yang tak lekang oleh waktu.

Berkat kerja luar biasa Valve pada [lapisan kompatibilitas proton](https://en.wikipedia.org/wiki/Proton_(software)), kini ada puluhan ribu game modern yang bisa dimainkan di Linux. Oh, dan tahukah kamu bahwa [Steam Deck](https://store.steampowered.com/steamdeck/) sebenarnya menjalankan Arch!

Semua installer gaming ada di bawah _Install > Gaming_ di menu Omarchy (`Super + Space`). Jika kamu ingin membatalkan salah satunya, gunakan _Remove > Gaming_.

## Steam

Instal [Steam](https://store.steampowered.com/) dengan memilih _Install > Gaming > Steam_ dari menu Omarchy (`Super + Space`).

Setelah kamu menginstalnya, kamu bisa meluncurkan Steam dengan `Super + Space`.

Perlu dicatat bahwa Steam bisa membutuhkan waktu 10-20 detik untuk memulai, dan tidak akan memberikan umpan balik visual apa pun bahwa ia sedang dimuat.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instal [RetroArch](https://www.retroarch.com/) dengan memilih _Install > Gaming > RetroArch_ dari menu Omarchy (`Super + Space`). Ini dilengkapi dengan set lengkap core libretro, jadi semua sistem klasik tercakup.

RetroArch sudah sepenuhnya dikonfigurasi sebelumnya dengan shader CRT Royale yang indah untuk tampilan retro yang sempurna itu.

Untuk memulai:

1. Letakkan file BIOS kamu ke `~/Games/bios` dan ROM kamu ke `~/Games/roms`.
2. Luncurkan RetroArch dengan `Super + Space` dan mengetik `retro`.
3. Pindai direktori `~/Games/roms` dan kamu siap bermain.

Kamu juga bisa memberikan game favorit entri tersendiri di peluncur aplikasi dengan _Install > Gaming > RetroArch Game Launcher_, yang memungkinkanmu memilih core dan ROM, dan langsung masuk ke game dari `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instal aplikasi web Xbox Cloud Gaming dengan memilih _Install > Gaming > Xbox Cloud Gaming_ dari menu Omarchy (`Super + Space`). Ini "hanya" aplikasi web untuk layanan tersebut, tetapi cepat dibuka dan berjalan sangat baik pada 1080p.

Jika kamu sudah memiliki Xbox Game Pass, ini cara yang solid untuk memainkan Fortnite dan judul lain yang tidak bisa kamu jalankan secara native di Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instal layanan cloud-gaming [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) dengan memilih _Install > Gaming > NVIDIA GeForce NOW_ dari menu Omarchy (`Super + Space`). Cara hebat lainnya untuk memainkan judul yang tidak tersedia secara native di Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instal Minecraft dengan memilih _Install > Gaming > Minecraft_ dari menu Omarchy (`Super + Space`).

Seperti Steam, perlu dicatat bahwa ini bisa membutuhkan waktu lama setelah masuk atau memulai hingga layar berikutnya muncul, dan kamu tidak akan mendapatkan umpan balik apa pun selama menunggu.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Instal dukungan untuk kontroler Xbox Bluetooth dengan memilih _Install > Gaming > Xbox Controllers_ dari menu Omarchy (`Super + Space`). Pasangkan kontroler melalui Bluetooth (`Super + Ctrl + B`) dan kontroler tersebut akan berfungsi di semua game kamu. Kamu tidak memerlukan ini jika kamu hanya menghubungkan kontroler dengan kabel USB-C.

## Moonlight (Streaming game dari PC)

Instal [klien Moonlight](https://github.com/moonlight-stream/moonlight-qt) dengan memilih _Install > Gaming > Moonlight_ dari menu Omarchy (`Super + Space`), dan kamu bisa melakukan streaming game dari PC Windows yang menjalankan [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Jika mesin Omarchy kamu dan PC gaming jarak jauh sama-sama terhubung dengan kabel, pengalamannya tidak bisa dibedakan dari bermain secara lokal. Naikkan resolusi ke native, atur refresh ke 120Hz, dan maksimalkan bitrate — ini cara terbaik untuk memainkan shooter kompetitif seperti Fortnite di Linux.

Kamu juga bisa mengubah mesin Omarchy menjadi host dengan menjalankan `omarchy install service sunshine`, yang menginstal Sunshine dan membuka port streaming Moonlight untuk LAN dan Tailscale kamu.

## Battle.net

Instal [Battle.net](https://eu.shop.battle.net/en-us) dengan memilih _Install > Gaming > Battle.net_ dari menu Omarchy (`Super + Space`). Ini memberimu judul seperti Diablo, Starcraft, dan World of Warcraft sebagai instalasi mandiri yang berjalan di bawah GE-Proton — tidak perlu Steam, Lutris, atau Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Game Windows)

Instal [Lutris](https://lutris.net/) dengan memilih _Install > Gaming > Lutris_ dari menu Omarchy (`Super + Space`). Lutris adalah cara untuk memainkan game Windows dari toko seperti EA dan Ubisoft Connect yang tidak memiliki installer sendiri di atas.

Instalasi agak janky dan terlihat seperti tidak terjadi apa-apa pada saat-saat tertentu — bersabar saja, ia bekerja di latar belakang.

## Heroic Launcher (Epic Games)

Instal [Heroic Launcher](https://heroicgameslauncher.com/) dengan memilih _Install > Gaming > Heroic (Epic Games)_ dari menu Omarchy (`Super + Space`). Heroic memungkinkanmu menjalankan judul Epic Games, seperti OddSparks, yang tidak bergantung pada anti-cheat — plus game dari GOG dan Amazon Prime Gaming. Sayangnya, itu berarti tidak ada Fortnite dan tidak ada Rocket League — sampai Tim Sweeney datang ke Linux, ini yang paling mendekati.

Seperti Lutris, ini bisa terasa lambat dan janky saat menginstal game. Beri waktu.
