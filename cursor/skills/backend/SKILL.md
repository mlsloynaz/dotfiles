# Backend Skill — Payment Processing & Reference

Use this skill when working on payment processors, payment flows, logging, or debugging payment issues. Always check the KB and remember: **every processor is different**; most answers are "it depends."

---

## KB links (check first)

- **Credit Card Processors:** http://kb/Freedom_Suite/Integrations/Payment_Processors/Credit_Card_Processors  
- **Tokenized CC Processors:** http://kb/Freedom_Suite/Integrations/Payment_Processors/Credit_Card_Processors/Tokenized_CC_Processors  

---

## Golden rules

- **Every processor is different.** There are similarities, but the answer to most payment processing questions is **"it depends."**
- **Negative IDs:** A `PaymentTypeID` or processor ID with a **negative number** is custom-built for that client.
- **Order creation:** Once a payment of any type is made, we create the order. A partially-paid order left in Entered status has much more visibility than an incomplete `OnlineOrder`.

---

## Development standards (new payment processor integration)

**Reference:** By Arianna Capasso. Use when developing a new payment processor integration.

### Coding

- **Do not hardcode URLs.** Production and test URLs belong in detail fields on the account (e.g. `CCAccount`, `TokenizedPaymentAccounts`).
- **Do Auth/Capture as one operation** when possible. **Do not wait until shipping to capture.** Most merchants capture on shipment; we capture immediately because reps receive value (volume towards bonus) when the order posts.
- **Payments record must support void/refund.** Store everything the processor needs: transaction number, order description, or any other required data.
- **We do not use processor recurring-payment features.** We use our own AutoShip; clients control when those orders run.
- **Secure all communication with the gateway.** HTTPS everywhere. If a disconnected processor uses a landing page, allow **only HTTPS**.
- **Think “How could someone exploit this?”** for every data exchange—especially **Disconnected** or **Tokenized** flows where part of the transaction happens outside our system.
- **Assume all incoming data is tampered.** If a user returns from a disconnected processor with a post saying they paid $100, **call the processor to confirm** they actually paid $100.

### Testing

- **Use processor test card numbers** when provided.
- If the processor has no test numbers, our **standard test card** `4111111111111111` can be used; it often returns “Invalid Card Number”—some processors accept it. Even a failure confirms the gateway received the request.
- For live-card testing, prefer a **gift card** if available.
- **Use $0.01** when possible. Some gateways have minimums; if a real charge happens, keep the amount minimal.
- **Credit (refund) all test charges**, especially when using a real card.
- **Log all test transactions** performed with the card.

### Logging (development standards)

- **Never log or store the CVV.** Not in `Log_WebService`, `Log_WebService_Payments`, Graylog, or any other log used by the processor integration. It is against regulations.
- **Never log full credit card numbers.** Obfuscate in all logs: `XXXX…` plus last four digits only.
- **Log_WebService_Payments:** Populate **CCProcessorID** and **CCAccountID** when this is a credit card processor.
- **Request and Response** in `Log_WebService_Payments` should be **as close to raw** as possible and **human-readable.** No CVV; obfuscate card numbers.
- **Serialize what you send/receive:** XML → store the XML; form POST → serialize form data; complex objects → serialize (so you see real data later, not `Object[]`).

---

Logging is essential for diagnosing payment processor problems. We're dealing with people's money—don't lose any.

| What | Where to record |
|------|------------------|
| **Completed payment** | `Payments` table |
| **Declined payment attempt** | `PaymentDeclines` table |
| **Request/response to external processor** | `Log_WebService_Payments` table |

**Log_WebService_Payments** should include when possible:

- `SubjectID` / `SubjectTypeID`
- `CCProcessorID` and `CCAccountID`
- **Raw response** from the processor

---

## Payment vs payout

- **Payments** = money customers/reps pay **to** our clients (goods/services).
- **Payouts** = money clients pay **out** to reps (bonus). Payouts are a bonus function and are **not** covered here.

A rep might use a debit card for a purchase while bonus payouts use the same account—these are **two separate, independent** actions. This document does not address payout functions.

---

## Payment types (PaymentTypes table)

**Reference:** By Arianna Capasso.

To list payment types:

```sql
SELECT TOP 100 * FROM PaymentTypes WITH (NOLOCK) ORDER BY PaymentTypeID
```

- **Negative PaymentTypeID** = custom for that client.

**Roles of payment types:**

| Role | Example | Purpose |
|------|---------|--------|
| Record that a payment was made | Cash | No extra data needed. |
| Record info for later research | Check | Stores Check Number, etc. |
| Record info for research/refunds in third-party systems | Credit Card, Disconnected | Detail fields hold tokens, refs, etc. |

### Credit Card

- **Bulk of payment traffic.** Most "tokenized" processors are handled as Credit Card now.
- **Detail1** contains either:
  - An **encrypted** card number (non-tokenized), usually starting with something like `E04_`, or
  - An **unencrypted token** string (tokenized).

### Tokenized Processor

- **For new development, treat as obsolete.** Use Credit Card payment type instead.
- Only covers three processors: **Adyen**, **CyberSource**, **Authorize.net Tokenized**.
- Originally for "disconnected processors that allowed AutoShip"; we now treat them like credit card processors.
- Fields are **not** fully defined by `PaymentTypes`; each processor defines them via the **`TransactionDetail…`** columns in **`TokenizedPaymentProcessors`**.

### Debit Card

- **Rarely** do we add a new Debit Card processor; when we do, it’s often for **bonus payouts** as well.
- **Auth = hold on funds.** An authorization (e.g. creating an AutoShip profile) can hold funds in the user’s account—avoid if possible; **void immediately** when appropriate.

### Disconnected

- User is **redirected to a third-party site** to complete payment.
- **Typically does not support AutoShip** (user not present for AutoShip runs).
- **Flow:** Our "request" page → redirect to third-party → third-party redirects back to our "receive" / "response" page.

**Other types** (out of scope here): eCheck, Check, Check Draft, Money Order, Wire Transfer, Cash, ACH, Gift Card, Bank Deposit, System Credit.

---

## Basic payment flow (cart example)

Rep in shopping cart → enters card number, expiration, CVV → clicks "Process Order" → thank-you screen.

In between:

1. Client has one or more **Credit Card Accounts** (each tied to a **Credit Card Processor** / gateway).
2. We call the **gateway API** → gateway talks to card network (Visa, Amex, etc.) → network talks to issuing bank.
3. Gateway returns success/failure; we proceed or show decline.

---

## Anatomy of a credit card number

- **Length:** Usually 16 digits; can be 13–19 depending on card type.
- **Last digit:** Check digit for the **Luhn (mod-10)** algorithm. You can validate that a number *could* be a valid CC# before sending to the gateway.
- **CVV (Card Verification Value / CSC):** 3 digits (4 for Amex), printed on the card.
  - **DO NOT STORE THE CVV.** Storing it violates PCI and is not permitted.
  - Sending CVV indicates card-present; can lower fraud risk and fees.
  - We may collect it in cart or BackOffice, but we must never persist it (and it won’t be available for Party or AutoShip).

---

## Payment functions: Auth, Capture, Void, Credit

| Function | Purpose |
|----------|--------|
| **Authorize** | Asks if the card is authorized to pay the amount to the merchant. |
| **Capture / Settlement** | Tells the issuing bank to complete the transaction. |
| **Void / Cancel** | Cancels a prior capture; usually only until the bank processes captures overnight that day. |
| **Credit / Refund** | After void is no longer possible, credit returns money to the cardholder. |

**Notes:**

- We usually do **Auth + Capture together** (single Auth/Capture). We capture immediately because volume is awarded when the order posts (rep gets value); we don’t hold auths.
- **Debit:** Auth can act as a "hold" on funds for a few days; less of an issue since we don’t hold auths open.
- **Credits** often have higher fees than **voids**—prefer void when still possible.

---

## Where is payment entered?

Orders (and thus payment) can be created in **BackOffice**, **Shopping Cart**, **Party**, or **AutoShip**. Limitations differ by context:

- **Cart / BackOffice:** Full card data (name, number, exp, CVV) can be entered; CVV must not be stored.
- **Party:** We should not expect hosts to write down CVVs; CVV may not be available.
- **AutoShip:** Card may be on file from a prior payment (we store token/pan, **not** CVV); CVV is not available at order time.

---

## When is the payment made? Real-time, batched, AutoShip, disconnected

- **Real-time:** Most integrations. User submits → we call gateway → auth/capture → order done.
- **Batched:** Uncommon for credit cards (more for checks/bank transfers). We have an Amex batch file sent nightly, but payments were captured in real time; the file is an Amex requirement.
- **AutoShip:** Card profile exists from user entry or from the payment that started the AutoShip (no CVV stored). We charge on schedule.
- **Disconnected processors:** We **redirect the user to the gateway**. They pay there and may return later (or not). We lose control of the session but gain flexibility (e.g. many payment options). We only need to know whether payment completed.

---

## Fraud detection & 3D Secure

- **Fraud detection:** Some processors (or merchant-account config) use amount, shipping address, etc. We have integrations with MaxMind, ThreatMetrix, and Kount; newer tokenized processors often include similar services.
- **3D Secure (Visa):** Extra verification (e.g. password challenge). May be configured in the client’s merchant account.

---

## Encryption

**Reference:** By Arianna Capasso. AES-256 replaced RC4 with epic **BDT-173**.

Encrypted values stored for later decryption use a **prefix** so we know which method to use:

| Prefix | Method |
|--------|--------|
| **E01_** | Original method: `EncryptionHelper.EncryptLocal()`. |
| **E02_** | Was used then abandoned. |
| **E03_** | Tokenization server: value is a token used to retrieve the original string from the tokenization server. |
| **E04_** | **AES-256.** Current preference. |

**Where encryption is called**

- **Single entry point:** `Util.Encryption` → `EncryptionHelper.Encrypt()`.
- **.NET:** References this library directly.
- **Extranet / BackOffice ASP:** Call **BackOffice SecurityAPI.asmx**, which calls the same library.
- **Extranet CCAUtil.aspx:** Encryption for **CC Avenue** disconnected processor only.
- **u_encryption** database procedure: **Deprecated.**

### AES-256 (single-source implementation)

Based on Microsoft docs and the CS work in:  
`SOA/Business/ByDesign.Business.Services/Clients/newulife/Helpers/AESEncoder.cs`  
([Aes Class - System.Security.Cryptography](https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.aes)).

- **Key:** 256-bit string. Company-wide **constant**, hardcoded in `Util.Encryption` `EncryptionHelper`.  
  **If this key is lost or changed, we cannot decrypt any data encrypted with it for any client.**
- **IV (Initialization Vector):** 128-bit (16-byte) string. **Client-specific**, stored in **`ByDesign.dbo.Clients.AES256_InitializationVector`**.  
  An insert trigger should set it for new clients; **tr_AuditClients** audits changes. **DO NOT EDIT.** If the IV changes, we cannot decrypt that client’s data.

**Security:** Key and IV are stored in separate places (both must be compromised). Per-client IV limits impact if one client is compromised.

### Setting up AES on a new client

1. Ensure the client has **`AES256_InitializationVector`** set in **`ByDesign.dbo.Clients`**.
2. IV must be **16 bytes** and **unchanged** from its initial value.
3. For an example of generating a new 128-bit (16-byte) IV, see the **Trigger_InitializeEncryptionKeys** trigger on **ByDesign.Clients**.
4. **Do not overwrite** an existing **AES256_InitializationVector**.
5. Set **USE_AES256_ENCRYPTION = 1**.
6. Newly encrypted values should use the **E04_** prefix.

---

## Quick reference

- **KB:** Credit Card Processors + Tokenized CC Processors (links above).  
- **Logging:** Completed → `Payments`; Declined → `PaymentDeclines`; All request/response → `Log_WebService_Payments` with SubjectID/Type, processor/account IDs, raw response.  
- **Negative PaymentTypeID / processor ID** = client-specific custom.  
- **Create the order** once any payment is made; prefer visible partially-paid order over stuck `OnlineOrder`.  

*Sources: ByDesign Standards Library — Payment Processing 101; Development Standards (gitlab/bd/ByDesignStandardsLibrary — General/Standards/Payment Processing).*
