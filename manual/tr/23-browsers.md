# Tarayıcılar

Omarchy, varsayılan tarayıcı olarak [Google Chrome](https://www.google.com/chrome/) ile birlikte gelir. Sisteminizin geri kalanıyla uyum sağlayacak şekilde temalandırılmıştır ve `Super + Shift + Return` kısayolunun açtığı şey ile her [web uygulamasının](25-web-apps.md) içinde çalıştığı şey budur. Doğrudan bir tarayıcı penceresine açılır: karşılama ekranı ya da oturum açma istemi yoktur, kullanım istatistikleri ve çökme raporları Google'a gönderilmez ve reklam gizliliği istemleri kapatılmıştır. Senkronizasyon istediğinizde, profil düğmesinden Google hesabınızda yine de oturum açabilirsiniz.

Chrome zevkinize uygun değilse, onunla yaşamak zorunda değilsiniz. Omarchy menüsünde _Install > Browser_ altında [Chromium](https://www.chromium.org/) (Chrome'un yapıldığı sade açık kaynak sürüm), Edge, Brave, Brave Origin, Firefox ve [Zen](https://zen-browser.app/) bulacaksınız. Birini seçin; Omarchy onu kurar, ilke dizinini ayarlar ve geçerli temanızı ona uygular.

## Birini varsayılan yapma

Bir tarayıcı kurmak onu öne çıkarmaz. Makineye kurulduktan sonra _Setup > Defaults > Browser_ yoluna gidin ve onu seçin — menü yalnızca gerçekten kurmuş olduğunuz tarayıcıları listeler ve geçerli varsayılanı bir onay işaretiyle işaretler.

Terminalden şöyle yapılır:

```bash
omarchy default browser firefox
```

Argümansız çalıştırırsanız size geçerli varsayılanı söyler. Bu, XDG işleyicisini ayarlar, dolayısıyla buna uyan yalnızca Omarchy'nin kısayol tuşları değildir — bir sohbet uygulamasından bir terminal komutuna kadar bağlantı açan her şey, seçtiğiniz tarayıcıya gider.

## URL'yi Kopyala ve Videoyu İndir

Chromium ailesi tarayıcılar (Chromium'un kendisi, Chrome, Edge ve Brave), tarayıcının dışına ve sisteminizin geri kalanına uzanan iki Omarchy uzantısıyla birlikte gelir.

**URL'yi Kopyala**, `Alt + Shift + L` ile geçerli sekmenin adresini panonuza koyar. Bu, adres çubuğuna tıklayıp kopyalamaktan daha hızlıdır ve tarayıcınınki yerine sistem panosu üzerinden geçtiği için, bunu doğrulayan bir Omarchy bildirimi alırsınız ve URL, [pano geçmişinde](08-unified-clipboard-history.md) ve diğer her uygulamada hemen kullanılabilir olur. Tıklamayı tercih ederseniz diye bir araç çubuğu düğmesi de vardır.

**Videoyu İndir**, `Alt + Shift + D` ile baktığınız sayfada oynatılan videoyu alır. URL'yi [yt-dlp](https://github.com/yt-dlp/yt-dlp) aracına teslim eder, bu yüzden YouTube'dan çok daha fazlasında çalışır ve indirme `~/Videos` içine iner. İlerleme, ses düzeyi ve parlaklığın kullandığı aynı ekran üstü göstergede görünür ve bildirimleri üst üste yığmak yerine yerinde güncellenir. Dosyaların başka bir yere gitmesini tercih ederseniz `OMARCHY_YTDLP_DIR` değişkenini ayarlayın — ortam değişkenlerini nereye koyacağınız için [FAQ](46-faq.md) bölümüne bakın.

Her iki uzantı da Omarchy ile, tarayıcıyla birlikte sizin için kurulan küçük bir yerel mesajlaşma ana bilgisayarı aracılığıyla konuşur. Bir web sayfasının videosunun ev dizininizde ve bir URL'nin pano yöneticinizde bitmesini sağlayan parça budur; normal bir uzantı bunu kendi başına yapamaz.

Bunlar yalnızca Chromium ailesi içindir. Firefox ve Zen bunları almaz.

## Firefox ve Zen

Firefox ve Zen farklı bir ailedir, bu yüzden farklı muamele görürler: Omarchy, makul varsayılanlar için bir ilkeler dosyası kurar ve onları yerel Wayland moduna geçirir; kesirli ölçeklendirme ve akıcı izleme dörtgeni kaydırması için bunu istersiniz.

Yukarıdaki Chromium uzantılarını almazlar ve Omarchy tarafından temalandırılmazlar, bu yüzden deneyimin o kısımlarını ayarlamak size kalır.

## Birini tekrar kaldırma

Chrome dahil bu tarayıcıların herhangi biri, _Remove > Browser_ altında tekrar kaldırılabilir. Diğer tarayıcı hâlâ kuruluysa bağlantılar bundan sonra Chrome veya Chromium'a gider.
