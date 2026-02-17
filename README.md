# Quackle (Wordle Clone) 🦆

A mobile word-guessing game built with **Flutter**, inspired by the popular game [Wordle](https://www.nytimes.com/games/wordle/index.html).

> **Note:** This project is created for **educational purposes only** to demonstrate mobile application development concepts, state management, and local data persistence.

## ✨ Features
* **Classic Gameplay:** Guess a 5-letter word in 6 tries.
* **Visual Feedback:**
    * 🟩 **Green:** Correct letter in the correct spot.
    * 🟨 **Yellow:** Correct letter in the wrong spot.
    * ⬜ **Grey:** Letter not in the word.
* **Mock Authentication System:** Simulate login flow with user profiles.
* **Economy System:** Earn coins for every correct word guessed.
* **Data Persistence:** Coins, game history, and found words are saved locally using `shared_preferences`.
* **Dictionary Check:** Validates guesses against a valid English dictionary.

## 🛠 Tech Stack
* **Framework:** Flutter (Dart)
* **State Management:** `setState` (StatefulWidget)
* **Local Storage:** `shared_preferences`
* **Asset Management:** Custom JSON/Text file parsing

## 🚀 How to Run

1.  **Clone the repository**
    **HTTPS**
    ```bash
    git clone https://github.com/whoosh09/MobileProject_204311.git
    ```
    **SSH**
    ```bash
    git clone git@github.com:whoosh09/MobileProject_204311.git
    ```
2.  **Install dependencies**
    ```bash
    flutter pub get
    ```
3.  **Run the app**
    * **For Mobile (Recommended):**
        ```bash
        flutter run
        ```
    * **For Web (Chrome):**
        To ensure data persistence works correctly on the web, specify a fixed port:
        ```bash
        flutter run -d chrome --web-port=5000
        ```

## 🔐 Mock Credentials (For Testing)
Use these pre-configured accounts to test the application:

| Username | Password | Initial Coins | Description |
| :--- | :--- | :--- | :--- |
| **`a`** | **`a`** | 10 | Low balance user |
| **`b`** | **`b`** | 0 | New user (Empty state) |
| **`c`** | **`c`** | 0 | New user (Empty state) |
| **`d`** | **`d`** | 0 | New user (Empty state) |

## ⚖️ Disclaimer & Credits
This project is a clone created for learning purposes. It is **not** affiliated with, associated with, or endorsed by The New York Times or Josh Wardle.

* **Original Game Concept:** [Josh Wardle](https://twitter.com/powerlanguish)
* **Current Rights Holder:** [The New York Times](https://www.nytimes.com/games/wordle/index.html)

<!-- ---
Developed by [] -->
