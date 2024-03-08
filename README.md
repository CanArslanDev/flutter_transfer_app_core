# Flutter File Transfer App Backend 
## Introduction
This repository contains the backend codes I made for my file sending application. You can transfer files between phones by simply opening two emulators.
This application was made in [Flutter SDK](https://flutter.dev) using the [Bloc package](https://pub.dev/packages/bloc) for state management.

## How it works?
The application connects to firebase and saves the ID and other phone information in the firestore. Then, when another phone wants to connect, it sends a connection request to the other user by querying firebase with the entered ID. If the user accepts after the request is sent, a connection with a different collection is made.
During the connection, the file is selected and when the file is sent, it is first saved on firebase storage, the information that the file is saved in the cloud is sent to the other phone and the file starts downloading on the other phone.

## Screenshots
<img src='https://github.com/CanArslanDev/flutter_transfer_app_core/assets/76579053/b748a3ee-46ab-47c9-8311-a8124aed9cee' width='500'>
<img src='https://github.com/CanArslanDev/flutter_transfer_app_core/assets/76579053/c6328456-12b0-4365-9d01-4981d8c4098c' width='500'>

## How to use

### Firebase setup
 1. First, create a ```firebase project```.
 2. Then activate Firebase Storage in your Firebase project.
 3. Then implement your ```google-services``` json or plist file for android into the application.

### App setup
 1. Then download the repo (```git clone https://github.com/CanArslanDev/flutter_transfer_app_core```)
 2. After opening the repo in the editor, download the packages with the ```pub get``` command from the terminal.
 3. Finally, you can start the application with the ```flutter run``` command.


## Features List
Here is a list of the arrangements and improvements made for the repo and those that will be made in the next or near future. If you think there is a need for another regulation other than the regulations here, you can [open an issue](https://github.com/CanArslanDev/flutter_transfer_app_core/issues).


### To do
  - user cannot log out while in file transfer
  - It is checked whether the user has storage space on the phone and in the database and files can be added accordingly (during transfer)
  - After exiting the file transfer, it will be checked whether the lastConnections on the user are cleared (they should not change)
  - When the QR code page is opened, the connection request snack bar will not appear from above (inappnotifications).
  - Connection requester will not be accepted after 5 minutes, and will not be accepted even if the user closes the application
It will be done using timestamp, and when timestamp is used, when more requests are received from the same person in connection requests, the deletion process will be done according to timestamp, thus preventing more than one request from being deleted at the same time.
  - Constants.dart file will be created and places such as cloud storage files folder will be entered into it.
  - application min sdk will be 20 (build.gradle),
  - info.plist [here](https://pub.dev/packages/qr_code_scanner) will be added

### connection conditions (the rest are optional and can be done in the future)
  - ~~If any party disconnects~~
  - If any party's app goes down (conceivable)
  - ~~If either party cancels~~
  - If any error occurs
  - If a file transfer request comes from a different user while the file is being sent, it will either not be able to accept it, or a message will appear asking if you want to accept it, and if it says yes, this file transfer will be canceled and connected to it.
  - When two requests are made to send a file, if one of them is accepted and the file sending is started, if the request is accepted by another person, that connection will not be connected. This applies to both the sender and the receiver.
## For Later
  - tomap and formap for user model will be moved to user model
  - Firebase in user bloc will be moved to a separate file
  - A model will be created for connectionRequest, connectedUser and previousConnectionRequest in the user model and their names will be changed to connectionRequests and previousConnectionRequests. After the connectionRequest model is created, it will be replaced with the map model in the acceptRequest and acceptRequestQR functions in the userblock.
  - Let's add an update warning system
  - let's add google analytics

### What has been done

  - ~~The data will be refreshed while data is being transferred to the latestConnection on the user~~
  - ~~The list will be added to change the url download enum ~~
  - ~~What will be in the connection document~~
  - ~~The document name will be formed by listing the ids from smallest to largest and placing a - sign between them~~
  - ~~Content~~
  - ~~Receiver user id (receiverID)~~
  - ~~Sender user id(senderID)~~
  - ~~File status (enum, fileInfo)~~
  - ~~Total number of files (filesCount)~~
  - ~~Total file size (filesSize)~~
  - ~~Sending speed (sendSpeed)~~
  - ~~The names of the files sent, their file sizes, their extensions, information about which files were sent (map, filesList)~~
  - ~~ConnectedUser on the blog will be updated while connecting~~
  - ~~Data will be added to the sendList when the connection is finished~~
  - ~~When the request for Receiver is accepted, the file page will be redirected~~
  - ~~FirebaseSendFileUploading will be edited~~
  - ~~User data in the form of a map will be received for the send file~~
