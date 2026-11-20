# GUI'ler

## Files

Files (Folio), grafik dosya yöneticisidir. `Super + Shift + F` onu açar, `Super + Shift + Alt + F` ise terminalinizin bulunduğu dizinde açar; bu da bir sürü tıklamadan kurtarır. `Ctrl + L` bir yol yazmanızı sağlar ve herhangi bir dosya üzerinde `Space` tuşuna basmak, dosyayı açmadan tam boyutunda önizler.

Bir USB bellek ya da SD kart takın; otomatik olarak bağlanır, böylece kenar çubuğunda hemen görünür. Daha kapsamlı işler için — bir sürücüyü biçimlendirmek, SMART sağlığını kontrol etmek, bölüm oluşturmak — uygulama başlatıcıdan (`Super + Space`) _Disks_ uygulamasını başlatın.

Çift tıklama mantıklı varsayılanları izler: resimler, videolar ve müzikler Omaview'da, PDF'ler Document Viewer'da, Markdown Omawrite'da ve düz metin _Setup > Default > Editor_ altında seçilen düzenleyicide açılır.

## Disktree

Sürücü dolduğunda ve alanı neyin yediğine dair hiçbir fikriniz olmadığında, uygulama başlatıcıdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) uygulamasını başlatın. Ana dizininizin grafiksel bir ağaç haritasını gösterir. Daha büyük bloklar daha fazla yer kaplar; klavye ya da fareyle dizinlerin içine girin, gitmesi gerekenleri işaretleyin ve herhangi bir şeyi kaldırmadan önce seçimlerinizi gözden geçirin. Tüm diski taramak için `disktree --disk` komutunu çalıştırın.

## Obsidian

[Obsidian](https://obsidian.md/), depolama için basit Markdown dosyalarını kullanan, ücretsiz ve son derece genişletilebilir bir not alma uygulamasıdır.

Obsidian kişisel, ticari ve kâr amacı gütmeyen kullanım da dahil olmak üzere tüm amaçlar için ücretsizdir.

Obsidian ayrıca iOS ve Android'deki mobil uygulamalarla [senkronizasyon için ticari bir eklenti](https://obsidian.md/sync) de sunar. (https://obsidian.md/pricing).

Obsidian'ı `Super + Shift + O` ile başlatırsınız. Tema senkronizasyonunu kullanmak için ayarlar altında `Omarchy` temasını seçmelisiniz.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite), Omarchy'nin kendi son derece basit Markdown yazma uygulamasıdır. Kasalar yok, eklentiler yok, sadece siz ve kelimeler var.

Omawrite'ı `Super + Shift + W` ile başlatırsınız.

## Pinta

[Pinta](https://www.pinta-project.com/), kırpma, yeniden boyutlandırma ve diğer temel işlemler için harika, basit bir resim düzenleme aracıdır. Sadece bir Photoshop alternatifi beklemeyin. Ama yine de Magic Wand ve katmanları var!

Pinta'yı uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız.

## Aether

[Aether](https://github.com/bjarneo/aether), bir arka plan resminden renkler çıkarıp onları eksiksiz, uyumlu bir temaya dönüştürebilen bir tema oluşturma uygulamasıdır. [Kendi temanızı yapmanın](43-making-your-own-theme.md) en kolay yoludur.

Aether'ı uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız.

## LocalSend

[LocalSend](https://localsend.org/), aynı ağda uygulamayı çalıştıran diğer cihazlara dosya göndermenizi sağlar; Apple'ın AirDrop'u gibi. Ancak platformlar arası çalışır, böylece Windows, macOS, Android, iOS ve elbette Linux'a ve bunlardan dosya gönderebilirsiniz.

Share menüsünü `Super + Ctrl + S` ile ya da Omarchy menüsünde _Trigger > Share_ altından açabilirsiniz. Size dört seçenek sunar:

- **Clipboard**, kopyaladığınız her şeyi bir metin dosyası olarak gönderir. Kendinize e-posta atmadan telefonunuza bir bağlantı ya da kod parçacığı ulaştırmak için harikadır.
- **File**, aynı anda birkaç tane seçebileceğiniz bir dosya seçici açar.
- **Folder**, bütün bir dizini gönderir.
- **Receive**, başka bir cihazın size bir şey gönderebilmesi için LocalSend'in kendisini açar.

Aynı şey terminalden `omarchy share clipboard`, `omarchy share file [path]` ve `omarchy share folder [path]` ile de çalışır. Yolu boş bırakırsanız seçiciyi alırsınız.

Doğrudan dosya yöneticisinden de gönderebilirsiniz: Files içinde herhangi bir seçime sağ tıklayın ve LocalSend ile paylaşın.

Omarchy'nin güvenlik duvarı, LocalSend'in bağlantı noktası dışında varsayılan olarak kapalıdır, bu yüzden bu, yeni bir kurulumda kutudan çıktığı gibi çalışır. Bkz. [güvenlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/), kelime işlemci, hesap tablosu, sunumlar, çizim uygulaması ve daha fazlasını içeren eksiksiz bir ofis paketidir. Microsoft Office dosyalarıyla uyumludur, bu yüzden o Word belgelerini açabilmenin harika bir yoludur.

LibreOffice'i uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız.

## Hype

[Hype](https://github.com/omacom/hype), Omarchy'nin kendi son derece basit sunum uygulamasıdır. Sunumunuz, resimleri ve videoları yanında duran tek bir Markdown dosyasıdır: her slaydı canlı önizlemenin altında yazın, slaytları sıraya sürükleyin, ardından tam ekran sunun ya da PDF ve PowerPoint'e dışa aktarın. Omarchy temanızı bile algılar.

Hype'ı uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız. Her kısayolu görmek için içinde `?` tuşuna basın.

## Signed

[Signed](https://github.com/omacom/signed), Omarchy'nin PDF'leri imzalamanın ve doldurmanın kendi son derece basit yoludur. Kaydedilmiş imzanızı, metni ve bugünün tarihini bir sayfada istediğiniz yere koyun, ardından imzalı bir kopyayı orijinalin yanına kaydedin. Nasıl yapılacağı için bkz. [PDF'leri doldurma](27-filling-out-pdfs.md).

Signed'ı uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız ya da dosya yöneticisinden onunla bir PDF açarsınız.

## Game Vibes

Uygulama başlatıcıdaki (`Super + Space`) Game Vibes, Omarchy'nin küçük oyunlarının yaşadığı yerdir: Bir arkadaşınıza ya da yerleşik rakibe karşı 3D bir satranç oyunu olan Checkmate; Klondike solitaire olan Cards; ve bir arcade nişancı oyunu olan Neon Swarm. Her biri temanızı izleyen tek bir web sayfasıdır. Ok tuşları ve `Enter` ile birini seçin ve bir oyunun başlık ekranından `Esc` ile ya da duraklatılmışken `Q` ile listeye geri dönün. Tam ekran açılır: `Super + F` onu bir pencere yapar ve `Super + W` kapatır.

Bir agent ile yaptığınız oyunlar da burada görünür: agent'lar panelinde _Make something cool → Game_ seçeneğini seçip bir oyun tarif edin ya da üzerinde çalışmaya devam etmek için Game Vibes'ta zaten bulunan bir oyunu adlandırın. Agent onu, değiştirmenin size ait olduğu `~/Games/vibes` içine kopyalar ve bittiğinde açar. Bu kopyayı `omarchy games vibes copy <game>` ile kendiniz de yapabilirsiniz. Başkasının paylaştığı bir oyun, bir tema gibi kurulur: _Install > Gaming > Game Vibes_ seçeneğini seçip git adresini yapıştırın ya da `omarchy games vibes install <git-repo-url>` komutunu çalıştırın. _Remove > Gaming_ bir oyunu tekrar çıkarır ve _Update > Game Vibes Games_ yeni sürümleri getirir. Oyunlar three.js'yi web'den yükler, bu yüzden başlamak için bir bağlantıya ihtiyaç duyarlar.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc), yüzen bir pencerede açılan, Omarchy'nin kendi son derece basit hesap makinesidir.

Omacalc'ı `Super + Shift + Q` ile (ya da klavyenizde varsa hesap makinesi tuşuyla) başlatırsınız.

## Signal

[Signal](https://signal.org/), E2E şifreli mesajlaşmanın öncüsüdür ve büyük teknoloji holdinglerinden birinden geçmemeyi tercih eden herkes için harika bir iletişim seçeneğidir.

Signal'ı `Super + Shift + G` ile başlatırsınız. Temel kurulumun bir parçası değildir, bu yüzden o tuşlara ilk bastığınızda Omarchy size onu kurmayı teklif eder (ayrıca Omarchy menüsünde _Install > Service_ altındadır).

## Omaview

[Omaview](https://github.com/omacom/omaview), Omarchy'nin kendi son derece basit resim görüntüleyicisi ve medya oynatıcısıdır: fotoğraflarınız, videolarınız ve müziğiniz için tek bir pencere. Bir fotoğraf açın; ok tuşları o klasörün geri kalanında adım adım ilerler, `N` ve `P` bunu her şey için yapar ve `Ctrl + M` tüm klasörü bir ızgara olarak gösterir. HEIC, AVIF ve JPEG XL fotoğrafları da gösterir ve uzun her şeyde kaldığınız yerden devam eder.

Tam ekran için `F` tuşuna, bir resmi Omasnap'te düzenlemek ya da bir videoyu Omacut'ta kırpmak için `E` tuşuna, bir resmi yazdırmak için `Ctrl + P` tuşuna ve bir dosyayı Trash'e taşımak için `Delete` tuşuna basın (`Ctrl + Z` onu geri getirir). Her kısayolu görmek için içinde `?` tuşuna basın.

Omaview'ı uygulama başlatıcı üzerinden (`Super + Space`) _Media Viewer_ olarak başlatırsınız ya da dosya yöneticisinde bir resme, videoya ya da şarkıya çift tıklarsınız.

## Omacut

[Omacut](https://github.com/omacom-io/omacut), Omarchy'nin kendi son derece basit video kırpma aracıdır. Tek ihtiyacınız bir klibin başını ve sonunu kesmek olduğunda, tam bir video düzenleyiciyi açmaktan iyidir.

Omacut'ı uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız.

## Monologue

[Monologue](https://github.com/omacom/monologue), Omarchy'nin kendi son derece basit web kamerası kaydedicisidir. Kameranızı ve mikrofonunuzu bir kez seçin, ardından kaydetmek için `Space` tuşuna, aynı çekimi duraklatıp devam ettirmek için tekrar basın. Her zaman kameranızın en yüksek çözünürlüğünde kaydeder; başlamadan önce seviyelerinizi kontrol edebilmeniz için canlı bir mikrofon ölçeri vardır.

Çekimi durdurun; hemen yerleşik bir düzenleyicide açılır. Bölmek için bir klibe çift tıklayın, her parçayı kırpmak için tutamaçları sürükleyin ve istemediğiniz kısımları kaldırın. Ardından MP4 olarak kaydedin. Siz atana kadar orijinal kaydınız saklanır, böylece her zaman geri gelip farklı şekilde kesebilirsiniz.

Monologue'u uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız.
