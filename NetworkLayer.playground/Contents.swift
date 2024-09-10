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

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { throw NetworkError.invalidResponse }

        return data
    }

    func fetch<T: Decodable>(_ model: T.Type) async throws -> T {
        let data = try await fetchData()
        do {
            let result = try JSONDecoder().decode(T.self, from: data)
            return result
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}

extension AsyncNetworkManager {
    enum NetworkError: String, Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case decodingFailed

        var errorDescription: String? {
            return NSLocalizedString(rawValue, comment: "")
        }
    }

    func handleError(_ error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: Calling...

let host = "api.magicthegathering.io"
let path = Path.v1Cards
//let path = Path.wrongURL
let queryItems = [URLQueryItem(name: "name", value: "Opt|Black Lotus")]
let model = Cards.self

let networkManager = AsyncNetworkManager(host: host, path: path, queryItems: queryItems)

Task {
    do{
        let result = try await networkManager.fetch(model)

        result.cards.forEach( { card in
            if card.name == "Opt" || card.name == "Black Lotus" {
                print("""
                    \(card.name.uppercased()) card:
                    cmc: \(card.cmc ?? 0)
                    set name: \(card.setName)
                    number: \(card.number ?? "No number")
                    power: \(card.power ?? "Doesn't matter")
                    artist: \(card.artist ?? "Unknowm")\n
                    """)
                }
            })
    } catch {
        networkManager.handleError(error)
    }
}
