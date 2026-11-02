# Hardwarové ověřování

### Ověřování otiskem prstu

Spousta notebooků se dodává se snímačem otisků prstů pro ověřování. V Omarchy ho můžeš používat spuštěním _Nastavení > Zabezpečení > Otisk prstu_ v nabídce Omarchy (`Super + Space`).

Nainstaluje to balíček pro otisky prstů, sejme tvůj otisk, ověří ho a budeš připravený používat svůj otisk prstu k odemykání ze zamykací obrazovky (kterou můžeš vyvolat pomocí `Super + Ctrl + L`), vstupování do režimu sudo a autorizování systémových výzev.

Jakmile zamykací obrazovka vypne displej, snímač odpočívá, aby šetřil energii, takže předtím, než se ho dotkneš, probuď obrazovku libovolnou klávesou nebo touchpadem.

Když je víko notebooku zavřené, výzva k otisku prstu se automaticky přeskočí, takže jdeš rovnou na výzvu k zadání hesla místo čekání na snímač, na který nedosáhneš. Pokud jinak potřebuješ pracovat na externí klávesnici, která snímač nemá, prostě stiskni `CTRL + C`, když tě během `sudo` vyzve k otisku prstu.

Ověřování otiskem prstu můžeš odebrat pod _Odebrat > Zabezpečení > Otisk prstu_ v nabídce Omarchy.

### Ověřování pomocí Fido2

Pokud používáš zařízení Fido2, můžeš ho nastavit pro ověřování `sudo` pomocí _Nastavení > Zabezpečení > Fido2_ v nabídce Omarchy (`Super + Space`). Pokrývá to ale `sudo` a systémové autorizační výzvy, ne odemykání počítače.

Ověřování fido2 můžeš odebrat pod _Odebrat > Zabezpečení > Fido2_ v nabídce Omarchy.
