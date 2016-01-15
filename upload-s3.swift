//
//  upload-s3.swift
//
//  Created by Ondrej Kuchta on 15.01.16.
//  Copyright © 2016 Ondra. All rights reserved.
//

import Alamofire
import SwiftyJSON

/*

This is the response from your server containing all necesary information for uploading file to S3.
See the Server Code (node-s3.js file in this repositary) for more information.

{
    "method" : "post",
    "payload" : {
        "Policy" : "eyJleHBpcmwwww9uIjoiMjAxNi0xLTE1VDE2OjQxOjM0WiIsImNvbmRpdGlvbnMiOlt7ImJ1Y2tldCI6ImpvaWR5bWVkaWEifSx7ImtleSI6ImdpZnQvZmE0YjVlYTktMTkzMi00YTkwLTlkYzctMDQ5ZjI3MTc3NzkzLzNlMzU1NjFmLTE5MDMtNDczMC04YTczLTIxNjgxOWViOTlkMS5tcDQifSxbInN0YXJ0cy13aXRoIiwiJHgtYW16LW1ldGEtdGFnIiwiIl0seyJDb250ZW50LVR5cGUiOiJ2aWRlby9tcDQifSxbImNvbnRlbnQtbGVuZ3RoLXJhbmdlIiwwLDEwNDg1NzYwXSx7IngtYW16LWNyZWRlbnRpYWwiOiJBS0lBSlNGS09PWTZZM1FMTlQ3QS8yMDE2MDExNS9ldS13ZXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1kYXRlIjoiMjAxNjAxMTVUMDAwMDAwWiJ9LHsieC1hbXotYWxnb3JpdGhtIjoiQVdTNC1ITUFDLVNIQTI1NiJ9LHsieC1hbXotbWV0YS11dWlkIjoiZmE0YjVlYTktMTkzMi00YTkwLTlkYzctMDQ5ZjI3MTc3NzkzIn1dfQ==",
        "X-Amz-Signature" : "b42792b362bfcd77beee16434f6452c144487bb80a6aa1bda6b0b88c16316d7f",
        "X-Amz-Algorithm" : "AWS4-HMAC-SHA256",
        "Content-Type" : "video\/mp4",
        "X-Amz-Credential" : "AKIAJSFKEEY6Y3QLNT7A\/20160115\/eu-west-1\/s3\/aws4_request",
        "x-amz-meta-tag" : [
        
        ],
        "X-Amz-Date" : "20160115T000000Z",
        "key" : "file\/fa4b5ea9-1932-4a90-9dc7-049f27377793\/3e35561f-1903-4730-8a73-215519eb99d1.mp4",
        "x-amz-meta-uuid" : "fa4b5ea9-1932-4a90-9dc7-045627177793"
    },
    "payloadOrder" : [
    "key",
    "Content-Type",
    "x-amz-meta-uuid",
    "x-amz-meta-tag",
    "X-Amz-Credential",
    "Policy",
    "X-Amz-Signature",
    "X-Amz-Algorithm",
    "X-Amz-Date"
    ],
    "field" : "file",
    "url" : "https:\/\/joidymedia.s3.amazonaws.com\/"
}

*/



func uploadVideo(uploadInfo: JSON, fileURL: NSURL) {
    
    // get video data from local phone storage
    
    let videoData = NSFileManager.defaultManager().contentsAtPath(fileURL.path!)
    
    //Get the upload data info from JSON response
    
    if let uploadURL = uploadInfo["url"].string {
        
        if let payload = uploadInfo["payload"].dictionaryObject {
            
            if let payloadOrder = uploadInfo["payloadOrder"].arrayObject {
                
                if let dataField = uploadInfo["field"].string {
                    
                    //Add data to send
                    let dataToSend = NetData(data: videoData!, mimeType: MimeType.VideoMp4, filename: "customName.mp4")
                    
                    //Create special request
                    let urlRequest = urlRequestWithComponents(uploadURL, parameters: payload, parametersOrder: payloadOrder, dataField: dataField, data: dataToSend)
                    uploadFile(urlRequest.0, parameters: urlRequest.1)
                    
                }
                
            }
            
            
        }
        
    }
    
}


func uploadFile(request: URLRequestConvertible, parameters: NSData) {
    
    Alamofire.upload(request, data: parameters)
        .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
            
            print(totalBytesWritten)
            print(totalBytesExpectedToWrite)
            
        }
        .response { request, response, data, error in
            
            print(request)
            print(response)
            print(data)
            print(error)
            
        }
}


func urlRequestWithComponents(urlString:String, parameters:NSDictionary, parametersOrder:NSArray, dataField:String, data:NetData) -> (URLRequestConvertible, NSData) {
    
    
    // create url request to send
    
    
    //var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "http://requestb.in/1e59q1w1")!)
    let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    
    mutableURLRequest.HTTPMethod = "POST"
    
    let boundaryConstant = "----WebKitFormBoundary\(arc4random())"
    let contentType = "multipart/form-data; boundary="+boundaryConstant
    mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
    
    
    //SET BODY PARAMETERS
    let uploadData = NSMutableData()
    
    
    for(var i = 0; i <  parametersOrder.count ; i++){
        
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        let key: String = parametersOrder[i] as! String
        let value: AnyObject? = parameters[key]
        
        if value is String {
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value!)".dataUsingEncoding(NSUTF8StringEncoding)!)
            
        }
        else{
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            
        }
        
    }
    
    uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    
    
    //Start Add data
    let postData = data
    
    // append content disposition
    let contentDispositionString = "Content-Disposition: form-data; name=\"\(dataField)\"\r\n\r\n"
    
    
    let contentDispositionData = contentDispositionString.dataUsingEncoding(NSUTF8StringEncoding)
    uploadData.appendData(contentDispositionData!)
    
    uploadData.appendData(postData.data)
    //End Add data
    
    uploadData.appendData("\r\n\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    
    
    let stringtest = NSString(data: uploadData, encoding: NSUTF8StringEncoding)
    print(stringtest)
    
    
    mutableURLRequest.HTTPBody = uploadData
    
    
    return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
}


