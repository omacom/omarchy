# Andre pakker

Arch har en fantastisk rigdom af pakker tilgængelige til næsten enhver type software mellem det officielle repository og Arch User Repository (AUR).

Det kunne heller ikke være nemmere at bruge. Du installerer en ny Arch-pakke ved at gå til _Installer > Package_ i Omarchy-menuen (`Super + Space`) og skrive den pakke, du ønsker. Den vil automatisk fuzzy-filtrere listen over alle pakker. (Du kan også gøre det manuelt ved hjælp af `omarchy pkg add [package]` i terminalen).

Du kan gøre det samme med AUR, brug bare _Installer > AUR_. Bare husk, at AUR ikke er kontrolleret af Arch-teamet. Det er ligesom RubyGems eller npm. Enhver kan uploade.

Hvis du vil fjerne en pakke, kan du bruge _Fjern > Package_ fra Omarchy-menuen. Den vil fjerne pakke, konfigurationsfiler og afhængigheder. (Du kan også gøre det manuelt ved hjælp af `omarchy pkg drop [package]`).
