# Başlarken

Omarchy bir ISO kullanılarak kurulur. Tüm sürücüyü ele geçiren tam disk kurulumu ile Omarchy'yi bir sürücüdeki ayrılmamış alana yerleştiren boş alan kurulumu arasında seçim yapabilirsiniz — Windows veya başka bir işletim sisteminin yanına çift önyükleme bu şekilde yapılır (bkz. [çift önyükleme kurulumu](50-dual-boot-install.md) — unutmayın, önce Windows'ta BitLocker'ı kapatmanız gerekir). Her iki durumda da kurulum varsayılan olarak tam şifrelemeyle gelir ve tam disk seçeneği seçilen sürücüyü silecektir, bu yüzden mevcut bir sürücüyü kullanmadan önce mutlaka yedek alın!

Apple Silicon bir Mac'te, ISO veya USB bellek olmadan, bunun yerine macOS üzerinden kurulum yaparsınız. Bkz. [Apple Silicon için Omarchy](44-mac-support.md#omarchy-for-apple-silicon).

Önce [Omarchy ISO'sunu indirin](https://omarchy.org/), bir USB belleğe yazın (Windows'ta [Rufus](https://rufus.ie/), Mac'te [balenaEtcher](https://etcher.balena.io/) veya Linux'ta [caligula](https://github.com/ifd3f/caligula) kullanın) ve bellekten önyükleme yapın.

_BIOS'ta Secure Boot ve/veya TPM'yi kapatmanız gerekir. Omarchy'yi kurabilmek için bunları kapatmak zorundasınız. Bunlar, Windows ve Microsoft'a bağlı Linux dağıtımları için tasarlanmış Microsoft güvenlik şemalarıdır._

Ardından yapılandırma sorularını yanıtlayın ve şu şekilde onaylayın:

 ![install-config](images/install-config.webp)

Ardından kurulumunuz için bir sürücü seçin, arkanıza yaslanın ve kurulum şovunu izleyin. En hızlı modern makinelerde bir dakikadan kısa sürede bitebilir, ancak daha eski bir bilgisayarda bile 5 dakikadan fazla sürmemesi gerekir.

 ![install-done](images/install-done.webp)

Artık Omarchy'ye hazırsınız!

### Kablolu veya 2.4ghz bir klavye kullanın!

Tam disk şifrelemesi, başlangıçta parolayı bir Bluetooth klavyeden girmenize izin vermez. Tıpkı bir PC'de BIOS'a girmek için Bluetooth klavye kullanamayacağınız gibi. Ya 2.4ghz dongle kullanan ya da kablolu bir klavyeye ihtiyacınız olacak (ki gecikme açısından da çok daha iyidir!). Ben şahsen [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)'e bayılıyorum!

### Başka bir sahip için kurulum

Bir makineyi başka biri için kuruyorsanız — bir aile üyesi, yeni bir çalışan, bir alıcı — kişisel soruları onun yerine siz yanıtlamamalısınız. Kurulum programının en ilk ekranında (klavye seçimi) `Ctrl + C` tuşlarına basın; Omarchy bunun yerine makineyi başka bir sahip için hazırlamayı teklif edecektir. Sistem hemen kurulur, ancak tüm kişisel kurulum — klavye düzeni, kullanıcı adı, parola — makine ilk kez açılana kadar ertelenir. Sürücü varsayılan olarak yine şifrelenir ve yeni sahibin o ilk açılışta seçtiği parola, şifreleme parolası da olur. (Zaten kullanmakta olduğunuz bir makine de yeniden kurulum yapmadan devredilebilir — bkz. [bilgisayarı sıfırlama](48-security.md).)

### Gözetimsiz kurulumlar

ISO, yapılandırması ikinci bir sürücüde kendisine verildiğinde tamamen kendi başına da kurulum yapabilir — klavye yok, sihirbaz yok. Omarchy'yi VM'ler ve filo makineleri için temel imaj olarak kullanmanın yolu budur. Bkz. [gözetimsiz kurulumlar](51-unattended-installs.md).

### Şifrelemesiz kurulumlar

Omarchy varsayılan olarak şifrelemeyle kurulur. Kaybolma veya çalınma ihtimali olan her bilgisayar için güvenli ve sorumlu seçim budur. Donanımınıza erişimi olan hiç kimsenin verilerinize ulaşabilmesini istemezsiniz!

Ancak korumalı bilgisayarlara uzaktan Omarchy kurulumları gibi özel durumlarda veya hassas veri içermeyen, kullanıp atmalık kurulumlarda şifrelemesiz kurmak isteyebilirsiniz. Şifrelemesiz bir kuruluma geçmek için disk biçimlendirme onayında `Ctrl + C` tuşlarına basabilirsiniz.

### Dil

Omarchy 50 dil konuşur — omarchy.org ile aynı set — ve varsayılan dil İngilizcedir. Değiştirmek için Omarchy menüsünü açın ve _Kurulum > Bölge > Dil_ yolunu izleyin ya da bir terminalde `omarchy language <code>` komutunu çalıştırın (`omarchy language list` kodları gösterir). Menü, masaüstü ve Omarchy'nin kendi bildirimleri dili hemen değiştirir ve sonrasında açtığınız her uygulama da buna uyar. Zaten açık olan uygulamalar, onları yeniden başlattığınızda değişir.

Dili koruyup tarihleri, saatleri, sayıları, parayı, birimleri ve kağıt boyutlarını başka bir bölgenin yaptığı gibi yazmak (örneğin Avrupa tarihleriyle ve 24 saatlik saatle İngilizce) için _Kurulum > Bölge > Biçimler_ altında, her seçimin bir örnek gösterdiği yerden bir bölge seçin ya da `omarchy region formats <code>` komutunu çalıştırın (`omarchy region formats list` kodları gösterir). _Dil ile aynı_ seçeneği, dilin kendi biçimlerine geri döner. Bir dil değişikliği gibi, bu da sonrasında açtığınız uygulamaları etkiler.

### Takılırsanız yardım

Takılırsanız, [topluluk Discord](https://omarchy.org/discord) üzerindeki _#omarchy-help_ kanalında genellikle size yardım etmeye istekli birini bulabilirsiniz.
