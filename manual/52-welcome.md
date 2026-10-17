# Moving from macOS

Open **Setup → Welcome** in the Omarchy menu, or run `omarchy setup welcome`, to work through an optional guide to iCloud, email, local files, shortcuts, and everyday apps.

Every step is optional. Your checklist stays on this device and you can return to it later. The wizard can create and remove iCloud Drive, Photos, Mail, Calendar, and Notes app shortcuts. Sign in directly on Apple’s website. These shortcuts provide web access, not a filesystem mount or background sync.

The email step explains iCloud Mail setup in a desktop client and can open Thunderbird when installed. Credentials belong in the mail client or Apple’s website; the wizard never asks for them. Keep your original Mac and backup until you have verified your documents, exported photos, local mailboxes, and important logins.

The guide opens your existing Files, Setup, and shortcut reference tools. It does not change your keyboard configuration, install packages, copy data, or disable Advanced Data Protection.

**Finish for now** saves your checklist even if some tasks remain. You can also download a text copy. To reset progress, remove `state.json` from `$XDG_STATE_HOME/omarchy-wizard` (normally `~/.local/state/omarchy-wizard`). Remove iCloud shortcuts with their individual buttons in the wizard; your Apple data is unaffected.
