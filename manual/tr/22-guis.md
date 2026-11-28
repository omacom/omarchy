# GUI'ler

## Files

Files (Folio) grafiksel dosya yöneticisidir. `Super + Shift + F` ile açılır ve `Super + Shift + Alt + F` ile terminalinizin bulunduğu dizinde açılır, bu da sizi bir sürü tıklamadan kurtarır. `Ctrl + L` ile bir yol yazabilirsiniz ve herhangi bir dosyada `Space` tuşuna basmak, dosyayı açmadan tam boyutta önizler.

Bir USB bellek ya da bir SD kart takın, otomatik olarak bağlanır, böylece kenar çubuğunda beliriverir. Daha karmaşık işler için — bir sürücüyü biçimlendirmek, SMART sağlığını kontrol etmek, bölümler oluşturmak — uygulama başlatıcıdan (`Super + Space`) _Disks_ uygulamasını başlatın.

Şifreli bir sürücü takıldığında parolasını sorar. Birinin kendi kendine kilidinin açılması için, `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` ile ona bir anahtar dosyası ekleyin ve bu anahtar dosyasını `~/.config/omarchy/drive-keys/<UUID>` konumuna koyun; dosya, şifreli bölüm için `lsblk -dno UUID /dev/sdX1` komutunun yazdırdığı UUID ile adlandırılır ve yalnızca sizin okuyabileceğiniz şekilde olur (`chmod 600`). Bu anahtar dosyası eksikse ya da reddedilirse, her zamanki gibi parola sorulur.

Çift tıklama mantıklı varsayılanları izler: resimler, videolar ve müzik Omaview'da, PDF'ler Document Viewer'da, Markdown Omawrite'ta ve düz metin düzenleyicinizde açılır; _Setup > Defaults > Editor_ altında başka birini seçmediyseniz düzenleyiciniz Plaindir.

## Disktree

Sürücü dolduğunda ve onu neyin yediğini hiç bilmiyorsanız, uygulama başlatıcıdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) uygulamasını başlatın. Ev dizininizin grafiksel bir ağaç haritasını gösterir. Daha büyük bloklar daha fazla yer kaplar; klavye ya da fareyle dizinlerin içine girin, gitmesi gerekenleri işaretleyin ve herhangi bir şeyi kaldırmadan önce seçimlerinizi gözden geçirin. Tüm diski taramak için `disktree --disk` komutunu çalıştırın.

## Obsidian

[Obsidian](https://obsidian.md/), depolama için basit Markdown dosyalarını kullanan, ücretsiz ve son derece genişletilebilir bir not alma uygulamasıdır.

Obsidian kişisel, ticari ve kâr amacı gütmeyen kullanım dahil her amaç için ücretsizdir.

Obsidian ayrıca iOS ve Android'deki mobil uygulamalarla [senkronizasyon için ticari bir eklenti](https://obsidian.md/sync) de sunar. (https://obsidian.md/pricing).

Obsidian'ı `Super + Shift + O` ile başlatırsınız. Tema senkronizasyonunu kullanmak için ayarlar altında `Omarchy` temasını seçmeniz gerekir.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite), Omarchy'nin kendi son derece basit Markdown yazma uygulamasıdır. Kasalar yok, eklentiler yok, sadece siz ve kelimeler.

Omawrite'ı `Super + Shift + W` ile başlatırsınız.

## Pinta

[Pinta](https://www.pinta-project.com/), kırpma, yeniden boyutlandırma ve diğer temel işlemler için harika olan temel bir görsel düzenleme aracıdır. Sadece bir Photoshop alternatifi beklemeyin. Ama yine de Magic Wand ve katmanları var!

Pinta'yı uygulama başlatıcı (`Super + Space`) üzerinden başlatırsınız.

## Aether

[Aether](https://github.com/bjarneo/aether), bir arka plan görselinden renkler çıkarıp bunları eksiksiz, uyumlu bir temaya dönüştürebilen bir tema uygulamasıdır. [Kendi temanızı yapmanın](43-making-your-own-theme.md) en kolay yoludur.

Aether'i uygulama başlatıcı (`Super + Space`) üzerinden başlatırsınız.

## LocalSend

[LocalSend](https://localsend.org/), aynı ağda uygulamayı çalıştıran diğer cihazlara dosya göndermenizi sağlar, tıpkı Apple'ın AirDrop'u gibi. Ancak platformlar arası çalışır, böylece Windows, macOS, Android, iOS ve elbette Linux'a ve bunlardan dosya gönderebilirsiniz.

Share menüsünü `Super + Ctrl + S` ile ya da Omarchy menüsünde _Trigger > Share_ altında açabilirsiniz. Size dört seçenek sunar:

- **Clipboard**, kopyaladığınız her şeyi bir metin dosyası olarak gönderir. Kendinize e-posta göndermeden telefonunuza bir bağlantı ya da bir parçacık aktarmak için harikadır.
- **File**, aynı anda birkaç tane seçebileceğiniz bir dosya seçici açar.
- **Folder** tüm bir dizini gönderir.
- **Receive**, başka bir cihazın size bir şey gönderebilmesi için LocalSend'in kendisini açar.

Aynı şey terminalden `omarchy share clipboard`, `omarchy share file [path]` ve `omarchy share folder [path]` ile de çalışır. Yolu yazmazsanız seçiciyi alırsınız.

Doğrudan dosya yöneticisinden de gönderebilirsiniz: Files içinde herhangi bir seçime sağ tıklayın ve LocalSend ile paylaşın.

Omarchy'nin güvenlik duvarı, LocalSend'in portu dışında varsayılan olarak kapalıdır, bu yüzden bu, yeni bir kurulumda kutudan çıktığı gibi çalışır. Bkz. [güvenlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/), kelime işlemci, hesap tablosu, sunumlar, çizim uygulaması ve daha fazlasını içeren eksiksiz bir ofis paketidir. Microsoft Office dosyalarıyla uyumludur, bu yüzden o Word belgelerini açabilmek için harika bir yoldur.

LibreOffice'i uygulama başlatıcı (`Super + Space`) üzerinden başlatırsınız.

## Hype

[Hype](https://github.com/omacom/hype), Omarchy'nin kendi son derece basit sunum uygulamasıdır. Desteniz, görselleri ve videoları yanında duran tek bir Markdown dosyasıdır: her slaytı canlı bir önizlemenin altında yazın, slaytları sıraya sürükleyin, ardından tam ekran sunun ya da PDF ve PowerPoint'e aktarın. Omarchy temanızı bile alır.

Hype'ı uygulama başlatıcı (`Super + Space`) üzerinden başlatırsınız. Her kısayolu görmek için içinde `?` tuşuna basın.

## Signed

[Signed](https://github.com/omacom/signed), Omarchy'nin PDF'leri imzalamak ve doldurmak için kendi son derece basit yoludur. Kaydedilmiş imzanızı, metninizi ve bugünün tarihini bir sayfada istediğiniz yere koyun, ardından imzalanmış bir kopyayı orijinalin yanına kaydedin. Nasıl yapılacağı için bkz. [PDF'leri Doldurma](27-filling-out-pdfs.md).

Signed'ı uygulama başlatıcı (`Super + Space`) üzerinden başlatırsınız ya da dosya yöneticisinden bir PDF'yi onunla açarsınız.

## Game Vibes

Uygulama başlatıcıdaki (`Super + Space`) Game Vibes, Omarchy'nin küçük oyunlarının yaşadığı yerdir: Checkmate, bir arkadaşınıza ya da yerleşik rakibe karşı 3D bir satranç oyunu; Cards, Klondike solitaire; Death Wish, dikenler ve testerelerle dolu on odadan oluşan piksel hassasiyetinde bir platform oyunu; ve Neon Swarm, bir arcade nişancı oyunu. Her biri temanızı takip eden tek bir web sayfasıdır. Oklarla ve `Enter` ile birini seçin ve bir oyunun başlık ekranından `Esc` ile ya da duraklatılmışken `Q` ile listeye geri dönün. Tam ekran açılır: `Super + F` onu bir pencere yapar ve `Super + W` kapatır.

Bir agent ile yaptığınız oyunlar da burada görünür: agents panelinde _Make something cool → Game_ seçeneğini seçin ve bir tane tarif edin ya da üzerinde çalışmaya devam etmek için Game Vibes'ta zaten bulunan bir oyunu adlandırın. Agent onu `~/Games/vibes` içine kopyalar, orada değiştirmesi sizindir ve bittiğinde açar. Bu kopyayı kendiniz `omarchy games vibes copy <game>` ile yapabilirsiniz. Başka birinin paylaştığı bir oyun bir tema gibi kurulur: _Install > Gaming > Game Vibes_ seçeneğini seçin ve git adresini yapıştırın ya da `omarchy games vibes install <git-repo-url>` komutunu çalıştırın. _Remove > Gaming_ birini tekrar çıkarır ve _Update > Game Vibes Games_ yeni sürümleri getirir. Oyunlar three.js'yi webden yükler, bu yüzden başlamak için bir bağlantıya ihtiyaç duyarlar.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc), kayan bir pencerede açılan, Omarchy'nin kendi son derece basit hesap makinesidir.

Omacalc'ı `Super + Shift + Q` ile başlatırsınız (ya da klavyenizde varsa hesap makinesi tuşuyla).

## Signal

[Signal](https://signal.org/), E2E şifreli mesajlaşmanın öncüsüdür ve büyük teknoloji holdinglerinden birinden geçmemeyi tercih eden herkes için harika bir iletişim seçeneğidir.

Signal'i `Super + Shift + G` ile başlatırsınız. Temel kurulumun bir parçası değildir, bu yüzden o tuşlara ilk bastığınızda Omarchy size onu kurmayı teklif eder (Omarchy menüsünde _Install > Service_ altında da bulunur).

## Omaview

[Omaview](https://github.com/omacom/omaview), Omarchy'nin kendi son derece basit resim görüntüleyicisi ve medya oynatıcısıdır: fotoğraflarınız, videolarınız ve müziğiniz için tek bir pencere. Bir fotoğraf açın, ok tuşları klasörünün geri kalanında adım adım ilerler, `N` ve `P` bunu her şey için yapar ve `Ctrl + M` tüm klasörü bir ızgara olarak gösterir. HEIC, AVIF ve JPEG XL fotoğrafları da gösterir ve uzun olan her şeyde kaldığınız yerden devam eder.

Tam ekran için `F` tuşuna, bir resmi Omasnap'te düzenlemek ya da bir videoyu Omacut'ta kırpmak için `E` tuşuna, bir resmi yazdırmak için `Ctrl + P` tuşuna ve bir dosyayı Trash'e taşımak için `Delete` tuşuna basın (`Ctrl + Z` onu geri getirir). Her kısayolu görmek için içinde `?` tuşuna basın.

Omaview'u uygulama başlatıcı (`Super + Space`) üzerinden _Media Viewer_ olarak başlatırsınız ya da dosya yöneticisinde bir resme, videoya ya da şarkıya çift tıklarsınız.

## Omacut

[Omacut](https://github.com/omacom-io/omacut), Omarchy'nin kendi son derece basit video kırpıcısıdır. Tek ihtiyacınız bir klibin başını ve sonunu kesmek olduğunda, tam bir video düzenleyiciyi çalıştırmaktan daha iyidir.

Omacut'ı uygulama başlatıcı (`Super + Space`) üzerinden başlatırsınız.

## Monologue

[Monologue](https://github.com/omacom/monologue), Omarchy'nin kendi son derece basit web kamerası kaydedicisidir. Kameranızı ve mikrofonunuzu bir kez seçin, ardından kaydetmek için `Space` tuşuna basın ve aynı çekimi duraklatıp devam ettirmek için tekrar basın. Her zaman kameranızın en yüksek çözünürlüğünde kaydeder ve başlamadan önce seviyelerinizi kontrol edebilmeniz için canlı bir mikrofon ölçeri vardır.

Çekimi durdurun, yerleşik bir düzenleyicide hemen açılır. Bir klibi bölmek için çift tıklayın, her parçayı kırpmak için tutamaçları sürükleyin ve istemediğiniz kısımları kaldırın. Ardından MP4 olarak kaydedin. Vazgeçene kadar orijinal kaydınız saklanır, böylece her zaman geri gelip farklı şekilde kesebilirsiniz.

Monologue'u uygulama başlatıcı (`Super + Space`) üzerinden başlatırsınız.
