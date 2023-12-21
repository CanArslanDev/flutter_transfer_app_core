
## Yapılacaklar
 - Kullanıcının telefonda ve veri tabanında depolama alanı yeri olup olmadığı kontrol edilip dosyalar öyle eklenebilecek (transfer esnasında)
 - Connection requester 5 dakikadan sonra kabul edilemeyecek, ve kullanıcı uygulamayı kapadıysa da kabul edilemeyecek
Timestamp kullanılarak yapılacak, ve timestamp kullanıldığında connectionrequestlerde aynı kişiden fazla request geldiğinde silinme işlemini timestampe göre yaparak birden fazla aynı anda requested silinmesininde önüne geçilmiş olacak
 - constants.dart dosyası olşturulup içine cloud storage files klasörü gibi yerler girilecek

## connection conditionları
 - Herhangi bir taraf bağlantıdan çıkarsa
 - Herhangi bir tarafın uygulaması kapanırsa (düşünülebilir)
 - Herhangi bir taraf iptal ederse
 - Herhangi bir hata çıkarsa
 - Dosya gönderimindeyken farklı bir kullanıcıdan dosya transferi isteği gelirse ya kabul edemeyecek ya da kabul etmek istiyor musunuz diye yazı çıkacak ve evet der bise bu dosya gönderimi iptal olup ona bağlanacak
 - Dosya gönderiminde iki istek gelindiğinde biri kabul edilip dosya gönderimi başlatıldığında başka biri tarafından yine istek kabul edilirse o bağlantıya bağlanılmayacak. Bu hem gönderen hem alıcı için geçerli.

## İleriki Zaman İçin
 - user model için tomap ve formap user modele taşınacak
 - user modelinde ki connectionRequest ve previousConnectionRequest için Model oluşturulacak ve isimleri connectionRequests ve previousConnectionRequests olarak değiştirilecek
 - Update uyarı sistemi ekleyelim
 - google analytics ekleyelim

## Yapılanlar

 - ~~userda ki latestConnectionsa veri transferindeyken veri gidip yenilenecek~~
 - ~~url download enumı değişmesi için liste eklenecek ~~
 - ~~Connection dökümanında olacaklar~~
 - ~~Döküman adı idlerin küçükten büyüğe sıralanıp arasına - işareti konulmasıyla oluşacak~~
 - ~~İçeriği~~
 - ~~Alıcı kullanıcı id (receiverID)~~
 - ~~Gönderici kullanıcı id(senderID)~~
 - ~~Dosya statüsü  (enum, fileInfo)~~
 - ~~Toplam dosya sayısı (filesCount)~~
 - ~~Toplam dosya boyutu (filesSize)~~
 - ~~Gönderim hızı (sendSpeed)~~
 - ~~Gönderilen dosyaların isimleri, dosya boyutları, hangi uzantılı oldukları, hangi dosyaların gönderildiği bilgileri (map, filesList)~~
 - ~~Bağlanırken blogda ki connectedUser güncellenecek~~
 - ~~Bağlantı bittiğinde sendListe veri eklenecek~~
 - ~~Receiver için istek kabul edildiğinde file page yönlendilirilecek~~
 - ~~FirebaseSendFileUploading düzenlenecek~~
 - ~~send file için map şeklinde kullanıcı datası alınacak~~

