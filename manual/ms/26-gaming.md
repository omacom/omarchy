# Permainan

Omarchy bukan hanya untuk _pRoDUcTiVItY_, ia juga untuk berseronok, dan apa yang lebih menyeronokkan daripada permainan? Omarchy dilengkapi dengan pelbagai pilihan permainan — Steam dan RetroArch untuk permainan asli dan retro, Battle.net, Lutris, dan Heroic untuk kedai bukan Steam, Moonlight untuk penstriman PC, Xbox Cloud Gaming + NVIDIA GeForce NOW untuk awan, ditambah Minecraft yang sentiasa malar hijau.

Terima kasih kepada kerja luar biasa Valve pada [lapisan keserasian proton](https://en.wikipedia.org/wiki/Proton_(software)), kini terdapat puluhan ribu permainan moden yang boleh dimainkan di Linux. Oh, dan tahukah anda bahawa [Steam Deck](https://store.steampowered.com/steamdeck/) sebenarnya menggunakan Arch!

Semua pemasang permainan berada di bawah _Pasang > Permainan_ dalam menu Omarchy (`Super + Space`). Jika anda mahu membatalkannya, gunakan _Buang > Permainan_.

## Steam

Pasang [Steam](https://store.steampowered.com/) dengan memilih _Pasang > Permainan > Steam_ daripada menu Omarchy (`Super + Space`).

Selepas anda memasangnya, anda boleh melancarkan Steam dengan `Super + Space`.

Perhatikan bahawa Steam boleh mengambil masa 10-20 saat untuk dimulakan, dan ia tidak akan memberikan maklum balas visual bahawa ia sedang dimuatkan.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Pasang [RetroArch](https://www.retroarch.com/) dengan memilih _Pasang > Permainan > RetroArch_ daripada menu Omarchy (`Super + Space`). Ia disertakan dengan set lengkap core libretro, jadi semua sistem klasik diliputi.

RetroArch diprapasang sepenuhnya dengan shader CRT Royale yang cantik untuk rupa retro yang sempurna itu.

Untuk bermula:

1. Jatuhkan fail BIOS anda ke dalam `~/Games/bios` dan ROM anda ke dalam `~/Games/roms`.
2. Lancarkan RetroArch dengan `Super + Space` dan menaip `retro`.
3. Imbas direktori `~/Games/roms` dan anda bersedia untuk bermain.

Anda juga boleh memberi permainan kegemaran entri sendiri dalam pelancar aplikasi dengan _Pasang > Permainan > Pelancar Permainan RetroArch_, yang membolehkan anda memilih core dan ROM, dan lompat terus ke dalam permainan daripada `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Pasang aplikasi web Xbox Cloud Gaming dengan memilih _Pasang > Permainan > Xbox Cloud Gaming_ daripada menu Omarchy (`Super + Space`). Ia "hanyalah" aplikasi web untuk perkhidmatan itu, tetapi ia pantas untuk dimulakan dan berjalan dengan hebat pada 1080p.

Jika anda sudah ada Xbox Game Pass, ini adalah cara yang kukuh untuk bermain Fortnite dan judul lain yang tidak boleh anda jalankan secara asli di Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Pasang perkhidmatan permainan awan [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) dengan memilih _Pasang > Permainan > NVIDIA GeForce NOW_ daripada menu Omarchy (`Super + Space`). Satu lagi cara yang hebat untuk bermain judul yang tidak tersedia secara asli di Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Pasang Minecraft dengan memilih _Pasang > Permainan > Minecraft_ daripada menu Omarchy (`Super + Space`).

Seperti Steam, perhatikan bahawa ia boleh mengambil sedikit masa selepas log masuk atau bermula untuk skrin seterusnya muncul, dan anda tidak akan mendapat maklum balas semasa anda menunggu.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Alat Kawalan Xbox

Pasang sokongan untuk alat kawalan Bluetooth Xbox dengan memilih _Pasang > Permainan > Alat Kawalan Xbox_ daripada menu Omarchy (`Super + Space`). Pasangkan alat kawalan melalui Bluetooth (`Super + Ctrl + B`) dan ia akan berfungsi dalam semua permainan anda. Anda tidak memerlukannya jika anda hanya menyambung alat kawalan anda dengan kabel USB-C secara terus.

## Moonlight (Penstriman permainan daripada PC)

[Klien Moonlight](https://github.com/moonlight-stream/moonlight-qt) diprapasang dengan Omarchy, jadi anda boleh menstrim permainan daripada PC Windows yang menjalankan [Sunshine](https://app.lizardbyte.dev/Sunshine/) serta-merta. Lancarkan Moonlight melalui `Super + Space`.

Jika kedua-dua mesin Omarchy anda dan PC permainan jauh disambung secara terus, pengalaman itu tidak dapat dibezakan daripada bermain secara tempatan. Besarkan resolusi kepada asli, tetapkan segar semula kepada 120Hz, dan maksimumkan kadar bit — ini adalah cara terbaik untuk bermain penembak kompetitif seperti Fortnite di Linux.

Anda juga boleh menukar mesin Omarchy kepada hos dengan menjalankan `omarchy install service sunshine`, yang memasang Sunshine dan membuka port penstriman Moonlight untuk LAN dan Tailscale anda.

## Battle.net

Pasang [Battle.net](https://eu.shop.battle.net/en-us) dengan memilih _Pasang > Permainan > Battle.net_ daripada menu Omarchy (`Super + Space`). Ini memberi anda judul seperti Diablo, Starcraft, dan World of Warcraft sebagai pemasangan berdiri sendiri yang berjalan di bawah GE-Proton — tiada Steam, Lutris, atau Heroic diperlukan.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Permainan Windows)

Pasang [Lutris](https://lutris.net/) dengan memilih _Pasang > Permainan > Lutris_ daripada menu Omarchy (`Super + Space`). Lutris adalah cara untuk bermain permainan Windows daripada kedai seperti EA dan Ubisoft Connect yang tidak mempunyai pemasang sendiri di atas.

Pemasangan agak janky dan kadangkala kelihatan seperti tiada apa yang berlaku — bersabarlah, ia berfungsi di latar belakang.

## Pelancar Heroic (Epic Games)

Pasang [Pelancar Heroic](https://heroicgameslauncher.com/) dengan memilih _Pasang > Permainan > Heroic (Epic Games)_ daripada menu Omarchy (`Super + Space`). Heroic membolehkan anda menjalankan judul Epic Games, seperti OddSparks, yang tidak bergantung pada anti-cheat — ditambah permainan daripada GOG dan Amazon Prime Gaming. Malangnya, itu bermakna tiada Fortnite dan tiada Rocket League — sehingga Tim Sweeney datang ke Linux, ini adalah sedekat yang boleh didapati.

Seperti Lutris, ia boleh terasa perlahan dan janky semasa memasang permainan. Beri masa.
