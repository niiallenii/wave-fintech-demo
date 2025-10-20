import SwiftUI

struct SendView: View {
    @State private var toId: String = "u2"
    @State private var amountText: String = "10.00"
    @State private var message: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        Form {
            Section(header: Text("Recipient")) {
                TextField("To Wallet ID", text: $toId)
            }
            Section(header: Text("Amount")) {
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
            }
            Section {
                Button(action: send) {
                    if isLoading { ProgressView() } else { Text("Send") }
                }
            }
            if let m = message {
                Section { Text(m).foregroundColor(.secondary) }
            }
        }
        .navigationTitle("Send Money")
    }
    
    private func send() {
        guard let amount = Double(amountText) else { message = "Invalid amount"; return }
        isLoading = true
        let m = """
        mutation Send($from: ID!, $to: ID!, $amount: Float!) {
          sendMoney(fromId: $from, toId: $to, amount: $amount) {
            id amount currency status createdAt from { id } to { id }
          }
        }
        """
        GraphQLClient.shared.perform(query: m, variables: [
            "from": AnyEncodable("u1"),
            "to": AnyEncodable(toId),
            "amount": AnyEncodable(amount)
        ]) { (result: Result<SendMoneyMutationData, Error>) in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    message = "Sent \(data.sendMoney.currency) \(data.sendMoney.amount) to \(data.sendMoney.to.id)"
                case .failure(let err):
                    message = err.localizedDescription
                }
            }
        }
    }
}
