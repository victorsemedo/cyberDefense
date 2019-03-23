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
    
    var trustedServer = [String: Bool]()
    
    private var currentUrl = ""
    
    private override init() {
    }
    
    func validateServerSecurity(url: String, callback: @escaping (_ result: Bool) -> Void) {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue:OperationQueue.main)
        
        if let urlObj = URL(string: url) {
            var request = URLRequest(url: urlObj)
            request.httpMethod = "POST"
            currentUrl = url
            let task = session.dataTask(with: request) { data, response, error in
                guard let _ = data, error == nil else {
                    callback(false)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    callback(false)
                } else {
                    callback(true)
                }
            }
            task.resume()
        } else {
            callback(false)
        }
    }
}

extension CyberDefenseApi: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if let serverTrust = challenge.protectionSpace.serverTrust,
            let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            let policies = NSMutableArray();
            policies.add(SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString)))
            SecTrustSetPolicies(serverTrust, policies);
            
            var result: SecTrustResultType = SecTrustResultType(rawValue: 0)!
            SecTrustEvaluate(serverTrust, &result)
            let isServerTrusted:Bool = result == SecTrustResultType.unspecified || result ==  SecTrustResultType.proceed
            self.trustedServer[currentUrl] = isServerTrusted
            
            let remoteCertificateData:NSData = SecCertificateCopyData(certificate)
            let pathToCert = Bundle.main.path(forResource: "amazonawscom", ofType: "cer")
            let localCertificate:NSData = NSData(contentsOfFile: pathToCert!)!
            
            if (isServerTrusted && remoteCertificateData.isEqual(to: localCertificate as Data)) {
                let credential:URLCredential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }

        
    }
    
}
