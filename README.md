# Beauty Tips App (iOS Practical)

This is an iOS application built as part of a practical assignment. The app displays various beauty tips (Face, Hair, Eyes, etc.) fetched from a remote API. It demonstrates modern iOS development practices including MVVM architecture, offline caching, and dynamic localization with RTL support.

## Core Features
- **Categorized Tips:** Browse beauty tips by category (Face, Hair, Lips, Teeth, etc.).
- **Detail View:** Displays an image and formatted HTML description of the selected tip.
- **MVVM Architecture:** Clean separation of concerns between UI and business logic.
- **Programmatic & Storyboard UI:** Uses a mix of Storyboards and code for building the UI and Navigation flow.

## Implemented Bonus Tasks

1. **Language Switcher & RTL Support** 
   - A globe icon in the navigation bar lets the user switch between English, Hindi, Telugu, Arabic, Spanish, and French.
   - When Arabic is selected, the app automatically switches to a Right-to-Left (RTL) layout dynamically—without needing to restart the app. All system icons, alignments, and navigation bars adapt instantly.

2. **Offline Cache** 
   - Network responses are cached locally using `UserDefaults`.
   - If the user opens the app without an internet connection (or if the API fails), the app seamlessly loads the last cached data so the user isn't stuck with an empty screen.

3. **Favorites System** 
   - Users can "favorite" a tip from the detail screen using the heart icon.
   - Favorited tips are saved persistently and accessible via the dedicated "Favorites" tab in the bottom tab bar.
   - Favorites maintain full localization support and translate dynamically when the app language changes.

4. **Search Functionality** 
   - Real-time search bar implemented using `UISearchController` on the category lists. Filters results dynamically as the user types.

5. **Pull to Refresh** 
   - Integrated `UIRefreshControl` on the list screens to let users manually fetch the latest data from the server.

6. **Share Sheet** 
   - Integrated `UIActivityViewController` on the detail screen so users can share the tip's title and description natively with other apps.

## Architecture
- **Model-View-ViewModel (MVVM):** Chosen to ensure a clean separation between business logic and UI. The ViewModels handle data fetching, parsing, and caching, leaving the ViewControllers lightweight and focused strictly on updating the UI based on state changes (`.loading`, `.loaded`, `.error`).

## UI Framework Choice & Why
- **UIKit (Storyboards + Programmatic):** We used UIKit instead of SwiftUI. UIKit was chosen for its precise control over view lifecycles and layout transitions—especially necessary for manipulating the `UISearchController` across tab switches and injecting dynamic global layout changes. Storyboards were used to rapidly build the static UI, while programmatic UI (e.g., TabBar setup in `SceneDelegate` and RTL layout flipping) was used where dynamic control was required.

## Anything Skipped & Why
- **Heavy Database (CoreData/Realm):** We skipped implementing a heavy database for the Offline Cache and Favorites system. Why? The JSON dataset is extremely lightweight. Using `UserDefaults` with `JSONEncoder`/`JSONDecoder` is significantly faster to implement, requires zero schema migrations, and is perfectly optimal for this scale without over-engineering the app.
- **Dark Mode:** We explicitly disabled Dark Mode (`overrideUserInterfaceStyle = .light`) and skipped its implementation. Why? Without explicit color semantics and assets provided for a dark theme, forcing light mode ensures the UI matches the intended design perfectly without unpredictable color inversions.

## Time Spent
- **Total Time:** Approximately 5 to 6 hours (Including all 6 bonus tasks).

## Setup Instructions

1. Clone or download the repository.
2. Open `Nihar_Practical.xcodeproj` in Xcode.
3. Wait for Xcode to resolve dependencies (Kingfisher via Swift Package Manager).
4. Select a simulator or physical device and hit Run (`Cmd + R`).

No extra configuration or API keys are required.
