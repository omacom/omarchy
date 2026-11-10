# Mac desteği

Omarchy, **Intel Mac**'ler için yerleşik desteğe sahiptir. Şu anda birkaç bilinen sınırlama var, ancak bunların farkında olduğunuz ve sizin için sorun olmadığı sürece; eski Mac'lerinize Omarchy yükleyerek onlara yeni bir soluk kazandırabilirsiniz.

Lütfen şu anda M serisi bir Mac'e kurulumun doğrudan desteklenmediğini unutmayın. Bunun durumu hakkında daha fazla bilgiyi [Discord](https://discord.gg/tXFUdasqhY) sunucumuzdaki #omarchy-on-other kanalında bulabilirsiniz.

Basit bir testte, yalnızca Omarchy kurarak 2019 MacBook Pro'da %36 performans artışı elde edebildik.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy'yi Mac'e Kurma

Omarchy şu anda kurulu **tek** işletim sistemi olmayı destekliyor. Kurulum sırasında sürücü silinecek ve MacOS artık başlatılamayacak.

İsterseniz daha sonra Internet Recovery aracılığıyla onu geri yükleyebilirsiniz.

Bu bölüm için, [Başlangıç](02-getting-started.md) bölümünü zaten incelediğinizi ve USB sürücünüzün hazır olduğunu varsayacağız. Değilse şimdi hazırlayın.

#### Secure Boot'u Devre Dışı Bırakma

Önyüklenebilir USB'yi ve işletim sistemini başlatabilmek için Apple'ın Secure Boot özelliğini devre dışı bırakmak gerekiyor. Devre dışı bırakmak için şunları yapın:

1. Mac'inizi kapatın
2. Açın ve yükleme ekranı görünene kadar _hemen_ Command-R tuşlarına basılı tutun
3. Kullanıcınızı seçin ve istenirse parolanızı girin
4. Kurtarma ekranına geldiğinizde, menü çubuğundan **Utilities > Startup Security Utility** seçeneğini seçin
5. Kimlik doğrulama istendiğinde parolanızı girin
6. Secure Boot seçeneklerinden "No Security" seçeneğini seçin
7. External Boot seçeneklerinden "Allow booting from external or removable media" seçeneğini seçin

#### Kuruluma Başlayın

1. USB sürücüyü takın
2. Mac'inizi yeniden başlatın ve önyükleme aygıtlarının olduğu bir ekran görünene kadar _hemen_ Option tuşuna basılı tutun
3. Turuncu EFI Boot aygıtını seçin
4. [Normal şekilde kuruluma devam edin](02-getting-started.md)

Kurulum programı Mac donanımını algılar ve gerekli düzeltmeleri otomatik olarak uygular: Broadcom Wi-Fi sürücüleri ve aygıt yazılımı, buna ihtiyaç duyan MacBook modellerindeki SPI klavye sürücüsü ve yine aynı modeller için bir NVMe askıya alma düzeltmesi.

### Bilinen Sınırlamalar

Topluluk üyeleri bu zorluklara sürekli çözüm bulmak için çalışıyor, bu nedenle bunlar sizin için sorun oluşturuyorsa [Discord](https://discord.gg/tXFUdasqhY) sunucumuzdaki #omarchy-on-other kanalına katılın ve bunları çözmek için güncel yöntemler olup olmadığına bakın.

#### T1 Çipli Cihazlar

Apple T1 çipi 2016'nın sonlarında tanıtıldı ve yalnızca Touch Bar'lı birinci nesil MacBook Pro modellerinde kullanıldı.
- MacBook Pro 13 inç (2016, iki Thunderbolt 3 bağlantı noktası) – Model: A1706
- MacBook Pro 13 inç (2016, dört Thunderbolt 3 bağlantı noktası) – Model: A1708
- MacBook Pro 15 inç (2016) – Model: A1707

#### Bilinen Sorunlar

- Touch Bar çalışmıyor
- Ses çalışmıyor

#### T2 Çipli Cihazlar

Apple T2 Security Chip 2017'de tanıtıldı. T2 çipi, 2020'de başlayan Apple silicon'a (M serisi çipler) geçişle birlikte kullanımdan kaldırıldı.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13 inç (2018, dört Thunderbolt 3 bağlantı noktası) – Model: A1989
- MacBook Pro 15 inç (2018) – Model: A1990
- MacBook Air (Retina, 13 inç, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13 inç (2019, iki Thunderbolt 3 bağlantı noktası) – Model: A2159
- MacBook Pro 13 inç (2019, dört Thunderbolt 3 bağlantı noktası) – Model: A2178
- MacBook Pro 15 inç (2019) – Model: A1990
- iMac (Retina 5K, 27 inç, 2020) – Model: A2115 (iMac20,1 ve iMac20,2)
- MacBook Pro 13 inç (2020, iki Thunderbolt 3 bağlantı noktası) – Model: A2265
- MacBook Pro 15 inç (2020) – Model: A1990

Bu modellerde kurulum programı otomatik olarak yamalı `linux-t2` çekirdeğini, T2 ses yapılandırmasını, Apple'ın Broadcom Wi-Fi/Bluetooth aygıt yazılımını ve `t2fanrd` aracılığıyla fan kontrolünü kurar. Touch Bar, çekirdeğin yerleşik Boot Camp tarzı desteğiyle çalışır.

#### iMac Retina 5K (2017)

2017 model 27 inç iMac'te T2 çipi yoktur, bu nedenle kurulum programı onu diğer Intel Mac'ler gibi kurar.

- iMac (Retina 5K, 27 inç, 2017) – Model: A1419

#### Bilinen Sorunlar

- Ekran doğal çözünürlüğü olan 5120×2880'de çalışmıyor: panel iki döşemeden oluşuyor ve standart sürücü yalnızca birini çalıştırıyor
- Ses çalışmıyor
- Parlaklık kontrolünün hiçbir etkisi yok
- Uyku makineyi kilitliyor; yalnızca kapatıp açmak onu kurtarıyor

Bu model için bir topluluk yaması ekranı, sesi ve parlaklığı düzeltiyor: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
