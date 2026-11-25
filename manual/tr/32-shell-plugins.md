# Kabuk Eklentileri

Omarchy masaüstü, `omarchy-shell` adlı tek, uzun ömürlü bir Quickshell işlemi olarak çalışır ve ekranda gördüğünüz hemen her şey onun içindeki bir eklentidir. Çubuk bir eklentidir. Ondan açılan paneller, emoji seçici ve pano yöneticisi gibi tam ekran katmanlar, Omarchy menüsünün kendisi, kilit ekranı, polkit iletişim kutusu ve pilinizi izleyen ve geceleri ekranınızı ısıtan başsız hizmetler de öyledir.

Bu sadece bir uygulama ayrıntısı değildir. Masaüstünün parçalarını kapatabileceğiniz, değiştirebileceğiniz veya Omarchy'nin kaynağının tek bir satırına dokunmadan kendinizinkini yazabileceğiniz anlamına gelir.

Birinci taraf eklentiler Omarchy ile birlikte gelir ve `$OMARCHY_PATH/shell/plugins/` içinde yaşar. Kendinizin eklediği her şey — kendi deneyleriniz veya GitHub'da bulduğunuz bir şey — `~/.config/omarchy/plugins/` içinde yaşar. Her ikisi de başlangıçta aynı şekilde keşfedilir, ancak yerleşik eklentiler güvenilir kabuk arayüzleri alırken, üçüncü taraf eklentiler kendi hizmet ve yaşam döngülerine kapsamlandırılmış sınırlı bir arayüz alır. Yerleşik eklentilerin klonları, yalnızca orijinal davranış için gereken kaynağa özgü yapılandırma ve kullanıcı arayüzü çağrılarını korur.

## Sahip olduklarınızı görmek

```
omarchy plugin list
```

Bu, keşfedilen her eklentiyi kimliği, etkin olup olmadığı, birinci taraf mı üçüncü taraf mı olduğu, türleri ve görünen adı ile birlikte yazdırır. Bunu başka bir şeye besliyorsanız `--json` ekleyin.

Eklenti kimlikleri ad alanına sahiptir. Yerleşik eklentilerin tümü `omarchy.` ile başlar — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — ve bu ad alanı ayrılmıştır, bu yüzden bir üçüncü taraf eklenti onu asla talep edemez.

## Onları açıp kapatmak

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Veya menüyü kullanın: _Ayarlar > Plugins_ altında Enable, Disable, Add, Clone ve Remove vardır; her birinin, yalnızca o eylem için mantıklı olan eklentileri sunan bir seçicisi vardır.

Etkin durumu `~/.config/omarchy/shell.json` içinde depolanır ve kural iki tür eklenti için biraz farklıdır. Bir üçüncü taraf eklenti, kimliği o dosyanın herhangi bir yerinde göründüğünde tam olarak etkinleştirilir — bir çubuk düzeni girişi olarak, `plugins[]` içindeki bir giriş olarak veya `bar.id` olarak. Çubuk widget'ı olmayan birinci taraf eklentiler ters yöndedir: varsayılan olarak açıktırlar ve yalnızca `disabledPlugins[]` içinde listelenerek kapanırlar.

Tam bir çubuk eklentisinin hiç kapalı durumu yoktur. Her zaman tam olarak bir çubuk vardır, bu yüzden onu başka birini etkinleştirerek değiştirirsiniz. Çubuk widget yerleşimi, [üst çubuk](05-the-top-bar.md) bölümünde ele alınır.

## Git'ten bir eklenti eklemek

Bir üçüncü taraf eklenti, sadece kökünde bir `manifest.json` bulunan bir git deposudur.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Herhangi bir şey yapmadan önce, eklentilerin uzun ömürlü kabuk işleminiz içinde rastgele, kum havuzsuz kod olarak çalıştığını size açıkça söyler, size URL'yi gösterir ve onaylamanızı ister. Bunu ciddiye alın. Üçüncü taraf eklenti arayüzü, kimlik doğrulama hizmetlerini doğrudan açığa çıkarmaz ve yerine geçen bir çubuk, yapılandırılmış kimlik doğrulama dışı kullanıcı arayüzü için yalnızca sınırlı yetenekler alır. Görsel eklentiler hâlâ kabuğun QML sahnesini paylaşır ve sıradan üst nesneleri gezebilir; tüm eklenti kodu ise kullanıcı hesabınızın ulaşabileceği her şeyle çalışır. Kimlik doğrulama durumu, bu hizmetleri ulaşılabilir ana bilgisayar nesne grafiğinin dışında tutarak ayrıca korunur. Yalnızca çalıştırmaya istekli olduğunuz depoları ekleyin ve etkinleştirmeden önce onları okuyun.

Yerine geçen bir çubuk, kurulu widget'ları görüntüleyebilir, ancak çubuğun başka bir eklentinin canlı hizmet nesnesini istemesine izin verilmediği için hizmet destekli üçüncü taraf widget'ların işlevselliği orada azalabilir. Böyle bir widget'ın eşlik eden hizmetine ihtiyacı varsa yerleşik `omarchy.bar` eklentisine geri dönün.

Ardından depoyu bir hazırlama dizinine klonlar, manifesti doğrular, başka bir eklenti zaten o kimliği talep ediyorsa kurulumu reddeder ve onu `~/.config/omarchy/plugins/<id>/` içine taşır. `--enable` olmadan, şimdi açık olmasını isteyip istemediğinizi sorar; hayır deyip önce kodu okuyabilirsiniz. Eklentiden hiçbir şey çalıştırmaz, bir kurulum kancası yürütmez ve asla sudo istemez — dosyaları klonlar, manifesti kontrol eder ve IPC üzerinden bir bit çevirir.

Güncelleme, aynı kopyanın hızlı ileri sarma çekmesidir:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Kimlik olmadan, sahip olduğunuz git tarafından yönetilen her eklentiyi günceller. Uygulamadan önce size diff'i gösterir, hızlı ileri sarmanın ötesine geçemeyeceği yerel değişiklikleriniz varsa güncellemeyi reddeder ve yeni sürüm doğrulamada başarısız olursa geri alır.

```
omarchy plugin remove acme.weather
```

Kaldırma önce eklentiyi devre dışı bırakır, ardından bir git kopyasıysa onu siler (depo hâlâ yukarı akıştadır) veya bir sembolik bağ ise bağlantısını kaldırır. Git deposu olmayan el yapımı bir eklenti klasörü, tamamen silinmek yerine eklentiler dizini içindeki zaman damgalı bir yedeğe taşınır.

## Değiştirmek için yerleşik bir eklentiyi klonlamak

Bu benim en sevdiğim kısımdır. Yerleşik bir widget'ın nasıl davrandığını değiştirmek isterseniz, `$OMARCHY_PATH` altındaki dosyaları düzenlemeyin — bunlar pakete aittir ve bir sonraki güncelleme onların üzerine yazacaktır. Onun yerine klonlayın:

```
omarchy plugin clone omarchy.clock
```

Bu, tüm eklentiyi `~/.config/omarchy/plugins/dhh.clock` içine (benimki değil, sizin kullanıcı adınız) kopyalar, onu "My Clock" olarak yeniden adlandırır, etkinleştirir ve kabuğu yerleşik eklentiden kopyanıza geçirir — mevcut bir çubuk widget'ının konumunu ve ayarlarını koruyarak. Yeni dizini hemen `$EDITOR` içinde açmak için `--edit` ekleyin; menüdeki _Ayarlar > Plugins > Clone Plugin_ bunu sizin için yapar.

Kullanıcı adı öneki, klonunuzun kimliğini sizinki olarak tutar, böylece paylaşmak başkalarınınkiyle çakışmaz. Orijinal yerleşik kimliğe yapılan çağrılar klonunuza yönlendirilir, bu yüzden `omarchy.clock` öğesine başvuran hiçbir şeyin güncellenmesine gerek kalmaz. Ve onu karmakarışık ederseniz, `omarchy plugin remove dhh.clock` yerleşik eklentiyi geri koyar.

`~/.config/omarchy/plugins/` altında herhangi bir yerde bir dosya kaydetmek, eklenti kodunu otomatik olarak yeniden yükler, böylece editörü açık bırakıp değişikliklerinizin yapıldığını izleyebilirsiniz.

## Kendinizinkini yazmak

Bir eklenti, bir `manifest.json` ve biraz QML içeren bir dizindir. Manifest, `schemaVersion: 1`, bir `id`, `name`, `version`, bir veya daha fazla `kinds` ve her tür için QML dosyasına işaret eden bir `entryPoints` nesnesi bildirir:

| Tür | Ne olduğu |
|------|------------|
| `bar-widget` | Etkin çubuğun bir bölüme bırakabileceği bir bileşen |
| `panel` | Kalıcı veya çağrılan yüzen bir pencere |
| `overlay` | Tam ekran bir katman |
| `menu` | Çağrılan bir menü yüzeyi |
| `service` | Kullanıcı arayüzü olmayan başsız bir tekil |
| `bar` | Yerleşik olanın yerini alan tam bir çubuk |

Bir eklenti aynı anda birkaç tür bildirebilir — medya eklentisi hem bir `service` hem de bir `bar-widget`'dır. Çubuk widget'ları, bir görünen ad, bir kategori, isteğe bağlı bir `defaultSection` ve çubukta birden fazlasının olmasının mantıklı olup olmadığını söyleyen `allowMultiple` içeren ek bir `barWidget` bloğu alır. Çoğu widget bunu `false` olarak ayarlar; ayırıcılar ve göstergeler `true` olarak ayarlar.

Herhangi bir şey yayımlamadan önce onu kontrol edin:

```
omarchy plugin validate ./my-plugin
```

Bu, kabuğun yükleme sırasında yaptığı aynı kontrolleri çalıştırır: şema sürümü, gerekli alanlar, ayrılmamış bir kimlik, güvenli göreli yollar olan ve gerçekten var olan giriş noktaları, talep ettiğiniz her tür için bir giriş noktası ve klasör içinde hiçbir sembolik bağ yok.

Eklenti geliştirme için, [kabuk referansına](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) ve [birinci taraf eklenti kataloğuna](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md) bakın.

## Kendinizinkini dünyayla paylaşmak

Sevdiğiniz bir şey yaptıktan sonra onu herkese açık bir git deposuna koyun. Tüm dağıtım mekanizması budur — ardından herkes URL'nize karşı `omarchy plugin add` çalıştırabilir ve onu saniyeler içinde çalışır hale getirebilir.

İnsanların onu gerçekten bulmasına yardımcı olmak için, onu [plugins.omarchy.org](https://plugins.omarchy.org) adresinde listeleyin. Bu, Omarchy kabuk eklentileri için pazardır ve yazmak üzere olduğunuz widget'ı birinin zaten yapıp yapmadığını merak ettiğinizde bakılacak ilk yerdir. Başlamadan önce ona göz atın!
