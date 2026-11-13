# Üst Çubuk

Ekranınızın üst kısmındaki şerit Omarchy çubuğudur. Bu, sonradan eklenmiş bir durum çubuğu değil, Omarchy shell'inin bir parçasıdır; menüyü, bildirimleri, OSD açılır pencerelerini ve kilit ekranını da çizen tek, uzun ömürlü Quickshell sürecidir. Bu yüzden her şeyle kusursuz bir tema uyumu gösterir ve bir panel, yeni bir uygulama başlatmak yerine anında açılır.

Aynı zamanda masaüstünün her zaman ekranda olan tek parçasıdır, bu yüzden o küçük simgelerin hepsinin ne işe yaradığını bilmeye değer.

## Varsayılan olarak üzerinde neler var

Çubuğun üç bölümü vardır. Solda Omarchy logosu (menü başlatıcı) ve çalışma alanı göstergeleri yer alır. Ortada durum göstergelerini, saati, Elsewhen'i (bir dünya saati), hava durumunu ve bir Omarchy güncelleme rozetini görürsünüz. Sağda ise: sistem tepsisi, klavye düzeni (birden fazla yapılandırıldığında), agent'lar, bluetooth, ağ, ses, ekran ve güç.

Bunlardan birkaçı yalnızca söyleyecek bir şeyleri olduğunda görünür. Klavye düzeni yalnızca birden fazla düzen yapılandırdıysanız görünür. Güncelleme rozeti yalnızca bekleyen bir Omarchy güncellemesi olduğunda görünür. Agent'lar simgesi ise Omarchy makinede AI kodlama kullanımı ilk kez bulduğunda görünür (bkz. [AI](17-ai.md)).

## Tıklayıp gezinmek

Neredeyse her widget sol, sağ ve orta tıklamada bir şey yapar ve birçoğu kaydırmaya yanıt verir. İnsanların kaçırdığı kısım burasıdır — sağ ve orta düğmelerin arkasında pek çok güzel şey saklıdır.

| Widget | Sol | Sağ | Orta / kaydırma |
| --- | --- | --- | --- |
| Menü | Omarchy menüsü | Yeni terminal | — |
| Çalışma Alanları | O çalışma alanına bu monitörde odaklan | — | Kaydırma: sonraki/önceki çalışma alanı |
| Saat | Takvim açılır penceresi | Etiket biçimini döngüsel olarak değiştir | Orta: saat dilimi seçici |
| Hava Durumu | Tahmin açılır penceresi | Tam hava durumunu bildirim olarak göster | Orta: yenile |
| Ses | Ses paneli | Sessize al | Orta: panel · kaydırma: ses seviyesi |
| Mikrofon | Mikrofonu sessize al | — | Orta: ses paneli · kaydırma: giriş ses seviyesi |
| Ağ | Ağ paneli | — | — |
| Bluetooth | Bluetooth paneli | Radyoyu aç/kapat | — |
| Ekran | Ekran paneli | — | Kaydırma: parlaklık |
| Güç | Güç paneli | Pil yüzdesini aç/kapat | — |
| Medya | Oynat/duraklat | Kapak resmi açılır penceresi | Orta: sonraki · kaydırma: önceki/sonraki |
| Agent'lar | Agent'lar paneli | Agent'ınızı başlat | Orta: sonraki abonelik |
| Tepsi | Çekmeceyi göstermek için üzerine gel | Yönetmek için şevron üzerinde sağ tık | — |
| Omarchy güncellemesi | Güncellemeyi çalıştır | — | — |

O tablodaki her şey kutudan çıktığı haliyle çubuğunuzda değildir. Medya widget'ı (kayan parça ve sanatçı bilgisiyle MPRIS şu an çalınan) ve mikrofon widget'ı, ikisi de yerleşik olmalarına rağmen varsayılan olarak kapalıdır — isterseniz aşağıda anlatıldığı gibi ekleyin.

## Paneller

Bir çubuk simgesine tıklamak bir panel açar; bu, bir araç ipucu yerine kaydırıcılar, listeler ve klavye gezintisi içeren düzgün bir açılır penceredir. Her birinin bir kısayol tuşu da vardır, böylece 16 piksellik bir simgeyi hedeflemek zorunda asla kalmazsınız:

| Kısayol Tuşu | Panel |
| --- | --- |
| `Super + Ctrl + A` | Ses |
| `Super + Ctrl + N` | Ağ |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ekran |
| `Super + Ctrl + P` | Güç |
| `Super + Ctrl + Alt + D` | Takvim |
| `Super + Ctrl + Alt + E` | Dünya saati |
| `Super + Ctrl + 1-9` | Sağ bölümdeki n'inci paneli aç/kapat |

Paneller salt bilgi ekranları değildir. Asıl işi gerçekten yaptığınız yer burasıdır:

- **Ses** içinde ana ses seviyesi kaydırıcısı, bir çıkış aygıtı seçici ve uygulama başına karıştırıcı bulunur, böylece geri kalan her şeye dokunmadan o tek tarayıcı sekmesinin sesini kısabilirsiniz.
- **Ağ**, Wi-Fi taraması yapar, sinyal gücünü gösterir, bağlantı kurar ve bir DNS sağlayıcısı seçmenize olanak tanır.
- **Bluetooth**, aygıtlarınızı bağlanma/bağlantıyı kesme ve pil seviyeleriyle birlikte listeler.
- **Güç**, pil istatistiklerini gösterir, güç profillerini değiştirir (pil ve AC için ayrı birer seçimi hatırlar) ve bazı sistem bilgilerini yazdırır.
- **Ekran**, bir parlaklık kaydırıcısı, metin boyutu, monitör ölçekleme ön ayarları ve — birden fazla ekranınız olduğunda — monitör başına kontroller taşır. Daha derin hikâye için bkz. [monitörler](33-monitors.md).
- **Saat**, ISO hafta numaraları ve ay adım adım ilerleme ile bir ay ızgarası açar.
- **Dünya saati**, her şehir için hava durumuyla ve gününün nasıl geçtiğiyle birlikte bir satır tutar. Arama, saat dilimlerinin yanı sıra kasabaları da bulur, böylece Fort Lauderdale, New York değil Fort Lauderdale'dır. Üstteki satır yanlış şehri adlandırıyorsa üzerine tıklayın ve nerede olduğunuzu söyleyin; başka bir saat dilimindeki bir yer seçerseniz sistem saati de oraya taşınır, bu da seyahat ederken kullanışlıdır. Bir şehrin üzerine gelin ve orada kimin yaşadığını söylemek için kişi düğmesine tıklayın — düz isimler veya yüzlerini de beraberinde getirmek için `@` GitHub kullanıcı adları.

Her panel fare kadar klavyeyi de kabul eder: oklar hareket eder, Return etkinleştirir, Tab komşu panele geçer ve Escape kapatır.

`Super + Ctrl + 1-9`, sağ bölümdeki panelleri soldan sağa sayar ve kendisine ait bir paneli olmadığı için tepsiyi atlar. Böylece numara, işaret edeceğiniz simgeyle eşleşir.

### Tailscale ve Dropbox

**Install → Service** içinden eşleşen hizmeti yükledikten sonra çubukta iki widget daha görünür ve ikisini de bilmeye değer çünkü durum bildirmekten fazlasını yaparlar.

**Tailscale** paneli tailnet'e bağlanır ve bağlantıyı keser, hesaplar arasında geçiş yapar ve bir çıkış düğümü seçer (kendi makineleriniz ve Mullvad bölgeleri de o listede görünür). Aynı zamanda makinelerinize göz atar — ve biri seçiliyken `s`, Taildrop üzerinden ona dosya gönderir, bu da bir dosyayı telefonunuza ya da başka bir dizüstü bilgisayara taşımanın en hızlı yoludur. `c` makinenin IP'sini, `n` adını ve `d` tam DNS adını kopyalar. İsterseniz tıklayabilmeniz için her makine satırında bir gönder düğmesi de vardır. Terminalden aynısı `omarchy tailscale send <machine> [file...]` şeklindedir.

**Dropbox** paneli girişi yönetir, ne kadar depolama kullandığınızı gösterir ve yakın zamanda senkronize edilen dosyaları listeler.

Hizmetlerden birini kaldırmak widget'ını çubuktan geri alır.

## Göstergeler

Ortadaki küçük küme göstergeler widget'ıdır. Bunlar, açtığınız modlara ait durum simgeleridir: rahatsız etme, gece ışığı, sıraya alınmış bir [hatırlatıcı](09-reminders.md), aktif bir ekran kaydı, uyanık kal ve [dikte](11-text-extraction-dictation.md). Mod aktif olduğunda yanarlar, aksi halde ortalıkta görünmezler — pasif olanların bulunduğu yerde, hemen yanlarına gelerek onlara göz atın. Bir göstergeye tıklamak o modu açar/kapatır. Biri daha salt durum içindir: biri bu makineye gliff üzerinden bağlandığında uzak oturum kırmızıyla yanar.

Her zaman görünür olmalarını tercih ederseniz widget üzerinde `alwaysShow` değerini `true` olarak ayarlayın. Ve yalnızca bazıları umurunuzdaysa istediklerinizi `items` içinde listeleyin: `["Dnd", "Reminder", "NightLight"]`. Birden fazla göstergeler widget'ına sahip olabilirsiniz, böylece farklı bölümler farklı alt kümeler gösterebilir.

## Çubuğu yeniden düzenlemek

Çubuk kendini yapılandırır. Bir şeyleri taşımak için yapılandırma dosyası açmak zorunda değilsiniz.

Orta civarında boş bir çubuk alanını kavrayın ve başka bir ekran kenarına doğru sürükleyin, çubuk oraya taşınır — sol, sağ, üst ya da alt, hepsi çalışır ve her widget uyum sağlar (dikey çubuklar kompakt, yalnızca simgeli biçimlere düşer). Tıklayıp basılı tutmak da aynı sürüklemeyi başlatır. Aynı boş alanda çift sol tıklamak, çubuk arka planını şeffaftan camsıya, oradan opak olana döngüsel olarak değiştirir. Ve yeniden sıralamak ya da başka bir bölüme atmak için herhangi bir widget'ı sürükleyin; diğer widget'lar, ineceği yere yer açmak için ayrılır.

Çubuğun ortası bir kutudur: içinde ne varsa tek bir grup olarak ortalı kalır ve iki yanındaki widget'lar kenarlarından sarkar. Bir widget sürüklerken kutu bir ana hat olarak, boş olduğunda ise çubuk boyunca bir çizgi olarak görünür ve içine ya da yanına bırakabilirsiniz. Bir bırakma kutunun içine inecek olduğunda kutu, widget'ı içeri almak için büyür.

Etrafta olmasını istediğiniz ama her zaman görünmesini istemediğiniz bir widget tepsinin çekmecesine girebilir: onu tepsinin üzerine sürükleyin, çekmece onu almak için açılır. Uygulama simgelerinden sonra orada durur, çekmece ne zaman görünürse o da görünür ve paneli açıkken çekmecesini açık tutar. Geri koymak için çubuğun üzerine geri sürükleyin.

Menüden seçmeyi tercih ederseniz **Appearance → Menu Bar** konumu içerir ve **Bar Background**, çubuğun nasıl çizileceğini seçer: **Opaque Bar**, **Glassy Bar** (şeffaf, arkası bulanıklaştırılmış) ya da **Clear Bar**.

Aynı şeylerin komutları da vardır, bu da bir [dotfiles](31-dotfiles.md) kurulumu için istediğiniz şeydir:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Bir widget'ı tamamen eklemek ya da kaldırmak için plugin komutlarını kullanın. `omarchy plugin list`, shell'in bildiği her widget'ı id'siyle birlikte yazdırır ve ardından:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Çubuğu gizlemek

`Super + Shift + Space`, shell'i öldürmeden çubuğu kapatır ve geri açar — paneller ve kısayol tuşları çalışmaya devam eder, yalnızca pikselleri geri alırsınız. Bu aynı zamanda menüde **Appearance → Menu Bar → Hide Bar** altındadır.

## Yapılandırma dosyası

Bunların hepsi `~/.config/omarchy/shell.json` içinde `bar` anahtarının altında saklanır. İşte kısaltılmış bir sürümü:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Her widget beş düzen dizisinden birindeki tek bir girdidir ve ayarları o girdinin üzerinde satır içinde durur — ayrı bir ayar dosyası ve bir `config` alt nesnesi yoktur. Saatin `format`, `formatAlt` (sağ tıklamanın döngüsel olarak geçtiği şey) ve `verticalFormat` değerlerinin hepsi tam orada `{ "id": "omarchy.clock" }` üzerinde yaşar.

`center`, çubuğun ortasındaki kutudur: içindeki her şey ekranda tek bir grup olarak ortalanır. `centerBegin` ve `centerEnd` kutunun iki yanından sarkar, bu da hava durumu ve güncelleme rozeti gelip gitse bile saatin tam ortada kalmasını sağlar. `center` içine birden fazla widget koyarsanız birlikte ortalanırlar; boş bırakırsanız `centerBegin` ve `centerEnd` çubuğun ortasında buluşur.

İçselleştirmeye değer bir kural: **kendi `shell.json` dosyanız olduktan sonra o, esas olandır**. Herhangi bir şeyi özelleştirinceye kadar shell, Omarchy'nin varsayılan dosyasını okur. Bir widget'ı sürüklediğiniz, `omarchy bar` çalıştırdığınız ya da dosyayı kendiniz düzenlediğiniz anda o artık sizindir — derin birleştirme yoktur, bu yüzden gelecekteki Omarchy sürümlerindeki yeni varsayılan widget'lar çubuğunuzda otomatik olarak görünmez. `omarchy bar defaults`, temiz bir sayfa istediğinizde birlikte gelen düzeni geri koyar.

Aynı dosya, boşta bekleme zamanlamalarınızı da `bar` anahtarının dışında, üst seviyede tutar: `idle.screensaver` ve `idle.lock`, ikisi de boşta kaldığınızdan bu yana geçen saniyeler cinsindendir. Böylece varsayılan ekran koruyucu 150 saniyede ve kilit 300 saniyede devreye girer.
