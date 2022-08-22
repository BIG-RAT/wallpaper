//
//  JamfPro.swift
//  Jamf Wallpaper
//
//  Created by Leslie Helou on 4/13/22.
//  Copyright © 2022 Jamf. All rights reserved.
//

import Foundation
class JamfPro: NSObject, URLSessionDelegate {
    
    var renewQ     = DispatchQueue(label: "com.jamfie.token_refreshQ", qos: DispatchQoS.utility)   // running background process for refreshing token
    let apiActionQ = OperationQueue() // DispatchQueue(label: "com.jamfie.apiActionQ", qos: DispatchQoS.background)
    let defaults   = UserDefaults.standard
    
    func jsonAction(theServer: String, theEndpoint: String, theMethod: String, retryCount: Int, completion: @escaping (_ result: ([String:AnyObject],Int)) -> Void) {

        if retryCount == -1 {
            // skip action
//            print("skip lookup of \(theEndpoint)")
            completion(([:],0))
            return
        }
    
        URLCache.shared.removeAllCachedResponses()
        var existingDestUrl = ""
        

        existingDestUrl = "\(theServer)/JSSResource/\(theEndpoint)"
        existingDestUrl = existingDestUrl.replacingOccurrences(of: "//JSSResource", with: "/JSSResource")
//        print("looking up \(existingDestUrl)")
        
        //WriteToLog().message(theString: "[JamfPro.jsonAction] \(theMethod) - existing endpoint URL: \(existingDestUrl)")
        let destEncodedURL = URL(string: existingDestUrl)
        let jsonRequest    = NSMutableURLRequest(url: destEncodedURL! as URL)
        
        let semaphore = DispatchSemaphore(value: 0)
        apiActionQ.maxConcurrentOperationCount = JamfProServer.maxThreads
        apiActionQ.qualityOfService = .background
        apiActionQ.addOperation {
            
            jsonRequest.httpMethod = theMethod
            let destConf = URLSessionConfiguration.default
            destConf.timeoutIntervalForRequest = 10.0
            destConf.httpAdditionalHeaders = ["Authorization" : "\(JamfProServer.authType) \(JamfProServer.authCreds)", "Content-Type" : "application/json", "Accept" : "application/json", "User-Agent" : appInfo.userAgentHeader]
            
            let destSession = Foundation.URLSession(configuration: destConf, delegate: self, delegateQueue: OperationQueue.main)
            let task = destSession.dataTask(with: jsonRequest as URLRequest, completionHandler: {
                (data, response, error) -> Void in
                destSession.finishTasksAndInvalidate()
                if let err = error {
    //                    print("Error localizedDescription: \(err.localizedDescription)")
                    WriteToLog().message(theString: "[JamfPro.jsonAction] an HTTP error occured: \(err.localizedDescription)")
                    Alert().display(header: "\(err.localizedDescription)", message: "")
                    completion(([:],0))
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 {
                        do {
                            let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                            if let endpointJSON = json as? [String:AnyObject] {
//                                if LogLevel.debug { //WriteToLog().message(stringOfText: "[JamfPro.jsonAction] \(endpointJSON)\n") }
                                completion((endpointJSON,httpResponse.statusCode))
                            } else {
//                                //WriteToLog().message(stringOfText: "[JamfPro.jsonAction] error parsing JSON for \(existingDestUrl)\n")
                                completion(([:],httpResponse.statusCode))
                            }
                        }
                    } else {
                        //WriteToLog().message(theString: "[JamfPro.jsonAction] error during GET, HTTP Status Code: \(httpResponse.statusCode)\n")
                        if "\(httpResponse.statusCode)" == "401" && retryCount < 1 {
                            if JamfProServer.authType == "Bearer" {
                                //WriteToLog().message(theString: "[JamfPro.jsonAction] authentication failed.  Trying to gneerate a new token")
                                self.getToken(serverUrl: JamfProServer.URL, whichServer: "source", base64creds: JamfProServer.base64Creds) {
                                    (result: (Int,String)) in
                                    let (_,passFail) = result
                                    if passFail != "failed" {
                                        self.jsonAction(theServer: theServer, theEndpoint: theEndpoint, theMethod: theMethod, retryCount: retryCount+1) {
                                        (result: ([String:AnyObject],Int)) in
                                            completion(result)
                                        }
                                    } else {
                                        //WriteToLog().message(theString: "[JamfPro.jsonAction] authentication failed.")
                                        completion((["Message":"Failed to authenticate" as AnyObject],httpResponse.statusCode))
                                    }
                                }
                            } else {
                                completion((["Message":"Failed to authenticate" as AnyObject],httpResponse.statusCode))
                            }
                        } else if httpResponse.statusCode > 499 && retryCount < 1 {
                            sleep(5)
                            //WriteToLog().message(theString: "[JamfPro.jsonAction] Retry \(existingDestUrl)")
                            self.jsonAction(theServer: theServer, theEndpoint: theEndpoint, theMethod: theMethod, retryCount: retryCount+1) {
                                (result: ([String:AnyObject],Int)) in
                                completion(result)
                            }
                        } else {
                            completion(([:],0))
                        }
                    }
                } else {
                    //WriteToLog().message(theString: "[JamfPro.jsonAction] error parsing JSON for \(existingDestUrl)")
                    //WriteToLog().message(theString: "[JamfPro.jsonAction] error: \(String(describing: error))")
                    completion(([:],0))
                }   // if let httpResponse - end
                semaphore.signal()
                if error != nil {
                }
            })  // let task = destSession - end
            //print("GET")
            task.resume()
            semaphore.wait()
        }   // apiActionQ - end
    }
    
    func xmlAction(theServer: String, theEndpoint: String, theMethod: String, theData: String, skip: Bool, completion: @escaping (_ result: [Int:String]) -> Void) {

        if appInfo.stopUpdates {
            apiActionQ.cancelAllOperations()
            completion([0:"success"])
            return
        }
        
        if skip {
            completion([0:"success"])
            return
        }
        
        URLCache.shared.removeAllCachedResponses()
        var existingDestUrl = ""
        
        existingDestUrl = "\(theServer)/JSSResource/\(theEndpoint)"
        existingDestUrl = existingDestUrl.replacingOccurrences(of: "//JSSResource", with: "/JSSResource")
        
//        if LogLevel.debug { //WriteToLog().message(stringOfText: "[JamfPro.xmlAction] Looking up: \(existingDestUrl)\n") }
        //WriteToLog().message(theString: "[JamfPro.xmlAction] \(theMethod) - existing endpoint URL: \(existingDestUrl)")
        let destEncodedURL = URL(string: existingDestUrl)
        let xmlRequest    = NSMutableURLRequest(url: destEncodedURL! as URL)
        
        let semaphore = DispatchSemaphore(value: 0)
        apiActionQ.maxConcurrentOperationCount = JamfProServer.maxThreads
        apiActionQ.qualityOfService = .default
        apiActionQ.addOperation {
            
            xmlRequest.httpMethod = theMethod
            let destConf = URLSessionConfiguration.default
            destConf.httpAdditionalHeaders = ["Authorization" : "\(JamfProServer.authType) \(JamfProServer.authCreds)", "Content-Type" : "application/xml", "Accept" : "application/xml", "User-Agent" : appInfo.userAgentHeader]
            if theMethod == "POST" || theMethod == "PUT" {
                let encodedXML = theData.data(using: String.Encoding.utf8)
                xmlRequest.httpBody = encodedXML!
            }
            
            let destSession = Foundation.URLSession(configuration: destConf, delegate: self, delegateQueue: OperationQueue.main)
            let task = destSession.dataTask(with: xmlRequest as URLRequest, completionHandler: {
                (data, response, error) -> Void in
                destSession.finishTasksAndInvalidate()
                if let err = error {
    //                    print("Error localizedDescription: \(err.localizedDescription)")
                    WriteToLog().message(theString: "[JamfPro.xmlAction] an HTTP error occured: \(err.localizedDescription)")
                    Alert().display(header: "\(err.localizedDescription)", message: "")
                    completion([0:"failed"])
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
//                    print("[JamfPro.xmlAction] httpResponse: \(String(describing: httpResponse))")
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 {
                        
//                                //WriteToLog().message(stringOfText: "[JamfPro.xmlAction] error parsing JSON for \(existingDestUrl)\n")
                        completion([httpResponse.statusCode:"success"])
                        
                    } else {
                        //WriteToLog().message(theString: "[JamfPro.xmlAction] error during \(theMethod), HTTP Status Code: \(httpResponse.statusCode)\n")
                        if "\(httpResponse.statusCode)" == "401" {
                            //Alert().display(header: "Alert", message: "Verify username and password.")
                        }
                        if httpResponse.statusCode > 500 {
                            //WriteToLog().message(theString: "[JamfPro.xmlAction] momentary pause\n")
                            sleep(2)
                            //WriteToLog().message(theString: "[JamfPro.xmlAction] back to work\n")
                        }
//                        //WriteToLog().message(stringOfText: "[JamfPro.xmlAction] error HTTP Status Code: \(httpResponse.statusCode)\n")
                        completion([httpResponse.statusCode:"failed"])
                    }
                } else {
//                    //WriteToLog().message(stringOfText: "[JamfPro.xmlAction] error parsing JSON for \(existingDestUrl)\n")
                    completion([0:""])
                }   // if let httpResponse - end
                semaphore.signal()
                if error != nil {
                }
            })  // let task = destSession - end
            //print("GET")
            task.resume()
            semaphore.wait()
        }   // apiActionQ - end
    }
        
    func jpapiAction(serverUrl: String, endpoint: String, apiData: [String:Any], id: String, token: String, method: String, completion: @escaping (_ returnedJSON: [String: Any]) -> Void) {
        
        if method.lowercased() == "skip" {
            completion(["JPAPI_result":"failed", "JPAPI_response":000])
            return
        }
        
        URLCache.shared.removeAllCachedResponses()
        var path = ""

        switch endpoint {
        case  "buildings", "csa/token", "icon", "jamf-pro-version":
            path = "v1/\(endpoint)"
        default:
            path = "v2/\(endpoint)"
        }

        var urlString = "\(serverUrl)/api/\(path)"
        urlString     = urlString.replacingOccurrences(of: "//api", with: "/api")
        if id != "" && id != "0" {
            urlString = urlString + "/\(id)"
        }
//        print("[Jpapi] urlString: \(urlString)")
        
        let url            = URL(string: "\(urlString)")
        let configuration  = URLSessionConfiguration.ephemeral
        var request        = URLRequest(url: url!)
        switch method.lowercased() {
        case "get":
            request.httpMethod = "GET"
        case "create", "post":
            request.httpMethod = "POST"
        default:
            request.httpMethod = "PUT"
        }
        
        if apiData.count > 0 {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: apiData, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
//        print("[Jpapi.action] Attempting \(method) on \(urlString).")
        
        configuration.httpAdditionalHeaders = ["Authorization" : "Bearer \(token)", "Content-Type" : "application/json", "Accept" : "application/json"]
        let session = Foundation.URLSession(configuration: configuration, delegate: self as URLSessionDelegate, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            session.finishTasksAndInvalidate()
            if let err = error {
//                    print("Error localizedDescription: \(err.localizedDescription)")
                WriteToLog().message(theString: "[JamfPro.jpapiAction] an HTTP error occured: \(err.localizedDescription)")
                Alert().display(header: "\(err.localizedDescription)", message: "")
                completion(["JPAPI_result":"failed", "JPAPI_response":0])
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    if let endpointJSON = json! as? [String:Any] {
                        completion(endpointJSON)
                        return
                    } else {    // if let endpointJSON error
                        completion(["JPAPI_result":"failed", "JPAPI_response":httpResponse.statusCode])
                        return
                    }
                } else {    // if httpResponse.statusCode <200 or >299
                    completion(["JPAPI_result":"failed", "JPAPI_method":request.httpMethod ?? method, "JPAPI_response":httpResponse.statusCode, "JPAPI_server":urlString, "JPAPI_token":token])
                    return
                }
            } else {
                completion([:])
                return
            }
        })
        task.resume()
        
    }
    
    func getToken(serverUrl: String, whichServer: String, base64creds: String, completion: @escaping (_ result: (Int,String)) -> Void) {
        
        if serverUrl.prefix(4) != "http" {
            completion((200,"skipped"))
            return
        }
        URLCache.shared.removeAllCachedResponses()
                
        var tokenUrlString = "\(serverUrl)/api/v1/auth/token"
        tokenUrlString     = tokenUrlString.replacingOccurrences(of: "//api", with: "/api")
    //        print("\(tokenUrlString)")
        
        let tokenUrl       = URL(string: "\(tokenUrlString)")
        let configuration  = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15.0
        var request        = URLRequest(url: tokenUrl!)
        request.httpMethod = "POST"
        
        WriteToLog().message(theString: "[JamfPro.getToken] Attempting to retrieve token from \(String(describing: tokenUrl!)).")
        if !JamfProServer.validToken {
            configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(base64creds)", "Content-Type" : "application/json", "Accept" : "application/json"]
            let session = Foundation.URLSession(configuration: configuration, delegate: self as URLSessionDelegate, delegateQueue: OperationQueue.main)
            let task = session.dataTask(with: request as URLRequest, completionHandler: {
                (data, response, error) -> Void in
                if let err = error {
//                    print("Error localizedDescription: \(err.localizedDescription)")
                    WriteToLog().message(theString: "[JamfPro.getToken] an HTTP error occured: \(err.localizedDescription)")
                    Alert().display(header: "\(err.localizedDescription)", message: "")
                    completion((0, "failed"))
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 {
                        let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        if let endpointJSON = json! as? [String: Any], let _ = endpointJSON["token"], let _ = endpointJSON["expires"] {
                            JamfProServer.validToken = true
                            JamfProServer.base64Creds = base64creds
                            JamfProServer.authCreds = endpointJSON["token"] as! String
                            token.sourceExpires  = "\(endpointJSON["expires"] ?? "")"
                            
    //                      print("[JamfPro] result of token request: \(endpointJSON)")
    //                      print("[JamfPro] Bearer type: \(JamfProServer.authType)")
                            WriteToLog().message(theString: "[JamfPro.getToken] new token created.")
                            if JamfProServer.version == "" {
                                // get Jamf Pro version - start
                                self.jpapiAction(serverUrl: serverUrl, endpoint: "jamf-pro-version", apiData: [:], id: "", token: JamfProServer.authCreds, method: "GET") {
                                    (result: [String:Any]) in
                                    let versionString = result["version"] as! String
                
                                    if versionString != "" {
                                        WriteToLog().message(theString: "[JamfPro.getVersion] Jamf Pro Version: \(versionString)")
                                        JamfProServer.version = versionString
                                        let tmpArray = versionString.components(separatedBy: ".")
                                        if tmpArray.count > 2 {
                                            for i in 0...2 {
                                                switch i {
                                                case 0:
                                                    JamfProServer.majorVersion = Int(tmpArray[i]) ?? 0
                                                case 1:
                                                    JamfProServer.minorVersion = Int(tmpArray[i]) ?? 0
                                                case 2:
                                                    let tmp = tmpArray[i].components(separatedBy: "-")
                                                    JamfProServer.patchVersion = Int(tmp[0]) ?? 0
                                                    if tmp.count > 1 {
                                                        JamfProServer.build = tmp[1]
                                                    }
                                                default:
                                                    break
                                                }
                                            }
                                            if ( JamfProServer.majorVersion > 9 && JamfProServer.minorVersion > 34 ) {
                                                JamfProServer.authType = "Bearer"
                                                WriteToLog().message(theString: "[JamfPro.getVersion] \(serverUrl) set to use OAuth")
                                                
                                            } else {
                                                JamfProServer.authType  = "Basic"
                                                JamfProServer.authCreds = base64creds
                                                WriteToLog().message(theString: "[JamfPro.getVersion] \(serverUrl) set to use Basic")
                                            }
                                            if JamfProServer.authType == "Bearer" {
                                                self.refresh(server: serverUrl, whichServer: whichServer, b64Creds: base64creds)
                                            }
                                            completion((200, "success"))
                                            return
                                        }
                                    }
                                }
                                // get Jamf Pro version - end
                            } else {
                                if JamfProServer.authType == "Bearer" {
                                    self.refresh(server: serverUrl, whichServer: whichServer, b64Creds: base64creds)
                                }
                                completion((200, "success"))
                                return
                            }
                        } else {    // if let endpointJSON error
                            WriteToLog().message(theString: "[JamfPro.getToken] JSON error.\n\(String(describing: json))")
                            completion((httpResponse.statusCode,"failed"))
                            return
                        }
                    } else {    // if httpResponse.statusCode <200 or >299
                        WriteToLog().message(theString: "[JamfPro.getToken] response error: \(httpResponse.statusCode).")
                        if httpResponse.statusCode == 401 {
                            Alert().display(header: "Failed to authenticate", message: "")
                        }
                        completion((httpResponse.statusCode,"failed"))
                        return
                    }
                } else {
                    WriteToLog().message(theString: "[JamfPro.getToken] token response error.  Verify url and port.")
                    completion((0,"failed"))
                    return
                }
            })
            task.resume()
        } else {
//            WriteToLog().message(stringOfText: "[JamfPro.getToken] Use existing token from \(String(describing: tokenUrl!))\n")
            completion((200, "success"))
            return
        }
    }
    
    func refresh(server: String, whichServer: String, b64Creds: String) {
        renewQ.async { [self] in
//        sleep(1200) // 20 minutes
            sleep(token.refreshInterval)
            JamfProServer.validToken = false
            getToken(serverUrl: server, whichServer: whichServer, base64creds: b64Creds) {
                (result: (Int,String)) in
//                print("[JamfPro.refresh] returned: \(result)")
            }
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping(  URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
