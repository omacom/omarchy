# Güncellemeler

Omarchy ve paketleriniz, Omarchy menüsündeki (`Super + Space`) _Update > Omarchy_ üzerinden güncel tutulur.

Omarchy'nin kendisi, [Omarchy Paket Deposu](https://github.com/omacom-io/omarchy-pkgs) üzerinden normal pacman paketleri olarak kurulur; bu yüzden bir güncelleme [en son Omarchy sürümünü](https://github.com/omacom/omarchy/releases) kurar, sisteminizi en son sürümle senkronize etmek için bekleyen tüm geçişleri çalıştırır ve [Omarchy Arch Yansısı](https://github.com/omacom-io/omarchy-mirror) ile [AUR](https://aur.archlinux.org/) üzerinden tüm sistem paketlerini günceller (herhangi bir AUR paketi kurduysanız).

Yeni sürümler çıktığında, saatinizin sağında bir dairesel ok simgesi belirecektir. Ona tıklayın, güncelleme süreci başlayacaktır.

![update-available](images/update-available.webp)

### Dört kanal

Omarchy dört kanal üzerinden güncellenir: stable, RC, edge ve dev. Yeni kurulumlar, [resmi sürümleri](https://github.com/omacom/omarchy/releases/) takip eden stable kanalıyla başlar; ayrıca en son sürümün bir ay gerisinden gelen [stable Omarchy Arch yansısını](https://github.com/omacom-io/omarchy-mirror) kullanır, böylece yapılandırma değişiklikleri gerektiren yeni uyumsuzlukları, insanlara sorun çıkarmadan önce yakalayabiliriz.

Ama bu olası sorunları tespit etmeye yardımcı olmak isterseniz, edge kanalında çalışabilirsiniz. Bu, Omarchy paketlerinizin en son geliştirme derlemelerini takip etmesini sağlar ve en son Arch paketlerine çıkar çıkmaz güncellemenize olanak tanır. Bunu yalnızca Linux konusunda deneyimliyseniz ve sorun yaşayan bir sistemi nasıl kurtaracağınızı biliyorsanız yapmalısınız.

Her yeni büyük sürümden önce, RC kanalını kullanarak son doğrulamayı yapacağız. Son rötuşlara yardımcı olmakla ilgileniyorsanız, Discord'daki #omarchy-release-candidates kanalına takılmaya gelin.

Son olarak, Omarchy'yi edge paketleriyle birlikte `~/omarchy` içindeki kaynak kodun bir git kopyasına doğrudan bağlayan dev kanalı var. Bu kanalı yalnızca deneyimli bir Linux kullanıcısıysanız, doğrudan Omarchy üzerinde çalışıyorsanız ve bozulmalara katlanmaya razıysanız kullanmalısınız.

Kanallar arasında Omarchy menüsünden _Update > Channel_ kullanarak (veya terminalde `omarchy channel set <stable|rc|edge|dev>`, nerede olduğunuzu görmek için de `omarchy channel current`) geçiş yapabilirsiniz.

### Çekirdek değiştirme

Omarchy kendi `linux-omarchy` çekirdeğiyle önyüklenir, ancak stok Arch `linux` çekirdeği veya test ettiğiniz deneysel bir derleme gibi başkalarını da yanına kurulu tutabilirsiniz. Birden fazla olduğunda, Omarchy menüsündeki _Update > Kernel_, varsayılan olarak önyüklenenin yanında bir onay işaretiyle bunları listeler. Başka birini seçin, parolanızı bir kez girin, bir sonraki yeniden başlatmadan sonra onunla önyüklenecektir. Diğer çekirdekler önyükleme menüsünde kalır, bu yüzden yeni varsayılan size sorun çıkarırsa yine de elle birini seçebilirsiniz. Terminalde, mevcut varsayılanı görmek için `omarchy kernel`, neyin kurulu olduğunu görmek için `omarchy kernel list` ve geçiş yapmak için `omarchy kernel set <kernel>` kullanılır.

### Firmware güncellemeleri

Eskiyen tek şey paketleriniz değildir. Birçok dizüstü bilgisayar ve çevre birimi, BIOS, SSD ve dock firmware'ini Linux Vendor Firmware Service üzerinden sunar ve Omarchy menüsündeki _Update > Firmware_, donanımınız için bekleyen ne varsa getirip kuracaktır. İlk çalıştırdığınızda `fwupd` kurar. Pek çok firmware yalnızca yeniden başlatma sırasında yazılabilir, bu yüzden sizden yeniden başlatma istenirse şaşırmayın.

BIOS'un kendisinde bir ayarı değiştirmeniz gerektiğinde, sistem menüsünde (`Super + Escape`) `Alt` tuşunu basılı tutun; _Reboot_, _Reboot to BIOS_ hâline dönüşür ve önyükleme sırasında doğru tuşu yakalamak zorunda kalmadan doğrudan firmware kurulumuna yeniden başlatır. Terminalden ise `omarchy system firmware` komutunu kullanın.

### Doğrudan pacman/yay güncellemeleri hakkında uyarı

Arch'e zaten aşinaysanız, kendiniz `pacman -Syu` veya `yay -Syu` çalıştırmak cazip gelebilir, ancak bunu yaparsanız Omarchy'nin yeni paketlerle birlikte çalıştırdığı anlık görüntüyü, geçişleri ve yapılandırma güncellemelerini kaçırırsınız. İşte bu yüzden Omarchy, doğrudan bir sistem yükseltmesini aslında durduracak ve sizi bunun yerine `omarchy update` komutuna yönlendirecektir. (Gerçekten ne yaptığınızı biliyorsanız, koruma size bunu tek bir işlem için nasıl aşacağınızı söyleyecektir.)

### Kötü güncellemeleri geri alma

Bir güncelleme yaptıktan sonra hiç sorun yaşarsanız, sisteminizi güncellemeden önce alınan anlık görüntüye geri alabilirsiniz. Tek yapmanız gereken yeniden başlatmak ve önyükleme menüsünde güncellemeyi başlatmadan önceye ait anlık görüntüyü seçmektir.

![bootloader](images/bootloader.webp)

Yapılandırma dosyalarınız bir şekilde bozulduysa, terminalde `omarchy reinstall` kullanarak bir Omarchy yeniden kurulumu da gerçekleştirebilirsiniz. Bu, tüm varsayılan Omarchy paketlerini yeniden kuracak, sizi stable kanalına alacak (Apple Silicon'da edge) ve çok yeni olan tüm paketleri eski sürüme düşürecek ve tüm yapılandırma dosyalarını sıfırlayacaktır. Bunu yapmanın, Omarchy varsayılanlarında yaptığınız tüm kullanıcı yapılandırma değişikliklerinin üzerine yazacağını unutmayın!
