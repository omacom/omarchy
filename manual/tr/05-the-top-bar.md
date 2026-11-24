# Üst Bar

Ekranınızın üstündeki şerit Omarchy barıdır. Üzerine sonradan eklenmiş bir durum çubuğu değil, Omarchy shell'inin bir parçasıdır; menüyü, bildirimleri, OSD açılır pencerelerini ve kilit ekranını da çizen, uzun ömürlü tek Quickshell sürecidir. Bu yüzden her şeyle mükemmel uyumlu tema alır ve bir panel, yeni bir uygulama başlatmak yerine anında açılır.

Aynı zamanda masaüstünün her zaman ekranda olan tek parçasıdır, bu yüzden o küçük gliflerin ne işe yaradığını bilmeye değer.

## Varsayılan olarak üzerinde neler var

Barın üç bölümü vardır. Solunda Omarchy logosu (menü başlatıcı) ve çalışma alanı göstergeleri bulunur. Merkezde durum göstergelerini, saati, Elsewhen'u (bir dünya saati), hava durumunu ve bir Omarchy güncelleme rozetini alırsınız. Sağda: sistem tepsisi, klavye düzeni (birden fazla düzen veya giriş yöntemi yapılandırıldığında), agents, bluetooth, ağ, ses, ekran ve güç.

Bunlardan birkaçı yalnızca söyleyecek bir şeyleri olduğunda görünür. Klavye düzeni yalnızca birden fazla düzen veya giriş yöntemi yapılandırdıysanız görünür. Güncelleme rozeti yalnızca bekleyen bir Omarchy güncellemesi olduğunda görünür.

## Etrafta tıklamak

Neredeyse her widget sol, sağ ve orta tıklamada bir şey yapar ve birçoğu kaydırmaya yanıt verir. İnsanların kaçırdığı kısım burasıdır — iyi şeylerin çoğu sağ ve orta düğmelerde saklanır.

| Widget | Sol | Sağ | Orta / kaydırma |
| --- | --- | --- | --- |
| Menü | Omarchy menüsü | Yeni terminal | — |
| Çalışma Alanları | Bu monitörde o çalışma alanına odaklan | — | Kaydırma: sonraki/önceki çalışma alanı |
| Saat | Takvim açılır penceresi | Etiket biçimini döngüsel olarak değiştir | Orta: saat dilimi seçici |
| Dünya saati | Dünya saati paneli | Yenile | Orta: yenile |
| Hava Durumu | Tahmin açılır penceresi | Tam hava durumunu bildirim olarak göster | Orta: yenile |
| Ses | Ses paneli | Sessize al | Orta: panel · kaydırma: ses seviyesi |
| Mikrofon | Mikrofonu sessize al | — | Orta: ses paneli · kaydırma: giriş ses seviyesi |
| Ağ | Ağ paneli | — | — |
| Bluetooth | Bluetooth paneli | Radyoyu aç/kapat | — |
| Ekran | Ekran paneli | — | Kaydırma: parlaklık |
| Güç | Güç paneli | Pil yüzdesini aç/kapat | — |
| Medya | Oynat/duraklat | Kapak resmi açılır penceresi | Orta: sonraki · kaydırma: önceki/sonraki |
| Agents | Agents paneli | Agent'ınızı başlatın | Orta: kullanımı yenile |
| Tepsi | Çekmeceyi göstermek için üzerine gelin | Yönetmek için chevron'a sağ tıklayın | — |
| Omarchy güncellemesi | Güncellemeyi çalıştır | — | — |

Bu tablodaki her şey kutudan çıktığı haliyle barınızda değildir. Medya widget'ı (MPRIS şimdi çalıyor, kayan bir parça ve sanatçı bilgisiyle) ve mikrofon widget'ı, ikisi de yerleşik olarak gelir ancak varsayılan olarak kapalıdır — isterseniz aşağıda anlatıldığı gibi ekleyin.

## Paneller

Bir bar simgesine tıklamak bir panel açar; bu, bir araç ipucu değil, kaydırıcılar, listeler ve klavye navigasyonu içeren düzgün bir açılır penceredir. Her birinin bir kısayolu da vardır, böylece 16 piksellik bir glife nişan almak zorunda kalmazsınız:

| Kısayol | Panel |
| --- | --- |
| `Super + Ctrl + A` | Ses |
| `Super + Ctrl + N` | Ağ |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ekran |
| `Super + Ctrl + P` | Güç |
| `Super + Ctrl + Alt + D` | Takvim |
| `Super + Ctrl + Alt + E` | Dünya saati |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | Sağ bölümdeki n'inci paneli aç/kapat |

Paneller salt gösterge değildir. İşi gerçekten yaptığınız yer onlardır:

- **Ses** içinde bir ana ses seviyesi kaydırıcısı, bir çıkış cihazı seçici ve uygulama başına bir mikser bulunur, böylece diğer her şeyi etkilemeden o tek tarayıcı sekmesinin sesini kısabilirsiniz.
- **Ağ**, Wi-Fi taraması yapar, sinyal gücünü gösterir, bağlanır ve bir DNS sağlayıcısı seçmenize olanak tanır.
- **Bluetooth**, cihazlarınızı bağlanma/bağlantı kesme ve pil seviyeleriyle birlikte listeler.
- **Güç**, pil istatistiklerini gösterir, güç profillerini değiştirir (pil ve AC için ayrı bir tercihi hatırlar) ve bazı sistem bilgilerini gösterir.
- **Ekran**, bir parlaklık kaydırıcısı, metin boyutu, monitör ölçeklendirme hazır ayarları ve — birden fazla ekranınız olduğunda — monitör başına kontroller içerir. Daha derin hikâye için [monitörler](33-monitors.md) sayfasına bakın.
- **Saat**, ISO hafta numaraları ve aylar arasında gezinme içeren bir ay ızgarası açar.
- **Dünya saati**, her şehir için bir satır tutar, o şehrin hava durumunu ve gününün nasıl geçtiğini gösterir. Arama, kasabaları da saat dilimleri kadar bulur, bu yüzden Fort Lauderdale, New York değil Fort Lauderdale'dir. Üstteki satır yanlış şehri adlandırıyorsa, üzerine tıklayın ve nerede olduğunuzu söyleyin; başka bir saat dilimindeki bir yeri seçerseniz sistem saati de oraya taşınır, bu da seyahat ederken kullanışlıdır. Bir şehrin üzerine gelin ve orada kimin yaşadığını söylemek için kişi düğmesine tıklayın — düz isimler veya yüzlerini de getirmek için `@` GitHub kullanıcı adları.

Her panel fare kadar klavyeyi de kabul eder: ok tuşları hareket eder, Return etkinleştirir, Tab komşu panele geçer ve Escape kapatır.

`Super + Ctrl + 1-9`, sağ bölümdeki panelleri soldan sağa sayar, kendi paneli olmadığı için tepsiyi atlar. Böylece sayı, işaret edeceğiniz simgeyle eşleşir.

### Tailscale ve Dropbox

**Install → Service** üzerinden eşleşen hizmeti kurduğunuzda barda iki widget daha görünür ve ikisini de bilmeye değer çünkü durum bildirmekten fazlasını yaparlar.

**Tailscale** paneli tailnet'e bağlanır ve bağlantıyı keser, hesaplar arasında geçiş yapar ve bir çıkış düğümü seçer (kendi makineleriniz ve Mullvad bölgeleri de o listede görünür). Ayrıca makinelerinize göz atar — ve biri seçiliyken, `s` ona Taildrop üzerinden dosya gönderir, bu da bir dosyayı telefonunuza veya başka bir dizüstü bilgisayara taşımanın en hızlı yoludur. `c` makinenin IP adresini, `n` adını ve `d` tam DNS adını kopyalar. İsterseniz tıklamak için her makine satırında bir gönder düğmesi de vardır. Aynı şey terminalden `omarchy tailscale send <machine> [file...]` şeklindedir.

**Dropbox** paneli girişi yönetir, ne kadar depolama kullandığınızı gösterir ve yakın zamanda senkronize edilen dosyaları listeler.

Her iki hizmeti de kaldırmak, widget'ını bardan geri kaldırır.

## Göstergeler

Merkezdeki küçük küme, göstergeler widget'ıdır. Bunlar açtığınız modlar için durum glifleridir: rahatsız etmeyin, gece ışığı, kuyruğa alınmış bir [hatırlatıcı](09-reminders.md), aktif bir ekran kaydı ve uyanık kalma, ayrıca parolasız sudo açıkken veya biri uzak bir oturuma bağlıyken uyarılar. Mod aktif olduğunda yanarlar ve aksi hâlde göz önünden uzak dururlar — pasif olanların duracağı yerde, hemen yanlarına gelerek onlara göz atın. Bir göstergeye tıklamak o modu açıp kapatır. Bir tane daha yalnızca durum içindir: biri gliff üzerinden bu makineye bağlıyken uzak oturum kırmızı yanar.

Her zaman görünür olmalarını tercih ederseniz, widget üzerinde `alwaysShow` değerini `true` olarak ayarlayın. Ve yalnızca bazılarını önemsiyorsanız, istediklerinizi `items` içinde listeleyin: `["Dnd", "Reminder", "NightLight"]`. Birden fazla göstergeler widget'ına sahip olabilirsiniz, böylece farklı bölümler farklı alt kümeleri gösterebilir.

## Barı yeniden düzenleme

Bar kendini yapılandırır. Bir şeyleri taşımak için bir yapılandırma dosyası açmanız gerekmez.

Barın merkezinin etrafındaki boş bir alanı tutun ve başka bir ekran kenarına doğru sürükleyin, bar oraya taşınır — sol, sağ, üst veya alt, hepsi çalışır ve her widget uyum sağlar (dikey barlar kompakt, yalnızca simge formlarına geri döner). Tıklayıp basılı tutmak da aynı sürüklemeyi başlatır. Aynı boş alana çift sol tıklamak, bar arka planını şeffaftan camsıdan opak hâle döngüsel olarak değiştirir. Ve herhangi bir widget'ı yeniden sıralamak veya başka bir bölüme atmak için sürükleyin; diğer widget'lar, ineceği yerde yer açmak için kayarak ayrılır.

Barın ortası bir kutudur: içinde ne varsa tek bir grup olarak ortalı kalır ve iki yanındaki widget'lar onun kenarlarına asılır. Bir widget'ı sürüklerken kutu bir ana hat olarak, boş olduğunda ise bar boyunca bir çizgi olarak görünür ve içine veya yanına bırakabilirsiniz. Bırakma kutunun içine denk gelecekse, kutu widget'ı içine alacak şekilde büyür.

Etrafta olmasını istediğiniz ancak her zaman görünür olmasını istemediğiniz bir widget, tepsinin çekmecesine gidebilir: onu tepsinin üzerine sürükleyin, çekmece onu almak için açılır. Orada uygulama simgelerinin arkasında durur, çekmece ne zaman görünürse o da görünür ve paneli açıkken çekmecesini açık tutar. Geri koymak için bara geri sürükleyin.

Bir menüden seçmeyi tercih ederseniz, **Appearance → Menu Bar** konum seçeneğini içerir ve **Bar Background**, barın nasıl çizileceğini seçer: **Opaque Bar**, **Glassy Bar** (arkasındakiler bulanıklaştırılmış, şeffaf) veya **Clear Bar**.

Aynı şeylerin komutları da vardır, ki bu bir [dotfiles](31-dotfiles.md) kurulumu için istediğiniz şeydir:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Bir widget'ı tamamen eklemek veya kaldırmak için plugin komutlarını kullanın. `omarchy plugin list`, shell'in bildiği her widget'ı kimliğiyle birlikte yazdırır ve ardından:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Barı gizleme

`Super + Shift + Space`, shell'i öldürmeden barı kapatıp tekrar açar — paneller ve kısayollar çalışmaya devam eder, sadece pikselleri geri alırsınız. Ayrıca menüde **Appearance → Menu Bar → Hide Bar** altında da bulunur.

## Yapılandırma dosyası

Hepsi `~/.config/omarchy/shell.json` içinde, `bar` anahtarı altında saklanır. İşte kırpılmış bir sürümü:

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

Her widget, beş düzen dizisinden birindeki bir girdidir ve ayarları o girdinin üzerinde satır içi olarak bulunur — ayrı bir ayar dosyası ve `config` alt nesnesi yoktur. Saatin `format`, `formatAlt` (sağ tıklamanın döngüsel olarak geçtiği şey) ve `verticalFormat` değerlerinin hepsi tam orada, `{ "id": "omarchy.clock" }` üzerinde yaşar.

`center`, barın ortasındaki kutudur: içindeki her şey ekranda tek bir grup olarak ortalanır. `centerBegin` ve `centerEnd`, kutunun iki yanına asılır, bu da hava durumu ve güncelleme rozeti gelip giderken bile saatin tam ortada kalmasını sağlar. `center` içine birden fazla widget koyarsanız birlikte ortalanırlar; boş bırakırsanız `centerBegin` ve `centerEnd` barın ortasında buluşur.

İçselleştirmeye değer bir kural: **kendi `shell.json` dosyanıza sahip olduğunuzda, o kanoniktir**. Bir şeyi özelleştirene kadar shell, Omarchy'nin varsayılan dosyasını okur. Bir widget'ı sürüklediğiniz, `omarchy bar` çalıştırdığınız veya dosyayı kendiniz düzenlediğiniz anda, o artık sizindir — derin birleştirme yoktur, bu yüzden gelecekteki Omarchy sürümlerindeki yeni varsayılan widget'lar barınızda otomatik olarak görünmez. Temiz bir sayfa istediğinizde `omarchy bar defaults`, gelen düzeni geri koyar.

Aynı dosya, boşta kalma sürelerinizi de üst seviyede, `bar` anahtarının dışında tutar: `idle.screensaver` ve `idle.lock`, ikisi de boşta kaldığınızdan bu yana geçen saniye cinsindendir. Böylece varsayılan ekran koruyucu 150 saniyede devreye girer ve kilit 300 saniyede.
