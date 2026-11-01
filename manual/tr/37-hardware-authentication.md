# Donanım kimlik doğrulaması

### Parmak izi kimlik doğrulaması

Birçok dizüstü bilgisayarla birlikte kimlik doğrulaması yapmak için bir parmak izi sensörü gelir. Bunu Omarchy ile Omarchy menüsünde (`Super + Space`) _Kurulum > Güvenlik > Parmak İzi_ yolunu çalıştırarak kullanabilirsiniz.

Bu, parmak izi paketini kuracak, izinizi alacak, doğrulayacak ve parmak izinizi kilit ekranının (ki bunu `Super + Ctrl + L` ile tetikleyebilirsiniz) kilidini açmak, sudo moduna girmek ve sistem istemlerini yetkilendirmek için kullanmaya hazır olacaksınız.

Kilit ekranı ekranı kapattıktan sonra sensör güç tasarrufu için dinlenmeye geçer, bu yüzden sensöre dokunmadan önce ekranı herhangi bir tuşla ya da dokunmatik yüzeyle uyandırın.

Dizüstü bilgisayarınızın kapağı kapalıyken, parmak izi istemi otomatik olarak atlanır, böylece ulaşamayacağınız bir sensörü beklemek yerine doğrudan parola istemine gidersiniz. Bunun dışında, sensörü olmayan harici bir klavyeyle çalışmanız gerekirse, `sudo` sırasında parmak iziniz istendiğinde `CTRL + C` tuşlarına basmanız yeterli.

Parmak izi kimlik doğrulamasını Omarchy menüsündeki _Kaldır > Güvenlik > Parmak İzi_ bölümünden kaldırabilirsiniz.

### Fido2 kimlik doğrulaması

Bir Fido2 cihazı kullanıyorsanız, onu `sudo` kimlik doğrulaması için Omarchy menüsündeki (`Super + Space`) _Kurulum > Güvenlik > Fido2_ yolunu kullanarak kurabilirsiniz. Ancak bu, bilgisayarınızın kilidini açmayı değil, `sudo` ve sistem yetkilendirme istemlerini kapsar.

Fido2 kimlik doğrulamasını Omarchy menüsündeki _Kaldır > Güvenlik > Fido2_ bölümünden kaldırabilirsiniz.
