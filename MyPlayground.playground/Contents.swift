import UIKit

await fetchAndProcessData()

func fetchData(from url: URL) async throws -> Data {
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}

func fetchAndProcessData() async {
    do {
        let apiUrl = URL(string: "https://api.themoviedb.org/3/trending/all/day?api_key=5f2529f61e78a56c76db3a5d0d7b8790")!
        let data = try await fetchData(from: apiUrl)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response: \(responseString)")
        } else {
            print("Unable to convert data to string")
        }
    } catch {
        print("Error: \(error)")
    }
}
