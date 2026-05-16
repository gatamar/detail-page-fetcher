//
//  ContentViewModel.swift
//  detail-page-fetcher
//
//  Created by olia on 5/16/26.
//

import Observation
import Foundation

struct Mathematician: Decodable, Identifiable {
    let id: String
    let name: String
    let lifespan: String
    let category: String?
    let knownFor: String?
    let imageUrl: String?
}

@Observable
class ContentViewModel {
    private var mathematiciansLoaded = [Mathematician]()
    private(set) var mathematicians = [Mathematician]()
    private var fetchTask: Task<Void, Never>?

    func search(_ query: String) {
        guard !query.isEmpty else {
            mathematicians = mathematiciansLoaded
            return
        }
        mathematicians = mathematiciansLoaded.filter { $0.name.contains(query) }
    }

    func fetchData() {
        fetchTask = Task {
            let request = URLRequest(url: .init(string: "http://127.0.0.1:8000/mathematicians-list.json")!)
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let decoder = JSONDecoder()
                let records = try decoder.decode([Mathematician].self, from: data)
                await MainActor.run { [weak self] in
                    self?.mathematiciansLoaded = records
                    self?.mathematicians = records
                }
            } catch {
                print("Fetch failed: \(error)")
            }
        }
    }
    
    func cancelFetch() {
        fetchTask?.cancel()
        fetchTask = nil
    }
}
