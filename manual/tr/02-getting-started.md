# Başlarken

Omarchy bir ISO kullanılarak kurulur. Tüm diski ele geçiren tam disk kurulumu ile Omarchy'yi bir diskteki ayrılmamış alana yerleştiren boş alan kurulumu arasında seçim yapabilirsiniz — Windows'un veya başka bir işletim sisteminin yanına çift önyükleme bu şekilde yapılır (bkz. [çift önyükleme kurulumu](50-dual-boot-install.md) — önce Windows'ta BitLocker'ı kapatmanız gerekeceğini unutmayın). Her iki durumda da kurulum varsayılan olarak tam şifrelemeyle gelir ve tam disk seçeneği seçilen diski silecektir, bu yüzden mevcut bir diski kullanmadan önce mutlaka yedek alın!

Önce [Omarchy ISO'sunu indirin](https://omarchy.org/), bir USB belleğe yazın (Windows'ta [Rufus](https://rufus.ie/), Mac'te [balenaEtcher](https://etcher.balena.io/), Linux'ta [caligula](https://github.com/ifd3f/caligula) kullanın) ve bilgisayarı bellekten başlatın.

_BIOS'ta Secure Boot ve/veya TPM'yi kapatmalısınız. Omarchy'yi kurabilmek için bunları kapatmanız gerekir. Bunlar Windows ve Microsoft'a bağlı Linux dağıtımları için tasarlanmış Microsoft güvenlik düzenleridir._

Ardından yapılandırma sorularını yanıtlayın ve şu şekilde onaylayın:

 ![install-config](images/install-config.webp)

Ardından kurulumunuz için bir disk seçin ve arkanıza yaslanıp kurulum şovunu izleyin. En hızlı modern makinelerde bir dakikadan kısa sürede tamamlanabilir, ancak daha eski bir bilgisayarda bile 5 dakikadan fazla sürmemelidir.

 ![install-done](images/install-done.webp)

Artık Omarchy'ye hazırsınız!

### Kablolu veya 2.4ghz klavye kullanın!

Tam disk şifrelemesi, başlangıçta parolayı Bluetooth klavyeden girmenize izin vermez. Tıpkı bir PC'de BIOS'a girmek için Bluetooth klavye kullanamamanız gibi. 2.4ghz dongle veya kablo kullanan bir klavyeye ihtiyacınız olacak (kablo zaten gecikme açısından çok daha iyidir!). Ben şahsen [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)'e bayılıyorum!

### Başka bir sahip için kurulum

Bir makineyi başka biri için kuruyorsanız — bir aile üyesi, yeni bir çalışan, bir alıcı — kişisel soruları onların adına yanıtlamamalısınız. Kurulum programının en ilk ekranında (klavye seçimi) `Ctrl + C` tuşlarına basın; Omarchy bunun yerine makineyi başka bir sahip için hazırlamayı önerecektir. Sistem hemen kurulur, ancak tüm kişisel kurulum — klavye düzeni, kullanıcı adı, parola — makinenin ilk kez başlatılmasına ertelenir. Disk yine varsayılan olarak şifrelenir ve yeni sahibin o ilk açılışta seçtiği parola, şifreleme parolası da olur. (Zaten kullanmakta olduğunuz bir makine de yeniden kurulum yapmadan devredilebilir — bkz. [bilgisayarı sıfırlama](48-security.md).)

### Katılımsız kurulumlar

ISO, yapılandırması ikinci bir diskte verildiğinde tamamen kendi kendine de kurulabilir — klavye yok, sihirbaz yok. Omarchy'yi VM'ler ve filo makineleri için temel imaj olarak kullanmanın yolu budur. Bkz. [katılımsız kurulumlar](51-unattended-installs.md).

### Şifrelemesiz kurulumlar

Omarchy varsayılan olarak şifrelemeyle kurulur. Kaybolma veya çalınma ihtimali olan her bilgisayar için güvenli ve sorumlu seçim budur. Donanımınıza erişimi olan hiç kimsenin verilerinize ulaşabilmesini istemezsiniz!

Ancak korumalı bilgisayarlara uzaktan Omarchy kurulumu gibi özel durumlarda veya hassas veri içermeyen tek kullanımlık kurulumlarda, şifrelemesiz kurmak isteyebilirsiniz. Şifrelemesiz kuruluma geçmek için disk biçimlendirme onayında `Ctrl + C` tuşlarına basabilirsiniz.

### Dil

Omarchy 50 dil konuşur — omarchy.org ile aynı set — ve varsayılan dil İngilizcedir. Değiştirmek için Omarchy menüsünü açın ve _Setup > Language_ bölümüne gidin veya bir terminalde `omarchy language <code>` komutunu çalıştırın (`omarchy language list` kodları gösterir). Menü, masaüstü ve Omarchy'nin kendi bildirimleri dilini hemen değiştirir ve sonrasında açtığınız her uygulama da bunu izler. Zaten açık olan uygulamalar, onları yeniden başlattığınızda değişir.

### Takılırsanız yardım

Takılırsanız, genellikle [topluluk Discord](https://omarchy.org/discord) sunucusundaki _#omarchy-help_ kanalında yardım etmeye istekli birini bulabilirsiniz.
