# Başlangıç

Omarchy bir ISO kullanılarak kurulur. Tüm diski devralan tam disk kurulumu ile Omarchy'yi bir sürücüdeki ayrılmamış alana yerleştiren boş alan kurulumu arasında seçim yapabilirsiniz — Windows veya başka bir işletim sisteminin yanına çift önyükleme ile kurulum bu şekilde yapılır (bkz. [çift önyükleme kurulumu](50-dual-boot-install.md) — unutmayın, önce Windows'ta BitLocker'ı kapatmanız gerekir). Her iki durumda da kurulum varsayılan olarak tam şifrelemeyle yapılır ve tam disk seçeneği seçilen sürücüyü silecektir, bu yüzden mevcut bir sürücüyü kullanmadan önce mutlaka yedek alın!

Önce [Omarchy ISO'sunu indirin](https://omarchy.org/), bir USB belleğe yazın (Windows'ta [Rufus](https://rufus.ie/), Mac'te [balenaEtcher](https://etcher.balena.io/), Linux'ta [caligula](https://github.com/ifd3f/caligula) kullanın) ve bellekten önyükleme yapın.

_BIOS'ta Secure Boot ve/veya TPM'yi kapatmanız gerekir. Omarchy'yi kurabilmek için bunları kapatmak zorundasınız. Bunlar Windows ve Microsoft'a bağlı Linux dağıtımları için tasarlanmış Microsoft güvenlik düzenleridir._

Ardından yapılandırma sorularını yanıtlayın ve şu şekilde onaylayın:

 ![install-config](images/install-config.webp)

Ardından kurulumunuz için bir sürücü seçin, arkanıza yaslanın ve kurulum şovunu izleyin. En hızlı modern makinelerde bir dakikadan kısa sürede tamamlanabilir, ancak daha eski bir bilgisayarda bile 5 dakikadan fazla sürmemelidir.

 ![install-done](images/install-done.webp)

Artık Omarchy'ye hazırsınız!

### Kablolu veya 2.4ghz bir klavye kullanın!

Tam disk şifrelemesi, başlangıçta parolayı bir Bluetooth klavyeden girmenize izin vermez. Tıpkı bir PC'de BIOS'a girmek için Bluetooth klavye kullanamadığınız gibi. 2.4ghz adaptör kullanan veya kablolu bir klavyeye ihtiyacınız olacak (ki bu gecikme açısından zaten çok daha iyidir!). Ben şahsen [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)'e bayılıyorum!

### Başka bir sahip için kurulum

Bir makineyi başka biri için kuruyorsanız — bir aile üyesi, yeni bir çalışan, bir alıcı — kişisel soruları onun adına yanıtlamamalısınız. Kurulum programının ilk ekranında (klavye seçimi) `Ctrl + C` tuşlarına basın; Omarchy bunun yerine makineyi başka bir sahip için hazırlamayı teklif edecektir. Sistem hemen kurulur, ancak tüm kişisel kurulum — klavye düzeni, kullanıcı adı, parola — makine ilk kez açılana kadar ertelenir. Sürücü yine varsayılan olarak şifrelenir ve yeni sahibin o ilk açılışta seçtiği parola aynı zamanda şifreleme parolası da olur. (Zaten kullanmakta olduğunuz bir makine de yeniden kurulum yapılmadan devredilebilir — bkz. [bilgisayarı sıfırlama](48-security.md).)

### Katılımsız kurulumlar

ISO, yapılandırması ikinci bir sürücüde kendisine verildiğinde tamamen kendi başına da kurulum yapabilir — klavye yok, sihirbaz yok. Omarchy'yi VM'ler ve filo makineleri için temel imaj olarak kullanmanın yolu budur. Bkz. [katılımsız kurulumlar](51-unattended-installs.md).

### Şifrelemesiz kurulumlar

Omarchy varsayılan olarak şifrelemeyle kurulur. Kaybolma veya çalınma ihtimali olan her bilgisayar için güvenli ve sorumlu seçim budur. Donanımınıza erişimi olan hiç kimsenin verilerinize ulaşabilmesini istemezsiniz!

Ancak korumalı bilgisayarlara yapılan uzaktan Omarchy kurulumları veya hassas veri içermeyen kullan-at kurulumlar gibi özel durumlarda, şifreleme olmadan kurulum yapmak isteyebilirsiniz. Disk biçimlendirme onayında `Ctrl + C` tuşlarına basarak şifrelemesiz bir kuruluma geçebilirsiniz.

### Dil

Omarchy 50 dil konuşur — omarchy.org ile aynı set — ve varsayılan dil İngilizcedir. Değiştirmek için Omarchy menüsünü açın ve _Kurulum > Bölge > Dil_ yolunu izleyin veya bir terminalde `omarchy language <code>` komutunu çalıştırın (`omarchy language list` kodları gösterir). Menü, masaüstü ve Omarchy'nin kendi bildirimleri dili anında değiştirir ve sonrasında açtığınız her uygulama da buna uyar. Zaten açık olan uygulamalar, onları yeniden başlattığınızda geçiş yapar.

Dili koruyup tarihleri, saatleri, sayıları, parayı, birimleri ve kâğıt boyutlarını başka bir bölgenin tarzında yazmak için (örneğin Avrupa tarihleri ve 24 saatlik saatle İngilizce), _Kurulum > Bölge > Biçimler_ altında bir bölge seçin; burada her seçim bir örnek gösterir, veya bir terminalde `omarchy region formats <code>` komutunu çalıştırın (`omarchy region formats list` kodları gösterir). _Dille aynı_ seçeneği dilin kendi biçimlerine geri döner. Bir dil değişimi gibi, bu da sonrasında açtığınız uygulamalara ulaşır.

### Takılırsanız yardım

Takılırsanız, genellikle [topluluk Discord'u](https://omarchy.org/discord) üzerindeki _#omarchy-help_ kanalında size yardım etmeye istekli birini bulabilirsiniz.
