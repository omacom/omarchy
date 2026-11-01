# Oyun

Omarchy sadece _üReTkEnLiK_ için değildir, aynı zamanda eğlenmek içindir ve oyundan daha eğlenceli ne olabilir? Omarchy, bütün bir oyun seçenekleri paketiyle birlikte gelir — yerel ve retro oyun için Steam ve RetroArch, Steam dışı mağazalar için Battle.net, Lutris ve Heroic, PC akışı için Moonlight, bulut için Xbox Cloud Gaming + NVIDIA GeForce NOW, artı her daim yeşil Minecraft.

Valve'ın [proton uyumluluk katmanı](https://en.wikipedia.org/wiki/Proton_(software)) üzerindeki inanılmaz çalışması sayesinde, artık Linux üzerinde oynanabilir on binlerce modern oyun var. Ah, [Steam Deck](https://store.steampowered.com/steamdeck/) cihazının gerçekten Arch çalıştırdığını biliyor muydunuz!

Tüm oyun kurulumcuları Omarchy menüsündeki (`Super + Space`) _Kur > Gaming_ altında yaşar. Birini geri almak isterseniz _Kaldır > Gaming_ seçeneğini kullanın.

## Steam

[Steam](https://store.steampowered.com/) uygulamasını, Omarchy menüsünden (`Super + Space`) _Kur > Gaming > Steam_ seçeneğini seçerek kurun.

Kurduktan sonra Steam'i `Super + Space` ile başlatabileceksiniz.

Steam'in başlamasının 10-20 saniye sürebileceğini ve yüklendiğine dair herhangi bir görsel geri bildirim sağlamayacağını unutmayın.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

[RetroArch](https://www.retroarch.com/) uygulamasını, Omarchy menüsünden (`Super + Space`) _Kur > Gaming > RetroArch_ seçeneğini seçerek kurun. Tam libretro çekirdek setiyle birlikte gelir, böylece tüm klasik sistemler kapsanır.

RetroArch, o mükemmel retro görünüm için güzel CRT Royale gölgelendiricisiyle tamamen önceden yapılandırılmıştır.

Başlamak için:

1. BIOS dosyalarınızı `~/Games/bios` içine ve ROM'larınızı `~/Games/roms` içine bırakın.
2. RetroArch'ı `Super + Space` ile başlatın ve `retro` yazın.
3. `~/Games/roms` dizinini tarayın ve oynamaya hazırsınız.

Bir favori oyuna, bir çekirdek ve bir ROM seçmenizi ve `Super + Space` üzerinden doğrudan oyuna atlamanızı sağlayan _Kur > Gaming > RetroArch Game Launcher_ ile uygulama başlatıcıda kendi girişini de verebilirsiniz.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Xbox Cloud Gaming web uygulamasını, Omarchy menüsünden (`Super + Space`) _Kur > Gaming > Xbox Cloud Gaming_ seçeneğini seçerek kurun. Bu hizmet için "sadece" bir web uygulamasıdır, ancak başlatması hızlıdır ve 1080p'de harika çalışır.

Zaten Xbox Game Pass'iniz varsa, bu, Fortnite ve Linux üzerinde yerel olarak çalıştıramayacağınız diğer oyunları oynamanın sağlam bir yoludur.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Bulut oyun hizmeti [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) uygulamasını, Omarchy menüsünden (`Super + Space`) _Kur > Gaming > NVIDIA GeForce NOW_ seçeneğini seçerek kurun. Linux üzerinde yerel olarak kullanılamayan oyunları oynamanın bir başka harika yolu.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Minecraft'ı, Omarchy menüsünden (`Super + Space`) _Kur > Gaming > Minecraft_ seçeneğini seçerek kurun.

Steam gibi, giriş yaptıktan veya başlattıktan sonra bir sonraki ekranın görünmesinin biraz zaman alabileceğini ve beklerken herhangi bir geri bildirim alamayacağınızı unutmayın.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Konsolları

Bluetooth Xbox konsolları desteğini, Omarchy menüsünden (`Super + Space`) _Kur > Gaming > Xbox Controllers_ seçeneğini seçerek kurun. Konsolları Bluetooth (`Super + Ctrl + B`) aracılığıyla eşleştirin; tüm oyunlarınızda çalışacaklardır. Konsolunuzu USB-C kablosuyla kabloyla bağlıyorsanız buna ihtiyacınız yoktur.

## Moonlight (Bir PC'den oyun akışı)

[Moonlight istemcisi](https://github.com/moonlight-stream/moonlight-qt), Omarchy ile önceden kurulu olarak gelir, böylece [Sunshine](https://app.lizardbyte.dev/Sunshine/) çalıştıran bir Windows PC'den hemen oyun akışı yapabilirsiniz. Moonlight'ı `Super + Space` ile başlatın.

Hem Omarchy makineniz hem de uzak oyun PC'si kabloyla bağlıysa, deneyim yerel oynamaktan ayırt edilemez. Çözünürlüğü yerel değere yükseltin, yenileme hızını 120Hz'e ayarlayın ve bit hızını en üst düzeye çıkarın — bu, Linux üzerinde Fortnite gibi rekabetçi nişancı oyunlarını oynamanın en iyi yoludur.

Bir Omarchy makinesini, Sunshine'ı kuran ve LAN'ınız ve Tailscale için Moonlight akış bağlantı noktalarını açan `omarchy install service sunshine` komutunu çalıştırarak ana bilgisayar haline de getirebilirsiniz.

## Battle.net

[Battle.net](https://eu.shop.battle.net/en-us) uygulamasını, Omarchy menüsünden (`Super + Space`) _Kur > Gaming > Battle.net_ seçeneğini seçerek kurun. Bu, size Diablo, Starcraft ve World of Warcraft gibi oyunları GE-Proton altında çalışan bağımsız bir kurulum olarak verir — Steam, Lutris veya Heroic gerekmez.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows oyunları)

[Lutris](https://lutris.net/) uygulamasını, Omarchy menüsünden (`Super + Space`) _Kur > Gaming > Lutris_ seçeneğini seçerek kurun. Lutris, yukarıda kendi kurulumcusu olmayan EA ve Ubisoft Connect gibi mağazalardaki Windows oyunlarını oynamanın yoludur.

Kurulum biraz arızalıdır ve bazen hiçbir şey olmuyormuş gibi görünür — sadece sabırlı olun, arka planda çalışıyordur.

## Heroic Launcher (Epic Games)

[Heroic Launcher](https://heroicgameslauncher.com/) uygulamasını, Omarchy menüsünden (`Super + Space`) _Kur > Gaming > Heroic (Epic Games)_ seçeneğini seçerek kurun. Heroic, hile karşıtı sisteme dayanmayan OddSparks gibi Epic Games oyunlarını — artı GOG ve Amazon Prime Gaming oyunlarını — çalıştırmanızı sağlar. Ne yazık ki bu, Fortnite ve Rocket League yok demektir — Tim Sweeney Linux'a gelene kadar, bu olabilecek en yakınıdır.

Lutris gibi, oyun kurarken de yavaş ve arızalı hissedebilir. Ona zaman verin.
