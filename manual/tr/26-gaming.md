# Oyun

Omarchy sadece _pRoDUcTiVItY_ için değil; eğlenmek için de var ve oyun oynamaktan daha eğlenceli ne olabilir? Omarchy, eksiksiz bir oyun seçenekleri paketiyle birlikte geliyor — yerel ve retro oyunlar için Steam ve RetroArch, Steam dışındaki mağazalar için Battle.net, Lutris ve Heroic, PC'den oyun yayını için Moonlight, bulut oyunları için Xbox Cloud Gaming + NVIDIA GeForce NOW ve bir de hiç eskimeyen Minecraft.

Valve'ın [proton uyumluluk katmanı](https://en.wikipedia.org/wiki/Proton_(software)) üzerinde yaptığı inanılmaz çalışma sayesinde artık Linux'ta oynanabilen on binlerce modern oyun var. Ha, bir de [Steam Deck](https://store.steampowered.com/steamdeck/)'in aslında Arch çalıştırdığını biliyor muydunuz!

Tüm oyun yükleyicileri, Omarchy menüsünde (`Super + Space`) _Kurulum > Oyun_ altında yer alır. Birini geri almak isterseniz _Kaldır > Oyun_ seçeneğini kullanın. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris ve Heroic yalnızca x86 makinelerde sunulur.

## Steam

Omarchy menüsünden (`Super + Space`) _Kurulum > Oyun > Steam_ seçeneğini seçerek [Steam](https://store.steampowered.com/)'i kurun.

Kurduktan sonra Steam'i `Super + Space` ile başlatabileceksiniz.

Steam'in başlamasının 10-20 saniye sürebileceğini ve yüklenirken herhangi bir görsel geri bildirim vermeyeceğini unutmayın.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy menüsünden (`Super + Space`) _Kurulum > Oyun > RetroArch_ seçeneğini seçerek [RetroArch](https://www.retroarch.com/)'ı kurun. libretro çekirdeklerinin tamamıyla birlikte geliyor, yani tüm klasik sistemler kapsanıyor.

RetroArch, o kusursuz retro görünüm için güzel CRT Royale shader'ı ile tamamen önceden yapılandırılmış olarak geliyor.

Başlamak için:

1. BIOS dosyalarınızı `~/Games/bios` içine ve ROM'larınızı `~/Games/roms` içine bırakın.
2. `Super + Space` ile RetroArch'ı başlatın ve `retro` yazın.
3. `~/Games/roms` dizinini tarayın; oynamaya hazırsınız.

_Favori bir oyuna Kurulum > Oyun > RetroArch Game Launcher_ ile uygulama başlatıcıda kendi girişini de verebilirsiniz; bu, bir çekirdek ve bir ROM seçmenize ve `Super + Space` üzerinden doğrudan oyuna atlamanıza olanak tanır.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy menüsünden (`Super + Space`) _Kurulum > Oyun > Xbox Cloud Gaming_ seçeneğini seçerek Xbox Cloud Gaming web uygulamasını kurun. Bu "sadece" hizmet için bir web uygulaması, ama hızlı açılıyor ve 1080p'de harika çalışıyor.

Zaten Xbox Game Pass'iniz varsa bu, Fortnite'ı ve Linux'ta yerel olarak çalıştıramadığınız diğer oyunları oynamanın sağlam bir yolu.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy menüsünden (`Super + Space`) _Kurulum > Oyun > NVIDIA GeForce NOW_ seçeneğini seçerek bulut oyun hizmeti [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/)'ı kurun. Linux'ta yerel olarak bulunmayan oyunları oynamanın bir başka harika yolu.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy menüsünden (`Super + Space`) _Kurulum > Oyun > Minecraft_ seçeneğini seçerek Minecraft'ı kurun.

Steam gibi, giriş yaptıktan veya başlattıktan sonra bir sonraki ekranın görünmesinin biraz zaman alabileceğini ve beklerken herhangi bir geri bildirim almayacağınızı unutmayın.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Omarchy menüsünden (`Super + Space`) _Kurulum > Oyun > Xbox Controllers_ seçeneğini seçerek Bluetooth Xbox kontrolcüleri için destek kurun. Kontrolcüleri Bluetooth (`Super + Ctrl + B`) üzerinden eşleştirin; tüm oyunlarınızda çalışacaklar. Kontrolcünüzü sadece bir USB-C kablosuyla bağlıyorsanız buna ihtiyacınız yok.

## Moonlight (PC'den oyun yayını)

Omarchy menüsünden (`Super + Space`) _Kurulum > Oyun > Moonlight_ seçeneğini seçerek [Moonlight client](https://github.com/moonlight-stream/moonlight-qt)'ı kurun; böylece [Sunshine](https://app.lizardbyte.dev/Sunshine/) çalıştıran bir Windows PC'den oyun yayını yapabilirsiniz.

Hem Omarchy makineniz hem de uzaktaki oyun PC'niz kablolu bağlıysa deneyim, yerel olarak oynamaktan ayırt edilemez. Çözünürlüğü yerel çözünürlüğe kadar çıkarın, yenileme hızını 120Hz'e ayarlayın ve bit hızını en yükseğe getirin — Fortnite gibi rekabetçi shooter'ları Linux'ta oynamanın en iyi yolu bu.

Bir Omarchy makinesini `omarchy install service sunshine` komutunu çalıştırarak ana makineye de dönüştürebilirsiniz; bu, Sunshine'ı kurar ve Moonlight yayın portlarını LAN'ınız ve Tailscale için açar.

## Battle.net

Omarchy menüsünden (`Super + Space`) _Kurulum > Oyun > Battle.net_ seçeneğini seçerek [Battle.net](https://eu.shop.battle.net/en-us)'i kurun. Bu, Diablo, Starcraft ve World of Warcraft gibi oyunları GE-Proton altında çalışan bağımsız bir kurulum olarak sunar — Steam, Lutris veya Heroic gerekmez.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows oyunları)

Omarchy menüsünden (`Super + Space`) _Kurulum > Oyun > Lutris_ seçeneğini seçerek [Lutris](https://lutris.net/)'i kurun. Lutris, yukarıda kendi yükleyicisi olmayan EA ve Ubisoft Connect gibi mağazalardan Windows oyunları oynamanın yolu.

Kurulum biraz dengesiz ilerliyor ve bazen hiçbir şey olmuyormuş gibi görünüyor — sadece sabırlı olun, arka planda çalışıyor.

## Heroic Launcher (Epic Games)

Omarchy menüsünden (`Super + Space`) _Kurulum > Oyun > Heroic (Epic Games)_ seçeneğini seçerek [Heroic Launcher](https://heroicgameslauncher.com/)'ı kurun. Heroic, OddSparks gibi anti-cheat'e dayanmayan Epic Games oyunlarının yanı sıra GOG ve Amazon Prime Gaming oyunlarını çalıştırmanıza olanak tanır. Ne yazık ki bu, Fortnite ve Rocket League'in olmadığı anlamına geliyor — Tim Sweeney Linux'a gelene kadar elde edebileceğiniz en yakın şey bu.

Lutris gibi, oyunları kurarken yavaş ve dengesiz hissettirebilir. Ona zaman tanıyın.
