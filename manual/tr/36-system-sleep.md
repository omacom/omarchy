# Sistem uykusu

Omarchy varsayılan olarak askıya alma ve hazırda bekletmeyi etkinleştirir, ancak makinenizde bunlardan biriyle sorun yaşıyorsanız, onları kapatabilirsiniz.

### Güç profilleri

Bir dizüstü bilgisayarda Omarchy, güç profilinizi prize takılı ve pille çalışma için ayrı ayrı hatırlar ve takıp çıkardıkça ikisi arasında geçiş yapar. Kutudan çıktığı haliyle bu, AC'de performans ve pilde dengeli anlamına gelir.

Makinenizin neler sunduğunu `omarchy powerprofiles list` ile görebilir ve şu anda bulunduğunuz durum için istediğinizi `omarchy powerprofiles set autodetect power-saver` ile ayarlayabilirsiniz. Hiçbir şeyi çıkarmadan diğer durumu ayarlamak için onu doğrudan adlandırın: `omarchy powerprofiles set battery power-saver`. Ne seçerseniz seçin, bir sonraki sefer o durumda olduğunuzda geri alacağınız şey odur.

### Askıya almayı aç/kapat

Askıya almayı terminalden `omarchy toggle suspend` çalıştırarak açıp kapatırsınız. Bu yalnızca _Sistem_ altındaki (veya `Super + Esc`) seçeneği gösterir/gizler ve ardından sisteminizde tutarlı çalışıp çalışmadığını görebilirsiniz. Çalışmıyorsa, aynı komutla tekrar gizleyebilirsiniz.

### Hazırda bekletmeyi aç/kapat

Hazırda bekletmeyi terminalden `omarchy hibernation setup` çalıştırarak kurarsınız. Hazırda bekletme, önyükleme sürücünüzde fiziksel RAM tahsisiniz boyutunda bir /swap alt birimi oluşturur, bu yüzden bolca boş alanınız olduğundan emin olun. 32GB'lık bir makinede, bu birim için her zaman 32GB'tan fazla boş alana ihtiyacınız olacaktır. Hazırda bekletme ayrıca varsayılan Limine önyükleyicisini gerektirir.

Kurulduğunda, hazırda bekletme seçeneğini _Sistem_ altında (veya `Super + Esc`) görürsünüz ve ardından sisteminizde tutarlı çalışıp çalışmadığını görebilirsiniz. Çalışmıyorsa, `omarchy hibernation remove` çalıştırarak tekrar kaldırabilirsiniz.
