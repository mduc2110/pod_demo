import SwiftUI

final class ResultViewController: ViewController {
    private var imageUrl: String = ""

    static func newInstance(imageUrl: String) -> ResultViewController {
        let vc = ResultViewController()
        vc.imageUrl = imageUrl
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setContentView(content: ResultView(imageUrl: imageUrl))
    }
}

struct ResultView: View {
    let imageUrl: String

    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
                    .scaledToFit()
            default:
                ProgressView()
                    .scaledToFit()
            }
        }
    }
}
