İlk kurulum için setup_onion.sh çalıştırılması gerekir

bash "/Users/yahyakarabal/Downloads/github tor/setup_onion.sh" gibi sh dosyasının yolunu belirten bir kod ile istediğin kurulum dosyaları masaüstüne gelecek Sonrasında html kodunu istediğin an değiştirip; 
değişiklikleri güncellemek için aşağıda belirtilen komutu kullan. alternatif olarak buda çalışabilir ~/setup_onion.sh 


Web sitesinde bir değişiklik yaptığında maalesef bu otomatik olarak güncellenmiyecektir bu durumda bu komutu kullanacaksın 


pkill -f app.py && nohup python3 ~/Desktop/onion-site/app.py >/dev/null 2>&1 & echo "Server reloaded!"

Bu kod suncuuyu yeniden başlatacak ve tekrardan arka planda çalışacak şekildeğ yenileyecek.


Örnek html kodları ve dizilimi bu git hub içerisinde var.


Hazırsın açıldın...

Önemli!!!

~/kill_ports.sh     tüm portları öldür
