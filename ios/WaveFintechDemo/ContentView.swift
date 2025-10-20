import SwiftUI

struct ContentView: View {
    @State private var myWallet: Wallet? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if let w = myWallet {
                    Text("Hello, \(w.holderName)").font(.headline)
                    Text("Balance: \(w.currency) \(String(format: "%.2f", w.balance))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                } else {
                    Text("No wallet loaded").foregroundColor(.secondary)
                }
                
                HStack {
                    NavigationLink(destination: SendView()) {
                        Text("Send Money")
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)
                    
                    NavigationLink(destination: HistoryView()) {
                        Text("History")
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.bordered)
                }
                
                Button(action: loadMe) {
                    if isLoading { ProgressView() } else { Text("Refresh") }
                }
                .padding(.top, 8)
                
                if let msg = errorMessage {
                    Text(msg).foregroundColor(.red).font(.caption)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Wave Demo")
            .onAppear(perform: loadMe)
        }
    }
    
    private func loadMe() {
        isLoading = true
        errorMessage = nil
        let q = """
        query GetWallet($id: ID!) {
          wallet(id: $id) { id holderName currency balance }
        }
        """
        GraphQLClient.shared.perform(query: q, variables: ["id": AnyEncodable("u1")]) { (result: Result<WalletQueryData, Error>) in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    self.myWallet = data.wallet
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }
}
