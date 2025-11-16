struct PrintResultData: Codable {
    let success: Bool
    let datasetName: String
    let gender: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case success = "success"
        case datasetName = "dataset_name"
        case gender = "gender"
        case imageUrl = "image_url"
    }
}