# Geçişler, Boşta Kalma ve Ekran Koruyucu

Günlük olarak değiştirdiğiniz pek çok şey aslında bir ayar değildir. Bir saatliğine açıp sonra tekrar kapattığınız bir moddur: gece geç saatte çalışırken gece ışığı, sunum yaparken rahatsız etme, bir şey izlerken uyanık kalma. Omarchy bunlara geçişler der ve hepsi aynı şekilde çalışır — bir kısayol tuşu, bir menü girişi ve bir komut, hepsi aynı düğmeye basar.

### Geçiş menüsü

`Super + Ctrl + O` _Trigger > Toggle_ menüsünü doğrudan açar ya da Omarchy menüsünden (`Super + Space`) oraya gidebilirsiniz. O listedeki her şey, durumun nerede yaşadığını düşünmeden çevirebileceğiniz bir düğmedir. Masaüstünün nasıl göründüğüne dair düğmeler onun yanında, _Appearance_ altında durur.

Terminalden aynı düğmeler `omarchy toggle <thing>` komutlarıdır. Bütün grubu görmek için `omarchy toggle` komutunu tek başına çalıştırın.

| Geçiş | Kısayol Tuşu | Komut |
| ------ | ------ | ------- |
| Gece ışığı | — | `omarchy toggle nightlight` |
| Bildirimleri sessize al | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Uyanık kal (boşta kilidi yok) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Çökme yakalama | — | `omarchy toggle crash-capture` |
| Ekran koruyucu | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) tema senkronizasyonu | — | `omarchy toggle theme sync` |
| Menü çubuğu | `Super + Shift + Space` | `omarchy toggle bar` |
| Dokunmatik yüzey | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Dokunmatik ekran | — | `omarchy device touchscreen` |
| Askıya al | — | `omarchy toggle suspend` |
| Hibrit GPU | — | `omarchy toggle hybrid gpu` |

Dokunmatik yüzey, dokunmatik ekran ve hibrit GPU düğmeleri Toggle altında değil, _Trigger > Hardware_ (`Super + Ctrl + H`) altında yaşar, çünkü yalnızca o donanıma gerçekten sahipseniz görünürler. Dokunmatik yüzey ve dokunmatik ekran düğmeleri Hyprland yeniden yüklemesinden sağ çıkar — devre dışı bırakılan cihazın adı, Hyprland'in başlangıçta onu tekrar devre dışı bırakmak için okuduğu küçük bir durum dosyasına kaydedilir.

_Appearance_, menü çubuğunu ve animasyonları barındırır; artı `omarchy toggle` komutları olmayan ama aynı şekilde davranan birkaç şeyi de: çubuktaki pil yüzdesi, varsayılan çalışma alanı düzeni ve _Windows_ altında pencere boşlukları (`Super + Shift + Backspace`) ile 1 pencereli kare en-boy oranı (`Super + Ctrl + Backspace`).

Hyprland'in çizecek bir GPU'su olmadığında ve onun yerine CPU üzerinde render yaptığında (llvmpipe), GPU'su henüz desteklenmeyen Mac'lerde olduğu gibi, çoğu sanal makinede ya da bir grafik sürücüsü yüklenemediğinde, Omarchy o oturum için animasyonları, bulanıklığı ve gölgeleri kapatır ve bunu size bir kez bir bildirimle söyler. _Appearance > Animations On_ bunları geri getirir ve Omarchy bunu sonraki oturumlar için de hatırlar.

Bunların çoğu `~/.local/state/omarchy/toggles/` altında bir bayrak dosyasından ibarettir. Bir betikte birine göre dallanmak isterseniz, `omarchy-toggle-enabled` sizi aramaya göndermek yerine size bir çıkış kodu verir:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bayraklar kapalı durum için adlandırılır — `screensaver-off`, `suspend-off`, `bar-off` — yani varlıkları özelliğin devre dışı bırakıldığı anlamına gelir.

### Çubuktaki göstergeler

Bir mod açıkken saatin yanında üst çubuğun ortasında küçük bir simge alırsınız. Bu, göstergeler widget'ıdır ve dikteyi, ekran kaydını, bekleyen hatırlatıcıları, gece ışığını, rahatsız etmeyi ve uyanık kalmayı taşır.

Etkin olmayan göstergeler gizlidir. Çubuğun herhangi bir yerinde üzerine gelin, soluk bir şekilde belirirler; böylece kısayol tuşunu bilmeden birine tıklayıp açabilirsiniz. Etkin birine tıklamak onu tekrar kapatır. Hepsini her zaman görmeyi tercih ederseniz, `~/.config/omarchy/shell.json` içindeki `omarchy.indicators` girişinde `alwaysShow` değerini `true` olarak ayarlayın — çubuk widget'larının nasıl yapılandırıldığı için [üst çubuğa](05-the-top-bar.md) bakın.

### Gece ışığı

Gece ışığı ekranı 4000K'ye ısıtır ve tekrar geçiş yapmak onu 6500K'ye geri getirir. Geçiş menüsünden (`Super + Ctrl + O`) ya da `omarchy toggle nightlight` ile çevirin. Bu, hyprsunset tarafından yürütülür ve zaten çalışmıyorsa geçiş onu sizin için başlatır.

Varsayılan olarak hyprsunset ekranınıza hiçbir şey yapmaz. `~/.config/hypr/hyprsunset.conf`, siz sıcaklık isteyene kadar ekranın dokunulmadan kalması için tam da bu yüzden bir kimlik profiliyle gelir. Saate göre geçiş yapmasını tercih ederseniz, bunu bir zaman profiliyle değiştirin:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Sonra `~/.config/hypr/autostart.lua` dosyasına `o.launch_on_start("hyprsunset")` ekleyerek hyprsunset'i girişte başlatın. Geçişin kullandığı 4000K/6500K çifti sabittir, yani farklı bir sıcaklık isterseniz gideceğiniz yer yapılandırma dosyasıdır.

### Rahatsız etme

`Super + Ctrl + Alt + ,` bildirimleri sessize alır. Açıkken hiçbir bildirim baloncuğu çıkmaz ve üstü çizili zil göstergesi, masaüstünün neden sessizleştiğini hatırlatmak için çubukta durur.

Yine de hiçbir şey kaybolmaz. Sessize alınan bildirimler geri tutulur: son birkaçını `Super + Shift + Alt + ,` ile ekrana geri getirin. Geri kalanı için [bildirimlere](10-notices.md) bakın.

İki tür mesaj yine de geçer: az önce yaptığınız bir şey için Omarchy'nin kendi onay bildirimleri ("Theme changed", "Screenshot saved") ve komut satırından gönderilen kritik uyarılar. Kendilerini önünüze zorla çıkarmak için her şeyi kritik olarak işaretleyen sohbet uygulamaları buna hak kazanmaz.

### Boşta kalma

Boşta kalma davranışının sahibi Omarchy kabuğudur ve zamanlamalar `~/.config/omarchy/shell.json` içindeki üst düzey bir `idle` bloğudur:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Her iki sayı da boşta kalmaya başladığınız andan itibaren sayılan saniyelerdir — birbirinden değil. Yani varsayılanlarla ekran koruyucu iki buçuk dakika sonra çıkar ve ekran koruyucu çalışsa da çalışmasa da kilit ekranı beş dakikada devralır. Dosyayı kaydedin, kabuk yeni zamanlamaları hemen alır.

Ekran koruyucuyu kilit son tarihinden önce kapatırsanız bu etkinlik sayılır ve bekleyen kilit iptal edilir. Makinenize göz attığınız için kilitlenmezsiniz.

Boşta kilitlemeyi tamamen durdurmak için `Super + Ctrl + I` — ya da `omarchy toggle idle` — uyanık kalmayı açar ve kahve fincanı göstergesi çubukta görünür. Uzun bir sunumdan ya da izlemek istediğiniz bir derlemeden önce basacağınız şey budur. Normale dönmek için tekrar basın. Bir betikten ihtiyacınız olursa `omarchy toggle idle status` geçerli durumu JSON olarak yazdırır.

Bu, kilitleme ve ekran koruyucu ile ilgilidir, güç ile değil. Askıya alma ve hazırda bekletmenin kendi kurulumu [sistem uykusunda](36-system-sleep.md) vardır.

### Ekran koruyucu

Omarchy'nin ekran koruyucusu, rastgele metin efektlerinden geçen ASCII sanatıdır; her monitör için bir örnek çalışır. Herhangi bir tuş ya da fare hareketi ondan çıkar.

Onu _System > Screensaver_ (`Super + Esc`) üzerinden isteğe bağlı olarak başlatabilirsiniz; bu, boşta ekran koruyucuyu kapatmış olsanız bile onu zorla çıkarır. Varsayılan olarak ona atanmış bir kısayol tuşu yoktur.

Çalışmaktan doğrudan kilitli duruma geçmeyi tercih ederseniz, boşta olanı kapatan şey `omarchy toggle screensaver` komutudur. Herhangi bir tuş, tıklama, kaydırma ya da fare hareketi onu kapatır.

Çizdiği logo, _Appearance > Branding > Screensaver_ altında değiştirmeniz için sizindir. Bir png ya da svg yükleyin, Omarchy onu ASCII'ye dönüştürür. [markalamaya](41-branding.md) bakın.

### Kilit ekranı

`Super + Ctrl + L` makineyi kilitler. Bu, Omarchy kabuğundan kilit ekranını çalıştırır, ekranı karartır, parolanızı yanlış alfabede yazmamanız için klavye düzeninizi ilkine sıfırlar ve — çalıştırıyorsanız — çıkış yolunda 1Password'ü kilitler.

Kilit ekranı bir parola kabul eder ve bir tane ayarladıktan sonra parmak izini de kabul eder. Bu ve kimlik doğrulamanın diğer yolları [donanım kimlik doğrulamasında](37-hardware-authentication.md) ele alınır.
