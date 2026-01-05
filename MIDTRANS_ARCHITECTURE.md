# 🎨 Midtrans Integration Architecture

## 📐 System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         FLUTTER APPLICATION                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────┐      ┌──────────────────┐                      │
│  │ CheckoutPage   │─────▶│ Midtrans Payment │                      │
│  │                │      │ Page (WebView)   │                      │
│  └────────────────┘      └──────────────────┘                      │
│         │                         │                                 │
│         │                         │                                 │
│         ▼                         ▼                                 │
│  ┌─────────────────────────────────────┐                          │
│  │    MidtransService                   │                          │
│  │  - createTransaction()               │                          │
│  │  - checkTransactionStatus()          │                          │
│  │  - listenToTransactionStatus()       │                          │
│  └─────────────────────────────────────┘                          │
│                    │                                                 │
└────────────────────┼─────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      FIREBASE CLOUD FUNCTIONS                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐        │
│  │  createMidtransTransaction()                            │        │
│  │  ↓                                                      │        │
│  │  1. Validate user & data                               │        │
│  │  2. Call Midtrans Snap API                             │        │
│  │  3. Save to Firestore (transactions)                   │        │
│  │  4. Return payment token & URL                         │        │
│  └────────────────────────────────────────────────────────┘        │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐        │
│  │  handleMidtransNotification()                          │        │
│  │  ↓                                                      │        │
│  │  1. Receive webhook from Midtrans                      │        │
│  │  2. Verify signature                                   │        │
│  │  3. Update transaction status in Firestore             │        │
│  │  4. Update order status if paid                        │        │
│  └────────────────────────────────────────────────────────┘        │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐        │
│  │  checkTransactionStatus()                              │        │
│  │  ↓                                                      │        │
│  │  1. Query Midtrans for status                          │        │
│  │  2. Update Firestore                                   │        │
│  │  3. Return current status                              │        │
│  └────────────────────────────────────────────────────────┘        │
│                    │                                                 │
└────────────────────┼─────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         MIDTRANS API                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  • Snap API (Create Transaction)                                   │
│  • Transaction API (Check Status)                                  │
│  • Webhook Notification                                            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      FIRESTORE DATABASE                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Collections:                                                       │
│  ├─ transactions/                                                   │
│  │  └─ {orderId}                                                    │
│  │     ├─ orderId: "ORDER-1234..."                                 │
│  │     ├─ userId: "abc123"                                         │
│  │     ├─ amount: 150000                                           │
│  │     ├─ status: "pending|success|failed"                         │
│  │     ├─ paymentUrl: "https://..."                                │
│  │     ├─ token: "token123"                                        │
│  │     └─ createdAt: timestamp                                     │
│  │                                                                   │
│  └─ orders/                                                         │
│     └─ {orderId}                                                    │
│        ├─ orderStatus: "processing|paid"                           │
│        └─ paymentStatus: "pending|paid"                            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Payment Flow Sequence

```
User          Flutter App       Firebase         Midtrans       Firestore
 │                │                │                │               │
 │  1. Checkout   │                │                │               │
 ├───────────────▶│                │                │               │
 │                │                │                │               │
 │                │ 2. Create Tx   │                │               │
 │                ├───────────────▶│                │               │
 │                │                │                │               │
 │                │                │ 3. Snap API    │               │
 │                │                ├───────────────▶│               │
 │                │                │                │               │
 │                │                │ 4. Token+URL   │               │
 │                │                │◀───────────────┤               │
 │                │                │                │               │
 │                │                │ 5. Save Data   │               │
 │                │                ├───────────────────────────────▶│
 │                │                │                │               │
 │                │ 6. Return URL  │                │               │
 │                │◀───────────────┤                │               │
 │                │                │                │               │
 │ 7. Show WebView│                │                │               │
 │◀───────────────┤                │                │               │
 │                │                │                │               │
 │  8. Pay        │                │                │               │
 ├────────────────────────────────────────────────▶│               │
 │                │                │                │               │
 │ 9. Redirect    │                │                │               │
 │◀────────────────────────────────────────────────┤               │
 │                │                │                │               │
 │                │                │ 10. Webhook    │               │
 │                │                │◀───────────────┤               │
 │                │                │                │               │
 │                │                │ 11. Update     │               │
 │                │                ├───────────────────────────────▶│
 │                │                │                │               │
 │                │ 12. Listen     │                │               │
 │                ├───────────────────────────────────────────────▶│
 │                │                │                │               │
 │                │ 13. Status     │                │               │
 │                │◀───────────────────────────────────────────────┤
 │                │                │                │               │
 │ 14. Show Result│                │                │               │
 │◀───────────────┤                │                │               │
 │                │                │                │               │
```

---

## 📦 Component Breakdown

### 1. Flutter App Layer

```
┌────────────────────────────────────────┐
│         CheckoutPage.dart              │
│  ┌──────────────────────────────────┐  │
│  │ • Shipping form                  │  │
│  │ • Payment method selection       │  │
│  │ • "PAY WITH MIDTRANS" button     │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
              │
              ▼
┌────────────────────────────────────────┐
│     MidtransPaymentPage.dart           │
│  ┌──────────────────────────────────┐  │
│  │ • WebView container              │  │
│  │ • Loading indicator              │  │
│  │ • URL callback handler           │  │
│  │ • Status listener                │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
              │
              ▼
┌────────────────────────────────────────┐
│     services/midtrans_service.dart     │
│  ┌──────────────────────────────────┐  │
│  │ • createTransaction()            │  │
│  │ • checkTransactionStatus()       │  │
│  │ • listenToTransactionStatus()    │  │
│  │ • getTransactionDetails()        │  │
│  │ • generateOrderId()              │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
```

### 2. Firebase Functions Layer

```
┌────────────────────────────────────────┐
│         functions/index.js             │
│  ┌──────────────────────────────────┐  │
│  │ Exports:                         │  │
│  │ • createMidtransTransaction      │  │
│  │ • handleMidtransNotification     │  │
│  │ • checkTransactionStatus         │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
              │
              ▼
┌────────────────────────────────────────┐
│       functions/midtrans.js            │
│  ┌──────────────────────────────────┐  │
│  │ Midtrans Client Configuration:   │  │
│  │ • Server Key                     │  │
│  │ • Client Key                     │  │
│  │ • Sandbox/Production mode        │  │
│  │                                  │  │
│  │ Business Logic:                  │  │
│  │ • Transaction creation           │  │
│  │ • Webhook processing             │  │
│  │ • Status verification            │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
```

---

## 🎯 Data Flow

### Transaction Creation

```
Request: {
  orderId: "ORDER-1234567890-abc12",
  amount: 150000,
  customerName: "John Doe",
  customerEmail: "john@example.com",
  customerPhone: "081234567890",
  items: [
    {
      id: "prod1",
      name: "Product 1",
      price: 100000,
      quantity: 1
    },
    {
      id: "delivery",
      name: "Delivery Fee",
      price: 50000,
      quantity: 1
    }
  ]
}

         ↓

Midtrans Snap API

         ↓

Response: {
  token: "abc123xyz...",
  redirect_url: "https://app.sandbox.midtrans.com/snap/v2/..."
}

         ↓

Firestore: transactions/{orderId}

         ↓

Return to Flutter: {
  success: true,
  token: "abc123xyz...",
  redirectUrl: "https://..."
}
```

### Webhook Notification

```
Midtrans sends POST to:
https://your-project.cloudfunctions.net/handleMidtransNotification

Body: {
  transaction_status: "settlement",
  order_id: "ORDER-1234567890-abc12",
  gross_amount: "150000.00",
  payment_type: "credit_card",
  transaction_time: "2026-01-05 12:00:00",
  fraud_status: "accept"
}

         ↓

Verify Signature

         ↓

Map Status:
- settlement → success
- capture → success (if fraud_status = accept)
- pending → pending
- deny/cancel/expire → failed

         ↓

Update Firestore:
- transactions/{orderId}.status = "success"
- orders/{orderId}.paymentStatus = "paid"
```

---

## 🔑 Environment Configuration

### Development (Sandbox)
```
┌──────────────────────────────┐
│ Midtrans Sandbox             │
│ • isProduction: false        │
│ • Server Key: SB-xxx         │
│ • Client Key: SB-xxx         │
└──────────────────────────────┘
```

### Production
```
┌──────────────────────────────┐
│ Midtrans Production          │
│ • isProduction: true         │
│ • Server Key: xxx            │
│ • Client Key: xxx            │
└──────────────────────────────┘
```

---

## 📊 Status Mapping

```
Midtrans Status    →    Internal Status    →    Display to User
───────────────────────────────────────────────────────────────
pending            →    pending             →    "Payment Pending"
capture (accept)   →    success             →    "Payment Success"
settlement         →    success             →    "Payment Success"
deny               →    failed              →    "Payment Failed"
cancel             →    failed              →    "Payment Cancelled"
expire             →    failed              →    "Payment Expired"
```

---

## 🛠️ Testing Matrix

```
┌─────────────────┬──────────────┬──────────────┬───────────────┐
│ Payment Method  │ Test Data    │ Expected     │ Status Update │
├─────────────────┼──────────────┼──────────────┼───────────────┤
│ Credit Card     │ 4811...1114  │ Success      │ ✅ Auto      │
│ Credit Card     │ 4911...1113  │ Failed       │ ✅ Auto      │
│ GoPay           │ Any phone    │ Success      │ ✅ Auto      │
│ Bank Transfer   │ BCA VA       │ Pending      │ ⏳ Manual    │
│ BNI VA          │ 988310...15  │ Pending      │ ⏳ Manual    │
└─────────────────┴──────────────┴──────────────┴───────────────┘
```

---

## 📱 UI Flow

```
[Product List]
      │
      ▼
[Shopping Cart]
      │
      ▼
[Checkout Page]
      │
      ├─▶ [NEXT] → Standard Payment Flow
      │
      └─▶ [PAY WITH MIDTRANS]
             │
             ▼
      [Midtrans Payment Page]
             │
             ├─▶ Select: Credit Card
             ├─▶ Select: E-Wallet
             ├─▶ Select: Bank Transfer
             └─▶ Select: Others
                    │
                    ▼
             [Payment Success/Failed Dialog]
                    │
                    ▼
             [Back to Home/Order History]
```

---

**Last Updated:** 2026-01-05
