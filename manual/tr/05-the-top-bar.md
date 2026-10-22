# Üst Çubuk

Ekranınızın üstü boyunca uzanan şerit Omarchy çubuğudur. Sonradan eklenmiş bir durum çubuğu değildir; menüyü, bildirimleri, OSD açılır pencerelerini ve kilit ekranını da çizen tek, uzun ömürlü Quickshell süreci olan Omarchy kabuğunun bir parçasıdır. Bu yüzden her şeyle mükemmel uyum içinde tema uygular ve bir panel yeni bir uygulama başlatmak yerine anında açılır.

Aynı zamanda masaüstünde her zaman ekranda olan tek parçadır, bu yüzden o küçük simgelerin ne yaptığını bilmeye değer.

## Varsayılan olarak üzerinde neler var

Çubuğun üç bölümü vardır. Solda Omarchy logosu (menü başlatıcı) ve çalışma alanı göstergeleri bulunur. Merkezde durum göstergelerini, saati, Elsewhen'i (dünya saati), hava durumunu ve bir Omarchy güncelleme rozetini alırsınız. Sağda: klavye düzeni (birden fazla yapılandırıldığında), sistem tepsisi, ajanlar, bluetooth, ağ, ses, ekran ve güç.

Bunlardan birkaçı yalnızca söyleyecek bir şeyleri olduğunda ortaya çıkar. Klavye düzeni, yalnızca birden fazla düzen yapılandırdıysanız görünür. Güncelleme rozeti, yalnızca bekleyen bir Omarchy güncellemesi olduğunda görünür. Ve ajanlar simgesi, Omarchy makinede AI kodlama kullanımını ilk kez bulduğunda görünür (bkz. [AI](17-ai.md)).

## Etrafta tıklamak

Hemen hemen her widget sol, sağ ve orta tıklamada bir şey yapar ve birkaç tanesi kaydırma işlemine yanıt verir. İnsanların kaçırdığı kısım budur — sağ ve orta düğmeler, birçok iyi şeyin saklandığı yerdir.

| Widget | Sol | Sağ | Orta / kaydırma |
| --- | --- | --- | --- |
| Menü | Omarchy menüsü | Yeni terminal | — |
| Çalışma alanları | O çalışma alanına odaklan | — | Kaydır: sonraki/önceki çalışma alanı |
| Saat | Takvim açılır penceresi | Etiket biçimini döndür | Orta: saat dilimi seçici |
| Hava durumu | Tahmin açılır penceresi | Tam hava durumu bildirim olarak | Orta: yenile |
| Ses | Ses paneli | Sessize al | Orta: panel · kaydır: ses düzeyi |
| Mikrofon | Mikrofonu sessize al | — | Orta: ses paneli · kaydır: giriş ses düzeyi |
| Ağ | Ağ paneli | — | — |
| Bluetooth | Bluetooth paneli | Radyoyu aç/kapat | — |
| Ekran | Ekran paneli | — | Kaydır: parlaklık |
| Güç | Güç paneli | Pil yüzdesini aç/kapat | — |
| Medya | Oynat/duraklat | Kapak resmi açılır penceresi | Orta: sonraki · kaydır: önceki/sonraki |
| Ajanlar | Ajanlar paneli | Ajanınızı başlatın | Orta: sonraki abonelik |
| Tepsi | Çekmeceyi göstermek için üzerine gelin | Yönetmek için köşe işaretine sağ tıklayın | — |
| Omarchy güncellemesi | Güncellemeyi çalıştır | — | — |

Bu tablodaki her şey kutudan çıktığı haliyle çubuğunuzda değil. Medya widget'ı (kayan parça ve sanatçı ile MPRIS şu anda çalınan) ve mikrofon widget'ı ikisi de yerleşik ancak varsayılan olarak kapalıdır — istiyorsanız aşağıda açıklandığı gibi ekleyin.

## Paneller

Bir çubuk simgesine tıklamak bir panel açar; bu, bir araç ipucu yerine kaydırıcılar, listeler ve klavye gezinmesi olan gerçek bir açılır penceredir. Her birinin de bir kısayolu vardır, böylece asla 16 piksellik bir simgeye nişan almanız gerekmez:

| Kısayol | Panel |
| --- | --- |
| `Super + Ctrl + A` | Ses |
| `Super + Ctrl + W` | Ağ |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ekran |
| `Super + Ctrl + P` | Güç |
| `Super + Ctrl + Alt + D` | Takvim |
| `Super + Ctrl + Alt + E` | Dünya saati |
| `Super + Ctrl + 1-9` | Sağ bölümdeki n'inci paneli aç/kapat |

Paneller salt okunur değildir. Bir şeyi aslında yaptığınız yer onlardır:

- **Ses**, bir ana ses düzeyi kaydırıcısına, bir çıkış cihazı seçicisine ve uygulama başına miksere sahiptir, böylece o tek tarayıcı sekmesini her şeye dokunmadan kısabilirsiniz.
- **Ağ**, Wi-Fi için tarar, sinyal gücünü gösterir, bağlanır ve bir DNS sağlayıcısı seçmenize izin verir.
- **Bluetooth**, cihazlarınızı bağlan/bağlantıyı kes ve pil düzeyleri ile listeler.
- **Güç**, pil istatistiklerini gösterir, güç profillerini değiştirir (pil ve AC için ayrı bir seçimi hatırlar) ve bazı sistem bilgilerini yazar.
- **Ekran**, bir parlaklık kaydırıcısı, metin boyutu, monitör ölçeklendirme ön ayarları ve — birden fazla ekranınız olduğunda — monitör başına kontroller taşır. Daha derin hikaye için bkz. [monitörler](33-monitors.md).
- **Saat**, ISO hafta numaraları ve ay adım atma ile bir ay ızgarası açar.

Her panel fare kadar klavyeyi de kabul eder: oklar hareket eder, Return etkinleştirir, Tab komşu panele adım atar ve Escape kapatır.

`Super + Ctrl + 1-9`, panelleri sağ bölümde soldan sağa sayar, tepsiyi kendi paneli olmadığı için atlar. Böylece numara işaret edeceğiniz simgeyle eşleşir.

### Tailscale ve Dropbox

İki widget daha, yalnızca eşleşen hizmeti **Kur → Hizmet** seçeneğinden kurduğunuzda çubukta ortaya çıkar ve ikisini de bilmeye değer, çünkü yalnızca durum bildirmekten daha fazlasını yaparlar.

**Tailscale** paneli tailnet'i bağlar ve bağlantısını keser, hesaplar arasında geçiş yapar ve bir çıkış düğümü seçer (kendi makineleriniz ve Mullvad bölgelerinin ikisi de bu listede görünür). Ayrıca makinelerinize göz atar — ve biri seçiliyken, `s` dosyaları Taildrop üzerinden ona gönderir ki bu, bir dosyayı telefonunuza veya başka bir dizüstü bilgisayara taşımanın en hızlı yoludur. `c` makinenin IP'sini kopyalar, `n` adını ve `d` tam DNS adını. Tıklamayı tercih edersiniz diye her makine satırında bir gönder düğmesi de var. Terminalden aynısı `omarchy tailscale send <machine> [file...]` şeklindedir.

**Dropbox** paneli oturum açmayı sağlar, ne kadar depolama kullandığınızı gösterir ve yakın zamanda eşitlenen dosyaları listeler.

Hizmetlerden herhangi birini kaldırmak, widget'ını çubuktan geri alır.

## Göstergeler

Merkezdeki küçük küme göstergeler widget'ıdır. Bunlar açtığınız modlar için durum simgeleridir: rahatsız etme, gece ışığı, sıraya alınmış bir [hatırlatıcı](09-reminders.md), aktif bir ekran kaydı, uyanık tut ve [dikte](11-text-extraction-dictation.md). Mod aktifken yanarlar ve aksi halde yoldan uzak dururlar — aktif olmayanlara göz atmak için saatin soluna (dikey çubukta üzerine) gelin. Bir göstergeye tıklamak o modu açıp kapatır. Bir tanesi daha yalnızca durum amaçlıdır: birisi gliff üzerinden bu makineye bağlıyken uzak oturum kırmızıyla yanar.

Her zaman görünür olmalarını tercih ederseniz, widget üzerinde `alwaysShow` seçeneğini `true` olarak ayarlayın. Ve yalnızca bazılarını önemsiyorsanız, istediklerinizi `items` içinde listeleyin: `["Dnd", "Reminder", "NightLight"]`. Birden fazla göstergeler widget'ına sahip olabilirsiniz, böylece farklı bölümler farklı alt kümeler gösterebilir.

## Çubuğu yeniden düzenleme

Çubuk kendini yapılandırır. Bir şeyleri taşımak için bir yapılandırma dosyası açmak zorunda değilsiniz.

Çubuğun merkezinin etrafındaki boş bir yeri tutun ve başka bir ekran kenarına doğru sürükleyin; çubuk oraya taşınır — sol, sağ, üst veya alt hepsi çalışır ve her widget buna uyum sağlar (dikey çubuklar kompakt yalnızca simge biçimlerine döner). T tıklayıp basılı tutmak aynı sürüklemeyi başlatır. Çubuk arka planını şeffaftan camlıya ve opaklıya döndürmek için aynı boş alana çift sol tıklayın. Ve herhangi bir widget'ı sürükleyerek yeniden sıralayın veya başka bir bölüme atın.

El altında olmasını ancak her zaman görünmesini istemediğiniz bir widget tepsinin çekmecesinde durabilir: onu tepsinin üzerine sürükleyin, çekmece açılıp onu içine alır. Orada uygulama simgelerinin arkasında oturur, çekmece her açıldığında görünür ve kendi paneli açık olduğu sürece çekmeceyi de açık tutar. Geri koymak için onu çubuğun üzerine geri sürükleyin.

Bir menüden seçmeyi tercih ederseniz, **Tetikle → Görünüm → Menü Çubuğu** konumuna sahiptir ve **Çubuk Arka Planı** çubuğun nasıl çizileceğini seçer: **Opak Çubuk**, **Cam Çubuk** (arkasındaki bulanıklaştırılmış olarak görülebilen) veya **Şeffaf Çubuk**.

Aynı şeyler komutlara sahiptir; bu bir [dotfiles](31-dotfiles.md) kurulumu için isteyeceğiniz şeydir:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Bir widget'ı tamamen eklemek veya kaldırmak için eklenti komutlarını kullanın. `omarchy plugin list` kabuğun bildiği her widget'ı kimliğiyle yazar ve ardından:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Çubuğu gizleme

`Super + Shift + Space` kabuğu öldürmeden çubuğu kapatıp tekrar açar — paneller ve kısayollar çalışmaya devam eder, sadece pikselleri geri alırsınız. Bu aynı zamanda menüde **Tetikle → Görünüm → Menü Çubuğu → Çubuğu Gizle** altındadır.

## Yapılandırma dosyası

Tüm bunlar `~/.config/omarchy/shell.json` içinde, `bar` anahtarının altında saklanır. İşte kısaltılmış bir sürüm:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Her widget, üç düzen dizisinden birindeki tek bir girdidir ve ayarları o girdinin üzerinde satır içinde oturur — ayrı bir ayar dosyası ve `config` alt nesnesi yoktur. Saatin `format`, `formatAlt` (sağ tıklamanın döndürdüğü şey) ve `verticalFormat` değerlerinin hepsi `{ "id": "omarchy.clock" }` üzerinde tam orada yaşar.

`centerAnchor`, ekranın tam merkezine sabitlenecek tek merkez widget'ı adlandırır, diğerleri onun yanlarına dizilir. Saat, hava durumu ve güncelleme rozeti gelip giderken bile tam merkezde böyle kalır. Onu boş bir dizeye ayarlayın, merkez listesi bunun yerine bir grup olarak ortalanır.

İçselleştirmeye değer bir kural: **kendi `shell.json` dosyanıza sahip olduğunuzda, o kanoniktir**. Herhangi bir şeyi özelleştirene kadar, kabuk Omarchy'nin varsayılan dosyasını okur. Bir widget'ı sürüklediğiniz, `omarchy bar` çalıştırdığınız veya dosyayı kendiniz düzenlediğiniz anda, ona sahip olursunuz — derin birleştirme yoktur, bu yüzden gelecekteki Omarchy sürümlerindeki yeni varsayılan widget'lar çubuğunuzda otomatik olarak görünmez. `omarchy bar defaults`, temiz bir sayfa istediğinizde gönderilen düzeni geri koyar.

Aynı dosya, boşta kalma zamanlamalarınızı da üst düzeyde, `bar` anahtarının dışında tutar: `idle.screensaver` ve `idle.lock`, ikisi de boşta kaldığınız andan itibaren saniye cinsindendir. Böylece varsayılan ekran koruyucu 150 saniyede ve kilit 300 saniyede devreye girer.
