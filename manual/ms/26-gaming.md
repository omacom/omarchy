# Permainan

Omarchy bukan sekadar untuk _pRoDUcTiVItY_, ia juga untuk berseronok, dan apa yang lebih menyeronokkan daripada bermain permainan? Omarchy disertakan dengan satu set lengkap pilihan permainan — Steam dan RetroArch untuk permainan asli dan retro, Battle.net, Lutris, dan Heroic untuk stor bukan Steam, Moonlight untuk penstriman PC, Xbox Cloud Gaming + NVIDIA GeForce NOW untuk awan, serta Minecraft yang sentiasa malar hijau.

Terima kasih kepada kerja luar biasa Valve pada [lapisan keserasian proton](https://en.wikipedia.org/wiki/Proton_(software)), kini terdapat puluhan ribu permainan moden yang boleh dimainkan di Linux. Oh, dan tahukah anda bahawa [Steam Deck](https://store.steampowered.com/steamdeck/) sebenarnya menjalankan Arch!

Semua pemasang permainan terletak di bawah _Install > Gaming_ dalam menu Omarchy (`Super + Space`). Jika anda mahu membatalkan salah satunya, gunakan _Remove > Gaming_.

## Steam

Pasang [Steam](https://store.steampowered.com/) dengan memilih _Install > Gaming > Steam_ daripada menu Omarchy (`Super + Space`).

Selepas anda memasangnya, anda boleh melancarkan Steam dengan `Super + Space`.

Ambil perhatian bahawa Steam boleh mengambil masa 10-20 saat untuk bermula, dan ia tidak akan memberikan sebarang maklum balas visual bahawa ia sedang dimuatkan.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Pasang [RetroArch](https://www.retroarch.com/) dengan memilih _Install > Gaming > RetroArch_ daripada menu Omarchy (`Super + Space`). Ia disertakan dengan set lengkap teras libretro, jadi semua sistem klasik diliputi.

RetroArch telah dipratarif sepenuhnya dengan shader CRT Royale yang cantik untuk rupa retro yang sempurna itu.

Untuk bermula:

1. Letakkan fail BIOS anda ke dalam `~/Games/bios` dan ROM anda ke dalam `~/Games/roms`.
2. Lancarkan RetroArch dengan `Super + Space` dan menaip `retro`.
3. Imbas direktori `~/Games/roms` dan anda sudah bersedia untuk bermain.

Anda juga boleh memberikan permainan kegemaran anda entri tersendiri dalam pelancar aplikasi dengan _Install > Gaming > RetroArch Game Launcher_, yang membolehkan anda memilih teras dan ROM, dan terus masuk ke dalam permainan daripada `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Pasang aplikasi web Xbox Cloud Gaming dengan memilih _Install > Gaming > Xbox Cloud Gaming_ daripada menu Omarchy (`Super + Space`). Ia "hanyalah" aplikasi web untuk perkhidmatan itu, tetapi ia pantas untuk dimulakan dan berjalan dengan hebat pada 1080p.

Jika anda sudah mempunyai Xbox Game Pass, ini ialah cara yang mantap untuk bermain Fortnite dan judul lain yang tidak boleh anda jalankan secara asli di Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Pasang perkhidmatan permainan awan [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) dengan memilih _Install > Gaming > NVIDIA GeForce NOW_ daripada menu Omarchy (`Super + Space`). Satu lagi cara hebat untuk bermain judul yang tidak tersedia secara asli di Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Pasang Minecraft dengan memilih _Install > Gaming > Minecraft_ daripada menu Omarchy (`Super + Space`).

Seperti Steam, ambil perhatian bahawa ia boleh mengambil sedikit masa selepas log masuk atau bermula sebelum skrin seterusnya muncul, dan anda tidak akan mendapat sebarang maklum balas semasa anda menunggu.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Pengawal Xbox

Pasang sokongan untuk pengawal Xbox Bluetooth dengan memilih _Install > Gaming > Xbox Controllers_ daripada menu Omarchy (`Super + Space`). Pasangkan pengawal melalui Bluetooth (`Super + Ctrl + B`) dan ia akan berfungsi dalam semua permainan anda. Anda tidak memerlukan ini jika anda hanya menyambungkan pengawal anda dengan kabel USB-C.

## Moonlight (Penstriman permainan daripada PC)

Pasang [klien Moonlight](https://github.com/moonlight-stream/moonlight-qt) dengan memilih _Install > Gaming > Moonlight_ daripada menu Omarchy (`Super + Space`), dan anda boleh menstrim permainan daripada PC Windows yang menjalankan [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Jika kedua-dua mesin Omarchy anda dan PC permainan jauh disambungkan dengan kabel, pengalamannya tidak dapat dibezakan daripada bermain secara setempat. Tingkatkan resolusi kepada asli, tetapkan kadar segar semula kepada 120Hz, dan maksimumkan kadar bit — ini ialah cara terbaik untuk bermain permainan tembak-menembak kompetitif seperti Fortnite di Linux.

Anda juga boleh menukar mesin Omarchy menjadi hos dengan menjalankan `omarchy install service sunshine`, yang memasang Sunshine dan membuka port penstriman Moonlight untuk LAN dan Tailscale anda.

## Battle.net

Pasang [Battle.net](https://eu.shop.battle.net/en-us) dengan memilih _Install > Gaming > Battle.net_ daripada menu Omarchy (`Super + Space`). Ini memberikan anda judul seperti Diablo, Starcraft, dan World of Warcraft sebagai pemasangan kendiri yang berjalan di bawah GE-Proton — tiada Steam, Lutris, atau Heroic diperlukan.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Permainan Windows)

Pasang [Lutris](https://lutris.net/) dengan memilih _Install > Gaming > Lutris_ daripada menu Omarchy (`Super + Space`). Lutris ialah cara untuk bermain permainan Windows daripada stor seperti EA dan Ubisoft Connect yang tidak mempunyai pemasang tersendiri di atas.

Pemasangannya agak janggal dan kelihatan seperti tiada apa-apa yang berlaku pada masa-masa tertentu — bersabar sahaja, ia berfungsi di latar belakang.

## Heroic Launcher (Epic Games)

Pasang [Heroic Launcher](https://heroicgameslauncher.com/) dengan memilih _Install > Gaming > Heroic (Epic Games)_ daripada menu Omarchy (`Super + Space`). Heroic membolehkan anda menjalankan judul Epic Games, seperti OddSparks, yang tidak bergantung pada anti-cheat — serta permainan daripada GOG dan Amazon Prime Gaming. Malangnya, itu bermakna tiada Fortnite dan tiada Rocket League — sehingga Tim Sweeney datang ke Linux, inilah yang paling hampir anda boleh dapat.

Seperti Lutris, ia boleh terasa perlahan dan janggal semasa memasang permainan. Berikan ia masa.
