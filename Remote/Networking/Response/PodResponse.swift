public class PodResponse<T: Codable>: Codable {
    public let data: T?
    public let code: Int?
    public let message: String?

    init(
        data: T?,
        code: Int?,
        message: String?,
    ) {
        self.data = data
        self.code = code
        self.message = message
    }

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case code = "code"
        case message = "message"
    }

    deinit {
        cleanup()
    }

    @inline(never)
    private func cleanup() {}
}
