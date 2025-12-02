# Volleyball Team Generator & Scoreboard

## Overview

This application is a comprehensive tool for volleyball enthusiasts, designed to simplify team creation, manage scores, and track game statistics. It offers a user-friendly interface that allows users to create balanced teams from a list of players, customize game settings, and keep track of scores in real-time. The app also provides detailed statistics for each game, making it easy to analyze performance and identify areas for improvement.

## Key Features

### 1. Team Management
- **Create and Manage Teams**: Users can create and manage teams by adding players from a predefined list.
- **Balanced Team Generation**: The app automatically generates balanced teams based on player skills and availability.
- **Customizable Team Colors**: Users can assign unique colors to each team for easy identification.

### 2. Real-Time Scoreboard
- **Live Score Tracking**: The app features a real-time scoreboard that allows users to track scores for each team during a match.
- **Set and Timeout Management**: Users can manage sets and timeouts for each team, ensuring fair play and adherence to game rules.
- **Game and Set Winner Notifications**: The app provides clear notifications for set and game winners, making it easy to follow the match's progress.
- **Drawer Navigation**: A drawer has been added to the scoreboard for easy access to settings, team management, and team building screens.

### 3. Customizable Settings
- **Theme Customization**: Users can choose between light, dark, and system default themes to personalize the app's appearance.
- **Game Rules**: The app allows users to customize game rules, such as the maximum score per set and the number of timeouts per team.
- **Color-Coded Teams**: Users can assign custom colors to each team for better visual organization and identification.

### 4. Detailed Statistics
- **Game and Set History**: The app records detailed statistics for each game, including scores, sets won, and timeouts used.
- **Performance Analysis**: Users can view and analyze game statistics to identify trends and improve their gameplay.

### 5. Code Architecture
- **Provider State Management**: The app uses the provider package for state management, with separate providers for players, settings, and theme.
- **Refactored Providers**: The providers have been refactored into their own files for better organization and maintainability.

## Navigation Flow

1.  **Home Screen**: The app will open to the `HomeScreen`, where users can start a new game.
2.  **Scoreboard**: From the `HomeScreen`, users can navigate to the `PlacarScreen` to track scores in real-time.
3.  **Drawer Navigation**: The `PlacarScreen` now has a drawer for navigating to:
    -   **Settings**: Customize the app's appearance and game rules.
    -   **Team Management**: Create and manage teams.
    -   **Team Builder**: Automatically generate balanced teams.

## Current Plan

I have successfully implemented the following features:

-   **Refactored the providers** into separate files for better organization.
-   **Improved the UI of the `PlacarScreen`** by adding a `Drawer` for navigation.
-   **Fixed various analysis issues** to ensure code quality.

Next, I will:

-   Create a `HomeScreen` to serve as the new entry point for the app.
-   Add a button to the `HomeScreen` to navigate to the `PlacarScreen`.
-   Update the `main.dart` file to use the `HomeScreen` as the home widget.
