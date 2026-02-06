# VB Bank Mobile 🏦

A full-featured **mock mobile banking application** built with Flutter — the cross-platform companion to the VB Bank web app. All data is simulated and stored locally on-device; no real financial transactions are performed.

![Flutter](https://img.shields.io/badge/Flutter-3.27-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.6-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey)

---

## ✨ Features

| Category | Details |
|----------|---------|
| **Authentication** | Login / Register with validation, biometric login (Face ID / Fingerprint), quick-login demo accounts |
| **Dashboard** | Account balance (tap to hide), quick action buttons, recent transactions, live crypto prices, currency exchange rates |
| **Transfers** | User search with autocomplete, amount validation against balance, dual transaction records |
| **Top-Up** | Quick amount buttons ($50 – $2,000), custom amount input |
| **Bill Payments** | 8 utility providers, account number input, reference number generation |
| **Virtual Cards** | Card carousel with PageView, tap-to-flip animation (reveals CVV & full number), freeze / unfreeze / block, view PIN with biometric auth, create Visa or Mastercard |
| **Loans** | 4 loan types (Personal, Auto, Home, Education), amount & term sliders, live amortization calculator, auto-approval with balance disbursement |
| **Transaction History** | Search, filter chips (All / Transfers / Deposits / TopUp / Bills / Loans), date-grouped list, detail sheet, CSV export |
| **Settings** | Edit profile, change password, dark / light theme toggle, biometric toggle, app info |
| **Theme** | Glassmorphic dark theme (primary) + clean light theme |

## 🏗️ Architecture

```
lib/
├── main.dart                    # App entry point — Hive init, seeder, providers
├── models/                      # Hive data models + generated adapters
│   ├── user.dart                #   HiveType(0) — 14 fields
│   ├── transaction.dart         #   HiveType(1) — 15 fields
│   ├── card.dart                #   HiveType(2) — VirtualCard, 13 fields
│   ├── loan.dart                #   HiveType(3) — 12 fields, amortization calc
│   └── bill_payment.dart        #   HiveType(4) — 9 fields
├── services/                    # Business logic layer
│   ├── storage_service.dart     #   Singleton — Hive boxes + SharedPreferences
│   ├── auth_service.dart        #   Login, register, session management
│   ├── bank_service.dart        #   Transfers, bills, cards, loans, CSV export
│   ├── crypto_service.dart      #   CoinGecko API (BTC/ETH prices, 60s cache)
│   ├── api_service.dart         #   ExchangeRate-API (8 currencies, 5min cache)
│   ├── biometric_service.dart   #   local_auth wrapper
│   └── seeder.dart              #   Seeds 5 users, 13 txns, 3 cards, 1 loan
├── providers/                   # State management (ChangeNotifier)
│   ├── auth_provider.dart       #   Current user, theme, biometric prefs
│   └── banking_provider.dart    #   Account data, transactions, cards, loans
├── screens/                     # UI screens
│   ├── auth/                    #   login, register, biometric_setup
│   ├── home/                    #   dashboard
│   ├── transfer/                #   transfer
│   ├── history/                 #   history (search, filter, export)
│   ├── topup/                   #   top-up
│   ├── bills/                   #   bill payments
│   ├── cards/                   #   virtual cards (carousel, flip, actions)
│   ├── loans/                   #   loan calculator & application
│   └── settings/                #   profile, password, preferences
├── widgets/                     # Reusable UI components
│   ├── balance_card.dart        #   Gradient card with hide/show balance
│   ├── crypto_widget.dart       #   BTC/ETH portfolio display
│   ├── transaction_item.dart    #   Transaction row with color-coded amounts
│   ├── custom_button.dart       #   Loading state, outlined variant
│   ├── custom_input.dart        #   Label, validation, password toggle
│   ├── custom_card.dart         #   Gradient container with border
│   └── loading_spinner.dart     #   Centered spinner + overlay method
├── routes/
│   └── app_router.dart          # Named routes for all 11 screens
├── theme/
│   ├── colors.dart              # AppColors — dark & light palettes
│   └── app_theme.dart           # Full ThemeData (Material 3, Inter font)
└── utils/
    ├── constants.dart           # Storage keys, API URLs, loan options
    ├── validators.dart          # Form field validators
    └── formatters.dart          # Currency, date, masking helpers
```

## 📦 Tech Stack

| Purpose | Package |
|---------|---------|
| State Management | `provider` |
| Local Storage | `hive` / `hive_flutter` / `shared_preferences` |
| Secure Storage | `flutter_secure_storage` |
| Biometrics | `local_auth` |
| HTTP | `http` |
| Charts | `fl_chart` |
| QR Codes | `qr_flutter` |
| CSV Export | `csv` + `path_provider` |
| Fonts & Icons | `google_fonts` (Inter) / `material_design_icons_flutter` |
| Date Formatting | `intl` |
| Unique IDs | `uuid` |

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.2.0
- Chrome (for web) or Android Studio / Xcode (for mobile)

### Install & Run

```bash
# Clone the repo
git clone <repo-url>
cd vb_bank_mobile

# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on Android emulator
flutter run -d android

# Run on iOS simulator (macOS only)
flutter run -d ios
```

### Demo Accounts

The app is pre-seeded with test users you can use via the quick-login buttons on the login screen:

| Username | Password | Role | Balance |
|----------|----------|------|---------|
| `john.doe` | `password123` | user | $15,000 |
| `jane.smith` | `password123` | user | $22,500 |
| `mike.wilson` | `password123` | user | $8,750 |
| `sarah.jones` | `password123` | user | $31,000 |
| `admin` | `admin123` | admin | $50,000 |

## 🎨 Design System

| Token | Value |
|-------|-------|
| Background | `#0a0e27` (dark) |
| Card | `#111638` (dark) |
| Primary | `#6366f1` (Indigo) |
| Accent | `#22d3ee` (Cyan) |
| Success | `#22c55e` |
| Error | `#ef4444` |
| Font | Inter (Google Fonts) |
| Border Radius | 16px |
| Style | Glassmorphic dark cards |

## 📄 License

This project is for educational and demonstration purposes only.
