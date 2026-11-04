# Geçişler, Boşta Kalma ve Ekran Koruyucu

Gün içinde değiştirdiğiniz şeylerin çoğu aslında bir ayar değildir. Bir saatliğine açıp sonra tekrar kapattığınız bir moddur: gece geç saatlere kadar çalışırken gece ışığı, sunum yaparken rahatsız etme, bir şey izlerken uyanık kalma. Omarchy bunlara geçişler diyor ve hepsi aynı şekilde çalışıyor — bir kısayol tuşu, bir menü girdisi ve bir komut, hepsi aynı anahtara basıyor.

### Geçiş menüsü

`Super + Ctrl + O`, _Tetikleyici > Geçiş_ bölümünü doğrudan açar ya da Omarchy menüsünden (`Super + Space`) oraya gidebilirsiniz. O listedeki her şey, durumun nerede yaşandığını düşünmeden çevirebileceğiniz bir anahtardır. Masaüstünün nasıl göründüğüne dair anahtarlar, yanındaki _Görünüm_ bölümünün altında durur.

Terminalden aynı anahtarlar `omarchy toggle <thing>` şeklindedir. Grubun tamamını görmek için tek başına `omarchy toggle` çalıştırın.

| Geçiş | Kısayol Tuşu | Komut |
| ------ | ------ | ------- |
| Gece ışığı | — | `omarchy toggle nightlight` |
| Bildirimleri sessize al | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Uyanık kal (boşta kilidi yok) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Çökme yakalama | — | `omarchy toggle crash-capture` |
| Ekran koruyucu | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) tema senkronizasyonu | — | `omarchy toggle theme sync` |
| Menü çubuğu | `Super + Shift + Space` | `omarchy toggle bar` |
| Dokunmatik yüzey | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Dokunmatik ekran | — | `omarchy toggle touchscreen` |
| Askıya al | — | `omarchy toggle suspend` |
| Hibrit GPU | — | `omarchy toggle hybrid gpu` |

Dokunmatik yüzey, dokunmatik ekran ve hibrit GPU anahtarları, Geçiş altında değil _Tetikleyici > Donanım_ (`Super + Ctrl + H`) altında durur, çünkü yalnızca o donanıma gerçekten sahipseniz görünürler. Dokunmatik yüzey ve dokunmatik ekran anahtarları bir Hyprland yeniden yüklemesinden sonra da kalır — devre dışı bırakılan cihazın adı, Hyprland'ın başlangıçta okuyup cihazı yeniden devre dışı bıraktığı küçük bir durum dosyasına kaydedilir.

_Görünüm_, menü çubuğunu ve animasyonları barındırır; ayrıca `omarchy toggle` komutu olmayan ama aynı şekilde davranan birkaç şeyi de: çubuktaki pil yüzdesi, varsayılan çalışma alanı düzeni ve _Pencereler_ altında pencere boşlukları (`Super + Shift + Backspace`) ile 1 pencerelik kare en-boy oranı (`Super + Ctrl + Backspace`).

Hyprland'ın çizecek bir GPU'su olmadığında ve bunun yerine CPU üzerinde render yaptığında (llvmpipe), GPU'su henüz desteklenmeyen Mac'lerde, çoğu sanal makinede veya bir grafik sürücüsü yüklenemediğinde olduğu gibi, Omarchy o oturum için animasyonları, bulanıklığı ve gölgeleri kapatır ve bunu size bir kez bir bildirimle söyler. _Görünüm > Animasyonlar Açık_ bunları geri getirir ve Omarchy bunu sonraki oturumlar için de hatırlar.

Bunların çoğu yalnızca `~/.local/state/omarchy/toggles/` altında bir bayrak dosyasıdır. Bir betikte birine göre dallanmak isterseniz, `omarchy-toggle-enabled` size gidip aramak zorunda kalmadan bir çıkış kodu verir:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bayraklar kapalı durum için adlandırılır — `screensaver-off`, `suspend-off`, `bar-off` — bu yüzden varlıkları, özelliğin devre dışı olduğu anlamına gelir.

### Çubuktaki göstergeler

Bir mod açıkken, üst çubuğun ortasında saatin yanında küçük bir simge görürsünüz. Bu, göstergeler widget'ıdır ve dikte, ekran kaydı, bekleyen hatırlatıcılar, gece ışığı, rahatsız etme ve uyanık kalmayı taşır.

Etkin olmayan göstergeler gizlenir. Çubuğun herhangi bir yerinde üzerine gelin, soluk bir şekilde belirirler; böylece kısayol tuşunu bilmeden birine tıklayıp açabilirsiniz. Etkin birine tıklamak onu tekrar kapatır. Hepsini her zaman görmek isterseniz, `~/.config/omarchy/shell.json` içindeki `omarchy.indicators` girdisinde `alwaysShow` değerini `true` olarak ayarlayın — çubuk widget'larının nasıl yapılandırıldığını görmek için [üst çubuğa](05-the-top-bar.md) bakın.

### Gece ışığı

Gece ışığı ekranı 4000K'ye ısıtır ve tekrar açıp kapatmak onu 6500K'ye geri getirir. Geçiş menüsünden (`Super + Ctrl + O`) ya da `omarchy toggle nightlight` ile çevirin. Zaten çalışmıyorsa geçişin sizin için başlattığı hyprsunset tarafından yürütülür.

Varsayılan olarak hyprsunset ekranınıza hiçbir şey yapmaz. `~/.config/hypr/hyprsunset.conf`, siz sıcaklık isteyene kadar ekranın dokunulmadan kalması için tam olarak bir kimlik profiliyle gelir. Bunun yerine saate göre geçiş yapmasını isterseniz, onu bir zaman profiliyle değiştirin:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ardından `~/.config/hypr/autostart.lua` dosyasına `o.launch_on_start("hyprsunset")` ekleyerek hyprsunset'i oturum açarken başlatın. Geçişin kullandığı 4000K/6500K çifti sabittir, bu yüzden farklı bir sıcaklık isterseniz gideceğiniz yer yapılandırma dosyasıdır.

### Rahatsız etme

`Super + Ctrl + Alt + ,` bildirimleri sessize alır. Açıkken hiçbir bildirim penceresi açılmaz ve üzeri çizili zil göstergesi, masaüstünün neden sessizleştiğini hatırlatmak için çubukta durur.

Yine de hiçbir şey kaybolmaz. Sessize alınan bildirimler geri tutulur: son birkaçını `Super + Shift + Alt + ,` ile tekrar ekrana getirin. Geri kalanı için [bildirimlere](10-notices.md) bakın.

İki tür mesaj hâlâ geçer: Omarchy'nin az önce yaptığınız bir şey için kendi onay bildirimleri ("Tema değiştirildi", "Ekran görüntüsü kaydedildi") ve komut satırından gönderilen kritik uyarılar. Her şeyi önünüze çıkmak için kritik olarak işaretleyen sohbet uygulamaları buna hak kazanmaz.

### Boşta kalma

Boşta kalma davranışının sahibi Omarchy kabuğudur ve zamanlamalar, `~/.config/omarchy/shell.json` içinde üst düzey bir `idle` bloğudur:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Her iki sayı da boşta kaldığınız andan itibaren sayılan saniyelerdir — birbirlerinden itibaren değil. Yani varsayılanlarla ekran koruyucu iki buçuk dakika sonra gelir ve ekran koruyucu çalışmış olsun ya da olmasın kilit ekranı beş dakikada devralır. Dosyayı kaydedin, kabuk yeni zamanlamaları hemen alır.

Kilit son tarihinden önce ekran koruyucuyu kapatırsanız, bu etkinlik sayılır ve bekleyen kilit iptal edilir. Makinenize bir göz attığınız için kilitlenmezsiniz.

Boşta kilitlemeyi tamamen durdurmak için `Super + Ctrl + I` — ya da `omarchy toggle idle` — uyanık kalmayı açar ve kahve fincanı göstergesi çubukta belirir. Uzun bir sunumdan veya izlemek istediğiniz bir derlemeden önce basmanız gereken budur. Normale dönmek için tekrar basın. Bir betikten ihtiyacınız olursa `omarchy toggle idle status`, geçerli durumu JSON olarak yazdırır.

Bu, güçle değil kilitleme ve ekran koruyucuyla ilgilidir. Askıya alma ve hazırda bekletmenin kendi kurulumu [sistem uykusunda](36-system-sleep.md) vardır.

### Ekran koruyucu

Omarchy'nin ekran koruyucusu, rastgele metin efektlerinden geçen ASCII sanatıdır, monitör başına bir örnek çalışır. Herhangi bir tuş veya fare hareketi ondan çıkar.

Onu _Sistem > Ekran Koruyucu_ (`Super + Esc`) bölümünden isteğe bağlı başlatabilirsiniz; bu, boşta ekran koruyucuyu kapatmış olsanız bile onu zorla açar. Varsayılan olarak ona bağlı bir kısayol tuşu yoktur.

Çalışmaktan doğrudan kilitli duruma geçmeyi tercih ederseniz, boşta olanı kapatan şey `omarchy toggle screensaver` komutudur. Herhangi bir tuş, tıklama, kaydırma veya fare hareketi onu kapatır.

Çizdiği logo, _Görünüm > Markalama > Ekran Koruyucu_ altında değiştirmeniz için sizindir. Bir png veya svg yükleyin, Omarchy onu ASCII'ye dönüştürür. [markalamaya](41-branding.md) bakın.

### Kilit ekranı

`Super + Ctrl + L` makineyi kilitler. Bu, Omarchy kabuğundan kilit ekranını çalıştırır, ekranı karartır, parolanızı yanlış alfabede yazmamanız için klavye düzeninizi ilkine sıfırlar ve — çalıştırıyorsanız — çıkış yolunda 1Password'ü kilitler.

Kilit ekranı bir parola kabul eder ve bir parmak izi ayarladıktan sonra onu da kabul eder. Bu ve kimlik doğrulamanın diğer yolları, [donanım kimlik doğrulamasında](37-hardware-authentication.md) ele alınır.
