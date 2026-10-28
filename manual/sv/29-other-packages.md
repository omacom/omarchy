# Andra paket

Arch har en fantastisk rikedom av paket tillgängliga för nästan vilken typ av programvara som helst mellan det officiella repositoryt och Arch User Repository (AUR).

Det kunde inte vara enklare att använda heller. Du installerar ett nytt Arch-paket genom att gå till _Installera > Package_ i Omarchy-menyn (`Super + Space`) och skriva paketet du vill ha. Det filtrerar automatiskt fuzzy listan över alla paket. (Du kan också göra det manuellt med `omarchy pkg add [package]` i terminalen).

Du kan göra samma sak med AUR, använd bara _Installera > AUR_. Kom bara ihåg att AUR inte granskas av Arch-teamet. Det är som RubyGems eller npm. Vem som helst kan ladda upp.

Om du vill ta bort ett paket kan du använda _Ta bort > Package_ från Omarchy-menyn. Det tar bort paket, config-filer och beroenden. (Du kan också göra det manuellt med `omarchy pkg drop [package]`).
