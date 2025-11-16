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

    func postMultipart<T: Codable>(
        multipartFormData: @escaping (MultipartFormData) -> Void
    ) async throws -> T {
        return try await processMultipart(
            url: url,
            method: .post,
            headers: headers,
            multipartFormData: multipartFormData
        )
    }

    private func process<T: Codable>(request: DataRequest) async throws -> T {
        let response = await request.serializingResponse(
            using: DataResponseSerializer.data
        ).response

        do {
            switch response.result {

            case .success(let data):
                if response.response?.statusCode != 200 {
                    throw AppServiceException(
                        response.response?.statusCode ?? 0,
                        "Something went wrong",
                    )
                }

                let data = try JSONDecoder().decode(T.self, from: data)

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

    private func processMultipart<T: Codable>(
        url: String,
        method: HTTPMethod,
        headers: HTTPHeaders,
        multipartFormData: @escaping (MultipartFormData) -> Void
    ) async throws -> T {
        let uploadRequest = session.upload(
            multipartFormData: multipartFormData,
            to: url,
            method: method,
            headers: headers
        )
        
        let response = await uploadRequest.serializingResponse(
            using: DataResponseSerializer.data
        ).response

        do {
            switch response.result {

            case .success(let data):
                print("Result: \(String(data: data, encoding: .utf8))")
                if response.response?.statusCode != 200 {
                    throw AppServiceException(
                        response.response?.statusCode ?? 0,
                        "Something went wrong",
                    )
                }

                let decodedData = try JSONDecoder().decode(T.self, from: data)

                responseInterceptor.onSuccess(
                    curl: uploadRequest.cURLDescription(),
                    data: decodedData,
                )
                return decodedData

            case .failure(let error):
                throw error

            }
        } catch {
            responseInterceptor.onError(
                curl: uploadRequest.cURLDescription(),
                error: error,
            )
            throw error
        }
    }
}
