export const wallets = {
  u1: { id: "u1", holderName: "Allen Aryeetey", currency: "GHS", balance: 250.75 },
  u2: { id: "u2", holderName: "Liz", currency: "GHS", balance: 140.00 },
  m1: { id: "m1", holderName: "Shop - Dansoman", currency: "GHS", balance: 0.0 }
};

export const transactions = []; // push mutation results here

export function transfer(fromId, toId, amount) {
  const from = wallets[fromId];
  const to = wallets[toId];
  if (!from || !to) throw new Error("Invalid from/to");
  if (amount <= 0) throw new Error("Amount must be positive");
  if (from.balance < amount) throw new Error("Insufficient funds");
  from.balance -= amount;
  to.balance += amount;
}

export function pay(walletId, merchantId, amount) {
  transfer(walletId, merchantId, amount);
}
