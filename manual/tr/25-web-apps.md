# Web Uygulamaları

Omarchy menüsündeki (`Super + Space`) _Yükle > Web Uygulaması_ seçeneğini kullanarak kendi web uygulamalarınızı ekleyebilirsiniz. Sizden uygulama adını, uygulama URL'sini ve favicon aracılığıyla alamazsa simge URL'sini isteyecektir. Birçok popüler web uygulaması için harika PNG simgelerini [Dashboard Icons](https://dashboardicons.com) adresinde bulabilirsiniz.

Bunlara daha sonra uygulama başlatıcı (`Super + Space`) üzerinden erişilebilecek ve güzel çerçevesiz web uygulaması penceresini kullanacaklar.

Bir web uygulamasını kaldırmak isterseniz, Omarchy menüsünde _Kaldır > Web Uygulaması_ seçeneğine gitmeniz yeterli.

Web uygulaması kısayollarını kullanmadan önce tüm hesaplarınıza normal bir tarayıcıyla giriş yapmanız en iyisidir. İnce sarmalayıcı çerçeve 1password ile iyi çalışmıyor, bu yüzden önce doğrudan giriş yapmış olmak daha kolay.

Bu web uygulamalarına ait tüm klavye kısayolları `~/.config/hypr/bindings.lua` dosyasında değiştirilebilir.

Bir web uygulamasındayken, `Shift + Alt + L` kullanarak mevcut URL'yi panoya kopyalayabilirsiniz.

Varsayılan olarak, Omarchy zaten çeşitli varsayılan uygulamalarla birlikte geliyor:

## HEY

[HEY](https://www.hey.com/), Gmail, Outlook veya Apple Mail'den bıkmış kişiler için harika bir alternatif sunan bir e-posta ve takvim hizmetidir. Omarchy'nin ortaya çıktığı yer olan [37signals](https://37signals.com/) tarafından yapılmıştır.

HEY Email'i `Super + Shift + E` kullanarak başlatabilir, `Super + Shift + Alt + E` kullanarak doğrudan yeni bir e-posta oluşturmaya atlayabilir ve HEY Calendar'ı `Super + Shift + C` kullanarak başlatabilirsiniz.

## Basecamp

[Basecamp](https://basecamp.com/), küçük ekiplerin daha hızlı hareket etmesine ve daha fazla ilerleme kaydetmesine yardımcı olan bir proje yönetimi hizmetidir. Trello, Slack, Asana, Notion veya her neyse, bunların yamalı bir karmasını bir araya getirmek yerine, Basecamp ile hepsini tek bir yerde bulabilirsiniz. Omarchy'nin ortaya çıktığı yer olan [37signals](https://37signals.com/) tarafından yapılmıştır.

Basecamp'i uygulama başlatıcıyı (`Super + Space`) kullanarak başlatabilirsiniz

## ChatGPT

[ChatGPT](https://chatgpt.com), dünyanın en popüler AI sohbet botudur.

ChatGPT'yi `Super + Shift + A` kullanarak başlatabilirsiniz.

## Grok

[Grok](https://grok.com), xAI'nin sohbet botudur.

Grok'u `Super + Shift + Alt + A` kullanarak başlatabilirsiniz.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/), dünyanın en popüler mesajlaşma hizmetlerinden biridir ve web sürümü Linux için harika bir seçenektir.

WhatsApp'ı `Super + Shift + Alt + G` kullanarak başlatabilirsiniz.

## Google uygulamaları

Google Messages, Google Photos, Google Maps ve Google Contacts da web uygulamaları olarak dahildir.

Google Messages'ı `Super + Shift + Ctrl + G` kullanarak, Google Photos'u `Super + Shift + P` kullanarak ve Google Maps'i `Super + Shift + S` kullanarak başlatabilirsiniz. Google Contacts'a uygulama başlatıcı (`Super + Space`) üzerinden erişilebilir.

## X

X, haberlerin patladığı yerdir.

X'i `Super + Shift + X` kullanarak başlatabilir ve `Super + Shift + Alt + X` ile doğrudan yeni bir gönderi yazmaya gidebilirsiniz.

## YouTube

[YouTube](https://youtube.com/), dünyanın en popüler video platformudur.

YouTube'u `Super + Shift + Y` kullanarak başlatabilirsiniz.

## Zoom

[Zoom](https://zoom.us/), US'de kullanılan en popüler görüntülü sohbet sistemidir. Dünya genelinde harika bağlantılar. Ve ücretli bir hesap olmadan 40 dakikalık toplantılar yapılabilir. Omarchy, Zoom'un web istemcisini sarmalar ve zoom toplantı bağlantıları doğrudan orada açılır.

Zoom'u uygulama başlatıcıyı (`Super + Space`) kullanarak başlatırsınız.

## Discord

[Discord](https://discord.com/), [Omarchy'nin kendi topluluğu](https://discord.gg/tXFUdasqhY) da dahil olmak üzere çoğu oyun ve açık kaynak topluluğunun takıldığı yerdir.

Discord'u uygulama başlatıcıyı (`Super + Space`) kullanarak başlatırsınız.

## Microsoft uygulamaları

Outlook, Word, Excel, PowerPoint, Teams ve OneDrive'ı web uygulamaları olarak eklemek için _Yükle > Hizmet > Microsoft_ seçeneğini seçin. Her uygulamanın kendi başlatıcısı vardır ve ticari Microsoft 365 URL'lerini ve mevcut tarayıcı profilinizi kullanarak doğrudan açılır. Omarchy'nin diğer web uygulamalarıyla aynı tarayıcı uygulaması pencerelerinde açılırlar; ayrı Teams for Linux istemcisini kurmazlar.

Paketi _Kaldır > Hizmet > Microsoft_ ile kaldırın veya tek tek uygulamaları _Kaldır > Web Uygulaması_ ile kaldırın. İstediğiniz uygulamaları _Yükle > Web Uygulaması_ üzerinden tek başlarına da kurabilirsiniz.

Devlet veya egemen bir bulut için, kuruluşunuz tarafından sağlanan URL'yi kullanarak `~/.local/share/applications/` altındaki ilgili başlatıcıda, örneğin `Microsoft Teams.desktop` dosyasında, `Exec=` satırındaki URL'yi düzenleyin. O satırdaki herhangi bir gerçek `%` karakterini `%%` olarak yazın. Değişiklikler bir sonraki başlatmada uygulanır. Paket yükleyiciyi tekrar çalıştırmak, başlatıcılarını varsayılan URL'lerle değiştirir.

İş oturumlarını ayrı tutmak için, her başlatıcının `Exec=` satırına bir tarayıcı veri dizini ekleyin:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Örnek dizini seçtiğiniz mutlak bir yolla değiştirin ve iş oturumlarını aralarında paylaşmak için altı başlatıcının tamamında aynı yolu kullanın. Web uygulamaları, Omarchy'nin seçtiği desteklenen tarayıcıyı kullanır, varsayılan tarayıcı desteklenmediğinde Chrome'a geri döner.
