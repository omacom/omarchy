# Sistem uykusu

Omarchy varsayılan olarak askıya almayı, kurulduktan sonra da hazırda bekletmeyi etkinleştirir, ancak makinenizde ikisinden biriyle sorun yaşıyorsanız bunları kapatabilirsiniz.

DGX Spark ve ASUS Ascent GX10 gibi NVIDIA GB10 makinelerinde, NVIDIA'nın DGX OS'unda olduğu gibi askıya alma ve hazırda bekletme kapalıdır, çünkü uykunun o donanımda çalıştığı henüz gösterilmemiştir. Aynı durum, askıya almanın çipi henüz tam olarak uyutamadığı ve gece boyunca takılıp kalabildiği ASUS Zenbook A16 (UX3607OA) için de geçerlidir. Askıya almayı açıp kapatma ve hazırda bekletme kurulumu orada geçerli değildir. Uykuyu tekrar açmak için `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` dosyasını `sudo rm` ile kaldırın; Askıya al seçeneği daha sonra menüye geri döner ve hazırda bekletme diğer makinelerdeki gibi kurulabilir. `sudo omarchy apply hardware --install-user "$USER"` komutunu çalıştırmak dosyayı geri koyar.

### Güç profilleri

Bir dizüstü bilgisayarda Omarchy, güç profilinizi prize takılı olma ve pille çalışma durumları için ayrı ayrı hatırlar ve siz fişi takıp çıkardıkça ikisi arasında geçiş yapar. Kutudan çıktığı haliyle bu, AC'de performans ve pilde dengeli anlamına gelir.

Makinenizin neler sunduğunu `omarchy powerprofiles list` ile görebilir ve şu anda içinde olduğunuz durum için istediğinizi `omarchy powerprofiles set autodetect power-saver` ile ayarlayabilirsiniz. Hiçbir şeyin fişini çekmeden diğer durumu ayarlamak için doğrudan adını belirtin: `omarchy powerprofiles set battery power-saver`. Neyi seçerseniz, bir sonraki sefer o duruma geçtiğinizde geri alacağınız şey odur.

### Askıya almayı açıp kapatma

Askıya almayı terminalden `omarchy toggle suspend` komutunu çalıştırarak açıp kapatırsınız. Bu yalnızca _Sistem_ (veya `Super + Esc`) altındaki seçeneği gösterir/gizler ve böylece sisteminizde tutarlı bir şekilde çalışıp çalışmadığını görebilirsiniz. Çalışmazsa, aynı komutla tekrar gizleyebilirsiniz.

### Hazırda bekletmeyi açıp kapatma

Hazırda bekletmeyi terminalden `omarchy hibernation setup` komutunu çalıştırarak kurarsınız (Apple Silicon Mac'lerde kullanılamaz). Hazırda bekletme, önyükleme sürücünüzde fiziksel RAM tahsisinizin boyutunda bir /swap alt birimi oluşturur, bu yüzden bolca boş alanınız olduğundan emin olun. 32GB'lik bir makinede, bu birim için her zaman 32GB+ boş alana ihtiyacınız olacaktır. Hazırda bekletme ayrıca varsayılan Limine önyükleyicisini gerektirir.

Kurulduğunda, hazırda bekletme seçeneğini _Sistem_ (veya `Super + Esc`) altında görürsünüz ve böylece sisteminizde tutarlı bir şekilde çalışıp çalışmadığını görebilirsiniz. Çalışmazsa, `omarchy hibernation remove` komutunu çalıştırarak tekrar kaldırabilirsiniz.
