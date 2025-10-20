import Foundation

struct Wallet: Codable, Identifiable {
    let id: String
    let holderName: String
    let currency: String
    var balance: Double
}

struct Transaction: Codable, Identifiable {
    let id: String
    let amount: Double
    let currency: String
    let status: String
    let createdAt: String
    let from: WalletRef
    let to: WalletRef
    
    struct WalletRef: Codable {
        let id: String
    }
}

// GraphQL DTOs
struct WalletQueryData: Decodable {
    let wallet: Wallet?
}

struct WalletsQueryData: Decodable {
    let wallets: [Wallet]
}

struct TransactionsQueryData: Decodable {
    let transactions: [Transaction]
}

struct SendMoneyMutationData: Decodable {
    let sendMoney: Transaction
}
