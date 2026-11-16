# Θέματα

Το Omarchy έρχεται με είκοσι δύο όμορφα θέματα. Μπορείτε να επιλέξετε μεταξύ τους μέσω _Appearance > Theme_ στο Omarchy Menu (`Super + Space`) ή να μεταβείτε απευθείας στον επιλογέα θέματος χρησιμοποιώντας `Super + Ctrl + T`.

Κάθε θέμα διαμορφώνει την επιφάνεια εργασίας, το τερματικό, το neovim, την οθόνη δραστηριότητας (btop), το Chromium και ολόκληρο το κέλυφος του Omarchy: την επάνω γραμμή, το μενού, τις ειδοποιήσεις, το OSD και την οθόνη κλειδώματος. (Για το Obsidian, πρέπει να επιλέξετε χειροκίνητα το θέμα του Omarchy μέσω _Appearance > Themes_ μέσα στην εφαρμογή).

Τα θέματα διαθέτουν ένα σύνολο εικόνων φόντου, μεταξύ των οποίων μπορείτε να επιλέξετε χρησιμοποιώντας `Super + Ctrl + W`.

Μπορείτε να βρείτε ακόμα περισσότερα θέματα στη [σελίδα με τα επιπλέον θέματα](https://omarchy.org/themes/) ή ακόμα και να [δημιουργήσετε το δικό σας θέμα](43-making-your-own-theme.md).

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

### Εικονίδια εφαρμογών

Τα εικονίδια στον εκκινητή εφαρμογών και στο dock σχεδιάζονται στα χρώματα του θέματός σας, οπότε αλλάζουν μαζί με αυτό. Προέρχονται από ένα σύνολο εικονιδίων, το οποίο επιλέγετε ξεχωριστά από το θέμα κάτω από το _Appearance > Icons_, από προεπισκοπήσεις κάθε συνόλου, με τον ίδιο τρόπο που επιλέγετε ένα θέμα:

- _Papercraft_ είναι το προεπιλεγμένο: όλα όσα είναι εγκατεστημένα, σχεδιασμένα σε ένα στυλ. Οι εφαρμογές που είναι γνωστές από το λογότυπό τους, όπως το Chrome, το HEY ή το YouTube, διατηρούν το σχήμα του και παίρνουν τα χρώματα του θέματος.
- _Arcade_ σχεδιάζει τις ίδιες εφαρμογές ως pixel art 8-bit, όπως θα έκανε μια παλιά κονσόλα παιχνιδιών.
- _Original_ εμφανίζει κάθε εφαρμογή με το εικονίδιο που της έδωσε ο δημιουργός της.

Μπορείτε να εγκαταστήσετε ένα σύνολο εικονιδίων που έχει δημιουργήσει κάποιος άλλος με το _Install > Style > Icons_ (ή `omarchy icons install <git url>`), και να το αφαιρέσετε πάλι κάτω από το _Remove > Icons_. Το _Update > Extra Icons_ ανακτά την τελευταία έκδοση των συνόλων που έχετε εγκαταστήσει.

Για να δημιουργήσετε το δικό σας, τοποθετήστε τα εικονίδιά σας στο `~/.config/omarchy/icons/<name>/`, ένα αρχείο ανά εφαρμογή, με όνομα από τη γραμμή `Icon=` του αρχείου `.desktop` της εφαρμογής. Ένα αρχείο που τελειώνει σε `.svg` εμφανίζεται όπως είναι. Ένα αρχείο που τελειώνει σε `.svg.tpl` σχεδιάζεται στα χρώματα του θέματος: γράψτε `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ή `{{ icon_shadow }}` όπου μπαίνει ένα χρώμα. Το προεπιλεγμένο σύνολο στο `/usr/share/omarchy/icons/papercraft/` είναι ένα καλό σημείο για να ξεκινήσετε. Προσθέστε ένα `preview.png` για να εμφανίζεται το σύνολό σας στον επιλογέα· χωρίς αυτό, το Omarchy σχεδιάζει μια προεπισκόπηση από τα εικονίδιά σας. Για να αλλάξετε ένα μόνο εικονίδιο του προεπιλεγμένου συνόλου, τοποθετήστε τη δική σας έκδοση στο `~/.config/omarchy/icons/papercraft/`.

### Ξεκλειδώματα

Τα θέματα μπορούν επίσης να έχουν έναν προσαρμοσμένο σχεδιασμό ξεκλειδώματος, ο οποίος χρησιμοποιείται για τη διαδικασία αποκρυπτογράφησης κατά την εκκίνηση. Μπορείτε να επιλέξετε έναν από αυτούς κάτω από το _Appearance > Unlock_. Μοιάζουν κάπως έτσι:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
