# GUI'ler

## Dosyalar

Dosyalar (Nautilus) grafiksel dosya yöneticisidir. `Super + Shift + F` onu açar ve `Super + Shift + Alt + F` onu terminalinizin bulunduğu dizinde açar, bu da size bir sürü tıklamadan tasarruf ettirir. `Ctrl + L` bir yol yazmanızı sağlar ve herhangi bir dosyada `Space` tuşuna basmak, hiçbir şey açmadan size hızlı bir önizleme verir.

Bir USB bellek veya bir SD kart takın, otomatik olarak bağlanır, böylece kenar çubuğunda hemen görünür. Daha kapsamlı işler — bir sürücüyü biçimlendirmek, SMART sağlığını kontrol etmek, bölümler oluşturmak — için uygulama başlatıcıdan (`Super + Space`) _Disks_ uygulamasını başlatın.

Çift tıklama mantıklı varsayılanları izler: resimler, videolar ve müzik Omaview'de, PDF'ler Document Viewer'da ve düz metin Neovim'de açılır.

## Disktree

Sürücü dolduğunda ve neyin onu yiyip bitirdiğine dair hiçbir fikriniz olmadığında, uygulama başlatıcıdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) uygulamasını başlatın. Ana dizininizin grafiksel bir ağaç haritasını gösterir. Daha büyük bloklar daha fazla alan kaplar; klavye veya fareyle dizinlerin içine girin, gitmesi gerekenleri işaretleyin ve bir şeyi kaldırmadan önce seçimlerinizi gözden geçirin. Tüm diski taramak için `disktree --disk` komutunu çalıştırın.

## Obsidian

[Obsidian](https://obsidian.md/), depolama için basit Markdown dosyaları kullanan, ücretsiz ve son derece genişletilebilir bir not alma uygulamasıdır.

Obsidian; kişisel, ticari ve kâr amacı gütmeyen kullanım da dahil olmak üzere tüm amaçlar için ücretsizdir.

Obsidian ayrıca iOS ve Android'deki mobil uygulamalarla [eşitleme için ticari bir eklenti](https://obsidian.md/sync) sunar. (https://obsidian.md/pricing).

Obsidian'ı `Super + Shift + O` ile başlatırsınız. Tema eşitlemeyi kullanmak için ayarlar altında `Omarchy` temasını seçmelisiniz.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite), Omarchy'nin kendi son derece basit Markdown yazma uygulamasıdır. Kasalar yok, eklentiler yok, sadece siz ve kelimeler var.

Omawrite'ı `Super + Shift + W` ile başlatırsınız.

## Pinta

[Pinta](https://www.pinta-project.com/), kırpma, yeniden boyutlandırma ve diğer temel manipülasyonlar için harika, basit bir resim düzenleme aracıdır. Bir Photoshop alternatifi beklemeyin. Ama yine de bir Sihirli Değneği ve katmanları var!

Pinta'yı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## Aether

[Aether](https://github.com/bjarneo/aether), bir arka plan resminden renkler çıkarıp bunları eksiksiz, uyumlu bir temaya dönüştürebilen bir tema uygulamasıdır. [Kendi temanızı yapmanın](43-making-your-own-theme.md) en kolay yoludur.

Aether'i uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## LocalSend

[LocalSend](https://localsend.org/), Apple'ın AirDrop'u gibi, uygulamayı çalıştıran aynı ağdaki diğer cihazlara dosya göndermenizi sağlar. Ancak platformlar arası çalışır, böylece Windows, macOS, Android, iOS ve tabii ki Linux arasında dosya gönderip alabilirsiniz.

Paylaşım menüsünü `Super + Ctrl + S` ile veya Omarchy menüsünde _Trigger > Share_ altında açabilirsiniz. Size dört seçenek sunar:

- **Clipboard** kopyaladığınız her şeyi bir metin dosyası olarak gönderir. Kendinize e-posta göndermeden telefonunuza bir bağlantı veya bir kod parçacığı ulaştırmak için harikadır.
- **File** aynı anda birkaç tane seçebileceğiniz bir dosya seçici açar.
- **Folder** tüm bir dizini gönderir.
- **Receive** başka bir cihazın size bir şey gönderebilmesi için LocalSend'in kendisini açar.

Aynı şey terminalden `omarchy share clipboard`, `omarchy share file [path]` ve `omarchy share folder [path]` ile de çalışır. Yolu yazmazsanız seçiciyi alırsınız.

Doğrudan dosya yöneticisinden de gönderebilirsiniz: Nautilus'ta herhangi bir seçime sağ tıklayın ve _Send via LocalSend_ öğesini seçin.

Omarchy'nin güvenlik duvarı, LocalSend'in bağlantı noktası dışında varsayılan olarak kapalıdır, bu nedenle bu, yeni bir kurulumda kutudan çıktığı gibi çalışır. Bkz. [güvenlik](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/), kelime işlemci, hesap tablosu, sunumlar, çizim uygulaması ve daha fazlasını içeren eksiksiz bir ofis paketidir. Microsoft Office dosyalarıyla uyumludur, bu nedenle bu, o Word belgelerini açabilmek için harika bir yoldur.

LibreOffice'i uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## Hype

[Hype](https://github.com/omacom/hype), Omarchy'nin kendi son derece basit sunum uygulamasıdır. Sunumunuz, resimleri ve videoları yanında duran tek bir Markdown dosyasıdır: her slaytı canlı bir önizlemenin altında yazın, slaytları sıraya sürükleyin, ardından tam ekran sunun veya PDF ve PowerPoint olarak dışa aktarın. Hatta Omarchy temanızı bile alır.

Hype'ı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız. Her kısayolu görmek için içindeyken `?` tuşuna basın.

## Signed

[Signed](https://github.com/omacom/signed), Omarchy'nin PDF'leri imzalamak ve doldurmak için kendi son derece basit yoludur. Kaydedilmiş imzanızı, metni ve bugünün tarihini bir sayfanın herhangi bir yerine koyun, ardından orijinalin yanına imzalı bir kopya kaydedin. Nasıl yapılacağını görmek için [PDF'leri doldurma](27-filling-out-pdfs.md) bölümüne bakın.

Signed'i uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız veya dosya yöneticisinden onunla bir PDF açarsınız.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc), yüzen bir pencerede açılan, Omarchy'nin kendi son derece basit hesap makinesidir.

Omacalc'ı `Super + Shift + Q` ile (veya klavyenizde varsa hesap makinesi tuşuyla) başlatırsınız.

## Signal

[Signal](https://signal.org/), E2E şifreli mesajlaşmanın öncüsüdür ve büyük teknoloji holdinglerinden birinin üzerinden geçmemeyi tercih eden herkes için harika bir iletişim seçeneğidir.

Signal'i `Super + Shift + G` ile başlatırsınız. Temel kurulumun bir parçası değildir, bu nedenle bu tuşlara ilk bastığınızda Omarchy size onu kurmayı teklif edecektir (ayrıca Omarchy menüsünde _Install > Service_ altında da bulunur).

## Omaview

[Omaview](https://github.com/omacom/omaview), Omarchy'nin kendi son derece basit resim görüntüleyicisi ve medya oynatıcısıdır: fotoğraflarınız, videolarınız ve müziğiniz için tek bir pencere. Bir fotoğraf açın ve ok tuşları klasöründeki geri kalanında adım adım gezdirsin, `N` ve `P` bunu her şey için yapar ve `Ctrl + M` tüm klasörü bir ızgara olarak gösterir. HEIC, AVIF ve JPEG XL fotoğrafları da gösterir ve uzun olan her şeyde kaldığınız yerden devam eder.

Tam ekran için `F` tuşuna, bir resmi Omasnap'te düzenlemek veya bir videoyu Omacut'ta kırpmak için `E` tuşuna, bir resmi yazdırmak için `Ctrl + P` tuşuna ve bir dosyayı Trash'e taşımak için `Delete` tuşuna basın (`Ctrl + Z` onu geri getirir). Her kısayolu görmek için içindeyken `?` tuşuna basın.

Omaview'i uygulama başlatıcı (`Super + Space`) aracılığıyla _Media Viewer_ olarak başlatırsınız veya dosya yöneticisinde bir resme, videoya ya da şarkıya çift tıklarsınız.

## Omacut

[Omacut](https://github.com/omacom-io/omacut), Omarchy'nin kendi son derece basit video kırpıcısıdır. Tek ihtiyacınız bir klibin başını ve sonunu kesmek olduğunda, tam bir video düzenleyici çalıştırmaktan daha iyidir.

Omacut'ı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## Monologue

[Monologue](https://github.com/omacom/monologue), Omarchy'nin kendi son derece basit web kamerası kaydedicisidir. Kameranızı ve mikrofonunuzu bir kez seçin, ardından kaydetmek için `Space` tuşuna basın ve aynı çekimi duraklatıp sürdürmek için tekrar basın. Canlı bir mikrofon ölçerle her zaman kameranızın en yüksek çözünürlüğünde kaydeder, böylece başlamadan önce seviyelerinizi kontrol edebilirsiniz.

Çekimi durdurun, hemen yerleşik bir düzenleyicide açılır. Bölmek için bir klibe çift tıklayın, her parçayı kırpmak için tutamaçları sürükleyin ve istemediğiniz kısımları kaldırın. Ardından MP4 olarak kaydedin. Orijinal kaydınız siz onu atana kadar saklanır, böylece her zaman geri gelip onu farklı şekilde kesebilirsiniz.

Monologue'u uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.
