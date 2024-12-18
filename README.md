# RecipeFinderApp

RecipeFinderApp is a robust iOS application designed to help users discover, organize, and manage recipes effortlessly. Leveraging APIs, Core Data, and UIKit, the app provides a seamless user experience for exploring recipes, saving favorites, and managing shopping lists.

## Features

- **Search Recipes:** Find recipes by ingredients and apply dietary filters for a personalized experience.
- **Favorites Management:** Save your favorite recipes for quick access.
- **Shopping List:** Add ingredients to a shopping list and manage them efficiently.
- **Detailed Recipe View:** Explore recipe details, including steps, ingredients, and nutritional information.
- **Filter Recipes:** Apply sorting and filtering options such as vegan, gluten-free, or sugar-free.

## Tech Stack

- **Programming Language:** Swift
- **UI Framework:** UIKit with SnapKit for layout management
- **Networking:** Alamofire for API communication
- **Data Storage:** Core Data for persistent storage
- **API Integration:** [Spoonacular API](https://spoonacular.com/food-api) for fetching recipe data

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/allwsaa/RecipeFinderApp.git
    ```
2. Open the project in Xcode:
    ```bash
    open RecipeFinderApp.xcodeproj
    ```
3. Install dependencies using CocoaPods or Package Dependencies in XCode:
    ```bash
    pod install
    ```
4. Replace the API key in `NetworkManager.swift` with your Spoonacular API key:
    ```swift
    private let apiKey = "your-api-key"
    ```
5. Run the app on a simulator or a physical device.

## App Structure

### Main Components

1. **ViewController:** The home screen displaying a list of recipes with search and filter capabilities.
2. **IngredientsSearchViewController:** A screen for searching recipes by entering ingredients.
3. **RecipeDetailViewController:** Displays detailed information about a selected recipe, including ingredients and steps.
4. **FavoritesViewController:** Manages the list of favorite recipes stored using Core Data.
5. **ShoppingListViewController:** Helps users manage their shopping lists by adding or removing items.
6. **FilterViewController:** Allows users to apply filters and sort recipes.

### Models

- **Recipe:** Represents recipe data fetched from the Spoonacular API.
- **RecipeDetail:** Contains detailed information about a recipe, including steps and ingredients.
- **Ingredient:** Represents individual ingredients in a recipe.
- **RecipeEntity:** Core Data entity for saving favorite recipes.

## Screenshots
<img width="230" alt="1" src="https://github.com/user-attachments/assets/d5c4fee4-fa20-46b0-8fec-1abc58eff3dd" /><img width="230" alt="2" src="https://github.com/user-attachments/assets/91a011e4-bd92-4504-9bec-09a5d415fc6f" /><img width="230" alt="3" src="https://github.com/user-attachments/assets/5cd2fdf1-3245-4ee7-991e-fffc21083cca" /><img width="230" alt="4" src="https://github.com/user-attachments/assets/c1181ca2-d684-40db-8b57-82690ba35543" /><img width="230" alt="5" src="https://github.com/user-attachments/assets/924d7c98-c560-4129-bb60-7c684145dffe" />

## Acknowledgments

- **[Spoonacular API](https://spoonacular.com/food-api)** for providing comprehensive recipe data.
- **[SnapKit](https://github.com/SnapKit/SnapKit)** for simplifying Auto Layout in UIKit.
- **[Alamofire](https://github.com/Alamofire/Alamofire)** for streamlined networking.

## Link to Demo Video of the app

[Demo video](https://youtu.be/Xu8eDMzcdCE?si=9rz6XjYbCXXHIHoj)
---

Made with ❤️ by Aisha and Alima .
