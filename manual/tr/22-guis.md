# GUI'ler

## Files

Files (Folio) grafik dosya yöneticisidir. `Super + Shift + F` onu açar ve `Super + Shift + Alt + F` onu terminalinizin bulunduğu dizinde açar, bu da sizi bir sürü tıklamadan kurtarır. `Ctrl + L` bir yol yazmanızı sağlar ve herhangi bir dosyanın üzerinde `Space` tuşuna basmak, onu açmadan tam boyutta önizler.

Bir USB bellek veya bir SD kart takın, otomatik olarak bağlanır, böylece kenar çubuğunda hemen görünür. Daha kapsamlı işler için — bir sürücüyü biçimlendirmek, SMART sağlığını kontrol etmek, bölümler oluşturmak — uygulama başlatıcıdan (`Super + Space`) _Disks_ uygulamasını başlatın.

Çift tıklama mantıklı varsayılanları izler: resimler, videolar ve müzik Omaview'da, PDF'ler Document Viewer'da, Markdown Omawrite'da ve düz metin düzenleyicinizde açılır; bu düzenleyici, _Setup > Defaults > Editor_ altında başka bir tane seçmediğiniz sürece Plain'dir.

## Disktree

Sürücü dolduğunda ve neyin onu yediğini hiç bilmiyorsanız, uygulama başlatıcıdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) uygulamasını başlatın. Ana dizininizin grafiksel bir ağaç haritasını gösterir. Daha büyük bloklar daha fazla yer kaplar; klavye veya fareyle dizinlerin içine girin, gidecekleri işaretleyin ve herhangi bir şeyi kaldırmadan önce seçimlerinizi gözden geçirin. Tüm diski taramak için `disktree --disk` komutunu çalıştırın.

## Obsidian

[Obsidian](https://obsidian.md/), depolama için basit Markdown dosyaları kullanan, ücretsiz ve son derece genişletilebilir bir not alma uygulamasıdır.

Obsidian, kişisel, ticari ve kâr amacı gütmeyen kullanım da dahil olmak üzere tüm amaçlar için ücretsizdir.

Obsidian, iOS ve Android'deki mobil uygulamalarla [senkronizasyon için ticari bir eklenti](https://obsidian.md/sync) de sunar. (https://obsidian.md/pricing).

Obsidian'ı `Super + Shift + O` ile başlatırsınız. Tema senkronizasyonunu kullanmak için ayarlar altında `Omarchy` temasını seçmelisiniz.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite), Omarchy'nin kendi son derece basit Markdown yazma uygulamasıdır. Kasa yok, eklenti yok, sadece siz ve kelimeler var.

Omawrite'ı `Super + Shift + W` ile başlatırsınız.

## Pinta

[Pinta](https://www.pinta-project.com/), kırpma, yeniden boyutlandırma ve diğer temel işlemler için harika olan temel bir görüntü düzenleme aracıdır. Sakın bir Photoshop alternatifi beklemeyin. Ama yine de Magic Wand'ı ve katmanları var!

Pinta'yı uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız.

## Aether

[Aether](https://github.com/bjarneo/aether), bir arka plan görüntüsünden renkler çıkarabilen ve bunları eksiksiz, uyumlu bir temaya dönüştürebilen bir tema uygulamasıdır. [Kendi temanızı yapmanın](43-making-your-own-theme.md) en kolay yoludur.

Aether'ı uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız.

## LocalSend

[LocalSend](https://localsend.org/), Apple'ın AirDrop'u gibi, uygulamayı çalıştıran aynı ağdaki diğer cihazlara dosya göndermenizi sağlar. Ancak platformlar arasıdır, bu yüzden Windows, macOS, Android, iOS ve tabii ki Linux'a ve bunlardan dosya gönderebilirsiniz.

Share menüsünü `Super + Ctrl + S` ile veya Omarchy menüsünde _Trigger > Share_ altında açabilirsiniz. Size dört seçenek sunar:

- **Clipboard** kopyaladığınız her şeyi bir metin dosyası olarak gönderir. Kendinize e-posta göndermeden telefonunuza bir bağlantı veya bir parça metin aktarmak için harikadır.
- **File** aynı anda birkaç tane seçebileceğiniz bir dosya seçici açar.
- **Folder** tüm bir dizini gönderir.
- **Receive** başka bir cihazın size bir şey gönderebilmesi için LocalSend'in kendisini açar.

Aynı şey terminalden `omarchy share clipboard`, `omarchy share file [path]` ve `omarchy share folder [path]` ile de çalışır. Yolu yazmazsanız seçici açılır.

Doğrudan dosya yöneticisinden de gönderebilirsiniz: Files'ta herhangi bir seçime sağ tıklayın ve LocalSend ile paylaşın.

Omarchy'nin güvenlik duvarı, LocalSend'in bağlantı noktası dışında varsayılan olarak kapalıdır, bu yüzden bu, yeni bir kurulumda kutudan çıktığı gibi çalışır. Bkz. [güvenlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/), kelime işlemci, elektronik tablo, sunumlar, çizim uygulaması ve daha fazlasını içeren eksiksiz bir ofis paketidir. Microsoft Office dosyalarıyla uyumludur, bu yüzden o Word belgelerini açabilmenin harika bir yoludur.

LibreOffice'i uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız.

## Hype

[Hype](https://github.com/omacom/hype), Omarchy'nin kendi son derece basit sunum uygulamasıdır. Sunumunuz, görüntüleri ve videoları yanında olan tek bir Markdown dosyasıdır: her slaytı canlı bir önizlemenin altına yazın, slaytları sıraya sürükleyin, ardından tam ekran sunun veya PDF ve PowerPoint'e aktarın. Omarchy temanızı bile alır.

Hype'ı uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız. Her kısayolu görmek için içinde `?` tuşuna basın.

## Signed

[Signed](https://github.com/omacom/signed), Omarchy'nin PDF'leri imzalamak ve doldurmak için kendi son derece basit yoludur. Kaydedilmiş imzanızı, metni ve bugünün tarihini bir sayfanın herhangi bir yerine koyun, ardından imzalı bir kopyayı orijinalin yanına kaydedin. Nasıl yapılacağı için bkz. [PDF'leri doldurma](27-filling-out-pdfs.md).

Signed'ı uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız veya dosya yöneticisinden onunla bir PDF açarsınız.

## Game Vibes

Game Vibes, uygulama başlatıcıda (`Super + Space`), Omarchy'nin küçük oyunlarının yaşadığı yerdir: Checkmate, bir arkadaşa veya yerleşik rakibe karşı 3D bir satranç oyunu; Cards, Klondike solitaire; Death Wish, dikenler ve testerelerle dolu on odadan oluşan piksel hassasiyetinde bir platform oyunu; ve Neon Swarm, bir arcade nişancı oyunu. Her biri temanızı izleyen tek bir web sayfasıdır. Ok tuşları ve `Enter` ile birini seçin ve bir oyunun başlık ekranından `Esc` ile veya duraklatıldığında `Q` ile listeye geri dönün. Tam ekran açılır: `Super + F` onu bir pencere yapar ve `Super + W` kapatır.

Bir ajanla yaptığınız oyunlar da burada görünür: ajanlar panelinde _Make something cool → Game_ seçeneğini seçin ve bir oyun tanımlayın veya üzerinde çalışmaya devam etmek için Game Vibes'ta zaten bulunan bir oyunun adını verin. Ajan onu `~/Games/vibes` içine kopyalar, orada değiştirmek sizindir ve bittiğinde açar. Bu kopyayı `omarchy games vibes copy <game>` ile kendiniz de yapabilirsiniz. Başka birinin paylaştığı bir oyun bir tema gibi kurulur: _Install > Gaming > Game Vibes_ seçeneğini seçin ve git adresini yapıştırın veya `omarchy games vibes install <git-repo-url>` komutunu çalıştırın. _Remove > Gaming_ bir oyunu tekrar kaldırır ve _Update > Game Vibes Games_ yeni sürümleri getirir. Oyunlar three.js'yi web'den yükler, bu yüzden başlamak için bir bağlantıya ihtiyaç duyarlar.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc), yüzen bir pencerede açılan, Omarchy'nin kendi son derece basit hesap makinesidir.

Omacalc'ı `Super + Shift + Q` ile başlatırsınız (veya klavyenizde varsa hesap makinesi tuşuyla).

## Signal

[Signal](https://signal.org/), E2E şifreli mesajlaşmanın öncüsüdür ve büyük teknoloji holdinglerinden birinden geçmemeyi tercih eden herkes için harika bir iletişim seçeneğidir.

Signal'i `Super + Shift + G` ile başlatırsınız. Temel kurulumun bir parçası değildir, bu yüzden buna ilk bastığınızda Omarchy sizin için kurmayı teklif edecektir (ayrıca Omarchy menüsünde _Install > Service_ altındadır).

## Omaview

[Omaview](https://github.com/omacom/omaview), Omarchy'nin kendi son derece basit resim görüntüleyicisi ve medya oynatıcısıdır: fotoğraflarınız, videolarınız ve müziğiniz için tek bir pencere. Bir fotoğraf açın, ok tuşları klasörünün geri kalanında adım adım ilerler, `N` ve `P` bunu her şey için yapar ve `Ctrl + M` tüm klasörü bir ızgara olarak gösterir. HEIC, AVIF ve JPEG XL fotoğrafları da gösterir ve uzun olan her şeyde kaldığınız yerden devam eder.

Tam ekran için `F` tuşuna, bir resmi Omasnap'te düzenlemek veya bir videoyu Omacut'ta kırpmak için `E` tuşuna, bir resmi yazdırmak için `Ctrl + P` tuşuna ve bir dosyayı Çöp'e taşımak için `Delete` tuşuna basın (`Ctrl + Z` onu geri getirir). Her kısayolu görmek için içinde `?` tuşuna basın.

Omaview'ı uygulama başlatıcı aracılığıyla (`Super + Space`) _Media Viewer_ olarak başlatırsınız veya dosya yöneticisinde bir resme, videoya veya şarkıya çift tıklamanız yeterlidir.

## Omacut

[Omacut](https://github.com/omacom-io/omacut), Omarchy'nin kendi son derece basit video kırpıcısıdır. İhtiyacınız olan tek şey bir klibin başını ve sonunu kesmek olduğunda, tam bir video düzenleyiciyi açmaktan iyidir.

Omacut'ı uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız.

## Monologue

[Monologue](https://github.com/omacom/monologue), Omarchy'nin kendi son derece basit web kamerası kaydedicisidir. Kameranızı ve mikrofonunuzu bir kez seçin, ardından kaydetmek için `Space` tuşuna basın ve aynı çekimi duraklatmak ve sürdürmek için tekrar basın. Başlamadan önce seviyelerinizi kontrol edebilmeniz için canlı bir mikrofon ölçerle, her zaman kameranızın en yüksek çözünürlüğünde kaydeder.

Çekimi durdurun, yerleşik bir düzenleyicide hemen açılır. Bölmek için bir klibe çift tıklayın, her parçayı kırpmak için tutamaçları sürükleyin ve istemediğiniz kısımları kaldırın. Ardından MP4 olarak kaydedin. Orijinal kaydınız siz atana kadar saklanır, böylece her zaman geri gelip farklı şekilde kesebilirsiniz.

Monologue'u uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız.
