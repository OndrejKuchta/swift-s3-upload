# swift-s3-upload
This is example of uploading file (mp4 file in this case) from iOS device (Swift 2.0) to Amazon S3 bucket.
It consists of 2 parts, the client in swift and server in JS (Node.js). All secrets are stored on the server side and clients gets 
just the playload and policy information necesary for uploading given file to the S3 bucket.


## Swift part (2.0)
See the file in this repo : [upload-s3.swift](https://github.com/OndrejKuchta/swift-s3-upload/blob/master/upload-s3.swift)

Pods used in this example
* [Alamofire](https://github.com/Alamofire/Alamofire)
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) 

#### What it does:
* Parse the JSON from server with playload and policy information
* Gets the local data from storage which has to be send
* Creates special POST HTTP Header for upload
* Tracks progress of uploading

#### How to call the function 
```
uploadInfo - info from server (playload and policy in JSON format).
fileURL - Local file url to the file on the device.

uploadVideo(uploadInfo: JSON, fileURL: NSURL)
```



## Server part (Node.js)
See the file in this repo : [node-s3.js](https://github.com/OndrejKuchta/swift-s3-upload/blob/master/node-s3.js)

You have to first install and configure [aws-sdk](https://aws.amazon.com/sdk-for-node-js/) to use this example.




##The MIT License

Copyright (c) 2016 Ondrej Kuchta

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
