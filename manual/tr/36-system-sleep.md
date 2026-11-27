# Sistem uykusu

Omarchy varsayılan olarak askıya almayı, kurulduktan sonra da hazırda bekletmeyi etkinleştirir, ancak makinenizde ikisiyle de sorun yaşıyorsanız bunları kapatabilirsiniz.

DGX Spark ve ASUS Ascent GX10 gibi NVIDIA GB10 makinelerinde, NVIDIA'nın DGX OS'unda olduğu gibi askıya alma ve hazırda bekletme kapalıdır, çünkü uykunun bu donanımda çalıştığı henüz gösterilmemiştir. Askıya alma anahtarı ve hazırda bekletme kurulumu orada geçerli değildir. Uykuyu tekrar açmak için `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` dosyasını `sudo rm` ile kaldırın; Askıya Al menüye geri döner ve hazırda bekletme diğer makinelerdeki gibi kurulabilir. `sudo omarchy apply hardware --install-user "$USER"` komutunu çalıştırmak dosyayı geri koyar.

### Güç profilleri

Bir dizüstü bilgisayarda Omarchy, güç profilinizi prize takılı olma ve pilde çalışma durumları için ayrı ayrı hatırlar ve fişi takıp çıkardıkça ikisi arasında geçiş yapar. Kutudan çıktığı haliyle bu, AC'de performans ve pilde dengeli anlamına gelir.

Makinenizin neler sunduğunu `omarchy powerprofiles list` ile görebilir, şu anda içinde olduğunuz durum için istediğinizi `omarchy powerprofiles set autodetect power-saver` ile ayarlayabilirsiniz. Hiçbir şeyin fişini çekmeden diğer durumu ayarlamak için doğrudan adını verin: `omarchy powerprofiles set battery power-saver`. Ne seçerseniz, bir sonraki sefer o durumda olduğunuzda alacağınız şey odur.

### Askıya almayı açıp kapatma

Askıya almayı terminalden `omarchy toggle suspend` komutunu çalıştırarak açıp kapatırsınız. Bu yalnızca _Sistem_ altındaki seçeneği gösterir/gizler (veya `Super + Esc`), ardından sisteminizde tutarlı çalışıp çalışmadığını görebilirsiniz. Çalışmıyorsa aynı komutla tekrar gizleyebilirsiniz.

### Hazırda bekletmeyi açıp kapatma

Hazırda bekletmeyi terminalden `omarchy hibernation setup` komutunu çalıştırarak kurarsınız (Apple Silicon Mac'lerde kullanılamaz). Hazırda bekletme, önyükleme sürücünüzde fiziksel RAM tahsisinizin boyutunda bir /swap alt birimi oluşturur, bu yüzden bolca boş alanınız olduğundan emin olun. 32GB bir makinede bu birim için her zaman 32GB+ boş alana ihtiyacınız olur. Hazırda bekletme ayrıca varsayılan Limine önyükleyicisini gerektirir.

Kurulduğunda hazırda bekletme seçeneğini _Sistem_ altında (veya `Super + Esc`) görürsünüz, ardından sisteminizde tutarlı çalışıp çalışmadığını görebilirsiniz. Çalışmıyorsa `omarchy hibernation remove` komutunu çalıştırarak tekrar kaldırabilirsiniz.
