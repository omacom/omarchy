# সিস্টেম স্লিপ

Omarchy ডিফল্টভাবে suspend এবং hibernation সক্রিয় রাখে, কিন্তু আপনার মেশিনে এগুলোর যেকোনো একটিতে সমস্যা হলে আপনি সেগুলো বন্ধ করে দিতে পারেন।

NVIDIA GB10 মেশিনগুলোতে, যেমন DGX Spark এবং ASUS Ascent GX10, NVIDIA-র DGX OS-এর মতোই suspend এবং hibernation বন্ধ রাখা হয়, কারণ ওই hardware-এ sleep এখনো কাজ করে বলে দেখানো যায়নি। ASUS Zenbook A16 (UX3607OA)-এর ক্ষেত্রেও একই কথা প্রযোজ্য, যেখানে suspend এখনো chip-কে পুরোপুরি sleep-এ পাঠায় না এবং রাতভর hang করতে পারে। সেখানে suspend toggle এবং hibernation setup প্রযোজ্য নয়। sleep আবার চালু করতে, `sudo rm` দিয়ে `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` সরিয়ে ফেলুন; তাহলে Suspend মেনুতে ফিরে আসবে, এবং অন্যান্য মেশিনের মতোই hibernation সেট আপ করা যাবে। `sudo omarchy apply hardware --install-user "$USER"` চালালে ফাইলটি আবার ফিরে আসে।

### পাওয়ার প্রোফাইল

ল্যাপটপে, Omarchy আপনার power profile আলাদাভাবে মনে রাখে plug লাগানো অবস্থার জন্য এবং battery-তে চালানোর জন্য, এবং আপনি plug লাগানো বা খোলার সাথে সাথে দুটির মধ্যে switch করে। Out of the box এর মানে হলো AC-তে performance এবং battery-তে balanced।

`omarchy powerprofiles list` দিয়ে আপনি দেখতে পারেন আপনার মেশিন কী কী অফার করে, এবং `omarchy powerprofiles set autodetect power-saver` দিয়ে বর্তমানে আপনি যে অবস্থায় আছেন তার জন্য পছন্দেরটি সেট করতে পারেন। কিছু unplug না করেই অন্য অবস্থাটি সেট করতে, সরাসরি তার নাম দিন: `omarchy powerprofiles set battery power-saver`। আপনি যেটাই বেছে নেবেন, পরের বার ওই অবস্থায় গেলে সেটাই ফিরে পাবেন।

### Suspend toggle করুন

terminal থেকে `omarchy toggle suspend` চালিয়ে আপনি suspend toggle করতে পারেন। এটি শুধু _System_-এর অধীনে (বা `Super + Esc`) optionটি দেখায়/লুকায়, এবং তারপর আপনি দেখতে পারেন এটি আপনার system-এ ধারাবাহিকভাবে কাজ করে কিনা। যদি না করে, একই command দিয়ে আবার লুকিয়ে ফেলতে পারেন।

### Hibernation toggle করুন

terminal থেকে `omarchy hibernation setup` চালিয়ে আপনি hibernation সেট আপ করতে পারেন। Hibernation আপনার boot drive-এ আপনার physical RAM allocation-এর সমান আকারের একটি /swap subvolume তৈরি করে, তাই আপনার পর্যাপ্ত খালি জায়গা আছে কিনা নিশ্চিত করুন। 32GB মেশিনে, এই volume-এর জন্য আপনার সবসময় 32GB+ খালি জায়গা লাগবে। Hibernation-এর জন্য default Limine bootloader-ও প্রয়োজন।

সেট আপ হয়ে গেলে, আপনি _System_-এর অধীনে (বা `Super + Esc`) hibernate optionটি দেখতে পাবেন, এবং তারপর দেখতে পারেন এটি আপনার system-এ ধারাবাহিকভাবে কাজ করে কিনা। যদি না করে, `omarchy hibernation remove` চালিয়ে আবার সরিয়ে ফেলতে পারেন।
