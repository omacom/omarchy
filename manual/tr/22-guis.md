# GUI'lar

## Files

Files (Nautilus), grafik dosya yöneticisidir. `Super + Shift + F` onu açar ve `Super + Shift + Alt + F` onu terminalinizin bulunduğu dizinde açar; bu da çok fazla tıklamadan tasarruf sağlar. `Ctrl + L` bir yol yazmanızı sağlar ve herhangi bir dosyada `Space` tuşuna basmak, hiçbir şey açmadan size hızlı bir önizleme verir.

Bir USB bellek veya SD kart takın; otomatik olarak bağlanır, böylece kenar çubuğunda belirir. Daha karmaşık herhangi bir şey için — bir sürücüyü biçimlendirmek, SMART sağlığını kontrol etmek, bölümler oluşturmak — uygulama başlatıcıdan (`Super + Space`) _Disks_ uygulamasını başlatın.

Çift tıklama mantıklı varsayılanları izler: görüntüler imv'de, video mpv'de, PDF'ler Document Viewer'da ve düz metin Neovim'de açılır.

## Disktree

Sürücü dolduğunda ve neyin onu yediği hakkında hiçbir fikriniz olmadığında, uygulama başlatıcıdan (`Super + Space`) [Disktree](https://github.com/tobi/disktree) uygulamasını başlatın. Ana dizininizin grafik bir ağaç haritasını gösterir. Daha büyük bloklar daha fazla yer kaplar; klavye veya fare ile dizinlerin içine girin, gitmesi gerekenleri işaretleyin ve herhangi bir şeyi kaldırmadan önce seçimlerinizi gözden geçirin. Tüm diski taramak için `disktree --disk` komutunu çalıştırın.

## Obsidian

[Obsidian](https://obsidian.md/), depolama için basit Markdown dosyaları kullanan ücretsiz ve son derece genişletilebilir bir not alma uygulamasıdır.

Obsidian; kişisel, ticari ve kâr amacı gütmeyen kullanım dahil tüm amaçlar için ücretsizdir.

Obsidian ayrıca iOS ve Android'deki mobil uygulamalarla eşitleme için bir [ticari eklenti](https://obsidian.md/sync) de sunar. (https://obsidian.md/pricing).

Obsidian'ı `Super + Shift + O` ile başlatırsınız. Tema eşitlemeyi kullanmak için ayarlar altında `Omarchy` temasını seçmeniz gerekir.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite), Omarchy'nin kendi son derece basit Markdown yazma uygulamasıdır. Kasalar yok, eklentiler yok, sadece siz ve kelimeler.

Omawrite'ı `Super + Shift + W` ile başlatırsınız.

## Pinta

[Pinta](https://www.pinta-project.com/), kırpma, yeniden boyutlandırma ve diğer temel işlemler için harika olan temel bir görüntü düzenleme aracıdır. Sadece bir Photoshop alternatifi beklemeyin. Ama yine de bir Sihirli Değneği ve katmanları var!

Pinta'yı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## Aether

[Aether](https://github.com/bjarneo/aether), bir arka plan görüntüsünden renkleri çıkarıp bunları eksiksiz, uyumlu bir temaya dönüştürebilen bir tema uygulamasıdır. [Kendi temanızı yapmanın](43-making-your-own-theme.md) en kolay yoludur.

Aether'i uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## LocalSend

[LocalSend](https://localsend.org/), Apple'ın AirDrop'u gibi, uygulamayı çalıştıran aynı ağdaki diğer cihazlara dosya göndermenizi sağlar. Ancak platformlar arasıdır, bu yüzden Windows, macOS, Android, iOS ve elbette Linux ile dosya gönderip alabilirsiniz.

Share menüsünü `Super + Ctrl + S` ile veya Omarchy menüsündeki _Tetikle > Paylaş_ altından açabilirsiniz. Size dört seçenek sunar:

- **Clipboard**, kopyaladığınız her şeyi bir metin dosyası olarak gönderir. Kendinize e-posta göndermeden bir bağlantıyı veya bir parçayı telefonunuza almak için harikadır.
- **File**, bir kerede birkaçını seçebileceğiniz bir dosya seçici açar.
- **Folder**, tüm bir dizini gönderir.
- **Receive**, başka bir cihazın size bir şey gönderebilmesi için LocalSend'in kendisini açar.

Aynı şey terminalden `omarchy share clipboard`, `omarchy share file [path]` ve `omarchy share folder [path]` ile de çalışır. Yolu boş bırakın, seçiciyi elde edin.

Dosya yöneticisinden de doğrudan gönderebilirsiniz: Nautilus'ta herhangi bir seçime sağ tıklayın ve _Send via LocalSend_ seçeneğini seçin.

Omarchy'nin güvenlik duvarı varsayılan olarak LocalSend'in bağlantı noktası dışında kapalıdır, bu yüzden bu, yeni bir kurulumda kutudan çıktığı gibi çalışır. [güvenlik](48-security.md) bölümüne bakın.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/), kelime işlemci, elektronik tablo, sunumlar, çizim uygulaması ve daha fazlasını içeren eksiksiz bir ofis paketidir. Microsoft Office dosyalarıyla uyumludur, bu yüzden bu Word belgelerini açabilmenin harika bir yoludur.

LibreOffice'i uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## Hype

[Hype](https://github.com/omacom/hype), Omarchy'nin kendi son derece basit sunum uygulamasıdır. Sunumunuz, görüntüleri ve videoları yanında duran tek bir Markdown dosyasıdır: her slaydı canlı bir önizlemenin altına yazın, slaytları sıraya sürükleyin, ardından tam ekran sunun veya PDF ve PowerPoint'e aktarın. Hatta Omarchy temanızı bile alır.

Hype'ı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız. Her kısayolu görmek için içinde `?` tuşuna basın.

## Signed

[Signed](https://github.com/omacom/signed), Omarchy'nin PDF'leri imzalamak ve doldurmak için kendi son derece basit yoludur. Kaydedilmiş imzanızı, metni ve bugünün tarihini bir sayfanın herhangi bir yerine koyun, ardından orijinalin yanına imzalı bir kopya kaydedin. Nasıl yapılacağı için [PDF'leri Doldurmak](27-filling-out-pdfs.md) bölümüne bakın.

Signed'ı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız veya dosya yöneticisinden onunla bir PDF açarsınız.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc), yüzen bir pencerede açılan, Omarchy'nin kendi son derece basit hesap makinesidir.

Omacalc'ı `Super + Ctrl + Q` ile (veya klavyenizde varsa hesap makinesi tuşuyla) başlatırsınız.

## Signal

[Signal](https://signal.org/), E2E şifreli mesajlaşmanın öncüsüdür ve büyük teknoloji holdinglerinden biri üzerinden geçmemeyi tercih eden herkes için harika bir iletişim seçeneğidir.

Signal'i `Super + Shift + G` ile başlatırsınız. Temel kurulumun bir parçası değildir, bu yüzden buna ilk bastığınızda Omarchy onu sizin için kurmayı teklif edecektir (ayrıca Omarchy menüsündeki _Kur > Service_ altındadır).

## mpv

[mpv](https://mpv.io/), hemen her kaynaktan hemen her şeyi oynatabilen basit, hızlı bir medya oynatıcıdır. Video izlemek için harikadır.

mpv'yi uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız veya dosya yöneticisinde bir videoya çift tıklarsınız.

## Omacut

[Omacut](https://github.com/omacom-io/omacut), Omarchy'nin kendi son derece basit video kırpıcısıdır. Tek ihtiyacınız bir klibin başını ve sonunu kesmek olduğunda, tam bir video düzenleyici başlatmaktan daha iyidir.

Omacut'ı uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.

## Monologue

[Monologue](https://github.com/omacom/monologue), Omarchy'nin kendi son derece basit web kamerası kaydedicisidir. Kameranızı ve mikrofonunuzu bir kez seçin, ardından kaydetmek için `Space` tuşuna basın ve aynı çekimi duraklatıp devam ettirmek için tekrar basın. Her zaman kameranızın en yüksek çözünürlüğünde kaydeder ve başlamadan önce seviyelerinizi kontrol edebilmeniz için canlı bir mikrofon ölçeri vardır.

Çekimi durdurun, hemen yerleşik bir düzenleyicide açılacaktır. Bir klibi bölmek için çift tıklayın, her parçayı kırpmak için tutamaçları sürükleyin ve istemediğiniz kısımları kaldırın. Ardından MP4 olarak kaydedin. Orijinal kaydınız, onu atana kadar saklanır, böylece her zaman geri gelip farklı şekilde kesebilirsiniz.

Monologue'yi uygulama başlatıcı (`Super + Space`) aracılığıyla başlatırsınız.
