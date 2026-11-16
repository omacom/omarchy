# GUI'ler

## Files

Files (Nautilus) grafik dosya yöneticisidir. `Super + Shift + F` onu açar ve `Super + Shift + Alt + F` onu terminalinizin bulunduğu dizinde açar, bu da size bir sürü tıklamadan tasarruf ettirir. `Ctrl + L` bir yol yazmanızı sağlar ve herhangi bir dosyada `Space` tuşuna basmak size hiçbir şeyi açmadan hızlı bir önizleme verir.

Bir USB bellek veya bir SD kart takın, otomatik olarak bağlanır, böylece kenar çubuğunda hemen görünür. Daha kapsamlı herhangi bir şey için — bir sürücüyü biçimlendirmek, SMART sağlığını kontrol etmek, bölümler oluşturmak — uygulama başlatıcıdan (`Super + Space`) _Disks_ uygulamasını başlatın.

Çift tıklama mantıklı varsayılanları izler: resimler, videolar ve müzik Omaview'da, PDF'ler Document Viewer'da, Markdown Omawrite'da ve düz metin _Setup > Default > Editor_ altında seçilen editörde açılır.

## Disktree

Sürücü dolduğunda ve onu neyin yediğine dair hiçbir fikriniz olmadığında, uygulama başlatıcıdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) uygulamasını başlatın. Ev dizininizin grafik bir ağaç haritasını gösterir. Daha büyük bloklar daha fazla yer kaplar; klavye veya fareyle dizinlerin içine girin, gitmesi gerekenleri işaretleyin ve herhangi bir şeyi kaldırmadan önce seçimlerinizi gözden geçirin. Tüm diski taramak için `disktree --disk` çalıştırın.

## Obsidian

[Obsidian](https://obsidian.md/), depolama için basit Markdown dosyalarını kullanan ücretsiz ve son derece genişletilebilir bir not alma uygulamasıdır.

Obsidian, kişisel, ticari ve kâr amacı gütmeyen kullanım dahil tüm amaçlar için ücretsizdir.

Obsidian ayrıca iOS ve Android'deki mobil uygulamalarla [senkronizasyon için ticari bir eklenti](https://obsidian.md/sync) sunar. (https://obsidian.md/pricing).

Obsidian'ı `Super + Shift + O` ile başlatırsınız. Tema senkronizasyonunu kullanmak için ayarlar altında `Omarchy` temasını seçmelisiniz.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite), Omarchy'nin kendi son derece basit Markdown yazma uygulamasıdır. Kasalar yok, eklentiler yok, sadece siz ve sözcükler var.

Omawrite'ı `Super + Shift + W` ile başlatırsınız.

## Pinta

[Pinta](https://www.pinta-project.com/), kırpma, yeniden boyutlandırma ve diğer temel işlemler için harika olan temel bir görüntü düzenleme aracıdır. Sakın bir Photoshop alternatifi beklemeyin. Ama yine de Magic Wand ve katmanları var!

Pinta'yı uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız.

## Aether

[Aether](https://github.com/bjarneo/aether), bir arka plan görüntüsünden renkler çıkarıp bunları eksiksiz, uyumlu bir temaya dönüştürebilen bir tema uygulamasıdır. [kendi temanızı yapmanın](43-making-your-own-theme.md) en kolay yoludur.

Aether'i uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız.

## LocalSend

[LocalSend](https://localsend.org/), aynı ağda uygulamayı çalıştıran diğer cihazlara dosya göndermenizi sağlar, Apple'ın AirDrop'u gibi. Ancak platformlar arasıdır, dolayısıyla Windows, macOS, Android, iOS ve tabii ki Linux'a dosya gönderebilir ve bunlardan dosya alabilirsiniz.

Paylaş menüsünü `Super + Ctrl + S` ile veya Omarchy menüsünde _Trigger > Share_ altında açabilirsiniz. Size dört seçenek sunar:

- **Clipboard** kopyaladığınız her şeyi bir metin dosyası olarak gönderir. Bir bağlantıyı veya bir parçacığı kendinize e-posta göndermeden telefonunuza aktarmak için harikadır.
- **File** aynı anda birkaç tane seçebileceğiniz bir dosya seçici açar.
- **Folder** tüm bir dizini gönderir.
- **Receive** LocalSend'in kendisini açar, böylece başka bir cihaz size bir şey gönderebilir.

Aynı şey terminalden `omarchy share clipboard`, `omarchy share file [path]` ve `omarchy share folder [path]` ile de çalışır. Yolu boş bırakırsanız seçiciyi görürsünüz.

Dosya yöneticisinden de doğrudan gönderebilirsiniz: Nautilus'ta herhangi bir seçime sağ tıklayın ve _Send via LocalSend_ seçeneğini seçin.

Omarchy'nin güvenlik duvarı LocalSend'in portu dışında varsayılan olarak kapalıdır, bu yüzden bu, yeni bir kurulumda kutudan çıktığı gibi çalışır. Bkz. [güvenlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/), kelime işlemci, elektronik tablo, sunumlar, çizim uygulaması ve daha fazlasını içeren eksiksiz bir ofis paketidir. Microsoft Office dosyalarıyla uyumludur, bu yüzden bu, o Word belgelerini açabilmenin harika bir yoludur.

LibreOffice'i uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız.

## Hype

[Hype](https://github.com/omacom/hype), Omarchy'nin kendi son derece basit sunum uygulamasıdır. Desteniz, görüntüleri ve videoları yanında olan tek bir Markdown dosyasıdır: her slaytı canlı bir önizlemenin altında yazın, slaytları sıraya sürükleyin, sonra tam ekran sunun veya PDF ve PowerPoint'e dışa aktarın. Omarchy temanızı bile alır.

Hype'ı uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız. Her kısayolu görmek için içinde `?` tuşuna basın.

## Signed

[Signed](https://github.com/omacom/signed), Omarchy'nin PDF'leri imzalamanın ve doldurmanın kendi son derece basit yoludur. Kaydedilmiş imzanızı, metni ve bugünün tarihini bir sayfada istediğiniz yere koyun, sonra imzalı bir kopyayı orijinalin yanına kaydedin. Nasıl yapılacağı için bkz. [PDF'leri doldurma](27-filling-out-pdfs.md).

Signed'i uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız veya dosya yöneticisinden bir PDF'yi onunla açarsınız.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc), yüzen bir pencerede açılan, Omarchy'nin kendi son derece basit hesap makinesidir.

Omacalc'ı `Super + Shift + Q` ile başlatırsınız (veya klavyenizde varsa hesap makinesi tuşuyla).

## Signal

[Signal](https://signal.org/), E2E şifreli mesajlaşmanın öncüsüdür ve büyük teknoloji holdinglerinden birinden geçmemeyi tercih eden herkes için harika bir iletişim seçeneğidir.

Signal'i `Super + Shift + G` ile başlatırsınız. Temel kurulumun bir parçası değildir, bu yüzden buna ilk bastığınızda Omarchy size onu kurmayı teklif eder (Omarchy menüsünde _Install > Service_ altında da bulunur).

## Omaview

[Omaview](https://github.com/omacom/omaview), Omarchy'nin kendi son derece basit resim görüntüleyicisi ve medya oynatıcısıdır: fotoğraflarınız, videolarınız ve müziğiniz için tek bir pencere. Bir fotoğraf açın ve ok tuşları klasörünün geri kalanında adım adım ilerler, `N` ve `P` bunu her şey için yapar ve `Ctrl + M` tüm klasörü bir ızgara olarak gösterir. HEIC, AVIF ve JPEG XL fotoğrafları da gösterir ve uzun olan her şeyde kaldığınız yerden devam eder.

Tam ekran için `F` tuşuna, bir resmi Omasnap'te düzenlemek veya bir videoyu Omacut'ta kırpmak için `E` tuşuna, bir resmi yazdırmak için `Ctrl + P` tuşuna ve bir dosyayı Trash'e taşımak için `Delete` tuşuna basın (`Ctrl + Z` onu geri getirir). Her kısayolu görmek için içinde `?` tuşuna basın.

Omaview'u uygulama başlatıcı üzerinden (`Super + Space`) _Media Viewer_ olarak başlatırsınız veya dosya yöneticisinde bir resme, videoya ya da şarkıya çift tıklarsınız.

## Omacut

[Omacut](https://github.com/omacom-io/omacut), Omarchy'nin kendi son derece basit video kırpıcısıdır. Tek ihtiyacınız bir klibin başını ve sonunu kesmek olduğunda, tam bir video düzenleyiciyi açmaktan iyidir.

Omacut'ı uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız.

## Monologue

[Monologue](https://github.com/omacom/monologue), Omarchy'nin kendi son derece basit webcam kaydedicisidir. Kameranızı ve mikrofonunuzu bir kez seçin, sonra kaydetmek için `Space` tuşuna basın ve aynı çekimi duraklatıp devam ettirmek için tekrar basın. Her zaman kameranızın en yüksek çözünürlüğünde kaydeder, başlamadan önce seviyelerinizi kontrol edebilmeniz için canlı bir mikrofon ölçeriyle birlikte.

Çekimi durdurun ve hemen yerleşik bir düzenleyicide açılır. Bölmek için bir klibe çift tıklayın, her parçayı kırpmak için tutamaçları sürükleyin ve istemediğiniz kısımları kaldırın. Sonra onu bir MP4 olarak kaydedin. Siz atana kadar orijinal kaydınız saklanır, böylece her zaman geri gelip onu farklı şekilde kesebilirsiniz.

Monologue'u uygulama başlatıcı üzerinden (`Super + Space`) başlatırsınız.
