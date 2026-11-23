# সিস্টেম স্লিপ

Omarchy ডিফল্টভাবে suspend সক্রিয় রাখে, আর সেট আপ করা হয়ে গেলে hibernation-ও, কিন্তু আপনার মেশিনে এর কোনো একটিতে সমস্যা হলে আপনি সেগুলো বন্ধ করে দিতে পারেন।

NVIDIA GB10 মেশিনগুলোতে, যেমন DGX Spark এবং ASUS Ascent GX10, suspend এবং hibernation বন্ধ থাকে, যেমন NVIDIA-র DGX OS-এও থাকে, কারণ ওই hardware-এ sleep এখনও কাজ করে বলে দেখা যায়নি। ASUS Zenbook A16 (UX3607OA)-এর ক্ষেত্রেও একই কথা, যেখানে suspend এখনও chip-কে পুরোপুরি ঘুম পাড়ায় না এবং রাতভর hang হয়ে থাকতে পারে। সেখানে suspend toggle এবং hibernation সেট আপ প্রযোজ্য নয়। Sleep আবার চালু করতে, `sudo rm` দিয়ে `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` সরিয়ে ফেলুন; তাহলে Suspend মেনুতে ফিরে আসবে, এবং অন্য মেশিনগুলোর মতোই hibernation সেট আপ করা যাবে। `sudo omarchy apply hardware --install-user "$USER"` চালালে ফাইলটি আবার ফিরে আসে।

### পাওয়ার প্রোফাইলগুলো

ল্যাপটপে, Omarchy প্লাগ ইন করা থাকার জন্য এবং ব্যাটারিতে চলার জন্য আপনার power profile আলাদাভাবে মনে রাখে, এবং আপনি প্লাগ ইন ও আনপ্লাগ করার সাথে সাথে দুটির মধ্যে বদলে দেয়। ডিফল্টভাবে এর মানে হলো AC-তে performance এবং ব্যাটারিতে balanced।

আপনার মেশিনে কী কী আছে তা আপনি `omarchy powerprofiles list` দিয়ে দেখতে পারেন, এবং আপনি বর্তমানে যে অবস্থায় আছেন তার জন্য যেটি চান সেটি `omarchy powerprofiles set autodetect power-saver` দিয়ে সেট করতে পারেন। কোনো কিছু আনপ্লাগ না করে অন্য অবস্থাটি সেট করতে, সরাসরি তার নাম দিন: `omarchy powerprofiles set battery power-saver`। আপনি যা-ই বেছে নিন, পরের বার ওই অবস্থায় গেলে সেটিই ফিরে পাবেন।

### Suspend টগল করা

টার্মিনাল থেকে `omarchy toggle suspend` চালিয়ে আপনি suspend টগল করেন। এটি কেবল _System_-এর অধীনে (বা `Super + Esc`) বিকল্পটিকে দেখায়/লুকায়, এবং তারপর আপনি দেখতে পারেন এটি আপনার সিস্টেমে ধারাবাহিকভাবে কাজ করে কিনা। যদি না করে, একই কমান্ড দিয়ে আপনি আবার সেটি লুকিয়ে ফেলতে পারেন।

### Hibernation টগল করা

টার্মিনাল থেকে `omarchy hibernation setup` চালিয়ে আপনি hibernation সেট আপ করেন (এটি Apple Silicon Macs-এ উপলভ্য নয়)। Hibernation আপনার boot drive-এ আপনার physical RAM allocation-এর সমান আকারের একটি /swap subvolume তৈরি করে, তাই আপনার যথেষ্ট খালি জায়গা আছে কিনা নিশ্চিত করুন। একটি 32GB মেশিনে, এই volume-এর জন্য আপনার সবসময় 32GB+ খালি জায়গা লাগবে। Hibernation-এর জন্য ডিফল্ট Limine bootloader-ও প্রয়োজন।

সেট আপ হয়ে গেলে, আপনি _System_-এর অধীনে (বা `Super + Esc`) hibernate বিকল্পটি দেখতে পাবেন, এবং তারপর দেখতে পারেন এটি আপনার সিস্টেমে ধারাবাহিকভাবে কাজ করে কিনা। যদি না করে, `omarchy hibernation remove` চালিয়ে আপনি আবার সেটি সরিয়ে ফেলতে পারেন।
