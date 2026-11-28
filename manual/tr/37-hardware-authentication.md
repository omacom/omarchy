# Donanım kimlik doğrulaması

### Parmak izi kimlik doğrulaması

Birçok dizüstü bilgisayar, kimlik doğrulaması yapmak için bir parmak izi sensörüyle gelir. Bunu Omarchy ile, Omarchy menüsünde (`Super + Space`) _Setup > Security > Fingerprint_ yolunu çalıştırarak kullanabilirsiniz.

Bu, sensöre dokundukça dolan tam ekran bir parmak izi açar. Arka planda Omarchy parmak izi paketini kuracak, izinizi alacak, doğrulayacak ve kilit ekranından (ki bunu `Super + Ctrl + L` ile tetikleyebilirsiniz) kilidi açmak, sudo moduna girmek ve sistem istemlerini yetkilendirmek için parmak izinizi kullanmaya hazır olacaksınız.

Kilit ekranı ekranı kapattıktan sonra sensör güç tasarrufu için dinlenmeye geçer, bu yüzden sensöre dokunmadan önce herhangi bir tuşla veya dokunmatik yüzeyle ekranı uyandırın.

Dizüstü bilgisayarınızın kapağı kapalıyken parmak izi istemi otomatik olarak atlanır, böylece ulaşamadığınız bir sensörü beklemek yerine doğrudan parola istemine gidersiniz. Sensörü olmayan harici bir klavyeyle çalışmanız gerekirse, `sudo` sırasında parmak iziniz istendiğinde `CTRL + C` tuşlarına basmanız yeterlidir.

Parmak izi kimlik doğrulamasını Omarchy menüsünde _Remove > Security > Fingerprint_ altından kaldırabilirsiniz.

### Fido2 kimlik doğrulaması

Bir Fido2 cihazı kullanıyorsanız, onu `sudo` kimlik doğrulaması için Omarchy menüsünde (`Super + Space`) _Setup > Security > Fido2_ ile kurabilirsiniz. Ancak bu, bilgisayarınızın kilidini açmayı değil, `sudo` ve sistem yetkilendirme istemlerini kapsar.

Fido2 kimlik doğrulamasını Omarchy menüsünde _Remove > Security > Fido2_ altından kaldırabilirsiniz.
