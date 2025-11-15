public protocol ApiResponseInterceptor {
    func onSuccess(curl: String, data: Codable)
    func onError(curl: String, error: Error)
}
