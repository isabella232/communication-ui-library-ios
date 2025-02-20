//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

class AuthenticationHelper {
    static func getCommunicationToken(tokenUrl: URL) -> TokenRefresher {
        struct TokenResponse: Decodable {
            let token: String
        }
        return { completionHandler in
            var urlRequest = URLRequest(url: tokenUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
            urlRequest.httpMethod = "GET"
            URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        let res = try JSONDecoder().decode(TokenResponse.self, from: data)
                        print(res.token)
                        completionHandler(res.token, nil)
                    } catch let error {
                        print(error)
                    }
                }
            }.resume()
        }
    }
}
