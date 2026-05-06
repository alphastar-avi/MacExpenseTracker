# CashFlow

CashFlow is a premium, offline-first personal finance tracker built natively for macOS. Designed with a sleek, minimalist interface inspired by Apple's own design principles, CashFlow helps you track your income and expenses with complete privacy. Your financial data never leaves your Mac.


---

## Features

* **Visual Cash Flow:** A stunning, native Sankey diagram built in SwiftUI Canvas visually maps your money from Income → Budget → Expenses.
* **Offline-First Privacy:** All transactions and categories are stored locally on your device using SwiftData. No cloud, no tracking.
* **Local Vault Security:** Protect your financial data by requiring a Master Passcode upon launching the application.
* **CSV Export:** Easily export your entire transaction history to a CSV file for tax purposes or backup.
* **Dynamic Categories:** Fully customize your expense categories via the Settings panel.
* **Responsive Layout:** A fluid two-column layout that gracefully adapts to different window sizes and supports macOS Dark Mode.

---

## Local Vault Security

CashFlow acts as a secure local vault. Since financial data is sensitive, you have the option to secure the application without needing to create an online account.

**Configuration Settings:**
* **Require Passcode:** Toggle this on to require a master password whenever the app is launched or locked.
* **Lock Vault:** Quickly secure your data when stepping away from your desk.

---

## Requirements

* macOS 14.0 (Sonoma) or later
* Built exclusively for Apple Silicon and Intel Macs using SwiftUI and SwiftData.

---

## Data Privacy & Storage

Unlike web-based trackers, CashFlow uses **zero network requests**. All transaction data, user preferences, and hashed passcodes are stored directly inside your macOS user container using Apple's `SwiftData` framework and the `Keychain`. If you delete the app and its container, your data is permanently destroyed unless you have exported a CSV backup.

---

## Sandbox Permissions

Because CashFlow is a sandboxed macOS application, it requires your explicit permission to save CSV files to your file system. When you click "Download CSV" for the first time, macOS will securely prompt you to choose exactly where you want the file saved.

"
