# Θέματα

Το Omarchy συνοδεύεται από είκοσι τρία όμορφα θέματα. Μπορείτε να επιλέξετε ανάμεσά τους μέσω του _Appearance > Theme_ στο Omarchy Menu (`Super + Space`) ή να μεταβείτε απευθείας στον επιλογέα θέματος χρησιμοποιώντας `Super + Ctrl + T`.

Κάθε θέμα διαμορφώνει το στυλ της επιφάνειας εργασίας, του τερματικού, του neovim, της οθόνης δραστηριότητας (btop), του προγράμματος περιήγησής σας (Chrome, Chromium, Edge ή Brave) και ολόκληρου του κελύφους του Omarchy: επάνω γραμμή, μενού, ειδοποιήσεις, OSD και οθόνη κλειδώματος. (Για το Obsidian, πρέπει να επιλέξετε χειροκίνητα το θέμα Omarchy μέσω του _Appearance > Themes_ μέσα στην εφαρμογή).

Τα θέματα διαθέτουν ένα σύνολο εικόνων φόντου, ανάμεσα στις οποίες μπορείτε να επιλέξετε χρησιμοποιώντας `Super + Ctrl + W`.

Μπορείτε να βρείτε ακόμη περισσότερα θέματα στη [σελίδα με τα επιπλέον θέματα](https://omarchy.org/themes/) ή ακόμη και να [δημιουργήσετε το δικό σας θέμα](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### Εικονίδια εφαρμογών

Τα εικονίδια στην εφαρμογή εκκίνησης και στην μπάρα εφαρμογών σχεδιάζονται στα χρώματα του θέματός σας, οπότε αλλάζουν μαζί με αυτό. Προέρχονται από ένα σύνολο εικονιδίων, το οποίο επιλέγετε ξεχωριστά από το θέμα στην επιλογή _Appearance > Icons_, από προεπισκοπήσεις κάθε συνόλου, με τον ίδιο τρόπο που επιλέγετε ένα θέμα:

- Το _Papercraft_ είναι το προεπιλεγμένο: όλα όσα έρχονται εγκατεστημένα, σχεδιασμένα σε ένα στυλ. Οι εφαρμογές που είναι γνωστές από το λογότυπό τους, όπως το Chrome, το HEY ή το YouTube, διατηρούν το σχήμα τους και παίρνουν τα χρώματα του θέματος.
- Το _Arcade_ σχεδιάζει τις ίδιες εφαρμογές ως pixel art 8-bit, όπως θα έκανε μια παλιά κονσόλα παιχνιδιών.
- Το _Original_ εμφανίζει κάθε εφαρμογή με το εικονίδιο που της έδωσε ο δημιουργός της.

Μπορείτε να εγκαταστήσετε ένα σύνολο εικονιδίων που έχει δημιουργήσει κάποιος άλλος με την επιλογή _Install > Style > Icons_ (ή `omarchy icons install <git url>`) και να το αφαιρέσετε ξανά από την επιλογή _Remove > Icons_. Η επιλογή _Update > Extra Icons_ λαμβάνει την πιο πρόσφατη έκδοση των συνόλων που έχετε εγκαταστήσει.

Για να δημιουργήσετε το δικό σας, τοποθετήστε τα εικονιδιά σας στο `~/.config/omarchy/icons/<name>/`, ένα αρχείο ανά εφαρμογή, με όνομα από τη γραμμή `Icon=` του αρχείου `.desktop` της εφαρμογής. Ένα αρχείο που τελειώνει σε `.svg` εμφανίζεται ως έχει. Ένα αρχείο που τελειώνει σε `.svg.tpl` σχεδιάζεται στα χρώματα του θέματος: γράψτε `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ή `{{ icon_shadow }}` όπου μπαίνει ένα χρώμα. Το προεπιλεγμένο σύνολο στο `/usr/share/omarchy/icons/papercraft/` είναι ένα καλό μέρος για να ξεκινήσετε. Προσθέστε ένα `preview.png` για να εμφανίζεται το σύνολό σας στον επιλογέα· χωρίς αυτό, το Omarchy σχεδιάζει μια προεπισκόπηση από τα εικονιδιά σας. Για να αλλάξετε ένα μόνο εικονίδιο του προεπιλεγμένου συνόλου, τοποθετήστε την εκδοχή σας στο `~/.config/omarchy/icons/papercraft/`.

### Εκκίνηση και σύνδεση

Η οθόνη που ζητά τον κωδικό πρόσβασης του δίσκου σας όταν ξεκινά ο υπολογιστής και η οθόνη σύνδεσης ακολουθούν και αυτές το θέμα. Κάθε φορά που αλλάζετε θέματα, παίρνουν το φόντο, το κείμενο, το χρώμα έμφασης και τα κόκκινα χρώματά του, οπότε δεν υπάρχει ξεχωριστός σχεδιασμός ξεκλειδώματος για να επιλέξετε. Σε Mac με Apple Silicon, η οθόνη κωδικού πρόσβασης του δίσκου διατηρεί την προεπιλεγμένη εμφάνιση του Omarchy όποιο κι αν είναι το θέμα.
