import Foundation

/// Debug version of AuthenticationService to test different endpoints
class AuthenticationServiceDebug {
    private let baseURL = "https://breathesafe.xyz"
    
    /// Test login with different endpoints and formats
    func testLogin(email: String, password: String, completion: @escaping (String) -> Void) {
        let endpoints = [
            "/users/log_in",
            "/users/sign_in",
            "/users/sessions"
        ]
        
        let formats = [
            "form": [
                "user[email]": email,
                "user[password]": password
            ],
            "json": [
                "user": [
                    "email": email,
                    "password": password
                ]
            ]
        ]
        
        for endpoint in endpoints {
            for (formatName, parameters) in formats {
                testEndpoint(endpoint: endpoint, format: formatName, parameters: parameters) { result in
                    completion("\(endpoint) (\(formatName)): \(result)")
                }
            }
        }
    }
    
    private func testEndpoint(endpoint: String, format: String, parameters: [String: Any], completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if format == "json" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        } else {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let formString = parameters.map { key, value in
                "\(key)=\(value)"
            }.joined(separator: "&")
            request.httpBody = formString.data(using: .utf8)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? -1
            let responseText = String(data: data ?? Data(), encoding: .utf8) ?? "No response"
            completion("Status: \(statusCode), Response: \(responseText.prefix(100))")
        }.resume()
    }
}