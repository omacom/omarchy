# Hardwarové ověřování

### Ověřování otiskem prstu

Řada notebooků má snímač otisků prstů. V Omarchy ho nastavíte v nabídce _Nastavení > Zabezpečení > Otisk prstu_ (`Super + Space`).

Průvodce nainstaluje potřebný balíček, sejme váš otisk a ověří ho. Potom ho můžete používat k odemykání obrazovky (zamknete ji pomocí `Super + Ctrl + L`), získání oprávnění správce přes sudo a potvrzování systémových výzev.

Když zamykací obrazovka vypne displej, snímač přejde do úsporného režimu. Než k němu přiložíte prst, probuďte obrazovku libovolnou klávesou nebo touchpadem.

Při zavřeném víku notebooku se ověření otiskem automaticky přeskočí a rovnou můžete zadat heslo. Nemusíte tak čekat na snímač, ke kterému se nedostanete. Pokud pracujete na externí klávesnici bez snímače, můžete výzvu k ověření otiskem při použití `sudo` přeskočit stisknutím `CTRL + C`.

Ověřování otiskem prstu odeberete v nabídce _Odebrat > Zabezpečení > Otisk prstu_.

### Ověřování pomocí FIDO2

Zařízení FIDO2 můžete nastavit pro ověřování `sudo` v nabídce _Nastavení > Zabezpečení > Fido2_ (`Super + Space`). Tato možnost funguje pro `sudo` a systémové výzvy k ověření, nikoli pro odemykání obrazovky.

Ověřování pomocí FIDO2 odeberete v nabídce _Odebrat > Zabezpečení > Fido2_.
