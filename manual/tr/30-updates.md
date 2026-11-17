# Güncellemeler

Omarchy ve paketleriniz, Omarchy menüsündeki (`Super + Space`) _Güncelle > Omarchy_ üzerinden güncel tutulur.

Omarchy'nin kendisi, [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) üzerinden normal pacman paketleri olarak kurulur, bu yüzden bir güncelleme [en son Omarchy sürümünü](https://github.com/omacom/omarchy/releases) kurar, sisteminizi en son sürümle senkronize etmek için bekleyen tüm geçişleri çalıştırır ve [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) ile [AUR](https://aur.archlinux.org/) üzerindeki tüm sistem paketlerini günceller (herhangi bir AUR paketi kurduysanız).

Yeni sürümler yayınlandığında, saatinizin sağında dairesel bir ok simgesi belirecektir. Ona tıklayın, güncelleme işlemi başlayacaktır.

![update-available](images/update-available.webp)

### Dört kanal

Omarchy dört kanal boyunca güncellenir: stable, RC, edge ve dev. Yeni kurulumlar, [resmi sürümleri](https://github.com/omacom/omarchy/releases/) takip eden stable kanalında başlar; ayrıca en son sürümün bir ay gerisinden gelen [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) kullanılır, böylece yapılandırma değişiklikleri gerektiren yeni uyumsuzlukları, insanlara sorun çıkarmadan önce yakalayabiliriz.

Ancak bu olası sorunları tespit etmeye yardımcı olmak isterseniz, edge kanalında çalışabilirsiniz. Bu, Omarchy paketlerinizin en son geliştirme derlemelerini takip etmesini sağlar ve en son Arch paketlerine çıkar çıkmaz güncellemenize olanak tanır. Bunu yalnızca Linux konusunda deneyimliyseniz ve sorun yaşayan bir sistemi nasıl kurtaracağınızı biliyorsanız yapmalısınız.

Her yeni büyük sürümden önce, son doğrulamayı RC kanalını kullanarak yapacağız. Son rötuşlara yardımcı olmak isterseniz, Discord'daki #omarchy-release-candidates kanalına gelip takılın.

Son olarak, Omarchy'yi edge paketleriyle birlikte `~/omarchy` içindeki kaynak kodun bir git kopyasına doğrudan bağlayan dev kanalı var. Bu kanalı yalnızca deneyimli bir Linux kullanıcısıysanız, doğrudan Omarchy üzerinde çalışıyorsanız ve bozulmalara katlanmaya razıysanız kullanmalısınız.

Kanallar arasında Omarchy menüsündeki _Güncelle > Kanal_ seçeneğiyle (veya terminalde `omarchy-channel-set` ile) geçiş yapabilirsiniz.

### Çekirdek değiştirme

Omarchy kendi `linux-omarchy` çekirdeğiyle önyüklenir, ancak yanına stok Arch `linux` çekirdeği veya test ettiğiniz deneysel bir derleme gibi başkalarını da kurulu tutabilirsiniz. Birden fazla çekirdek olduğunda, Omarchy menüsündeki _Güncelle > Kernel_ bunları listeler ve varsayılan olarak önyüklenenin yanında bir onay işareti gösterir. Başka birini seçin, parolanızı bir kez girin; bir sonraki yeniden başlatmadan sonra onunla önyüklenecektir. Diğer çekirdekler önyükleme menüsünde kalır, böylece yeni varsayılan size sorun çıkarırsa yine de birini elle seçebilirsiniz. Terminalde, geçerli varsayılanı görmek için `omarchy-kernel`, kurulu olanları görmek için `omarchy-kernel list` ve geçiş yapmak için `omarchy-kernel set <kernel>` kullanılır.

### Donanım yazılımı güncellemeleri

Eskiyen tek şey paketleriniz değil. Birçok dizüstü bilgisayar ve çevre birimi, BIOS, SSD ve dock donanım yazılımını Linux Vendor Firmware Service aracılığıyla sunar ve Omarchy menüsündeki _Güncelle > Firmware_, donanımınız için bekleyen ne varsa getirip kurar. İlk çalıştırdığınızda `fwupd` kurar. Pek çok donanım yazılımı yalnızca yeniden başlatma sırasında yazılabilir, bu yüzden sizden yeniden başlatma istenirse şaşırmayın.

BIOS'un kendisinde bir ayarı değiştirmeniz gerektiğinde, sistem menüsünde (`Super + Escape`) `Alt` tuşunu basılı tutun; _Yeniden Başlat_, _BIOS'a Yeniden Başlat_ seçeneğine dönüşür ve önyükleme sırasında doğru tuşu yakalamak zorunda kalmadan doğrudan donanım yazılımı kurulumuna yeniden başlatır. Terminalden ise `omarchy system firmware` kullanılır.

### Doğrudan pacman/yay güncellemeleri hakkında uyarı

Arch'e zaten aşinaysanız, kendiniz `pacman -Syu` veya `yay -Syu` çalıştırmak isteyebilirsiniz, ancak bunu yaparsanız Omarchy'nin yeni paketlerle birlikte çalıştırdığı anlık görüntüyü, geçişleri ve yapılandırma güncellemelerini kaçırırsınız. Bu yüzden Omarchy, doğrudan bir sistem yükseltmesini gerçekten durdurur ve sizi bunun yerine `omarchy update` komutuna yönlendirir. (Gerçekten ne yaptığınızı biliyorsanız, koruma size tek bir işlem için bunu nasıl atlatacağınızı söyler.)

### Kötü güncellemeleri geri alma

Bir güncelleme yaptıktan sonra hiç sorun yaşarsanız, sisteminizi güncellemeden önce alınan anlık görüntüye geri alabilirsiniz. Tek yapmanız gereken yeniden başlatmak ve önyükleme menüsünden güncellemeyi başlatmadan önceki anlık görüntüyü seçmek.

![bootloader](images/bootloader.webp)

Yapılandırma dosyalarınız bir şekilde bozulduysa, terminalde `omarchy reinstall` kullanarak Omarchy'yi yeniden de kurabilirsiniz. Bu, tüm varsayılan Omarchy paketlerini yeniden kurar, sizi stable kanalına alır ve çok yeni olan tüm paketleri eski sürüme düşürür, ayrıca tüm yapılandırma dosyalarını sıfırlar. Bunu yapmanın, Omarchy varsayılanlarında yaptığınız tüm kullanıcı yapılandırma değişikliklerinin üzerine yazacağını unutmayın!
