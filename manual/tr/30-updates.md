# Güncellemeler

Omarchy ve paketleriniz, Omarchy menüsündeki (`Super + Space`) _Güncelle > Omarchy_ aracılığıyla güncel tutulur.

Omarchy'nin kendisi, [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) üzerinden normal pacman paketleri olarak kurulur; bu yüzden bir güncelleme, [en son Omarchy sürümünü](https://github.com/omacom/omarchy/releases) kurar, sisteminizi en son sürümle senkronize etmek için bekleyen taşımaları çalıştırır ve [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) ve [AUR](https://aur.archlinux.org/) (herhangi bir AUR paketi kurduysanız) üzerinden tüm sistem paketlerini günceller.

Yeni sürümler yayınlandığında, saatinizin sağında bir daire ok simgesi belirecektir. Ona tıklayın, güncelleme süreci başlayacaktır.

![update-available](images/update-available.webp)

### Dört kanal

Omarchy dört kanal boyunca güncellenir: stable, RC, edge ve dev. Yeni kurulumlar, [resmi sürümleri](https://github.com/omacom/omarchy/releases/) izleyen stable kanalında başlar; ayrıca en son sürümün bir ay gerisinde çalışan [stable Omarchy Arch aynası](https://github.com/omacom-io/omarchy-mirror) kullanılır, böylece yapılandırma değişiklikleri gerektiren yeni uyumsuzlukları, insanlara sorun çıkarmadan önce yakalayabiliriz.

Ancak bu olası sorunları tespit etmeye yardımcı olmak isterseniz edge kanalında çalışabilirsiniz. Bu, Omarchy paketlerinizin en son geliştirme sürümlerini izlemesini sağlar ve en son Arch paketlerine kullanılabilir olur olmaz güncellemenize olanak tanır. Bunu yalnızca Linux konusunda deneyimliyseniz ve sorun yaşayan bir sistemi nasıl kurtaracağınızı biliyorsanız yapmalısınız.

Herhangi bir büyük yeni sürümden önce, RC kanalını kullanarak son doğrulamayı yapacağız. Son rötuşlara yardım etmekle ilgileniyorsanız, Discord'da #omarchy-release-candidates kanalına gelin.

Son olarak, Omarchy'yi `~/omarchy` içindeki kaynak kodun bir git kopyasına doğrudan bağlayan ve edge paketleriyle birleştiren dev kanalı vardır. Bu kanalı yalnızca doğrudan Omarchy üzerinde çalışan ve bozulmaya katlanmaya hazır deneyimli bir Linux kullanıcısıysanız kullanmalısınız.

Omarchy menüsünden _Güncelle > Channel_ (veya terminalde `omarchy-channel-set`) kullanarak kanallar arasında geçiş yapabilirsiniz.

### Bellenim güncellemeleri

Güncel olmayan tek şey paketleriniz değildir. Birçok dizüstü bilgisayar ve çevre birimi, Linux Vendor Firmware Service aracılığıyla BIOS, SSD ve dock bellenimi gönderir ve Omarchy menüsündeki _Güncelle > Firmware_, donanımınızın bekleyen her şeyini alıp kuracaktır. İlk çalıştırdığınızda `fwupd` kurar. Çok fazla bellenim yalnızca yeniden başlatma sırasında yazılabilir, bu yüzden bir tane istenirse şaşırmayın.

### Doğrudan pacman/yay güncellemeleri hakkında uyarı

Arch'a zaten aşinaysanız, kendinizi sadece `pacman -Syu` veya `yay -Syu` çalıştırmaya cazip bulabilirsiniz, ancak bunu yaparsanız Omarchy'nin yeni paketlerle birlikte çalıştırdığı anlık görüntüyü, taşımaları ve yapılandırma güncellemelerini kaçırırsınız. Bu yüzden Omarchy aslında doğrudan bir sistem yükseltmesini durduracak ve sizi bunun yerine `omarchy update` komutuna yönlendirecektir. (Gerçekten ne yaptığınızı biliyorsanız, koruma size tek bir işlem için bunu nasıl atlayacağınızı söyleyecektir.)

### Kötü güncellemeleri geri almak

Bir güncelleme yaptıktan sonra bir sorun yaşarsanız, sisteminizi güncellemeden önce alınan anlık görüntüye geri alabilirsiniz. Sadece yeniden başlatın ve önyükleme yükleme menüsünde, güncellemeyi başlatmadan önceki anlık görüntüyü seçin.

![bootloader](images/bootloader.webp)

Yapılandırma dosyalarınız bir şekilde bozulduysa, terminalde `omarchy reinstall` kullanarak bir Omarchy yeniden kurulumu da gerçekleştirebilirsiniz. Bu, tüm varsayılan Omarchy paketlerini yeniden kuracak, sizi stable'a koyacak ve çok yeni olan paketleri düşürecek ve tüm yapılandırma dosyalarını sıfırlayacaktır. Bunu yaparken Omarchy varsayılanlarına yaptığınız tüm kullanıcı yapılandırma değişikliklerinin üzerine yazılacağını unutmayın!
