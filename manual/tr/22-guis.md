# GUI'ler

## Files

Files (Nautilus), grafik dosya yöneticisidir. `Super + Shift + F` onu açar ve `Super + Shift + Alt + F`, terminalinizin bulunduğu dizinde açar; bu da sizi bir sürü tıklamadan kurtarır. `Ctrl + L` bir yol yazmanızı sağlar ve herhangi bir dosyanın üzerindeyken `Space` tuşuna basmak, hiçbir şey açmadan size hızlı bir önizleme verir.

Bir USB bellek veya SD kart takın; otomatik olarak bağlanır, böylece kenar çubuğunda hemen görünür. Daha karmaşık işler için — bir sürücüyü biçimlendirmek, SMART durumunu kontrol etmek, bölümler oluşturmak — uygulama başlatıcıdan (`Super + Space`) _Disks_ uygulamasını başlatın.

Çift tıklama, mantıklı varsayılanları izler: resimler, videolar ve müzikler Omaview'da, PDF'ler Document Viewer'da, Markdown Omawrite'da ve düz metin _Setup > Default > Editor_ altında seçilen düzenleyicide açılır.

## Disktree

Sürücü dolduğunda ve neyin yer kapladığına dair hiçbir fikriniz olmadığında, uygulama başlatıcıdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) uygulamasını başlatın. Ev dizininizin grafiksel bir ağaç haritasını gösterir. Daha büyük bloklar daha fazla yer kaplar; klavye veya fareyle dizinlerin içine girin, gitmesi gerekenleri işaretleyin ve herhangi bir şeyi kaldırmadan önce seçimlerinizi gözden geçirin. Tüm diski taramak için `disktree --disk` komutunu çalıştırın.

## Obsidian

[Obsidian](https://obsidian.md/), depolama için basit Markdown dosyaları kullanan, ücretsiz ve son derece genişletilebilir bir not alma uygulamasıdır.

Obsidian, kişisel, ticari ve kâr amacı gütmeyen kullanım da dahil olmak üzere tüm amaçlar için ücretsizdir.

Obsidian ayrıca iOS ve Android'deki mobil uygulamalarla [senkronizasyon için ticari bir eklenti](https://obsidian.md/sync) de sunar. (https://obsidian.md/pricing).

Obsidian'ı `Super + Shift + O` ile başlatırsınız. Tema senkronizasyonunu kullanmak için ayarlar altında `Omarchy` temasını seçmelisiniz.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite), Omarchy'nin kendi son derece basit Markdown yazma uygulamasıdır. Kasa yok, eklenti yok; sadece siz ve kelimeler var.

Omawrite'ı `Super + Shift + W` ile başlatırsınız.

## Pinta

[Pinta](https://www.pinta-project.com/), kırpma, yeniden boyutlandırma ve diğer temel işlemler için harika olan temel bir görsel düzenleme aracıdır. Sakın bir Photoshop alternatifi beklemeyin. Ama yine de Magic Wand ve katmanları var!

Pinta'yı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## Aether

[Aether](https://github.com/bjarneo/aether), bir arka plan görselinden renkler çıkarabilen ve bunları eksiksiz, uyumlu bir temaya dönüştürebilen bir tema oluşturma uygulamasıdır. [Kendi temanızı yapmanın](43-making-your-own-theme.md) en kolay yoludur.

Aether'ı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## LocalSend

[LocalSend](https://localsend.org/), Apple'ın AirDrop'u gibi, uygulamayı çalıştıran aynı ağdaki diğer cihazlara dosya göndermenizi sağlar. Ancak platformlar arası çalışır; böylece Windows, macOS, Android, iOS ve tabii ki Linux ile karşılıklı dosya gönderebilirsiniz.

Share menüsünü `Super + Ctrl + S` ile veya Omarchy menüsünde _Trigger > Share_ altında açabilirsiniz. Size dört seçenek sunar:

- **Clipboard**, kopyaladığınız her şeyi bir metin dosyası olarak gönderir. Kendinize e-posta göndermeden telefonunuza bir bağlantı veya bir parça metin aktarmak için harikadır.
- **File**, aynı anda birkaç tane seçebileceğiniz bir dosya seçici açar.
- **Folder**, bir dizinin tamamını gönderir.
- **Receive**, başka bir cihazın size bir şey gönderebilmesi için LocalSend'in kendisini açar.

Aynı şey terminalden `omarchy share clipboard`, `omarchy share file [path]` ve `omarchy share folder [path]` ile de çalışır. Yolu yazmazsanız seçici açılır.

Doğrudan dosya yöneticisinden de gönderebilirsiniz: Nautilus'ta herhangi bir seçime sağ tıklayın ve _Send via LocalSend_ seçeneğini seçin.

Omarchy'nin güvenlik duvarı, LocalSend'in portu dışında varsayılan olarak kapalıdır; bu yüzden bu, yeni bir kurulumda kutudan çıktığı gibi çalışır. Bkz. [güvenlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/), kelime işlemci, hesap tablosu, sunumlar, çizim uygulaması ve daha fazlasını içeren eksiksiz bir ofis paketidir. Microsoft Office dosyalarıyla uyumludur; bu yüzden o Word belgelerini açabilmek için harika bir yoldur.

LibreOffice'i uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## Hype

[Hype](https://github.com/omacom/hype), Omarchy'nin kendi son derece basit sunum uygulamasıdır. Sunumunuz, görselleri ve videoları yanında duran tek bir Markdown dosyasıdır: her slaytı canlı önizlemenin altında yazın, slaytları sürükleyerek sıralayın, ardından tam ekran sunun veya PDF ve PowerPoint olarak dışa aktarın. Hatta Omarchy temanızı bile alır.

Hype'ı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız. Tüm kısayolları görmek için içindeyken `?` tuşuna basın.

## Signed

[Signed](https://github.com/omacom/signed), Omarchy'nin PDF'leri imzalamak ve doldurmak için kendi son derece basit yoludur. Kaydedilmiş imzanızı, metni ve bugünün tarihini bir sayfada istediğiniz yere koyun, ardından imzalı bir kopyayı orijinalin yanına kaydedin. Nasıl yapılacağı için bkz. [PDF'leri doldurma](27-filling-out-pdfs.md).

Signed'ı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız veya dosya yöneticisinden onunla bir PDF açarsınız.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate), Omarchy'nin kendi 3D satranç oyunudur. Aynı bilgisayarda bir arkadaşınızla veya üç seviyede yerleşik rakibe karşı, her biri kendine özgü şekilde hareket eden dört yontulmuş setle oynayın: yörünge araçları, oyulmuş ahşap ve fildişi, orman yaratıkları ve şeker. Oyunlarda saat yoktur ve her hamleden sonra kaydedilir.

Checkmate'i uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız; orada Chess olarak listelenir. Tüm kısayolları görmek için içindeyken `?` tuşuna basın.

## Cards

[Cards](https://github.com/omacom/cards), Omarchy'nin kendi Klondike solitaire oyunudur. Dört kart serisiyle, turlarda sınır olmadan üçerli çekin: biri temanızın renkleriyle çizilmiş, üçü de kendine özgü bir görünüme sahiptir. Bir karta ve ardından gideceği yere tıklayın, onu sürükleyin veya en iyi yere göndermek için çift tıklayın. Oyunlar her hamleden sonra kaydedilir.

Cards'ı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız. Tüm kısayolları görmek için adına tıklayın veya `?` tuşuna basın.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc), yüzen bir pencerede açılan, Omarchy'nin kendi son derece basit hesap makinesidir.

Omacalc'ı `Super + Shift + Q` ile başlatırsınız (veya klavyenizde varsa hesap makinesi tuşuyla).

## Signal

[Signal](https://signal.org/), E2E şifreli mesajlaşmanın öncüsüdür ve büyük teknoloji şirketlerinden birinden geçmemeyi tercih eden herkes için harika bir iletişim seçeneğidir.

Signal'i `Super + Shift + G` ile başlatırsınız. Temel kurulumun bir parçası değildir; bu yüzden o tuşlara ilk bastığınızda Omarchy size onu kurmayı teklif eder (ayrıca Omarchy menüsünde _Install > Service_ altındadır).

## Omaview

[Omaview](https://github.com/omacom/omaview), Omarchy'nin kendi son derece basit resim görüntüleyicisi ve medya oynatıcısıdır: fotoğraflarınız, videolarınız ve müziğiniz için tek bir pencere. Bir fotoğraf açın ve ok tuşları klasörün geri kalanında adım adım ilerler, `N` ve `P` bunu her şey için yapar ve `Ctrl + M` tüm klasörü bir ızgara olarak gösterir. HEIC, AVIF ve JPEG XL fotoğrafları da gösterir ve uzun olan her şeyde kaldığınız yerden devam eder.

Tam ekran için `F` tuşuna, bir resmi Omasnap'te düzenlemek veya bir videoyu Omacut'ta kırpmak için `E` tuşuna, bir resmi yazdırmak için `Ctrl + P` tuşuna ve bir dosyayı Trash'e taşımak için `Delete` tuşuna basın (`Ctrl + Z` onu geri getirir). Tüm kısayolları görmek için içindeyken `?` tuşuna basın.

Omaview'ı uygulama başlatıcı (`Super + Space`) aracılığıyla _Media Viewer_ olarak başlatırsınız veya dosya yöneticisinde bir resme, videoya ya da şarkıya çift tıklamanız yeterlidir.

## Omacut

[Omacut](https://github.com/omacom-io/omacut), Omarchy'nin kendi son derece basit video kırpıcısıdır. Tek ihtiyacınız bir klibin başını ve sonunu kesmek olduğunda, tam bir video düzenleyiciyi açmaktan iyidir.

Omacut'ı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## Monologue

[Monologue](https://github.com/omacom/monologue), Omarchy'nin kendi son derece basit webcam kaydedicisidir. Kameranızı ve mikrofonunuzu bir kez seçin, ardından kaydetmek için `Space` tuşuna basın ve aynı çekimi duraklatıp devam ettirmek için tekrar basın. Her zaman kameranızın en yüksek çözünürlüğünde kaydeder ve başlamadan önce seviyelerinizi kontrol edebilmeniz için canlı bir mikrofon ölçeri vardır.

Çekimi durdurun; hemen yerleşik bir düzenleyicide açılır. Bir klibi bölmek için çift tıklayın, her parçayı kırpmak için tutamaçları sürükleyin ve istemediğiniz kısımları kaldırın. Ardından MP4 olarak kaydedin. Orijinal kaydınız siz onu atana kadar saklanır; böylece her zaman geri gelip farklı şekilde kesebilirsiniz.

Monologue'u uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.
