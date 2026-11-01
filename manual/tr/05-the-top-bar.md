# Üst Çubuk

Ekranınızın üstündeki şerit Omarchy çubuğudur. Üzerine sonradan eklenmiş bir durum çubuğu değil, Omarchy kabuğunun bir parçasıdır; menüyü, bildirimleri, OSD açılır pencerelerini ve kilit ekranını da çizen, uzun süre çalışan tek Quickshell sürecidir. Bu yüzden diğer her şeyle kusursuz biçimde uyum sağlar ve bir panel yeni bir uygulama başlatmak yerine anında açılır.

Aynı zamanda masaüstünün her zaman ekranda olan tek parçasıdır, bu yüzden o küçük simgelerin ne işe yaradığını bilmeye değer.

## Varsayılan olarak üzerinde neler var

Çubuğun üç bölümü vardır. Sol tarafta Omarchy logosu (menü başlatıcısı) ve çalışma alanı göstergeleri bulunur. Ortada durum göstergeleri, saat, Elsewhen (bir dünya saati), hava durumu ve bir Omarchy güncelleme rozeti yer alır. Sağda ise sistem tepsisi, klavye düzeni (birden fazla yapılandırıldığında), ajanlar, bluetooth, ağ, ses, ekran ve güç bulunur.

Bunlardan birkaçı yalnızca söyleyecek bir şeyi olduğunda görünür. Klavye düzeni yalnızca birden fazla düzen yapılandırdıysanız görünür. Güncelleme rozeti yalnızca bekleyen bir Omarchy güncellemesi olduğunda görünür. Ajanlar simgesi ise Omarchy makinede ilk kez AI kodlama kullanımı bulduğunda görünür (bkz. [Yapay Zeka](17-ai.md)).

## Tıklama turu

Neredeyse her widget sol, sağ ve orta tıklamada bir şey yapar ve birkaçı kaydırmaya da yanıt verir. İnsanların kaçırdığı kısım burasıdır — iyi şeylerin çoğu sağ ve orta düğmelerde saklıdır.

| Widget | Sol | Sağ | Orta / kaydırma |
| --- | --- | --- | --- |
| Menü | Omarchy menüsü | Yeni terminal | — |
| Çalışma Alanları | O çalışma alanına bu monitörde odaklan | — | Kaydırma: sonraki/önceki çalışma alanı |
| Saat | Takvim açılır penceresi | Etiket biçimini değiştir | Orta: saat dilimi seçici |
| Hava Durumu | Tahmin açılır penceresi | Tam hava durumunu bildirim olarak göster | Orta: yenile |
| Ses | Ses paneli | Sessize al | Orta: panel · kaydırma: ses düzeyi |
| Mikrofon | Mikrofonu sessize al | — | Orta: ses paneli · kaydırma: giriş ses düzeyi |
| Ağ | Ağ paneli | — | — |
| Bluetooth | Bluetooth paneli | Radyoyu aç/kapat | — |
| Ekran | Ekran paneli | — | Kaydırma: parlaklık |
| Güç | Güç paneli | Pil yüzdesini aç/kapat | — |
| Medya | Oynat/duraklat | Kapak resmi açılır penceresi | Orta: sonraki · kaydırma: önceki/sonraki |
| Ajanlar | Ajanlar paneli | Ajanınızı başlatın | Orta: sonraki abonelik |
| Tepsi | Çekmeceyi göstermek için üzerine gelin | Yönetmek için köşe işaretine sağ tıklayın | — |
| Omarchy güncellemesi | Güncellemeyi çalıştır | — | — |

O tablodaki her şey kutudan çıktığı haliyle çubuğunuzda değildir. Medya widget'ı (MPRIS şimdi çalıyor, kayan parça ve sanatçı bilgisiyle) ve mikrofon widget'ı yerleşik olarak gelir ancak varsayılan olarak kapalıdır — isterseniz aşağıda anlatıldığı gibi ekleyin.

## Paneller

Bir çubuk simgesine tıklamak bir panel açar; bu, bir araç ipucu değil, kaydırıcılar, listeler ve klavye gezinmesi içeren düzgün bir açılır penceredir. Her birinin bir kısayol tuşu da vardır, böylece 16 piksellik bir simgeyi hedeflemek zorunda kalmazsınız:

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

Paneller salt gösterim amaçlı değildir. İşinizi asıl orada halledersiniz:

- **Ses** ana ses düzeyi kaydırıcısına, bir çıkış aygıtı seçicisine ve uygulama başına karıştırıcıya sahiptir, böylece diğer her şeye dokunmadan o tek tarayıcı sekmesinin sesini kısabilirsiniz.
- **Ağ** Wi-Fi taraması yapar, sinyal gücünü gösterir, bağlantı kurar ve bir DNS sağlayıcısı seçmenize izin verir.
- **Bluetooth** aygıtlarınızı bağlanma/bağlantı kesme ve pil düzeyleriyle birlikte listeler.
- **Güç** pil istatistiklerini gösterir, güç profillerini değiştirir (pil ve AC için ayrı seçimleri hatırlar) ve bazı sistem bilgilerini yazar.
- **Ekran** parlaklık kaydırıcısını, metin boyutunu, monitör ölçeklendirme hazır ayarlarını ve — birden fazla ekranınız olduğunda — monitör başına kontrolleri barındırır. Daha ayrıntılı hikaye için bkz. [monitörler](33-monitors.md).
- **Saat** ISO hafta numaraları ve ay adımlamasıyla bir aylık ızgara açar.
- **Dünya saati** her şehir için hava durumu ve gününün nasıl geçtiğiyle birlikte bir satır tutar. Arama saat dilimlerinin yanı sıra kasabaları da bulur, böylece Fort Lauderdale, New York değil Fort Lauderdale olur. Üstteki satır yanlış şehri söylüyorsa üzerine tıklayın ve nerede olduğunuzu söyleyin; başka bir saat dilimindeki bir yer seçerseniz sistem saati de oraya taşınır, bu da seyahat ederken kullanışlıdır. Bir şehrin üzerine gelin ve orada kimin yaşadığını söylemek için kişi düğmesine tıklayın — düz adlar veya yüzlerini de getirmek için `@` GitHub kullanıcı adları.

Her panel fare kadar klavyeyi de kabul eder: oklar hareket eder, Return etkinleştirir, Tab komşu panele geçer ve Escape kapatır.

`Super + Ctrl + 1-9` sağ bölümdeki panelleri soldan sağa sayar ve kendi paneli olmadığı için tepsiyi atlar. Böylece sayı, işaret edeceğiniz simgeyle eşleşir.

### Tailscale ve Dropbox

**Install → Service** içinden eşleşen servisi kurduğunuzda çubukta iki widget daha görünür ve ikisini de bilmeye değer çünkü durum bildirmekten fazlasını yaparlar.

**Tailscale** paneli tailnet'e bağlanır ve bağlantısını keser, hesaplar arasında geçiş yapar ve bir çıkış düğümü seçer (kendi makineleriniz ve Mullvad bölgeleri de o listede görünür). Ayrıca makinelerinize göz atar — ve birini seçtiğinizde `s` ona Taildrop üzerinden dosya gönderir; bu, telefonunuza veya başka bir dizüstü bilgisayara dosya taşımanın en hızlı yoludur. `c` makinenin IP adresini, `n` adını ve `d` tam DNS adını kopyalar. Tıklamayı tercih ederseniz her makine satırında bir gönder düğmesi de vardır. Terminalden aynısı `omarchy tailscale send <machine> [file...]` şeklindedir.

**Dropbox** paneli girişi yönetir, ne kadar depolama kullandığınızı gösterir ve yakın zamanda eşitlenen dosyaları listeler.

Servislerden birini kaldırmak widget'ını da çubuktan geri alır.

## Göstergeler

Ortadaki küçük küme göstergeler widget'ıdır. Bunlar açtığınız modların durum simgeleridir: rahatsız etme, gece ışığı, sıraya alınmış bir [hatırlatıcı](09-reminders.md), etkin bir ekran kaydı, uyanık kal ve [dikte](11-text-extraction-dictation.md). Mod etkin olduğunda yanarlar, aksi halde ortalıkta görünmezler — etkin olmayanlara göz atmak için çubuğun herhangi bir yerinde bekleyin. Bir göstergeye tıklamak o modu açıp kapatır. Biri yalnızca durum içindir: birisi gliff üzerinden bu makineye bağlandığında bir uzak oturum kırmızı yanar.

Her zaman görünmelerini tercih ederseniz widget üzerinde `alwaysShow` değerini `true` olarak ayarlayın. Ve yalnızca bazılarını önemsiyorsanız istediklerinizi `items` içinde listeleyin: `["Dnd", "Reminder", "NightLight"]`. Birden fazla göstergeler widget'ınız olabilir, böylece farklı bölümler farklı alt kümeler gösterebilir.

## Çubuğu yeniden düzenleme

Çubuk kendini yapılandırır. Bir şeyleri taşımak için bir yapılandırma dosyası açmak zorunda değilsiniz.

Orta civarındaki boş bir çubuk parçasını tutun ve başka bir ekran kenarına sürükleyin; çubuk oraya taşınır — sol, sağ, üst veya alt, hepsi çalışır ve her widget uyum sağlar (dikey çubuklar kompakt yalnızca simge biçimlerine döner). Tıklayıp basılı tutmak da aynı sürüklemeyi başlatır. Aynı boş alana çift sol tıklayarak çubuk arka planını şeffaftan camsıya, oradan opak olana doğru döndürün. Ve herhangi bir widget'ı yeniden sıralamak veya başka bir bölüme atmak için sürükleyin; diğer widget'lar ineceği yerde yer açmak için ayrılır.

Çubuğun ortası bir kutudur: içindeki her şey tek bir grup olarak ortalanmış kalır ve iki yanındaki widget'lar kenarlarından sarkar. Bir widget'ı sürüklerken kutu bir çerçeve olarak, boşken çubuk boyunca bir çizgi olarak görünür ve içine ya da yanına bırakabilirsiniz. Bir bırakma kutuya inecekse kutu widget'ı içine almak için büyür.

Etrafta olmasını istediğiniz ancak her zaman görünmesini istemediğiniz bir widget tepsinin çekmecesine gidebilir: onu tepsinin üzerine sürükleyin, çekmece onu almak için açılır. Uygulama simgelerinden sonra orada durur, çekmece her göründüğünde görünür ve paneli açıkken çekmecesini açık tutar. Çubuğa geri koymak için dışarı sürükleyin.

Bir menüden seçmeyi tercih ederseniz **Appearance → Menu Bar** konumu içerir ve **Bar Background** çubuğun nasıl çizileceğini seçer: **Opaque Bar**, **Glassy Bar** (arkasındaki bulanıklaştırılmış şekilde saydam) veya **Clear Bar**.

Aynı şeylerin komutları da vardır; bu, bir [dotfiles](31-dotfiles.md) kurulumu için istediğiniz şeydir:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Bir widget'ı tamamen eklemek veya kaldırmak için plugin komutlarını kullanın. `omarchy plugin list` kabuğun bildiği her widget'ı kimliğiyle birlikte yazar ve ardından:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Çubuğu gizleme

`Super + Shift + Space` çubuğu kabuğu sonlandırmadan kapatır ve geri açar — paneller ve kısayol tuşları çalışmaya devam eder, yalnızca pikselleri geri alırsınız. Menüde **Appearance → Menu Bar → Hide Bar** altında da yer alır.

## Yapılandırma dosyası

Bunların hepsi `~/.config/omarchy/shell.json` içinde, `bar` anahtarı altında saklanır. İşte kırpılmış bir sürümü:

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

Her widget beş düzen dizisinden birindeki tek bir girdidir ve ayarları o girdinin üzerinde satır içinde durur — ayrı bir ayar dosyası ve `config` alt nesnesi yoktur. Saatin `format`, `formatAlt` (sağ tıklamanın döndürdüğü) ve `verticalFormat` değerlerinin hepsi tam orada `{ "id": "omarchy.clock" }` üzerinde yaşar.

`center` çubuğun ortasındaki kutudur: içindeki her şey ekranda tek bir grup olarak ortalanır. `centerBegin` ve `centerEnd` kutunun iki yanından sarkar; saat, hava durumu ve güncelleme rozeti gelip giderken bile böylece tam ortada kalır. `center` içine birden fazla widget koyarsanız birlikte ortalanırlar; boş bırakırsanız `centerBegin` ve `centerEnd` çubuğun ortasında buluşur.

İçselleştirmeye değer bir kural: **kendi `shell.json` dosyanız olduğunda artık kanonik olan odur**. Hiçbir şeyi özelleştirene kadar kabuk Omarchy'nin varsayılan dosyasını okur. Bir widget'ı sürüklediğiniz, `omarchy bar` çalıştırdığınız veya dosyayı kendiniz düzenlediğiniz anda sahibi siz olursunuz — derin birleştirme yoktur, bu yüzden gelecek Omarchy sürümlerindeki yeni varsayılan widget'lar çubuğunuzda otomatik olarak görünmez. `omarchy bar defaults` temiz bir başlangıç istediğinizde birlikte gelen düzeni geri koyar.

Aynı dosya, `bar` anahtarının dışında, üst düzeyde boşta kalma sürelerinizi de tutar: `idle.screensaver` ve `idle.lock`, ikisi de boşta kaldığınızdan bu yana saniye cinsindendir. Böylece varsayılan ekran koruyucu 150 saniyede devreye girer ve kilit 300 saniyede.
