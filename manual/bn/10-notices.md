# নোটিশ

হটকি নোটিশ ব্যবহার করে আপনি দ্রুত তারিখ ও সময়, ব্যাটারির অবস্থা এবং বর্তমান আবহাওয়া জানতে পারেন।

### তারিখ ও সময়

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### আবহাওয়া

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

অবস্থানটি আপনার IP ঠিকানা থেকে শনাক্ত করা হয়, যা সাধারণত যথেষ্ট কাছাকাছি, তবে সবসময় নয়। আপনি `omarchy weather location --set Malibu` দিয়ে এটি নির্দিষ্ট করতে পারেন, অথবা স্থানাঙ্ক যোগ করে নির্ভুল হতে পারেন: `omarchy weather location --set Malibu 34.0259,-118.7798`। আপনি কোথায় আছেন বলে এটি মনে করে তা দেখতে শুধু `omarchy weather location` চালান, এবং স্বয়ংক্রিয় শনাক্তকরণে ফিরতে `--clear` ব্যবহার করুন।

### ব্যাটারি

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
