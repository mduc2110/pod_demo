import Alamofire
import Foundation

public class MeshService {
    private let url: String
    private let factory: ApiProcessorFactory

    init(
        url: String,
        factory: ApiProcessorFactory
    ) {
        self.url = url
        self.factory = factory
    }

    func healthCheck() async throws -> HealthCheckData {
        let builder = ApiUrlBuilder(initUrl: url)

        return try await factory.create()
            .setUrl(url: builder.build())
            .get()
    }

    func getFinalResult(
        stickerImage: Data,
    ) async throws -> PrintResultData {
        let builder = ApiUrlBuilder(initUrl: url + "print")

        return try await factory.create()
            .setUrl(url: builder.build())
            .postMultipart { multipartFormData in
                // Add sticker_image as file (Data)
                multipartFormData.append(
                    stickerImage,
                    withName: "sticker_image",
                    fileName: "image.jpg",
                    mimeType: "image/jpeg"
                )
                
                // Add dataset_name as simple string value
                multipartFormData.append("data1".data(using: .utf8)!, withName: "dataset_name")
                
                // Add gender as simple string value
                multipartFormData.append("male".data(using: .utf8)!, withName: "gender")
                
                // Add keep_white as simple string value
                multipartFormData.append("true".data(using: .utf8)!, withName: "keep_white")
            }
    }
}
