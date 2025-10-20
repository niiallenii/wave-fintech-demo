import { gql } from 'graphql-tag';

export const typeDefs = gql`
  scalar DateTime

  type Wallet {
    id: ID!
    holderName: String!
    currency: String!
    balance: Float!
  }

  type Transaction {
    id: ID!
    amount: Float!
    currency: String!
    status: String!
    createdAt: String!
    from: Wallet!
    to: Wallet!
  }

  type Query {
    wallet(id: ID!): Wallet
    wallets: [Wallet!]!
    transactions(walletId: ID, limit: Int = 20): [Transaction!]!
  }

  type Mutation {
    sendMoney(fromId: ID!, toId: ID!, amount: Float!): Transaction!
    payMerchant(walletId: ID!, merchantId: ID!, amount: Float!): Transaction!
    deposit(walletId: ID!, amount: Float!): Wallet!
    withdraw(walletId: ID!, amount: Float!): Wallet!
  }
`;
