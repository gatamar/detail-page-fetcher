//
//  ContentView.swift
//  detail-page-fetcher
//
//  Created by olia on 5/16/26.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    private var viewModel = ContentViewModel()
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.mathematicians, id: \.id) { person in
                    NavigationLink {
                        MathematicianDetailView(person: person)
                    } label: {
                        MathematicianListView(person: person)
                    }

                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer)
        }
        .task {
            viewModel.fetchData()
        }
        .onChange(of: self.searchText) { oldValue, newValue in
            viewModel.search(searchText)
        }
    }
}

#Preview {
    ContentView()
}

private struct MathematicianListView: View {
    let person: Mathematician
    var body: some View {
        VStack {
            Text(person.name).font(.title3)
            if let knownFor = person.knownFor {
                Text(knownFor + ", " + person.lifespan)
            }
        }
    }
}

private struct MathematicianDetailView: View {
    let person: Mathematician
    var body: some View {
        VStack {
            Text(person.name).font(.title3)
            if let knownFor = person.knownFor {
                Text(knownFor + ", " + person.lifespan)
            }
            if let imageUrl = person.imageUrl {
                AsyncImage(url: .init(string: imageUrl)) { imagePhase in
                    switch imagePhase {
                    case .empty:
                        ProgressView("Loading...")
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure(let error):
                        Text("Failed to load image: \(error.localizedDescription)").padding()
                    @unknown default:
                        assertionFailureView("async image state not implemented")
                    }
                }
            }
        }
    }
    
    private func assertionFailureView(_ message: String) -> EmptyView {
        assertionFailure(message)
        return EmptyView()
    }
}
