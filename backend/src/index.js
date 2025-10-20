import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import { typeDefs } from './schema.js';
import { wallets, transactions, transfer, pay } from './data.js';

const resolvers = {
  Query: {
    wallet: (_, { id }) => wallets[id] ?? null,
    wallets: () => Object.values(wallets),
    transactions: (_, { walletId, limit }) => {
      let t = transactions;
      if (walletId) {
        t = t.filter(tx => tx.from.id === walletId || tx.to.id === walletId);
      }
      return t.slice(-limit).reverse();
    }
  },
  Mutation: {
    sendMoney: (_, { fromId, toId, amount }) => {
      transfer(fromId, toId, amount);
      const tx = {
        id: `tx_${Date.now()}`,
        amount,
        currency: wallets[fromId].currency,
        status: "SUCCESS",
        createdAt: new Date().toISOString(),
        from: wallets[fromId],
        to: wallets[toId]
      };
      transactions.push(tx);
      return tx;
    },
    payMerchant: (_, { walletId, merchantId, amount }) => {
      pay(walletId, merchantId, amount);
      const tx = {
        id: `tx_${Date.now()}`,
        amount,
        currency: wallets[walletId].currency,
        status: "SUCCESS",
        createdAt: new Date().toISOString(),
        from: wallets[walletId],
        to: wallets[merchantId]
      };
      transactions.push(tx);
      return tx;
    },
    deposit: (_, { walletId, amount }) => {
      if (amount <= 0) throw new Error("Amount must be positive");
      const w = wallets[walletId];
      if (!w) throw new Error("Wallet not found");
      w.balance += amount;
      return w;
    },
    withdraw: (_, { walletId, amount }) => {
      if (amount <= 0) throw new Error("Amount must be positive");
      const w = wallets[walletId];
      if (!w) throw new Error("Wallet not found");
      if (w.balance < amount) throw new Error("Insufficient funds");
      w.balance -= amount;
      return w;
    }
  }
};

const app = express();
app.use(cors());
app.use(bodyParser.json());

const server = new ApolloServer({ typeDefs, resolvers });
await server.start();
app.use('/graphql', expressMiddleware(server));

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`GraphQL server ready at http://localhost:${PORT}/graphql`);
});
