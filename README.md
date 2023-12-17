
## Yapılacaklar
 - Receiver için istek kabul edildiğinde file page yönlendilirilecek
 - Update uyarı sistemi ekleyelim

## connection conditionları
 - Herhangi bir taraf bağlantıdan çıkarsa
 - Herhangi bir tarafın uygulaması kapanırsa (düşünülebilir)
 - Herhangi bir taraf iptal ederse
 - Herhangi bir hata çıkarsa
 - Dosya gönderimindeyken farklı bir kullanıcıdan dosya transferi isteği gelirse ya kabul edemeyecek ya da kabul etmek istiyor musunuz diye yazı çıkacak ve evet der bise bu dosya gönderimi iptal olup ona bağlanacak
 - Dosya gönderiminde iki istek gelindiğinde biri kabul edilip dosya gönderimi başlatıldığında başka biri tarafından yine istek kabul edilirse o bağlantıya bağlanılmayacak.

## Connection dökümanında olacaklar
 - Döküman adı idlerin küçükten büyüğe sıralanıp arasına - işareti konulmasıyla oluşacak
### İçeriği
 - Alıcı kullanıcı id (receiverID)
 - Gönderici kullanıcı id(senderID)
 - Dosya statüsü  (enum, fileInfo)
 - Toplam dosya sayısı (filesCount)
 - Toplam dosya boyutu (filesSize)
 - Gönderim hızı (sendSpeed)
 - Gönderilen dosyaların isimleri, dosya boyutları, hangi uzantılı oldukları, hangi dosyaların gönderildiği bilgileri (map, filesList)
 - Bağlanırken blogda ki connectedUser güncellenecek-
 - Bağlantı bittiğinde sendListe veri eklenecek


## Yapılanlar

- ~~FirebaseSendFileUploading düzenlenecek~~
- ~~send file için map şeklinde kullanıcı datası alınacak~~

