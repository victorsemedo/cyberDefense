//
//  CyberDefenseApi.swift
//  CyberDefense
//
//  Created by Victor Tavares on 22/03/19.
//  Copyright © 2019 Victor Semedo. All rights reserved.
//

import Foundation

class CyberDefenseApi: NSObject {
    
    static let shared = CyberDefenseApi()
    
    private var currentUrl = ""
    
    private override init() {
    }
    
    func validateServerSecurity(url: String, callback: @escaping (_ result: Bool) -> Void) {
        let configuration = URLSessionConfiguration.default
        let delegate = CyberDefenseDelegate.init(url: url)
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue:OperationQueue.main)
        if let urlObj = URL(string: url) {
            var request = URLRequest(url: urlObj)
            request.httpMethod = "POST"
            currentUrl = url
            let task = session.dataTask(with: request) { data, response, error in
                callback(delegate.isServerTrusted)
            }
            task.resume()
        } else {
            callback(false)
        }
    }
}

class CyberDefenseDelegate: NSObject, URLSessionDelegate {
    
    private var url: String
    
    var isServerTrusted: Bool = false
    
    init(url: String) {
        self.url = url
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if let serverTrust = challenge.protectionSpace.serverTrust,
            SecTrustGetCertificateCount(serverTrust) > 0,
            let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            
            let policies = NSMutableArray();
            policies.add(SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString)))
            SecTrustSetPolicies(serverTrust, policies);
            
            var result: SecTrustResultType = SecTrustResultType(rawValue: 0)!
            SecTrustEvaluate(serverTrust, &result)
            isServerTrusted = result == SecTrustResultType.unspecified || result ==  SecTrustResultType.proceed
            
            if let localCertificate = getLocalCertificateForUrl(url), isServerTrusted {
                let remoteCertificateData:NSData = SecCertificateCopyData(certificate)
                isServerTrusted = remoteCertificateData.isEqual(to: localCertificate as Data)
            }
            
            if isServerTrusted {
                let credential:URLCredential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
    }
    
    private func getLocalCertificateForUrl(_ url: String) -> NSData? {
        
        if url == "https://ec2-100-26-89-97.compute-1.amazonaws.com/",
            let pathToCert = Bundle.main.path(forResource: "amazonaw", ofType: "cer") {
            return NSData(contentsOfFile: pathToCert)
        } else if url == "https://parsify-format.p.rapidapi.com/",
            let pathToCert = Bundle.main.path(forResource: "rapidapi", ofType: "cer") {
            return NSData(contentsOfFile: pathToCert)
        }
        
        return nil
    }
    
}
