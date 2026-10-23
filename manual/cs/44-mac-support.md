# Podpora počítačů Mac

Omarchy má vestavěnou podporu pro **počítače Mac s procesorem Intel**. V tuto chvíli existuje pár známých omezení, ale pokud o nich víte a nevadí vám, můžete svým starým počítačům Mac vdechnout nový život právě instalací Omarchy.

Upozorňujeme, že instalace na počítač Mac s čipy řady M zatím není oficiálně podporována. Více o současném stavu zjistíte v kanále #omarchy-on-other na našem serveru [Discord](https://discord.gg/tXFUdasqhY).

V jednoduchém testu se nám pouhou instalací systému Omarchy podařilo dosáhnout na MacBooku Pro z roku 2019 o 36 % vyššího výkonu.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalace systému Omarchy na počítač Mac

Omarchy zatím podporuje pouze to, aby byl **jediným** nainstalovaným operačním systémem. Během instalace se disk vymaže a macOS již nepůjde spustit.

Přesto ho můžete později v případě zájmu obnovit pomocí Internet Recovery.

Pro účely této části budeme předpokládat, že jste si už přečetli část [Začínáme](02-getting-started.md) a máte připravenou jednotku USB. Pokud ne, udělejte to teď.

#### Vypnutí zabezpečeného spouštění

Chcete-li zavést bootovatelné médium USB i operační systém, je nutné vypnout zabezpečené spouštění od společnosti Apple. Vypnete ho následovně:

1. Vypněte počítač Mac
2. Zapněte ho a _ihned_ stiskněte a podržte klávesy Command-R, dokud se nezobrazí obrazovka načítání
3. Vyberte svého uživatele a v případě výzvy zadejte heslo
4. Na obrazovce obnovení zvolte v panelu nabídek **Utility > Startup Security Utility**
5. Po výzvě k ověření zadejte heslo
6. Z možností Secure Boot zvolte „No Security“
7. Z možností External Boot zvolte „Allow booting from external or removable media“

#### Spuštění instalace

1. Vložte jednotku USB
2. Restartujte počítač Mac a _ihned_ stiskněte a podržte klávesu Option, dokud se nezobrazí obrazovka se spouštěcími zařízeními
3. Vyberte oranžové zařízení EFI Boot
4. Pokračujte obvyklou [instalací](02-getting-started.md)

Instalátor rozpozná hardware počítače Mac a automaticky použije potřebné opravy: ovladače a firmware Wi-Fi Broadcom, ovladač klávesnice SPI u modelů MacBook, které ho potřebují, a opravu uspávání NVMe u týchž modelů.

### Známá omezení

Členové komunity neustále pracují na řešení těchto obtíží, takže pokud vám vadí, připojte se ke kanálu #omarchy-on-other na našem serveru [Discord](https://discord.gg/tXFUdasqhY) a zjistěte, zda nejsou k dispozici aktuální postupy k jejich řešení.

#### Zařízení s čipem T1

Čip Apple T1 byl představen koncem roku 2016 a používal se výhradně v modelech MacBook Pro první generace s panelem Touch Bar.
- MacBook Pro 13palcový (2016, dva porty Thunderbolt 3) – model: A1706
- MacBook Pro 13palcový (2016, čtyři porty Thunderbolt 3) – model: A1708
- MacBook Pro 15palcový (2016) – model: A1707

#### Známé problémy

- Panel Touch Bar nefunguje
- Zvuk nefunguje

#### Zařízení s čipem T2

Bezpečnostní čip Apple T2 byl představen v roce 2017. Výroba čipu T2 byla ukončena s přechodem na čipy Apple silicon (čipy řady M) počínaje rokem 2020.

- iMac Pro (2017) – model: A1862
- MacBook Pro 13palcový (2018, čtyři porty Thunderbolt 3) – model: A1989
- MacBook Pro 15palcový (2018) – model: A1990
- MacBook Air (Retina, 13palcový, 2018) – model: A1932
- Mac mini (2018) – model: A1998
- MacBook Pro 13palcový (2019, dva porty Thunderbolt 3) – model: A2159
- MacBook Pro 13palcový (2019, čtyři porty Thunderbolt 3) – model: A2178
- MacBook Pro 15palcový (2019) – model: A1990
- iMac (Retina 5K, 27palcový, 2020) – model: A2115 (iMac20,1 a iMac20,2)
- MacBook Pro 13palcový (2020, dva porty Thunderbolt 3) – model: A2265
- MacBook Pro 15palcový (2020) – model: A1990

U těchto modelů instalátor automaticky nastaví upravené jádro `linux-t2`, konfiguraci zvuku T2, firmware Broadcom Wi-Fi/Bluetooth od společnosti Apple a ovládání ventilátoru pomocí `t2fanrd`. Panel Touch Bar běží na vestavěné podpoře ve stylu Boot Camp, kterou nabízí jádro.
