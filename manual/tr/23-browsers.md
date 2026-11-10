# Tarayıcılar

Omarchy, varsayılan tarayıcı olarak [Chromium](https://www.chromium.org/) ile gelir. Bu, sisteminizin geri kalanıyla eşleşecek şekilde temalandırılmış sade açık kaynaklı sürümdür ve `Super + Shift + Return` tuşlarının açtığı ve her [web uygulamasının](25-web-apps.md) içinde çalıştığı tarayıcıdır.

Chromium zevkinize uymuyorsa, ona mahkûm değilsiniz. Omarchy menüsündeki _Kur > Browser_ altında Chrome, Edge, Brave, Brave Origin, Firefox ve [Zen](https://zen-browser.app/) bulacaksınız. Birini seçin; Omarchy onu kurar, ilke dizinini ayarlar ve geçerli temanızı ona uygular.

## Birini varsayılan yapmak

Bir tarayıcı kurmak onu varsayılan yapmaz. Makineye girdikten sonra _Ayarlar > Defaults > Browser_ bölümüne gidin ve onu seçin — menü yalnızca gerçekten kurduğunuz tarayıcıları listeler ve geçerli varsayılanı bir onay işaretiyle işaretler.

Terminalden şöyle yapılır:

```bash
omarchy default browser firefox
```

Argümansız çalıştırın; size geçerli varsayılanı söyler. Bu, XDG işleyicisini ayarlar, bu yüzden yalnızca Omarchy'nin kısayolları buna uymaz — bir sohbet uygulamasından terminal komutuna kadar bağlantı açan her şey seçtiğiniz tarayıcıya gider.

## URL'yi Kopyala ve Videoyu İndir

Chromium ailesi tarayıcıları (Chromium'un kendisi, Chrome, Edge ve Brave), tarayıcının dışına ve sisteminizin geri kalanına uzanan iki Omarchy uzantısıyla birlikte gelir.

**Copy URL**, geçerli sekmenin adresini `Alt + Shift + L` ile panonuza koyar. Bu, adres çubuğuna tıklayıp kopyalamaktan daha hızlıdır ve tarayıcının panosu yerine sistem panosu üzerinden geçtiği için bunu doğrulayan bir Omarchy bildirimi alırsınız ve URL, [pano geçmişinde](08-unified-clipboard-history.md) ve diğer tüm uygulamalarda hemen kullanılabilir olur. Tıklamayı tercih ederseniz bir araç çubuğu düğmesi de vardır.

**Download Video**, `Alt + Shift + D` ile baktığınız sayfada oynayan videoyu yakalar. URL'yi [yt-dlp](https://github.com/yt-dlp/yt-dlp) aracına iletir, bu yüzden YouTube'dan çok daha fazlasında çalışır ve indirme `~/Videos` içine düşer. İlerleme, ses ve parlaklığın kullandığı aynı ekran görüntüsünde gösterilir; bildirimleri üst üste yığmak yerine yerinde güncellenir. Dosyaların başka bir yere gitmesini isterseniz `OMARCHY_YTDLP_DIR` değişkenini ayarlayın — ortam değişkenlerini nereye koyacağınız için [SSS](46-faq.md) bölümüne bakın.

Her iki uzantı da Omarchy ile, tarayıcıyla birlikte sizin için kurulan küçük bir yerel mesajlaşma ana bilgisayarı aracılığıyla konuşur. Bu, bir web sayfasının videosunun ana dizininize ve bir URL'nin pano yöneticinize ulaşmasını sağlayan parçadır; bunu normal bir uzantı kendi başına yapamaz.

Bunlar yalnızca Chromium ailesine özeldir. Firefox ve Zen bunları almaz.

## Firefox ve Zen

Firefox ve Zen farklı bir ailedir, bu yüzden farklı muamele görürler: Omarchy, mantıklı varsayılanlar için bir ilkeler dosyası kurar ve onları yerel Wayland moduna geçirir; bunu kesirli ölçekleme ve akıcı dokunmatik yüzey kaydırma için istersiniz.

Yukarıdaki Chromium uzantılarını almazlar ve Omarchy tarafından temalandırılmazlar, bu yüzden deneyimin bu kısımlarını ayarlamak size kalmıştır.

## Birini yeniden kaldırmak

Burada kurduğunuz her şey _Kaldır > Browser_ altından geri kaldırılabilir. Chromium bu listede değildir — temel sistemin bir parçasıdır.
