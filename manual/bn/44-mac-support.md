# Mac সমর্থন

Omarchy-তে **Intel Macs**-এর জন্য বিল্ট-ইন সমর্থন আছে। এই মুহূর্তে কয়েকটি জানা সীমাবদ্ধতা আছে, কিন্তু আপনি সচেতন ও সেগুলো নিয়ে ঠিক থাকলেই; Omarchy লোড করে আপনার পুরনো Mac-গুলোতে নতুন প্রাণ সঞ্চার করতে পারেন।

অনুগ্রহ করে মনে রাখবেন এই সময়ে M-সিরিজ Mac-এ ইনস্টল করা সরাসরি সমর্থিত নয়। আমাদের [Discord](https://discord.gg/tXFUdasqhY)-এ #omarchy-on-other-এ এর অবস্থা সম্পর্কে আরও জানতে পারেন।

সাধারণ একটি পরীক্ষায়, শুধু Omarchy ইনস্টল করেই 2019 MacBook Pro-তে 36% পারফরম্যান্স লাভ অর্জন করতে পেরেছি।

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac-এ Omarchy ইনস্টল করা

Omarchy এই মুহূর্তে ইনস্টল করা **একমাত্র** OS হওয়া সমর্থন করে। ইনস্টলেশনের সময়, ড্রাইভ মুছে ফেলা হবে এবং MacOS আর বুটযোগ্য থাকবে না।

চাইলে পরে Internet Recovery দিয়ে তা ফিরিয়ে আনতে পারবেন।

এই অংশের জন্য, আমরা ধরে নেব আপনি ইতিমধ্যে [শুরু করা](02-getting-started.md) পর্যালোচনা করেছেন এবং আপনার USB ড্রাইভ প্রস্তুত আছে। না থাকলে এখনই তা করুন।

#### Secure Boot নিষ্ক্রিয় করা

বুটযোগ্য USB, পাশাপাশি OS বুট করতে Apple-এর Secure Boot নিষ্ক্রিয় করা দরকার। তা নিষ্ক্রিয় করতে, নিম্নলিখিত করুন:

1. আপনার Mac বন্ধ করুন
2. এটি চালু করুন এবং লোডিং স্ক্রিন দেখা না যাওয়া পর্যন্ত _সাথে সাথে_ Command-R চেপে ধরে রাখুন
3. আপনার ব্যবহারকারী বেছে নিন এবং চাওয়া হলে পাসওয়ার্ড দিন
4. রিকভারি স্ক্রিনে গেলে, মেনুবার থেকে **Utilities > Startup Security Utility** বেছে নিন
5. প্রমাণীকরণের জন্য চাওয়া হলে পাসওয়ার্ড দিন
6. Secure Boot বিকল্প থেকে "No Security" বেছে নিন
7. External Boot বিকল্প থেকে "Allow booting from external or removable media" বেছে নিন

#### ইনস্টলেশন শুরু করা

1. USB ড্রাইভ ঢোকান
2. আপনার Mac রিস্টার্ট করুন এবং বুট ডিভাইসের স্ক্রিন দেখা না যাওয়া পর্যন্ত _সাথে সাথে_ Option চেপে ধরে রাখুন
3. কমলা EFI Boot ডিভাইস বেছে নিন
4. [স্বাভাবিকভাবে ইনস্টল](02-getting-started.md) এগিয়ে যান

ইনস্টলার Mac হার্ডওয়্যার শনাক্ত করে এবং প্রয়োজনীয় ফিক্স স্বয়ংক্রিয়ভাবে প্রয়োগ করে: Broadcom Wi-Fi ড্রাইভার ও ফার্মওয়্যার, প্রয়োজন এমন MacBook মডেলে SPI কীবোর্ড ড্রাইভার, এবং সেই একই মডেলের জন্য একটি NVMe সাসপেন্ড ফিক্স।

### জানা সীমাবদ্ধতা

কমিউনিটির সদস্যরা ক্রমাগত এই চ্যালেঞ্জগুলোর সমাধান নিয়ে কাজ করছেন তাই এগুলো আপনার জন্য সমস্যাজনক হলে, আমাদের [Discord](https://discord.gg/tXFUdasqhY)-এ #omarchy-on-other-এ যোগ দিন এবং এগুলো সমাধানের কোনো হালনাগাদ পদ্ধতি আছে কিনা দেখুন।

#### T1 চিপ সহ ডিভাইস

Apple T1 চিপ 2016 সালের শেষের দিকে চালু হয়েছিল এবং Touch Bar সহ প্রথম-প্রজন্মের MacBook Pro মডেলগুলোতে একচেটিয়াভাবে ব্যবহৃত হয়েছিল।
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### জানা সমস্যা

- Touch Bar অকার্যকর
- শব্দ কাজ করছে না

#### T2 চিপ সহ ডিভাইস

Apple T2 Security Chip 2017 সালে চালু হয়েছিল। 2020 সাল থেকে Apple silicon (M-সিরিজ চিপ)-এ রূপান্তরের সাথে T2 চিপ বন্ধ হয়ে যায়।

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

এই মডেলগুলোতে, ইনস্টলার স্বয়ংক্রিয়ভাবে প্যাচ করা `linux-t2` কার্নেল, T2 অডিও কনফিগারেশন, Apple-এর Broadcom Wi-Fi/Bluetooth ফার্মওয়্যার এবং `t2fanrd` দিয়ে ফ্যান নিয়ন্ত্রণ সেট আপ করে। Touch Bar কার্নেলের বিল্ট-ইন Boot Camp-স্টাইল সমর্থনে চলে।
