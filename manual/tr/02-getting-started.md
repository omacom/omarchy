# Başlarken

Omarchy, bir ISO kullanılarak kurulur. Tüm diski ele geçiren tam disk kurulumu ile Omarchy'yi bir diskin üzerindeki ayrılmamış alana yerleştiren boş alan kurulumu arasında seçim yapabilirsiniz — Windows veya başka bir işletim sisteminin yanına çift önyükleme ile kurulum bu şekilde yapılır (bkz. [çift önyükleme kurulumu](50-dual-boot-install.md) — öncesinde Windows'ta BitLocker'ı kapatmanız gerektiğini unutmayın). Her iki durumda da kurulum varsayılan olarak tam şifreleme kullanır ve tam disk seçeneği seçilen diski silecektir, bu yüzden mevcut bir diski kullanmadan önce mutlaka yedek alın!

Önce [Omarchy ISO'sunu indirin](https://omarchy.org/), bir USB belleğe yazın (Windows'ta [Rufus](https://rufus.ie/), Mac'te [balenaEtcher](https://etcher.balena.io/), Linux'ta [caligula](https://github.com/ifd3f/caligula) kullanın) ve bilgisayarı bellekten başlatın.

_BIOS'ta Secure Boot ve/veya TPM'yi kapatmanız gerekir. Omarchy'yi kurabilmek için bunları kapatmak zorundasınız. Bunlar, Windows ve Microsoft'a bağlı Linux dağıtımları için tasarlanmış Microsoft güvenlik düzenleridir._

Ardından yapılandırma sorularını yanıtlayın ve şu şekilde onaylayın:

 ![install-config](images/install-config.webp)

Ardından kurulum için bir disk seçin, arkanıza yaslanın ve kurulum şovunu izleyin. En hızlı modern makinelerde bir dakikadan kısa sürede tamamlanabilir, ancak daha eski bir bilgisayarda bile 5 dakikadan fazla sürmemelidir.

 ![install-done](images/install-done.webp)

Artık Omarchy'ye hazırsınız!

### Kablolu veya 2.4ghz bir klavye kullanın!

Tam disk şifrelemesi, başlangıçta parolayı bir Bluetooth klavyeden girmenize izin vermez. Tıpkı bir PC'de BIOS'a girmek için Bluetooth klavye kullanamayacağınız gibi. 2.4ghz adaptör kullanan veya kablolu bir klavyeye ihtiyacınız olacak (kablo, gecikme açısından zaten çok daha iyidir!). Ben şahsen [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)'e bayılıyorum!

### Başka bir sahip için kurulum

Bir makineyi başka biri için kuruyorsanız — bir aile üyesi, yeni bir çalışan, bir alıcı — kişisel soruları onun adına yanıtlamamalısınız. Yükleyicinin en ilk ekranında (klavye seçimi) `Ctrl + C` tuşlarına basın; Omarchy bunun yerine makineyi başka bir sahip için hazırlamayı önerecektir. Sistem hemen kurulur, ancak tüm kişisel kurulum — klavye düzeni, kullanıcı adı, parola — makine ilk kez başlatılana kadar ertelenir. Disk varsayılan olarak yine şifrelenir ve yeni sahibin o ilk başlatmada seçtiği parola, şifreleme parolası da olur. (Zaten kullanmakta olduğunuz bir makine de yeniden kurulum yapılmadan devredilebilir — bkz. [bilgisayarı sıfırlama](48-security.md).)

### Katılımsız kurulumlar

ISO, yapılandırması ikinci bir diskte kendisine verildiğinde tamamen kendi başına — klavyesiz, sihirbazsız — da kurulabilir. Omarchy'yi VM'ler ve filo makineleri için temel imaj olarak kullanmanın yolu budur. Bkz. [katılımsız kurulumlar](51-unattended-installs.md).

### Şifrelemesiz kurulumlar

Omarchy varsayılan olarak şifrelemeyle kurulur. Kaybolabilecek veya çalınabilecek herhangi bir bilgisayar için güvenli ve sorumlu seçim budur. Donanımınıza erişimi olan hiç kimsenin verilerinize ulaşabilmesini istemezsiniz!

Ancak korumalı bilgisayarlara uzaktan Omarchy kurulumları veya hassas veri içermeyen, kullanılıp atılacak kurulumlar gibi özel durumlarda şifrelemesiz kurmak isteyebilirsiniz. Şifrelemesiz bir kuruluma geçmek için disk biçimlendirme onayında `Ctrl + C` tuşlarına basabilirsiniz.

### Dil

Omarchy 50 dil konuşur — omarchy.org ile aynı küme — ve varsayılan dil İngilizcedir. Değiştirmek için Omarchy menüsünü açın ve _Kurulum > Bölge > Dil_ yolunu izleyin ya da bir terminalde `omarchy language <code>` komutunu çalıştırın (`omarchy language list` kodları gösterir). Menü, masaüstü ve Omarchy'nin kendi bildirimleri dili hemen değiştirir ve sonrasında açtığınız her uygulama da buna uyar. Zaten açık olan uygulamalar, onları yeniden başlattığınızda geçiş yapar.

Dili koruyup tarihleri, saatleri, sayıları, parayı, birimleri ve kâğıt boyutlarını başka bir bölgenin tarzında yazmak için (örneğin Avrupa tarihleri ve 24 saatlik saatle İngilizce), _Kurulum > Bölge > Biçimler_ altında, her seçimin bir örnek gösterdiği yerden bir bölge seçin ya da `omarchy region <code>` komutunu çalıştırın (`omarchy region list` kodları gösterir). _Dille aynı_ seçeneği, dilin kendi biçimlerine geri döner. Dil değişiminde olduğu gibi, bu da sonrasında açtığınız uygulamalara ulaşır.

### Takılırsanız yardım

Takılırsanız, genellikle [topluluk Discord](https://omarchy.org/discord) sunucusundaki _#omarchy-help_ kanalında size yardım etmeye istekli birini bulabilirsiniz.
