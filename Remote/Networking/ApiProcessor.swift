import Alamofire
import Foundation

public class ApiProcessorFactory {
    private let session: Session
    private let responseInterceptor: ApiResponseInterceptor

    public init(
        session: Session,
        responseInterceptor: ApiResponseInterceptor,
    ) {
        self.session = session
        self.responseInterceptor = responseInterceptor
    }

    func create() -> ApiProcessor {
        ApiProcessor(
            session: session,
            responseInterceptor: responseInterceptor,
        )
    }
}

internal class ApiProcessor {

    // Connector
    private let session: Session
    private let responseInterceptor: ApiResponseInterceptor

    //
    private var url: String = ""
    private var headers: HTTPHeaders = [:]

    // Construct
    fileprivate init(
        session: Session,
        responseInterceptor: ApiResponseInterceptor,
    ) {
        self.session = session
        self.responseInterceptor = responseInterceptor
    }

    func setUrl(url: String) -> ApiProcessor {
        self.url = url
        return self
    }

    func putHeader(_ name: String, _ value: String?) -> ApiProcessor {
        if value != nil {
            headers[name] = value
        }
        return self
    }

    func get<T: Codable>() async throws -> T {
        return try await process(
            request: session.request(
                url,
                method: .get,
                headers: headers,
            )
        )
    }

    func post<T: Codable>(bodyParams: Parameters) async throws -> T {
        return try await process(
            request: session.request(
                url,
                method: .post,
                parameters: bodyParams,
                encoding: JSONEncoding.default,
                headers: headers,
            )
        )
    }

    private func process<T: Codable>(request: DataRequest) async throws -> T {
        let response = await request.serializingResponse(
            using: DataResponseSerializer.data
        ).response

        do {
            switch response.result {
            case .success(let data):
                let wrapper = try JSONDecoder().decode(
                    PodResponse<T>.self,
                    from: data,
                )

                let errorCode = wrapper.code ?? 0
                if errorCode != 200 {
                    throw AppServiceException(
                        errorCode,
                        wrapper.message ?? "Something went wrong",
                    )
                }

                let data = try wrapper.data.require()
                responseInterceptor.onSuccess(
                    curl: request.cURLDescription(),
                    data: data,
                )
                return data

            case .failure(let error):
                throw error

            }
        } catch {
            responseInterceptor.onError(
                curl: request.cURLDescription(),
                error: error,
            )
            throw error
        }
    }
}
