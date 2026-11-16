# GUI'ler

## Files

Files (Nautilus) grafik dosya yöneticisidir. `Super + Shift + F` onu açar ve `Super + Shift + Alt + F` terminalinizin bulunduğu dizinde açar; bu da sizi bir sürü tıklamadan kurtarır. `Ctrl + L` bir yol yazmanızı sağlar ve herhangi bir dosyanın üzerinde `Space` tuşuna basmak, hiçbir şey açmadan size hızlı bir önizleme verir.

Bir USB bellek veya SD kart taktığınızda otomatik olarak bağlanır, böylece kenar çubuğunda hemen belirir. Daha karmaşık işler için — bir sürücüyü biçimlendirmek, SMART sağlığını kontrol etmek, bölümler oluşturmak — uygulama başlatıcıdan (`Super + Space`) _Disks_'i başlatın.

Çift tıklama mantıklı varsayılanları izler: resimler, videolar ve müzik Omaview'de, PDF'ler Document Viewer'da, Markdown Omawrite'ta ve düz metin _Setup > Default > Editor_ altında seçilen düzenleyicide açılır.

## Disktree

Sürücü dolduğunda ve neyin yer kapladığına dair hiçbir fikriniz olmadığında, uygulama başlatıcıdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree)'yi başlatın. Ev dizininizin grafik bir ağaç haritasını gösterir. Daha büyük bloklar daha fazla yer kaplar; klavye veya fareyle dizinlerin içine girin, gitmesi gerekenleri işaretleyin ve herhangi bir şeyi kaldırmadan önce seçimlerinizi gözden geçirin. Tüm diski taramak için `disktree --disk` çalıştırın.

## Obsidian

[Obsidian](https://obsidian.md/), depolama için basit Markdown dosyaları kullanan, ücretsiz ve son derece genişletilebilir bir not alma uygulamasıdır.

Obsidian kişisel, ticari ve kâr amacı gütmeyen kullanım da dahil olmak üzere tüm amaçlar için ücretsizdir.

Obsidian ayrıca iOS ve Android'deki mobil uygulamalarla [senkronizasyon için ticari bir eklenti](https://obsidian.md/sync) sunar. (https://obsidian.md/pricing).

Obsidian'ı `Super + Shift + O` ile başlatırsınız. Tema senkronizasyonunu kullanmak için ayarlar altında `Omarchy` temasını seçmelisiniz.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite), Omarchy'nin kendi inanılmaz derecede basit Markdown yazma uygulamasıdır. Kasalar yok, eklentiler yok, sadece siz ve kelimeler.

Omawrite'ı `Super + Shift + W` ile başlatırsınız.

## Pinta

[Pinta](https://www.pinta-project.com/), kırpma, yeniden boyutlandırma ve diğer temel işlemler için harika olan temel bir görüntü düzenleme aracıdır. Sadece bir Photoshop alternatifi beklemeyin. Ama yine de Sihirli Değnek ve katmanları var!

Pinta'yı uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız.

## Aether

[Aether](https://github.com/bjarneo/aether), bir arka plan görüntüsünden renkler çıkarıp bunları eksiksiz, uyumlu bir temaya dönüştürebilen bir tema oluşturma uygulamasıdır. [Kendi temanızı yapmanın](43-making-your-own-theme.md) en kolay yoludur.

Aether'i uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız.

## LocalSend

[LocalSend](https://localsend.org/), Apple'ın AirDrop'u gibi, uygulamayı çalıştıran aynı ağdaki diğer cihazlara dosya göndermenizi sağlar. Ancak platformlar arası çalışır, böylece Windows, macOS, Android, iOS ve tabii ki Linux'a ve bunlardan dosya gönderebilirsiniz.

Share menüsünü `Super + Ctrl + S` ile veya Omarchy menüsünde _Trigger > Share_ altında açabilirsiniz. Size dört seçenek sunar:

- **Clipboard**, kopyaladığınız her şeyi bir metin dosyası olarak gönderir. Kendinize e-posta göndermeden bir bağlantıyı veya bir parçayı telefonunuza aktarmak için harikadır.
- **File**, aynı anda birkaç tane seçebileceğiniz bir dosya seçici açar.
- **Folder**, tüm bir dizini gönderir.
- **Receive**, başka bir cihazın size bir şey gönderebilmesi için LocalSend'in kendisini açar.

Aynı şey terminalden `omarchy share clipboard`, `omarchy share file [path]` ve `omarchy share folder [path]` ile de çalışır. Yolu boş bırakırsanız seçiciyi alırsınız.

Dosya yöneticisinden de doğrudan gönderebilirsiniz: Nautilus'ta herhangi bir seçime sağ tıklayın ve _Send via LocalSend_'i seçin.

Omarchy'nin güvenlik duvarı, LocalSend'in portu hariç varsayılan olarak kapalıdır, bu yüzden bu, yeni bir kurulumda kutudan çıktığı gibi çalışır. Bkz. [güvenlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/), kelime işlemci, hesap tablosu, sunumlar, çizim uygulaması ve daha fazlasını içeren eksiksiz bir ofis paketidir. Microsoft Office dosyalarıyla uyumludur, bu yüzden bu, o Word belgelerini açabilmenin harika bir yoludur.

LibreOffice'i uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız.

## Hype

[Hype](https://github.com/omacom/hype), Omarchy'nin kendi inanılmaz derecede basit sunum uygulamasıdır. Sunumunuz, görüntüleri ve videoları yanında olan tek bir Markdown dosyasıdır: her slaytı canlı bir önizlemenin altında yazın, slaytları sıraya sürükleyin, ardından tam ekran sunun veya PDF ve PowerPoint'e aktarın. Omarchy temanızı bile algılar.

Hype'ı uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız. Her kısayolu görmek için içinde `?` tuşuna basın.

## Signed

[Signed](https://github.com/omacom/signed), Omarchy'nin PDF'leri imzalamak ve doldurmak için kendi inanılmaz derecede basit yoludur. Kaydedilmiş imzanızı, metninizi ve bugünün tarihini bir sayfada istediğiniz yere koyun, ardından imzalı bir kopyayı orijinalinin yanına kaydedin. Nasıl yapılacağı için bkz. [PDF'leri doldurma](27-filling-out-pdfs.md).

Signed'ı uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız veya dosya yöneticisinden bir PDF'yi onunla açarsınız.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate), Omarchy'nin kendi 3D satranç oyunudur. Aynı bilgisayarda bir arkadaşınızla veya üç seviyedeki yerleşik rakibe karşı, her biri kendi tarzında hareket eden dört yontulmuş setle oynayın: yörünge araçları, oyma ahşap ve fildişi, orman yaratıkları ve şekerleme. Oyunlarda saat yoktur ve her hamleden sonra kaydedilir.

Checkmate'i uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız. Her kısayolu görmek için içinde `?` tuşuna basın.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc), yüzen bir pencerede açılan, Omarchy'nin kendi inanılmaz derecede basit hesap makinesidir.

Omacalc'ı `Super + Shift + Q` ile (veya klavyenizde varsa hesap makinesi tuşuyla) başlatırsınız.

## Signal

[Signal](https://signal.org/), E2E şifreli mesajlaşmanın öncüsüdür ve büyük teknoloji holdinglerinden birinden geçmemeyi tercih eden herkes için harika bir iletişim seçeneğidir.

Signal'i `Super + Shift + G` ile başlatırsınız. Temel kurulumun bir parçası değildir, bu yüzden bu tuşa ilk kez bastığınızda Omarchy onu sizin için kurmayı teklif eder (ayrıca Omarchy menüsünde _Install > Service_ altındadır).

## Omaview

[Omaview](https://github.com/omacom/omaview), Omarchy'nin kendi inanılmaz derecede basit resim görüntüleyicisi ve medya oynatıcısıdır: fotoğraflarınız, videolarınız ve müziğiniz için tek bir pencere. Bir fotoğraf açın ve ok tuşları klasörün geri kalanında adım adım gezsin, `N` ve `P` bunu her şey için yapar ve `Ctrl + M` tüm klasörü bir ızgara olarak gösterir. HEIC, AVIF ve JPEG XL fotoğrafları da gösterir ve uzun olan her şeyde kaldığınız yerden devam eder.

Tam ekran için `F` tuşuna, bir resmi Omasnap'te düzenlemek veya bir videoyu Omacut'ta kırpmak için `E` tuşuna, bir resmi yazdırmak için `Ctrl + P` tuşuna ve bir dosyayı Trash'e taşımak için `Delete` tuşuna basın (`Ctrl + Z` onu geri getirir). Her kısayolu görmek için içinde `?` tuşuna basın.

Omaview'i uygulama başlatıcı aracılığıyla (`Super + Space`) _Media Viewer_ olarak başlatırsınız veya dosya yöneticisinde bir resme, videoya ya da şarkıya çift tıklarsınız.

## Omacut

[Omacut](https://github.com/omacom-io/omacut), Omarchy'nin kendi inanılmaz derecede basit video kırpıcısıdır. Tek ihtiyacınız bir klibin başını ve sonunu kesmek olduğunda, tam bir video düzenleyiciyi açmaktan iyidir.

Omacut'ı uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız.

## Monologue

[Monologue](https://github.com/omacom/monologue), Omarchy'nin kendi inanılmaz derecede basit web kamerası kaydedicisidir. Kameranızı ve mikrofonunuzu bir kez seçin, ardından kaydetmek için `Space` tuşuna basın ve aynı çekimi duraklatıp sürdürmek için tekrar basın. Başlamadan önce seviyelerinizi kontrol edebilmeniz için canlı bir mikrofon ölçeriyle her zaman kameranızın en yüksek çözünürlüğünde kaydeder.

Çekimi durdurduğunuzda hemen yerleşik bir düzenleyicide açılır. Bölmek için bir klibe çift tıklayın, her parçayı kırpmak için tutamaçları sürükleyin ve istemediğiniz kısımları kaldırın. Ardından MP4 olarak kaydedin. Orijinal kaydınız siz onu atana kadar saklanır, böylece her zaman geri gelip farklı şekilde kesebilirsiniz.

Monologue'u uygulama başlatıcı aracılığıyla (`Super + Space`) başlatırsınız.
