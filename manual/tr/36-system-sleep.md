# Sistem uykusu

Omarchy varsayılan olarak askıya almayı ve hazırda bekletmeyi etkinleştirir, ancak makinenizde ikisinden biriyle sorun yaşıyorsanız, bunları kapatabilirsiniz.

NVIDIA GB10 makinelerinde, DGX Spark ve ASUS Ascent GX10 gibi, askıya alma ve hazırda bekletme kapalıdır, NVIDIA'nın DGX OS'unda olduğu gibi, çünkü uykunun bu donanımda henüz çalıştığı gösterilmemiştir. Aynı şey ASUS Zenbook A16 (UX3607OA) için de geçerlidir; burada askıya alma çipi henüz tam olarak uyutmuyor ve gece boyunca takılıp kalabiliyor. Askıya alma açma/kapatma ve hazırda bekletme kurulumu orada uygulanmaz. Uykuyu tekrar açmak için `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` dosyasını `sudo rm` ile kaldırın; Askıya Al seçeneği menüye geri döner ve hazırda bekletme diğer makinelerde olduğu gibi kurulabilir. `sudo omarchy apply hardware --install-user "$USER"` komutunu çalıştırmak dosyayı geri koyar.

### Güç profilleri

Bir dizüstü bilgisayarda, Omarchy güç profilinizi prize takılı ve pilde çalışma için ayrı ayrı hatırlar ve fişi takıp çıkardıkça ikisi arasında geçiş yapar. Kutudan çıktığı haliyle bu, AC'de performans ve pilde dengeli anlamına gelir.

Makinenizin neler sunduğunu `omarchy powerprofiles list` ile görebilirsiniz ve şu anda içinde bulunduğunuz durum için istediğinizi `omarchy powerprofiles set autodetect power-saver` ile ayarlayabilirsiniz. Diğer durumu hiçbir şeyin fişini çekmeden ayarlamak için doğrudan adını belirtin: `omarchy powerprofiles set battery power-saver`. Ne seçerseniz, bir sonraki sefer o durumda olduğunuzda geri alacağınız şey odur.

### Askıya almayı aç/kapat

Askıya almayı terminalden `omarchy toggle suspend` çalıştırarak açıp kapatırsınız. Bu sadece _System_ (veya `Super + Esc`) altındaki seçeneği gösterir/gizler ve sonra sisteminizde tutarlı çalışıp çalışmadığını görebilirsiniz. Çalışmazsa, aynı komutla tekrar gizleyebilirsiniz.

### Hazırda bekletmeyi aç/kapat

Hazırda bekletmeyi terminalden `omarchy hibernation setup` çalıştırarak kurarsınız. Hazırda bekletme, önyükleme sürücünüzde fiziksel RAM tahsisinizin boyutunda bir /swap alt birimi oluşturur, bu yüzden bolca boş alanınız olduğundan emin olun. 32GB'lık bir makinede, bu birim için her zaman 32GB+ boş alana ihtiyacınız olacaktır. Hazırda bekletme ayrıca varsayılan Limine önyükleyicisini gerektirir.

Kurulduğunda, hazırda bekletme seçeneğini _System_ (veya `Super + Esc`) altında göreceksiniz ve sonra sisteminizde tutarlı çalışıp çalışmadığını görebilirsiniz. Çalışmazsa, `omarchy hibernation remove` çalıştırarak tekrar kaldırabilirsiniz.
