# সিস্টেম স্লিপ

Omarchy ডিফল্টভাবে suspend সক্রিয় রাখে, এবং সেট আপ হয়ে গেলে hibernation-ও, কিন্তু আপনার মেশিনে কোনো একটি নিয়ে সমস্যা হলে আপনি সেগুলো বন্ধ করে দিতে পারেন।

DGX Spark এবং ASUS Ascent GX10-এর মতো NVIDIA GB10 মেশিনগুলোতে suspend এবং hibernation বন্ধ থাকে, যেমনটা NVIDIA-র DGX OS-এও থাকে, কারণ ওই hardware-এ sleep এখনো কাজ করে বলে দেখানো যায়নি। সেখানে suspend toggle এবং hibernation setup প্রযোজ্য নয়। sleep আবার চালু করতে, `sudo rm` দিয়ে `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` সরিয়ে ফেলুন; Suspend তখন মেনুতে ফিরে আসবে, এবং অন্য মেশিনগুলোর মতোই hibernation সেট আপ করা যাবে। `sudo omarchy apply hardware --install-user "$USER"` চালালে ফাইলটি আবার ফিরে আসে।

### পাওয়ার প্রোফাইল

ল্যাপটপে, Omarchy প্লাগ ইন করা অবস্থা এবং ব্যাটারিতে চলা অবস্থার জন্য আপনার পাওয়ার প্রোফাইল আলাদাভাবে মনে রাখে, এবং আপনি প্লাগ ইন ও আনপ্লাগ করার সাথে সাথে দুটির মধ্যে অদলবদল করে। শুরু থেকেই এর মানে হলো AC-তে performance এবং ব্যাটারিতে balanced।

আপনার মেশিনে কী কী আছে তা আপনি `omarchy powerprofiles list` দিয়ে দেখতে পারেন, এবং আপনি বর্তমানে যে অবস্থায় আছেন তার জন্য যেটি চান সেটি `omarchy powerprofiles set autodetect power-saver` দিয়ে সেট করতে পারেন। কোনো কিছু আনপ্লাগ না করে অন্য অবস্থাটি সেট করতে, সরাসরি তার নাম বলুন: `omarchy powerprofiles set battery power-saver`। আপনি যা বেছে নেবেন, পরের বার ওই অবস্থায় গেলে সেটাই ফিরে পাবেন।

### Suspend টগল করা

টার্মিনাল থেকে `omarchy toggle suspend` চালিয়ে আপনি suspend টগল করেন। এটি শুধু _System_-এর অধীনে (বা `Super + Esc`) অপশনটি দেখায়/লুকায়, এবং তারপর আপনি দেখতে পারেন এটি আপনার সিস্টেমে ধারাবাহিকভাবে কাজ করে কিনা। যদি না করে, একই কমান্ড দিয়ে আপনি এটি আবার লুকিয়ে ফেলতে পারেন।

### Hibernation টগল করা

টার্মিনাল থেকে `omarchy hibernation setup` চালিয়ে আপনি hibernation সেট আপ করেন (এটি Apple Silicon Mac-গুলোতে উপলভ্য নয়)। Hibernation আপনার boot drive-এ আপনার physical RAM allocation-এর আকারের একটি /swap subvolume তৈরি করে, তাই নিশ্চিত করুন আপনার হাতে প্রচুর জায়গা খালি আছে। একটি 32GB মেশিনে, এই volume-এর জন্য আপনার সবসময় 32GB+ খালি জায়গা লাগবে। Hibernation-এর জন্য default Limine bootloader-ও প্রয়োজন।

সেট আপ হয়ে গেলে, আপনি _System_-এর অধীনে (বা `Super + Esc`) hibernate অপশনটি দেখতে পাবেন, এবং তারপর আপনি দেখতে পারেন এটি আপনার সিস্টেমে ধারাবাহিকভাবে কাজ করে কিনা। যদি না করে, `omarchy hibernation remove` চালিয়ে আপনি এটি আবার সরিয়ে ফেলতে পারেন।
