# Başlarken

Omarchy bir ISO kullanılarak kurulur. Sürücünün tamamını ele geçiren tam disk kurulumu ile Omarchy'yi bir sürücüdeki ayrılmamış alana yerleştiren boş alan kurulumu arasında seçim yapabilirsiniz — Windows veya başka bir işletim sisteminin yanında çift önyükleme bu şekilde yapılır (bkz. [çift önyükleme kurulumu](50-dual-boot-install.md) — önce Windows'ta BitLocker'ı kapatmanız gerekeceğini unutmayın). Her iki durumda da kurulum varsayılan olarak tam şifreleme kullanır ve tam disk seçeneği seçilen sürücüyü siler, bu yüzden mevcut bir sürücüyü kullanmadan önce mutlaka yedek alın!

Önce [Omarchy ISO'sunu indirin](https://omarchy.org/), bir USB belleğe yazın (Mac/Windows'ta [balenaEtcher](https://etcher.balena.io/) veya Linux'ta [caligula](https://github.com/ifd3f/caligula) kullanın) ve bellekten önyükleme yapın.

_BIOS'ta Secure Boot ve/veya TPM özelliğini kapatmalısınız. Omarchy kurabilmek için bunları kapatmanız gerekir. Bunlar Windows ve Microsoft ile ilişkili Linux dağıtımları için tasarlanmış Microsoft güvenlik düzenleridir._

Ardından yapılandırma sorularını yanıtlayın ve şu şekilde onaylayın:

 ![install-config](images/install-config.webp)

Sonra kurulumunuz için bir sürücü seçin, arkanıza yaslanın ve kurulum şovunu izleyin. En hızlı modern makinelerde bir dakikadan kısa sürede tamamlanabilir, ancak daha eski bir bilgisayarda bile 5 dakikadan uzun sürmemelidir.

 ![install-done](images/install-done.webp)

Artık Omarchy'lemeye hazırsınız!

### Kablolu veya 2.4ghz klavye kullanın!

Tam disk şifrelemesi, başlangıçta parolayı bir Bluetooth klavyeden girmenize izin vermez. Tıpkı bir PC'de BIOS'a girmek için Bluetooth klavye kullanamayacağınız gibi. 2.4ghz dongle veya kablo kullanan bir klavyeye ihtiyacınız olacak (kablo gecikme açısından zaten çok daha iyidir!). Ben şahsen [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) modelini çok seviyorum!

### Başka bir sahip için kurulum

Bir makineyi başka biri — bir aile üyesi, yeni bir çalışan, bir alıcı — için kuruyorsanız, kişisel soruları onun adına yanıtlamamalısınız. Kurulum programının en ilk ekranında (klavye seçimi) `Ctrl + C` tuşlarına basın; Omarchy bunun yerine makineyi başka bir sahip için hazırlamayı teklif eder. Sistem hemen kurulur, ancak tüm kişisel kurulum — klavye düzeni, kullanıcı adı, parola — makine ilk kez önyükleme yapana kadar ertelenir. Sürücü yine varsayılan olarak şifrelenir ve yeni sahibin o ilk önyüklemede seçtiği parola aynı zamanda şifreleme parolası da olur. (Zaten kullanmakta olduğunuz bir makine de yeniden kurulum yapmadan devredilebilir — bkz. [bilgisayarı sıfırlama](48-security.md).)

### Katılımsız kurulumlar

ISO, yapılandırması ikinci bir sürücüde kendisine verildiğinde tamamen kendi başına — klavye olmadan, sihirbaz olmadan — da kurulum yapabilir. Omarchy'yi VMs ve filo makineleri için temel imaj olarak kullanmanın yolu budur. Bkz. [katılımsız kurulumlar](51-unattended-installs.md).

### Şifrelemesiz kurulumlar

Omarchy varsayılan olarak şifreleme ile kurulur. Kaybolabilecek veya çalınabilecek her bilgisayar için güvenli ve sorumlu seçim budur. Donanımınıza erişimi olan herhangi birinin verilerinize ulaşabilmesini istemezsiniz!

Ancak korunaklı bilgisayarlara uzaktan Omarchy kurulumu gibi özel durumlarda veya hassas veri içermeyen tek kullanımlık kurulumlarda, şifreleme olmadan kurulum yapmak isteyebilirsiniz. Şifrelemesiz bir kuruluma geçmek için disk biçimlendirme onayında `Ctrl + C` tuşlarına basabilirsiniz.

### Dil

Omarchy, omarchy.org ile aynı set olmak üzere 50 dil konuşur ve varsayılan dil İngilizcedir. Değiştirmek için Omarchy menüsünü açın ve _Kurulum > Dil_ bölümüne gidin veya bir terminalde `omarchy language <code>` komutunu çalıştırın (`omarchy language list` kodları gösterir). Menü, masaüstü ve Omarchy'nin kendi bildirimleri dilini hemen değiştirir ve sonrasında açtığınız her uygulama da buna uyar. Zaten açık olan uygulamalar, onları yeniden başlattığınızda geçiş yapar.

### Takılırsanız yardım alın

Takılırsanız, [topluluk Discord'undaki](https://omarchy.org/discord) _#omarchy-help_ kanalında genellikle yardım etmeye istekli birini bulabilirsiniz.
