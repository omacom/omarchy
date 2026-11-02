# Mac desteği

Omarchy'nin **Intel Mac'ler** için yerleşik desteği vardır. Şu anda bilinen birkaç sınırlama vardır, ancak bunların farkında olduğunuz ve sizin için uygun olduğu sürece, Omarchy yükleyerek eski Mac'lerinize yeni bir hayat verebilirsiniz.

Lütfen M serisi bir Mac'e kurulumun şu anda doğrudan desteklenmediğini unutmayın. Bunun durumu hakkında daha fazla bilgiyi [Discord](https://discord.gg/tXFUdasqhY) sunucumuzdaki #omarchy-on-other kanalında bulabilirsiniz.

Basit bir testte, yalnızca Omarchy kurarak 2019 MacBook Pro'da %36 performans kazancı elde edebildik.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy'yi Mac'e kurma

Omarchy şu anda kurulu **tek** işletim sistemi olmayı destekler. Kurulum sırasında sürücü silinecek ve MacOS artık önyükleneemeyecektir.

İsterseniz daha sonra İnternet Kurtarma aracılığıyla geri yükleyebilirsiniz.

Bu bölümde, [Başlarken](02-getting-started.md) bölümünü zaten gözden geçirdiğinizi ve USB sürücünüzün hazır olduğunu varsayacağız. Eğer hazır değilse, şimdi gidip bunu yapın.

#### Güvenli Önyüklemeyi devre dışı bırak

Önyüklenebilir USB'yi ve işletim sistemini önyükleyebilmek için Apple'ın Güvenli Önyüklemesini devre dışı bırakmak gereklidir. Devre dışı bırakmak için şunları yapın:

1. Mac'inizi kapatın
2. Açın ve yükleme ekranının göründüğünü görene kadar _hemen_ Command-R tuşlarına basılı tutun
3. Kullanıcınızı seçin ve istenirse parolanızı girin
4. Kurtarma ekranına girdikten sonra, menü çubuğundan **Utilities > Startup Security Utility** seçeneğini seçin
5. Kimlik doğrulaması istendiğinde parolanızı girin
6. Güvenli Önyükleme seçeneklerinden "No Security" seçeneğini seçin
7. Harici Önyükleme seçeneklerinden "Allow booting from external or removable media" seçeneğini seçin

#### Kurulumu başlat

1. USB sürücüsünü takın
2. Mac'inizi yeniden başlatın ve bir önyükleme cihazları ekranı görene kadar _hemen_ Option tuşuna basılı tutun
3. Turuncu EFI Boot cihazını seçin
4. [Normal kurulum](02-getting-started.md) ile devam edin

Kurulum programı Mac donanımını algılar ve gereken düzeltmeleri otomatik olarak uygular: Broadcom Wi-Fi sürücüleri ve bellenimi, ona ihtiyaç duyan MacBook modellerindeki SPI klavye sürücüsü ve aynı modeller için bir NVMe askıya alma düzeltmesi.

### Bilinen Sınırlamalar

Topluluk üyeleri bu zorluklara sürekli çözüm üretmek için çalışıyor, bu yüzden bunlar sizin için sorun oluşturuyorsa, [Discord](https://discord.gg/tXFUdasqhY) sunucumuzdaki #omarchy-on-other kanalına katılın ve bunları çözmek için güncel yöntemler olup olmadığına bakın.

#### T1 Çipli cihazlar

Apple T1 çipi 2016'nın sonlarında tanıtıldı ve yalnızca Touch Bar'lı birinci nesil MacBook Pro modellerinde kullanıldı.
- MacBook Pro 13 inç (2016, iki Thunderbolt 3 bağlantı noktası) – Model: A1706
- MacBook Pro 13 inç (2016, dört Thunderbolt 3 bağlantı noktası) – Model: A1708
- MacBook Pro 15 inç (2016) – Model: A1707

#### Bilinen Sorunlar

- Touch Bar çalışmıyor
- Ses çalışmıyor

#### T2 Çipli cihazlar

Apple T2 Güvenlik Çipi 2017'de tanıtıldı. T2 çipi, 2020'de başlayan Apple silicon'a (M serisi çipler) geçişle birlikte sonlandırıldı.

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

Bu modellerde kurulum programı yamalı `linux-t2` çekirdeğini, T2 ses yapılandırmasını, Apple'ın Broadcom Wi-Fi/Bluetooth bellenimini ve `t2fanrd` aracılığıyla fan denetimini otomatik olarak kurar. Touch Bar, çekirdeğin yerleşik Boot Camp tarzı desteği üzerinde çalışır.
