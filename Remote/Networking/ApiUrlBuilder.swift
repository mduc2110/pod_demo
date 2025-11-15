import Foundation

class ApiUrlBuilder {
    private let initUrl: String
    private var queries: [String: [Any]] = [:]

    init(initUrl: String) {
        self.initUrl = initUrl
    }

    func query(key: String, value: Any?) -> ApiUrlBuilder {
        if let value {
            if queries[key] == nil {
                queries[key] = [value]
            } else {
                queries[key]?.append(value)
            }
        }

        return self
    }

    func query(key: String, values: [Any]) -> ApiUrlBuilder {
        for value in values {
            _ = query(key: key, value: value)
        }
        return self
    }

    func build() -> String {
        guard !queries.isEmpty else { return initUrl }
        return buildUrlWithParams()
    }

    private func buildUrlWithParams() -> String {
        var components = URLComponents(string: initUrl)

        var queryItems: [URLQueryItem] = []

        for (key, values) in queries {
            for value in values {
                let stringValue = String(describing: value)
                queryItems.append(URLQueryItem(name: key, value: stringValue))
            }
        }

        components?.queryItems = queryItems

        if let finalUrl = components?.url?.absoluteString {
            return finalUrl
        } else {
            return initUrl
        }
    }
}
