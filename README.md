# Wave-Style Fintech App (Demo) — Swift, SwiftUI, Node.js, GraphQL

A minimal **end-to-end demo** that mirrors core Wave-style flows: **wallet balance**, **P2P send**, **pay merchant**, and **transaction history**.

- **Backend:** Node.js + Apollo GraphQL (in‑memory store)
- **iOS App:** SwiftUI (no 3rd‑party deps), simple GraphQL HTTP client via `URLSession`

> This is a demo for interview/portfolio purposes. It is not production-ready (no auth, no persistence, no encryption).

---

## Quick Start

### 1) Backend (GraphQL API)

```bash
cd backend
npm install
npm run dev
# Server: http://localhost:4000/graphql
```

You can open the GraphQL sandbox in your browser to test queries/mutations.

**Sample Query**:
```graphql
query GetWallet($id: ID!) { 
  wallet(id: $id) { id holderName currency balance }
}
```
**Vars:**
```json
{"id": "u1"}
```

**Sample Mutation (Send Money):**
```graphql
mutation Send($from: ID!, $to: ID!, $amount: Float!) { 
  sendMoney(fromId: $from, toId: $to, amount: $amount) { 
    id amount currency status createdAt from { id } to { id } 
  } 
}
```
**Vars:**
```json
{"from": "u1", "to": "u2", "amount": 15.5}
```

### 2) iOS App (SwiftUI)

1. Open Xcode → **Create a new iOS App** named `WaveFintechDemo` (SwiftUI, Swift).
2. Replace the auto-generated files with the contents in `ios/WaveFintechDemo` (or copy these files into your project).
3. Ensure the backend is running on your machine at `http://localhost:4000/graphql`.
4. Run on Simulator. Try **Refresh**, **Send Money**, and check **History**.

> If you run the app on a device, ensure your phone can reach your dev machine (change the base URL in `GraphQLClient.swift`).

---

## Project Structure

```
wave-fintech-demo/
├── backend/
│   ├── package.json
│   └── src/
│       ├── index.js
│       ├── schema.js
│       └── data.js
└── ios/
    └── WaveFintechDemo/
        ├── WaveFintechDemoApp.swift
        ├── ContentView.swift
        ├── SendView.swift
        ├── HistoryView.swift
        ├── Models.swift
        └── GraphQLClient.swift
```

---

## Notes & Next Steps

- Add **Auth** (JWT / OAuth), **Persistence** (Postgres/Prisma), and **Validation**.
- Swap the hand-rolled GraphQL client with **Apollo iOS** if desired.
- Add **Background tasks**, **Push notifications**, **Localization**, and **Accessibility** to harden the app.

MIT License.
