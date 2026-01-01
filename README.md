# News App - Your Daily Dose of Global Updates

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![NewsAPI](https://img.shields.io/badge/NewsAPI-DD0031?style=for-the-badge&logo=news&logoColor=white)](https://newsapi.org)
[![Provider](https://img.shields.io/badge/Provider-%234DB6AC.svg?style=for-the-badge&logoColor=white)](https://pub.dev/packages/provider)
[![Firebase Auth](https://img.shields.io/badge/Firebase_Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/docs/auth)
[![Google Sign-In](https://img.shields.io/badge/Google_Sign--In-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://pub.dev/packages/google_sign_in)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue.svg)](https://flutter.dev/docs/get-started/install)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/your-username/news_app/pulls)
[![Issues](https://img.shields.io/github/issues/your-username/news_app)](https://github.com/your-username/news_app/issues)

**News App** is a sleek and comprehensive Flutter application designed to keep you informed with the latest headlines from around the globe. Whether you are looking for breaking alerts, trending stories, or in-depth coverage of national and world events, News App delivers it all. 

Security and user experience are paramount; the app features secure **Google Authentication** with automatic **Session Persistence**, ensuring you stay logged in seamlessly. Using **Provider** for state management and **Firebase** for backend authentication, News App offers a modern and responsive news-reading experience.

---

## 📸 Screenshots


<img src="https://github.com/user-attachments/assets/79eff980-308c-4a4f-9b82-7de349897ee0" width="180" height="340" />
<img src="https://github.com/user-attachments/assets/1f332268-85a3-42f7-a702-40ee49961173" width="180" height="340" />
<img src="https://github.com/user-attachments/assets/adc6247b-8343-414a-bd44-8a32a12b3ddb" width="180" height="340" />
<img src="https://github.com/user-attachments/assets/bb003ac9-75ec-4d6a-868b-0112a40c6e1c" width="180" height="340" />
<img src="https://github.com/user-attachments/assets/c0c23152-46d8-4eb1-9bb6-f3fe4d64b18e" width="180" height="340" />
<img src="https://github.com/user-attachments/assets/ca0171ac-b1b4-4a50-8df7-aee2045ce03c" width="180" height="340" />
<img src="https://github.com/user-attachments/assets/66d43641-b6d4-46b3-ba46-d6acbba96ebc" width="180" height="340" />
<img src="https://github.com/user-attachments/assets/936f51c6-e8bc-4ab1-8761-d1a41b8f357c" width="180" height="340" />
<img src="https://github.com/user-attachments/assets/70d9b56d-100e-4f06-8f7d-24740ba5c294" width="180" height="340" />
<img src="https://github.com/user-attachments/assets/8f6616e5-4b73-4873-bcbd-fcbdece54599" width="180" height="340" />

---

## ✨ Highlighted Features

* **Secure Google Sign-In:** Log in quickly and securely using your existing Google account. No need to remember new passwords.
* **Session Persistence:** Once logged in, the app remembers you. Close the app, restart your phone, or switch tasks—your session remains active until you explicitly log out.
* **Dark & Light Mode:** Switch seamlessly between dark and light themes. Whether you prefer a sleek dark look for night reading or a bright interface for the day, the app adapts to your preference.
* **Featured News:** A curated selection of high-impact stories hand-picked to keep you informed on the most critical topics of the day.
* **Breaking News:** Real-time alerts and updates. Never miss a major event as it unfolds with our dedicated breaking news section.
* **Nation:** Stay rooted with extensive coverage of national affairs. Get the latest political, social, and economic updates specific to your country.
* **World:** Go beyond borders with comprehensive international reporting. Understand global perspectives on key issues affecting the planet.
* **Trending:** See what everyone is talking about. Discover the most popular and shared stories across social media and the web.
* **Category:** Filter news by your specific interests. Browse seamlessly through diverse categories such as Business, Technology, Entertainment, Health, Science, and Sports.
* **In-App Web View:** Read the full story without leaving the application. News App integrates a smooth web view experience for reading original source articles.

---
## 📂 Project Structure

The project adheres to a clean **MVVM (Model-View-ViewModel)** architecture to separate UI logic from business logic.

```text
lib/
├── main.dart                          # Application entry point
├── models/
│   └── news_response_model.dart       # JSON parsing logic for API data
├── services/
│   ├── firebase_auth_service.dart     # Handles Google & Email Authentication
│   ├── firestore_service.dart         # Manages User data in Cloud Firestore
│   ├── news_services.dart             # API calls to NewsAPI.org
│   ├── url_launch_service.dart        # Helper for launching external URLs
│   └── utils/
│       ├── app_urls.dart              # Stores API endpoints and keys
│       └── date_formatter.dart        # Helper to format timestamps
├── view_models/                       # State Management (Providers)
│   ├── firebase_auth_view_model.dart  # Manages user session state
│   ├── index_view_model.dart          # Manages bottom navigation index
│   ├── news_view_model.dart           # Handles fetching and filtering articles
│   ├── theme_view_model.dart          # Manages Dark/Light mode state
│   └── toggle_view_model.dart         # Handles UI toggles (e.g. password visibility)
├── views/                             # UI Layer
│   ├── auth/
│   │   ├── forgot_password_screen.dart
│   │   ├── login_screen.dart
│   │   └── signUp_screen.dart
│   ├── home/
│   │   ├── article_web_view.dart      # In-app browser for full articles
│   │   ├── breaking_news_screen.dart  # Dedicated breaking news feed
│   │   ├── detail_screen.dart         # Article details view
│   │   ├── home_screen.dart           # Main dashboard
│   │   ├── main_controller.dart       # Controls navigation between screens
│   │   ├── see_all_screen.dart        # List view for categories
│   │   ├── settings_screen.dart       # Theme and account settings
│   │   └── trending_screen.dart       # Trending news feed
│   ├── profile/
│   │   └── user_profile_screen.dart   # User account details
│   └── splash_screen.dart             # Initial loading screen
└── widgets/                           # Reusable UI Components
    ├── category_pill.dart
    ├── custom_loader.dart
    ├── custom_snackbar.dart
    ├── featured_news_card.dart
    ├── news_list_item.dart
    └── section_header.dart
```
## 🛠️ Technologies Used

* **Flutter:** A powerful UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
* **Provider:** A simple, testable, and widely adopted state management solution for Flutter applications.
* **Firebase Auth:** Handles backend authentication securely, managing user sessions and tokens.
* **google_sign_in:** A Flutter plugin to support Google Sign-In authentication.
* **http:** A composable, Future-based library for making HTTP requests to fetch news data from the API.
* **webview_flutter:** A Flutter plugin that provides a WebView widget for displaying web content within the app.
* **url_launcher:** A plugin for launching URLs in the mobile platform, used for opening external links.
* **intl:** Provides internationalization and localization facilities, used here for date formatting.

---

## 🔐 Authentication & Session Management

**News App** utilizes **Firebase Authentication** to handle user identity and session states.

* **Google Auth Flow:** Users authenticate via the `google_sign_in` package, which obtains an OAuth token. This token is then exchanged with `firebase_auth` to create a secure Firebase session.
* **Persistence:** Firebase Authentication automatically persists the user's login state locally.
* **State Listening:** The app listens to the `FirebaseAuth.instance.authStateChanges()` stream. 
    * If a user is detected, they are automatically navigated to the Home Screen.
    * If no user is found (or upon logout), the app redirects to the Login Screen.
    * This ensures a seamless experience without requiring repeated logins.

---

## 🚦 State Management (Provider)

The application uses **Provider** to keep the app's logic organized and separate from the visual design (UI). Think of it as the "brain" of the application that tells the screen what to show.

### 1. AuthProvider (The Gatekeeper)
This handles everything related to your user account.
* **What it does:** It watches to see if you are currently logged in or logged out.
* **How it helps:** When you open the app, this provider instantly checks your status. If you are logged in, it lets you in. If not, it shows you the login button. It also handles the spinning loading circle while you are signing in.

### 2. NewsProvider (The Content Engine)
This connects to the internet to get the news and prepares it for the screen.
* **What it does:** It fetches the headlines, filters them by category (like Sports or Tech), and handles the data.
* **How it helps:**
    * **Loading:** It tells the screen when to show a loading bar while fetching data.
    * **Errors:** If the internet cuts out or the server fails, it catches the error and tells the screen to show a helpful message (like "No Internet Connection") instead of crashing the app.
    * **Efficiency:** It makes sure we don't download the same news twice if we don't have to.

### 3. ThemeProvider (The Stylist)
* **What it does:** It listens for your "Dark Mode" toggle switch.
* **How it helps:** It instantly repaints the app colors from light to dark (or vice versa) without needing to restart the app.

---

## 🤝 Contributing

We welcome contributions from the community! If you have ideas for new features, bug fixes, or improvements, please feel free to:

1.  Fork the repository.
2.  Create a new branch for your feature or fix.
3.  Implement your changes and write appropriate tests.
4.  Commit your changes following conventional commit guidelines.
5.  Push your branch to your forked repository.
6.  Submit a pull request detailing your changes.

Please ensure your code adheres to the project's coding standards and that your pull request clearly describes the issue or feature you are addressing.

---

## 🙏 Acknowledgements

* The Flutter team for providing an excellent cross-platform development framework.
* **NewsAPI.org** for providing the comprehensive data source.
* **Google Firebase** for providing robust Authentication services.
* The developers and maintainers of all the valuable Flutter packages used in this project.
