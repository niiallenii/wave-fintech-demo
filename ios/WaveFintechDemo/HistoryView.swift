import SwiftUI

struct HistoryView: View {
    @State private var items: [Transaction] = []
    @State private var isLoading = false
    @State private var error: String? = nil
    
    var body: some View {
        List {
            if let e = error {
                Text(e).foregroundColor(.red)
            }
            ForEach(items) { tx in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(tx.status) • \(tx.currency) \(String(format: "%.2f", tx.amount))").font(.headline)
                    Text("From: \(tx.from.id) → To: \(tx.to.id)").font(.subheadline)
                    Text(tx.createdAt).font(.caption).foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("History")
        .toolbar {
            Button(action: load) { if isLoading { ProgressView() } else { Text("Refresh") } }
        }
        .onAppear(perform: load)
    }
    
    private func load() {
        isLoading = true
        error = nil
        let q = """
        query Tx($id: ID, $limit: Int) {
          transactions(walletId: $id, limit: $limit) {
            id amount currency status createdAt from { id } to { id }
          }
        }
        """
        GraphQLClient.shared.perform(query: q, variables: ["id": AnyEncodable("u1"), "limit": AnyEncodable(50)]) { (result: Result<TransactionsQueryData, Error>) in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data): items = data.transactions
                case .failure(let err): error = err.localizedDescription
                }
            }
        }
    }
}
