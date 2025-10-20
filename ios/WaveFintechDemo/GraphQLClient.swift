import Foundation

struct GraphQLRequest: Encodable {
    let query: String
    let variables: [String: AnyEncodable]?
}

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}

final class GraphQLClient {
    static let shared = GraphQLClient()
    private init() {}
    
    // Change baseURL if testing on device (use your machine IP)
    private let baseURL = URL(string: "http://localhost:4000/graphql")!
    
    func perform<T: Decodable>(query: String, variables: [String: AnyEncodable]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = GraphQLRequest(query: query, variables: variables)
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(body) else {
            completion(.failure(NSError(domain: "encode", code: -1)))
            return
        }
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { data, _, error -> Void in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "nodata", code: -2))); return
            }
            do {
                let root = try JSONDecoder().decode(GraphQLResponse<T>.self, from: data)
                if let err = root.errors?.first {
                    completion(.failure(NSError(domain: "graphql", code: -3, userInfo: [NSLocalizedDescriptionKey: err.message])))
                } else if let value = root.data {
                    completion(.success(value))
                } else {
                    completion(.failure(NSError(domain: "graphql", code: -4)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLError]?
}

struct GraphQLError: Decodable {
    let message: String
}
