# Aç/Kapat Anahtarları, Boşta Kalma ve Ekran Koruyucu

Günlük olarak değiştirdiğiniz şeylerin çoğu aslında bir ayar değildir. Bir saatliğine açıp sonra tekrar kapattığınız bir moddur: gece geç saatlere kadar çalışırken gece ışığı, sunum yaparken rahatsız etme, bir şey izlerken uyanık kalma. Omarchy bunlara aç/kapat anahtarları der ve hepsi aynı şekilde çalışır — bir kısayol tuşu, bir menü girdisi ve bir komut, hepsi aynı anahtara basar.

### Aç/kapat menüsü

`Super + Ctrl + O`, _Tetikleyici > Aç/Kapat_ menüsünü doğrudan açar veya Omarchy menüsünden (`Super + Space`) oraya yürüyerek gidebilirsiniz. O listedeki her şey, durumun nerede yaşadığını düşünmeden çevirebileceğiniz bir anahtardır. Masaüstünün nasıl göründüğüne dair anahtarlar, yanındaki _Görünüm_ altında yer alır.

Terminalden, aynı anahtarlar `omarchy toggle <thing>` şeklindedir. Grubun tamamını görmek için `omarchy toggle` komutunu tek başına çalıştırın.

| Aç/Kapat Anahtarı | Kısayol Tuşu | Komut |
| ------ | ------ | ------- |
| Gece ışığı | — | `omarchy toggle nightlight` |
| Bildirimleri sessize alma | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Uyanık kalma (boşta kilidi yok) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Çökme yakalama | — | `omarchy toggle crash-capture` |
| Ekran koruyucu | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) tema senkronizasyonu | — | `omarchy toggle theme sync` |
| Menü çubuğu | `Super + Shift + Space` | `omarchy toggle bar` |
| Tam ekran masaüstü (çubuk yok, boşluk yok) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animasyonlar, bulanıklık ve gölgeler | — | `omarchy toggle animations` |
| Dokunmatik yüzey | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Dokunmatik ekran | — | `omarchy device touchscreen` |
| Askıya alma | — | `omarchy toggle suspend` |
| Hibrit GPU | — | `omarchy device gpu hybrid` |

Dokunmatik yüzey, dokunmatik ekran ve hibrit GPU anahtarları, _Aç/Kapat_ altında değil, _Tetikleyici > Donanım_ (`Super + Ctrl + H`) altında bulunur, çünkü bunlar yalnızca o donanıma gerçekten sahipseniz görünür. Dokunmatik yüzey ve dokunmatik ekran anahtarları bir Hyprland yeniden yüklemesinden sağ çıkar — devre dışı bırakılan cihazın adı, Hyprland'ın başlangıçta tekrar devre dışı bırakmak için okuduğu küçük bir durum dosyasına kaydedilir.

_Görünüm_, menü çubuğunu ve animasyonları, ayrıca `omarchy toggle` komutu olmayan ama aynı şekilde davranan birkaç şeyi barındırır: çubuktaki pil yüzdesi, varsayılan çalışma alanı düzeni ve _Pencereler_ altında, pencere boşlukları (`Super + Shift + Backspace`) ve 1 pencereli kare en boy oranı (`Super + Ctrl + Backspace`).

Hyprland'ın çizecek bir GPU'su olmadığında ve bunun yerine CPU üzerinde render yaptığında (llvmpipe), GPU'su henüz desteklenmeyen Mac'lerde olduğu gibi, çoğu sanal makinede veya bir grafik sürücüsü yüklenemediğinde, Omarchy o oturum için animasyonları, bulanıklığı ve gölgeleri kapatır ve bunu size bir kez bir bildirimle söyler. _Görünüm > Animasyonlar Açık_ bunları geri getirir ve Omarchy bunu sonraki oturumlar için de hatırlar.

Bunların çoğu, `~/.local/state/omarchy/toggles/` altında yalnızca bir bayrak dosyasıdır. Bir betikte birine göre dallanmak isterseniz, `omarchy-toggle-enabled` size aramaya gitmek zorunda kalmadan bir çıkış kodu verir:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bayraklar kapalı duruma göre adlandırılır — `screensaver-off`, `suspend-off`, `bar-off` — bu yüzden varlıkları, özelliğin devre dışı olduğu anlamına gelir.

### Çubuktaki göstergeler

Bir mod açık olduğunda, saatin yanındaki üst çubuğun ortasında küçük bir simge görürsünüz. Bu, göstergeler widget'ıdır ve ekran kaydını, bekleyen hatırlatıcıları, gece ışığını, rahatsız etme modunu ve uyanık kalmayı, ayrıca parolasız sudo açıkken veya birisi uzak bir oturuma bağlıyken uyarıları taşır.

Etkin olmayan göstergeler gizlidir. Çubuğun üzerinde herhangi bir yerde fareyle üzerine gelindiğinde soluk bir şekilde belirirler, böylece kısayol tuşunu bilmeden birine tıklayıp açabilirsiniz. Etkin birine tıklamak onu tekrar kapatır. Hepsini her zaman görmek isterseniz, `~/.config/omarchy/shell.json` içindeki `omarchy.indicators` girdisinde `alwaysShow` değerini `true` olarak ayarlayın — çubuk widget'larının nasıl yapılandırıldığı için bkz. [üst çubuk](05-the-top-bar.md).

### Gece ışığı

Gece ışığı ekranı 4000K'ye ısıtır ve tekrar aç/kapat yapmak onu 6500K'ye geri getirir. Aç/kapat menüsünden (`Super + Ctrl + O`) veya `omarchy toggle nightlight` ile çevirin. Bu, hyprsunset tarafından çalıştırılır; aç/kapat anahtarı, zaten çalışmıyorsa sizin için başlatır.

Varsayılan olarak hyprsunset ekranınıza hiçbir şey yapmaz. `~/.config/hypr/hyprsunset.conf`, tam olarak siz sıcaklık isteyene kadar ekranın dokunulmadan kalması için bir kimlik profiliyle gelir. Bunun yerine saate göre geçiş yapmasını isterseniz, bunu bir zaman profiliyle değiştirin:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Sonra `~/.config/hypr/autostart.lua` dosyasına `o.launch_on_start("hyprsunset")` ekleyerek hyprsunset'i oturum açılırken başlatın. Aç/kapat anahtarının kullandığı 4000K/6500K çifti sabittir, bu yüzden farklı bir sıcaklık istiyorsanız gideceğiniz yer yapılandırma dosyasıdır.

### Rahatsız etme

`Super + Ctrl + Alt + ,` bildirimleri sessize alır. Açıkken hiçbir toast belirmez ve üstü çizili zil göstergesi, masaüstünün neden sessizleştiğini hatırlatmak için çubukta durur.

Yine de hiçbir şey kaybolmaz. Sessize alınan bildirimler geri tutulur: son birkaçını `Super + Shift + Alt + ,` ile tekrar ekrana getirin. Geri kalanı için bkz. [bildirimler](10-notices.md).

Üç tür mesaj hâlâ geçer: Omarchy'nin az önce yaptığınız bir şey için kendi onay toast'ları ("Tema değiştirildi", "Ekran görüntüsü kaydedildi"), komut satırından gönderilen kritik uyarılar ve doğrulama kodları. Her şeyi, önünüze zorla çıkmak için kritik olarak işaretleyen sohbet uygulamaları buna uygun değildir.

### Boşta kalma

Omarchy kabuğu boşta kalma davranışını sahiplenir ve zamanlamalar, `~/.config/omarchy/shell.json` içinde üst düzey bir `idle` bloğudur:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Her iki sayı da boşta kaldığınız andan itibaren sayılan saniyelerdir — birbirinden değil. Yani varsayılanlarla, ekran koruyucu iki buçuk dakika sonra gelir ve kilit ekranı, ekran koruyucu çalışmış olsun ya da olmasın, beş dakikada devralır. Dosyayı kaydedin ve kabuk yeni zamanlamaları hemen alır.

Eğer kilit son tarihinden önce ekran koruyucuyu kapatırsanız, bu etkinlik olarak sayılır ve bekleyen kilit iptal edilir. Makinenize göz attığınız için kilitlenmezsiniz.

Boşta kilitlemeyi tamamen durdurmak için, `Super + Ctrl + I` — veya `omarchy toggle idle` — uyanık kalmayı açar ve kahve fincanı göstergesi çubukta belirir. Uzun bir sunumdan veya izlemek istediğiniz bir derlemeden önce basmanız gereken budur. Normale dönmek için tekrar basın. `omarchy toggle idle status`, bir betikten ihtiyacınız olursa mevcut durumu JSON olarak yazdırır.

Bu, kilitleme ve ekran koruyucu ile ilgilidir, güçle değil. Askıya alma ve hazırda bekletmenin kendi kurulumu [sistem uykusu](36-system-sleep.md) içindedir.

### Ekran koruyucu

Omarchy'nin ekran koruyucusu, rastgele metin efektleriyle çalışan ASCII sanatıdır, monitör başına bir örnek. Herhangi bir tuş veya fare hareketi onu kapatır.

Boşta ekran koruyucuyu kapatmış olsanız bile zorla çıkaran _Sistem > Ekran Koruyucu_ (`Super + Esc`) üzerinden isteğe bağlı olarak başlatabilirsiniz. Varsayılan olarak ona bağlı bir kısayol tuşu yoktur.

`omarchy toggle screensaver`, çalışmadan doğrudan kilitli duruma geçmeyi tercih ederseniz, boşta olanı kapatan şeydir. Herhangi bir tuş, tıklama, kaydırma veya fare hareketi onu kapatır.

Çizdiği logo, _Görünüm > Marka > Ekran Koruyucu_ altında değiştirmeniz için sizindir. Bir png veya svg yükleyin ve Omarchy onu ASCII'ye dönüştürür. Bkz. [marka](41-branding.md).

### Kilit ekranı

`Super + Ctrl + L` makineyi kilitler. Bu, Omarchy kabuğundan kilit ekranını çalıştırır, ekranı karartır, yanlış alfabede parolanızı yazmamanız için klavye düzeninizi ilkine sıfırlar ve — çalıştırıyorsanız — çıkarken 1Password'ü kilitler.

Kilit ekranı bir parola alır ve bir parmak izi ayarladıktan sonra bir parmak izi de alır. Bu ve kimlik doğrulamanın diğer yolları, [donanım kimlik doğrulaması](37-hardware-authentication.md) içinde ele alınır.
