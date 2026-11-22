# Mac desteği

## Apple Silicon için Omarchy

Apple Silicon için Omarchy, resmi bir Omacom çözümüdür ve ilk olarak Omarchy 4.5 ile yayımlandı. macOS'in yanına kurulur ve Mac'iniz açılırken ikisi arasında seçim yaparsınız.

Omarchy Mac hakkında bir bildirim mi aldınız? [Omarchy Mac'ten geliyorsanız](#coming-from-omarchy-mac) bölümüne gidin.

Şu Mac'lerde çalışır:

| Mac | Çipler |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 ve daha yeni Mac'ler henüz desteklenmiyor. M4 desteği edge kanalında test ediliyor ve sırada o var. Yükleyici, herhangi bir değişiklik yapmadan önce Mac'inizi kontrol eder.

M4 ve daha yeni modeller dahil herhangi bir Apple Silicon Mac'te, Omarchy'yi [Try Omarchy](https://github.com/omacom/try-omarchy) ile bir sanal makinede çalıştırabilirsiniz.

### Gerekenler

- macOS 15 Sequoia veya daha yenisi ve bir yönetici hesabı
- Omarchy için boş disk alanı. Yükleyici bir boyut önerir ve değiştirmenize izin verir.
- Mac'inizin bir yedeği, güç ve bir internet bağlantısı. Kurulum birkaç gigabayt indirir.

### Kurulum

Kurulumu macOS'ten yaparsınız. Omarchy Installer'ı [Homebrew](https://brew.sh) ile kurun:

```sh
brew install omacom/mac/omarchy
```

Veya en yeni Omarchy Installer'ı [sürümler sayfasından](https://github.com/omacom/omarchy-mac-installer/releases) indirin ve açın.

Yükleyici Mac'inizi kontrol eder, size planı gösterir ve macOS bölümünü küçülterek Omarchy için yer açar. macOS diskte kalır ve USB sürücü gerekmez. İlk aşama tamamlandığında, macOS Recovery içinde kurulumu bitirmeniz için size yol gösterir: kapatın, "Loading startup options" görünene kadar güç düğmesini basılı tutun, Omarchy'yi seçin ve adımları izleyin.

İlk açılışta Omarchy, diskini şifreleyen bir parola ister. Kurtarma anahtarı yok: parolayı unutursanız Omarchy dosyalarınız kurtarılamaz.

Daha sonra Omarchy ve macOS arasında geçiş yapmak için kapatın, ardından başlangıç seçenekleri görünene kadar güç düğmesini basılı tutun ve birini seçin.

### Omarchy Mac'ten geliyorsanız

Omarchy Mac artık Apple Silicon için Omarchy'nin bir parçası ve onu çalıştıran her Mac destekleniyor. Mevcut kurulumunuz çalışmaya devam eder ve sistem paketleri hâlâ güncellenir, ancak artık Omarchy güncellemeleri almaz. Bir son tarih yok ve yerinde yükseltme yok: yedeklersiniz, eski kurulumu kaldırırsınız, sıfırdan kurarsınız ve geri yüklersiniz. 2 ile 5 arasındaki adımlar macOS'te gerçekleşir, bu yüzden yeniden başlatmadan önce bu sayfayı telefonunuzda açın.

1. **Omarchy içinden, Mac'in dışına yedekleyin.** Eski kurulumu kaldırmak onu siler ve macOS, Omarchy diskini okuyamaz. Ana klasörünüzü harici bir sürücüye veya başka bir bilgisayara kopyalayın; SSH ve GPG anahtarları, tarayıcı profilleri ve gönderilmemiş çalışmalar dahil. Paket listenizi `pacman -Qqe > ~/packages.txt` ile kaydedin. Kaldırma ve kurulum işlemlerinin ikisi de diskini yeniden boyutlandırdığı için macOS'i de yedekleyin.
2. **Mac'inizi macOS'te başlatın.** Kapatın, başlangıç seçenekleri görünene kadar güç düğmesini basılı tutun ve macOS'i seçin.
3. **Omarchy Installer'ı kurun**; [Kurulum](#installing) bölümünde gösterildiği gibi.
4. **Eski kurulumu kaldırın.** Omarchy Installer'ı açın ve Installation > Remove Omarchy seçeneğini seçin. Neyi sileceğini gösterir ve alanı macOS'e geri verir. Kurulumunuzu tanımazsa, diskte değişiklik yapmadan durur. Bölümleri elle silmek yerine [Discord](https://discord.gg/tXFUdasqhY) üzerinden yardım isteyin; elle silmek macOS'i silebilir.
5. **Apple Silicon için Omarchy'yi** yükleyiciyle kurun.
6. **Dosyalarınızı geri yükleyin.** Tüm `~/.config` klasörünü yeni varsayılanların üzerine kopyalamak yerine ayarlarınızı parça parça geri getirin, çünkü eski ayarlar yenilerini geçersiz kılabilir.

### Bilmekte fayda var

- M1 ve M2 MacBook'larda, kapağı açarak veya güç düğmesine basarak uykudan uyandırın.
- Sorular veya sorunlar: [Discord](https://discord.gg/tXFUdasqhY) üzerinden bize sorun.

[Yükleyicinin README'si](https://github.com/omacom/omarchy-mac-installer#readme), sürüm kanallarını, yükleyiciyi güncellemeyi ve Omarchy'yi kaldırmayı kapsar.

## Intel Mac'ler

Basit bir testte, 2019 MacBook Pro'ya yalnızca Omarchy kurarak %36 performans artışı elde edebildik.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac'e Omarchy kurulumu

Omarchy şu anda kurulu **tek** işletim sistemi olmayı destekliyor. Kurulum sırasında sürücü silinecek ve MacOS artık başlatılamayacak.

Dilerseniz daha sonra Internet Recovery aracılığıyla onu yine de geri yükleyebilirsiniz.

Bu bölüm için, [Başlarken](02-getting-started.md) bölümünü zaten incelediğinizi ve USB sürücünüzün hazır olduğunu varsayacağız. İncelemediyseniz hemen şimdi yapın.

#### Secure Boot'u devre dışı bırakma

Önyüklenebilir USB'yi ve işletim sistemini başlatabilmek için Apple'ın Secure Boot'unu devre dışı bırakmak gerekir. Devre dışı bırakmak için şunları yapın:

1. Mac'inizi kapatın
2. Açın ve yükleme ekranı görünene kadar _hemen_ Command-R tuşlarını basılı tutun
3. Kullanıcınızı seçin ve istenirse parolanızı girin
4. Kurtarma ekranına geldiğinizde, menü çubuğundan **Utilities > Startup Security Utility** seçeneğini seçin
5. Kimlik doğrulaması istendiğinde parolanızı girin
6. Secure Boot seçeneklerinden "No Security" seçeneğini seçin
7. External Boot seçeneklerinden "Allow booting from external or removable media" seçeneğini seçin

#### Kurulumu başlatma

1. USB sürücüyü takın
2. Mac'inizi yeniden başlatın ve önyükleme cihazlarının olduğu bir ekran görene kadar _hemen_ Option tuşunu basılı tutun
3. Turuncu EFI Boot cihazını seçin
4. [Normal kurulumla devam edin](02-getting-started.md)

Yükleyici Mac donanımını algılar ve gereken düzeltmeleri otomatik olarak uygular: Broadcom Wi-Fi sürücüleri ve firmware'i, buna ihtiyaç duyan MacBook modellerindeki SPI klavye sürücüsü ve aynı modeller için bir NVMe askıya alma düzeltmesi.

### Bilinen sınırlamalar

Topluluk üyeleri bu zorluklara sürekli çözüm üretmek için çalışıyor; bu yüzden bunlar sizin için sorun teşkil ediyorsa, [Discord](https://discord.gg/tXFUdasqhY) üzerindeki #omarchy-on-other kanalına katılın ve bunları çözmek için güncel yöntemler olup olmadığına bakın.

#### T1 çipli cihazlar

Apple T1 çipi 2016'nın sonlarında tanıtıldı ve yalnızca Touch Bar'lı birinci nesil MacBook Pro modellerinde kullanıldı.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Bilinen sorunlar

- Touch Bar çalışmıyor
- Ses çalışmıyor

#### T2 çipli cihazlar

Apple T2 Security Chip 2017'de tanıtıldı. T2 çipi, 2020'den itibaren Apple silicon'a (M serisi çipler) geçişle birlikte kullanımdan kaldırıldı.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Bu modellerde yükleyici, yamalı `linux-t2` çekirdeğini, T2 ses yapılandırmasını, Apple'ın Broadcom Wi-Fi/Bluetooth firmware'ini ve `t2fanrd` aracılığıyla fan kontrolünü otomatik olarak kurar. Touch Bar, çekirdeğin yerleşik Boot Camp tarzı desteği üzerinde çalışır.

#### iMac Retina 5K (2017)

2017 27-inch iMac'te T2 çipi yok, bu yüzden yükleyici onu diğer Intel Mac'ler gibi kurar.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Bilinen sorunlar

- Ekran yerel 5120×2880 çözünürlüğünde çalışmıyor: panel iki döşemeden oluşuyor ve stok sürücü yalnızca birini aydınlatıyor
- Ses çalışmıyor
- Parlaklık kontrolünün hiçbir etkisi yok
- Uyku makineyi asıyor; yalnızca güç döngüsü onu kurtarıyor

Bu model için bir topluluk yaması ekranı, sesi ve parlaklığı düzeltir: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
