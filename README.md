Inset-Tester
===============

This project was developed as part of the iOS App: [My Things - Where Are They?] [link]   
[link]: http://itunes.apple.com/us/app/my-things-where-are-they/id529353551?ls=1&mt=8

Demonstrates uploading file to Dropbox using Dropbox SDK. More importantly it demonstrates creating a sharable link for an already existing file in Dropbox and receiving that file in your App as Share using NSURLConnection.

##Instructions to test the sample program

1) Prepare the App for [Dropbox Access] [dblink]  
- Obtain APPKEY & APPSECRET from your Dropbox Developer Account and updated them in AppDelegate.m lines 55, 56
- Update URL Scheme db-APPKEY with db-XXXXXX using the App Key
2) Run the program & watch the console window for logs
3) Go Through ViewController.h/m & AppDelegate.h/m to pick up relevant codes to use in your own App

[dblink]: https://www.dropbox.com/developers/start/setup#ios

##License
Copyright (c) 2012 Dhanush Balachandran  
Licensed under the MIT license.

##Contact
[My Things Support] [support] or [Support Email] [email]
[support]: http://www.mythingsapp.com/Support.html
[email]: mailto:support@mythingsapp.com