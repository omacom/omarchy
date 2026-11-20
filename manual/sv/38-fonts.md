# Typsnitt

Omarchy använder JetBrainsMono Nerd Font som både terminal- och systemtypsnitt som standard.

 ![fonts-jetbrainsmono](images/fonts-jetbrainsmono.webp)

Du kan ändra detta via menyn _Utseende > Typsnitt_ i Omarchy-menyn (`Super + Space`). Det anger typsnittet med fast bredd överallt: i terminalen, i listen och i allt annat som efterfrågar det.

Du kan installera andra populära programmeringstypsnitt via _Installera > Stil > Typsnitt_ i Omarchy-menyn: Cascadia Mono, Meslo LG Mono, Fira Code, Victor Code, Bitstream Vera Mono och Iosevka finns alla ett klick bort, i sina Nerd Font-versioner så att glyferna i listen och terminalen fortsätter att fungera. När du har installerat ett väljer du det under _Utseende > Typsnitt_.

## Kinesiska, japanska och koreanska

Kinesiska, japanska och koreanska delar många tecken men ritar några av dem olika, så samma tecken ser rätt ut för en läsare och främmande ut för en annan. Om du väljer ett av dessa språk under _Inställningar > Region > Språk_, eller dess inmatningsmetod, ställs de matchande formerna in. För att välja dem själv kör du `omarchy font cjk jp`, `kr`, `sc`, `tc` (Taiwan) eller `hk` (Hong Kong) i en terminal; `omarchy font cjk default` går tillbaka till systemets val, vilket är japanska former. Text som en webbsida eller ett dokument märker med sitt eget språk, och hela skrivbordet medan det är på ett av dessa språk, behåller det språkets former.
