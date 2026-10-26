# GUI'ler

## Dosyalar

Dosyalar (Nautilus) grafiksel dosya yöneticisidir. `Super + Shift + F` onu açar ve `Super + Shift + Alt + F` onu terminalinizin bulunduğu dizinde açar, bu da size bir sürü tıklamadan kurtarır. `Ctrl + L` bir yol yazmanızı sağlar ve herhangi bir dosyada `Space` tuşuna basmak, hiçbir şey açmadan size hızlı bir önizleme verir.

Bir USB bellek veya SD kart takın, otomatik olarak bağlanır; böylece kenar çubuğunda hemen görünür. Daha kapsamlı işler için — bir sürücüyü biçimlendirmek, SMART sağlığını kontrol etmek, bölümler oluşturmak — uygulama başlatıcıdan (`Super + Space`) _Disks_'i başlatın.

Çift tıklama mantıklı varsayılanları izler: görüntüler imv'de, video mpv'de, PDF'ler Document Viewer'da ve düz metin Neovim'de açılır.

## Disktree

Sürücü dolduğunda ve onu neyin yediği hakkında hiçbir fikriniz olmadığında, uygulama başlatıcıdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree)'yi başlatın. Ev dizininizin grafiksel bir ağaç haritasını gösterir. Daha büyük bloklar daha fazla yer kaplar; klavye veya fareyle dizinlerin içine girin, gitmesi gerekenleri işaretleyin ve bir şeyi kaldırmadan önce seçimlerinizi gözden geçirin. Tüm diski taramak için `disktree --disk` çalıştırın.

## Obsidian

[Obsidian](https://obsidian.md/), depolama için basit Markdown dosyalarını kullanan, ücretsiz ve son derece genişletilebilir bir not alma uygulamasıdır.

Obsidian kişisel, ticari ve kâr amacı gütmeyen kullanım da dahil olmak üzere tüm amaçlar için ücretsizdir.

Obsidian ayrıca iOS ve Android'deki mobil uygulamalarla [senkronizasyon için ticari bir eklenti](https://obsidian.md/sync) de sunar. (https://obsidian.md/pricing).

Obsidian'ı `Super + Shift + O` ile başlatırsınız. Tema senkronizasyonunu kullanmak için ayarlar altında `Omarchy` temasını seçmelisiniz.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite), Omarchy'nin kendi son derece basit Markdown yazma uygulamasıdır. Kasalar yok, eklentiler yok; sadece siz ve kelimeler var.

Omawrite'ı `Super + Shift + W` ile başlatırsınız.

## Pinta

[Pinta](https://www.pinta-project.com/), kırpma, yeniden boyutlandırma ve diğer temel işlemler için harika olan temel bir görüntü düzenleme aracıdır. Sadece bir Photoshop alternatifi beklemeyin. Ama yine de Magic Wand'ı ve katmanları var!

Pinta'yı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## Aether

[Aether](https://github.com/bjarneo/aether), bir arka plan görüntüsünden renkler çıkarıp bunları eksiksiz, uyumlu bir temaya dönüştürebilen bir tema oluşturma uygulamasıdır. [Kendi temanızı yapmanın](43-making-your-own-theme.md) en kolay yoludur.

Aether'i uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## LocalSend

[LocalSend](https://localsend.org/), Apple'ın AirDrop'u gibi, aynı ağda uygulamayı çalıştıran diğer cihazlara dosya göndermenizi sağlar. Ancak platformlar arası çalışır, böylece Windows, macOS, Android, iOS ve elbette Linux'a ve bunlardan dosya gönderebilirsiniz.

Paylaş menüsünü `Super + Ctrl + S` ile veya Omarchy menüsünde _Trigger > Share_ altında açabilirsiniz. Size dört seçenek sunar:

- **Clipboard**, kopyaladığınız her şeyi bir metin dosyası olarak gönderir. Kendinize e-posta göndermeden telefonunuza bir bağlantı veya bir kod parçacığı ulaştırmak için harikadır.
- **File**, birden fazlasını aynı anda seçebileceğiniz bir dosya seçici açar.
- **Folder** tüm bir dizini gönderir.
- **Receive**, başka bir cihazın size bir şey gönderebilmesi için LocalSend'in kendisini açar.

Aynı şey terminalden `omarchy share clipboard`, `omarchy share file [path]` ve `omarchy share folder [path]` ile de çalışır. Yolu atlarsanız seçiciyi alırsınız.

Dosya yöneticisinden de doğrudan gönderebilirsiniz: Nautilus'ta herhangi bir seçime sağ tıklayın ve _Send via LocalSend_'i seçin.

Omarchy'nin güvenlik duvarı, LocalSend'in bağlantı noktası dışında varsayılan olarak kapalıdır, bu yüzden bu yeni bir kurulumda kutudan çıktığı gibi çalışır. Bkz. [güvenlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/), kelime işlemci, elektronik tablo, sunumlar, çizim uygulaması ve daha fazlasını içeren eksiksiz bir ofis paketidir. Microsoft Office dosyalarıyla uyumludur, bu yüzden bu, o Word belgelerini açabilmenin harika bir yoludur.

LibreOffice'i uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## Hype

[Hype](https://github.com/omacom/hype), Omarchy'nin kendi son derece basit sunum uygulamasıdır. Sunumunuz, yanında görüntüleri ve videoları olan tek bir Markdown dosyasıdır: her slaytı canlı bir önizlemenin altında yazın, slaytları sıraya sürükleyin, ardından tam ekran sunun veya PDF ve PowerPoint olarak dışa aktarın. Hatta Omarchy temanızı bile alır.

Hype'ı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız. Her kısayolu görmek için içinde `?` tuşuna basın.

## Signed

[Signed](https://github.com/omacom/signed), Omarchy'nin PDF'leri imzalamanın ve doldurmanın kendi son derece basit yoludur. Kaydedilmiş imzanızı, metni ve bugünün tarihini bir sayfada istediğiniz yere koyun, ardından imzalı bir kopyayı orijinalin yanına kaydedin. Nasıl yapılacağı için bkz. [PDF'leri Doldurma](27-filling-out-pdfs.md).

Signed'i uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız veya dosya yöneticisinden onunla bir PDF açarsınız.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc), yüzen bir pencerede açılan, Omarchy'nin kendi son derece basit hesap makinesidir.

Omacalc'ı `Super + Shift + Q` ile (veya klavyenizde varsa hesap makinesi tuşuyla) başlatırsınız.

## Signal

[Signal](https://signal.org/), E2E şifreli mesajlaşmanın öncüsüdür ve büyük teknoloji holdinglerinden biri aracılığıyla gitmemeyi tercih eden herkes için harika bir iletişim seçeneğidir.

Signal'i `Super + Shift + G` ile başlatırsınız. Temel kurulumun bir parçası değildir, bu yüzden buna ilk kez bastığınızda Omarchy size onu kurmayı teklif edecektir (ayrıca Omarchy menüsünde _Install > Service_ altında da bulunur).

## mpv

[mpv](https://mpv.io/), hemen hemen her kaynaktan hemen hemen her şeyi oynatabilen basit, hızlı bir medya oynatıcısıdır. Video izlemek için harikadır.

mpv'yi uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız veya dosya yöneticisinde bir videoya çift tıklamanız yeterlidir.

## Omacut

[Omacut](https://github.com/omacom-io/omacut), Omarchy'nin kendi son derece basit video kırpma aracıdır. Tek ihtiyacınız olan bir klibin başını ve sonunu kesmek olduğunda, tam bir video düzenleyiciyi çalıştırmaktan daha iyidir.

Omacut'ı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## Monologue

[Monologue](https://github.com/omacom/monologue), Omarchy'nin kendi son derece basit webcam kaydedicisidir. Kameranızı ve mikrofonunuzu bir kez seçin, ardından kaydetmek için `Space` tuşuna basın ve aynı çekimi duraklatıp sürdürmek için tekrar basın. Başlamadan önce seviyelerinizi kontrol edebilmeniz için canlı bir mikrofon ölçeriyle her zaman kameranızın en yüksek çözünürlüğünde kaydeder.

Çekimi durdurduğunuzda, hemen yerleşik bir düzenleyicide açılır. Bölmek için bir klibe çift tıklayın, her parçayı kırpmak için tutamaçları sürükleyin ve istemediğiniz kısımları kaldırın. Ardından MP4 olarak kaydedin. Orijinal kaydınız siz onu atana kadar saklanır, böylece her zaman geri gelip onu farklı şekilde kesebilirsiniz.

Monologue'u uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.
