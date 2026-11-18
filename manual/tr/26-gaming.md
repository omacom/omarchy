# Gaming

Omarchy sadece _üReTkEnLiK_ için değil, eğlenmek için de var, oyun oynamaktan daha eğlenceli ne olabilir ki? Omarchy, eksiksiz bir oyun seçenekleri paketiyle gelir — yerel ve retro oyunlar için Steam ve RetroArch, Steam dışı mağazalar için Battle.net, Lutris ve Heroic, PC'den yayın için Moonlight, bulut için Xbox Cloud Gaming + NVIDIA GeForce NOW ve bir de eskimeyen Minecraft.

Valve'ın [proton uyumluluk katmanı](https://en.wikipedia.org/wiki/Proton_(software)) üzerindeki inanılmaz çalışması sayesinde, artık Linux'ta oynanabilen on binlerce modern oyun var. Ha, bir de [Steam Deck](https://store.steampowered.com/steamdeck/)'in aslında Arch çalıştırdığını biliyor muydun!

Tüm oyun kurulumları Omarchy menüsünde (`Super + Space`) _Install > Gaming_ altında yer alır. Bir gün birini geri almak istersen, _Remove > Gaming_ kullan.

## Steam

Omarchy menüsünden (`Super + Space`) _Install > Gaming > Steam_ seçerek [Steam](https://store.steampowered.com/)'i kur.

Kurduktan sonra, Steam'i `Super + Space` ile başlatabileceksin.

Steam'in başlamasının 10-20 saniye sürebileceğini ve yüklenirken hiçbir görsel geri bildirim vermeyeceğini unutma.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy menüsünden (`Super + Space`) _Install > Gaming > RetroArch_ seçerek [RetroArch](https://www.retroarch.com/)'ı kur. Tüm libretro çekirdekleriyle birlikte gelir, yani tüm klasik sistemler kapsanır.

RetroArch, o mükemmel retro görünüm için güzel CRT Royale shader'ı ile tamamen önceden yapılandırılmış olarak gelir.

Başlamak için:

1. BIOS dosyalarını `~/Games/bios` içine ve ROM'larını `~/Games/roms` içine bırak.
2. `Super + Space` ile RetroArch'ı başlat ve `retro` yaz.
3. `~/Games/roms` dizinini tara ve oynamaya hazırsın.

Ayrıca _Install > Gaming > RetroArch Game Launcher_ ile favori bir oyuna uygulama başlatıcıda kendi girişini verebilirsin; bu, bir çekirdek ve bir ROM seçmene ve `Super + Space`'ten doğrudan oyuna atlamana olanak tanır.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy menüsünden (`Super + Space`) _Install > Gaming > Xbox Cloud Gaming_ seçerek Xbox Cloud Gaming web uygulamasını kur. Bu hizmet için "sadece" bir web uygulaması, ama hızlı başlıyor ve 1080p'de harika çalışıyor.

Zaten Xbox Game Pass'in varsa, bu Fortnite ve Linux'ta yerel olarak çalıştıramadığın diğer oyunları oynamanın sağlam bir yolu.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy menüsünden (`Super + Space`) _Install > Gaming > NVIDIA GeForce NOW_ seçerek bulut oyun hizmeti [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/)'ı kur. Linux'ta yerel olarak bulunmayan oyunları oynamanın bir başka harika yolu.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy menüsünden (`Super + Space`) _Install > Gaming > Minecraft_ seçerek Minecraft'ı kur.

Steam gibi, giriş yaptıktan veya başlattıktan sonra bir sonraki ekranın görünmesinin biraz zaman alabileceğini ve beklerken hiçbir geri bildirim almayacağını unutma.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Omarchy menüsünden (`Super + Space`) _Install > Gaming > Xbox Controllers_ seçerek Bluetooth Xbox kontrolcüleri için desteği kur. Kontrolcüleri Bluetooth (`Super + Ctrl + B`) üzerinden eşleştir, tüm oyunlarında çalışacaklar. Kontrolcünü bir USB-C kablosuyla kablolu bağlıyorsan buna ihtiyacın yok.

## Moonlight (Game streaming from a PC)

Omarchy menüsünden (`Super + Space`) _Install > Gaming > Moonlight_ seçerek [Moonlight client](https://github.com/moonlight-stream/moonlight-qt)'ı kur ve [Sunshine](https://app.lizardbyte.dev/Sunshine/) çalıştıran bir Windows PC'den oyun yayını yapabilirsin.

Hem Omarchy makinen hem de uzak oyun PC'si kablolu bağlıysa, deneyim yerel olarak oynamaktan ayırt edilemez. Çözünürlüğü yerel çözünürlüğe çıkar, yenilemeyi 120Hz olarak ayarla ve bitrate'i en yükseğe getir — Fortnite gibi rekabetçi shooter'ları Linux'ta oynamanın en iyi yolu bu.

Ayrıca `omarchy install service sunshine` çalıştırarak bir Omarchy makinesini ana makineye dönüştürebilirsin; bu Sunshine'ı kurar ve LAN ve Tailscale için Moonlight yayın bağlantı noktalarını açar.

## Battle.net

Omarchy menüsünden (`Super + Space`) _Install > Gaming > Battle.net_ seçerek [Battle.net](https://eu.shop.battle.net/en-us)'i kur. Bu sana Diablo, Starcraft ve World of Warcraft gibi oyunları GE-Proton altında çalışan bağımsız bir kurulum olarak verir — Steam, Lutris veya Heroic gerekmez.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows games)

Omarchy menüsünden (`Super + Space`) _Install > Gaming > Lutris_ seçerek [Lutris](https://lutris.net/)'i kur. Lutris, yukarıda kendi kurucusu olmayan EA ve Ubisoft Connect gibi mağazalardaki Windows oyunlarını oynamanın yolu.

Kurulum biraz aksak ilerliyor ve bazen hiçbir şey olmuyormuş gibi görünüyor — sadece sabırlı ol, arka planda çalışıyor.

## Heroic Launcher (Epic Games)

Omarchy menüsünden (`Super + Space`) _Install > Gaming > Heroic (Epic Games)_ seçerek [Heroic Launcher](https://heroicgameslauncher.com/)'ı kur. Heroic, anti-cheat'e dayanmayan OddSparks gibi Epic Games oyunlarını — ayrıca GOG ve Amazon Prime Gaming oyunlarını — çalıştırmanı sağlar. Ne yazık ki bu, Fortnite yok ve Rocket League yok demek — Tim Sweeney Linux'a gelene kadar, olabilecek en yakını bu.

Lutris gibi, oyunları kurarken yavaş ve aksak hissettirebilir. Ona zaman ver.
