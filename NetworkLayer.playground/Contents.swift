import Foundation

// MARK: Model

public struct Cards: Decodable {
    let cards: [Card]
}

public struct Card: Decodable {
    var name: String
    var cmc: Int?
    var setName: String
    var number: String?
    var power: String?
    var artist: String?
}

// MARK: URL Creation

enum Path: String {
    case v1Cards = "/v1/cards"
    case wrongURL = "/v0/neverfindable"
}



// MARK: Network Manager

final class AsyncNetworkManager {
    var host: String
    var path: Path
    var queryItems: [URLQueryItem]

    init(host: String, path: Path, queryItems: [URLQueryItem]) {
        self.host = host
        self.path = path
        self.queryItems = queryItems
    }

    private func createURL(path: Path, queryItems: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path.rawValue
        components.queryItems = queryItems
        return components.url
    }

    private func createRequest(url: URL?) -> URLRequest? {
        guard let url else { return nil }
        let request = URLRequest(url: url)
        return request
    }

    private func fetchData() async throws -> Data {
guard let url = createURL(path: path, queryItems: queryItems),
      let urlRequest = createRequest(url: url) else { throw NetworkError.invalidURL }
    }
}

extension AsyncNetworkManager {
    enum NetworkError: String, Error, LocalizedError {
        case invalidURL
        case invalidRequest
        case decodingFailed

        var errorDescription: String? {
            return NSLocalizedString(rawValue, comment: "")
        }
    }
}
