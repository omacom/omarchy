# Hardwarové ověřování

### Ověřování otiskem prstu

Spousta notebooků je vybavena senzorem otisku prstu k ověřování. V Omarchy ho můžete používat tak, že v nabídce Omarchy (`Super + Space`) spustíte _Setup > Security > Fingerprint_.

Otevře se otisk prstu přes celou obrazovku, který se postupně vyplňuje, jak přikládáte prst na senzor. Na pozadí Omarchy nainstaluje balíček pro otisk prstu, zaznamená váš otisk, ověří ho a budete mít vše připravené, abyste otisk prstu mohli používat k odemykání ze zamykací obrazovky (kterou vyvoláte pomocí `Super + Ctrl + L`), ke vstupu do režimu sudo a k autorizaci systémových výzev.

Jakmile zamykací obrazovka vypne displej, senzor kvůli úspoře energie odpočívá, takže před přiložením prstu probuďte obrazovku libovolnou klávesou nebo touchpadem.

Když je víko notebooku zavřené, výzva k otisku prstu se automaticky přeskočí, takže přejdete rovnou na výzvu k zadání hesla místo čekání na senzor, na který nemůžete dosáhnout. Pokud jinak potřebujete pracovat na externí klávesnici, která senzor nemá, stačí při výzvě k otisku prstu během `sudo` stisknout `CTRL + C`.

Ověřování otiskem prstu můžete odstranit v nabídce Omarchy pod _Remove > Security > Fingerprint_.

### Ověřování pomocí Fido2

Pokud používáte zařízení Fido2, můžete ho nastavit pro ověřování `sudo` pomocí _Setup > Security > Fido2_ v nabídce Omarchy (`Super + Space`). Pokrývá však `sudo` a výzvy k autorizaci systému, nikoli odemykání počítače.

Ověřování pomocí Fido2 můžete odstranit v nabídce Omarchy pod _Remove > Security > Fido2_.
