internal class PodApiResponseInterceptor: ApiResponseInterceptor {
    func onSuccess(curl: String, data: any Codable) {
        Logger.i("ApiResponseInterceptor", curl)
        Logger.i("ApiResponseInterceptor", String(describing: data))
    }
    
    func onError(curl: String, error: any Error) {
        Logger.i("ApiResponseInterceptor", curl + "\n\(error)")
    }
}
