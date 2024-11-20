---
title: "Steam Games Explorer - README"
output: github_document
---

# Steam Games Explorer

Welcome to the application for **Gaming Meets Data: Steam Insights**! This project is a Shiny app that enables users to interactively explore and analyze data from Steam's gaming platform using the data set steam_games from the `datateachr` package. Through this app, users can gain insights into review trends, analyze missing data, and filter games based on various criteria.

---

## Features

### Table Tab
This tab displays the game data in an interactive table format. Users can:
- Search for specific games by name.
- Filter games by the percentage of positive reviews.
- Set a minimum threshold for the number of reviews.

The filtered results are dynamically displayed in a sortable and searchable table for easy exploration.

---

### Scatterplot Tab
The scatterplot visualizes relationships between the number of reviews and the percentage of positive reviews. Users can:
- Filter the data by the release year of the games.
- Adjust the range of review counts to focus on games with a specific number of reviews.
- Select specific review categories (e.g., "Very Positive", "Mixed") to customize the dataset displayed in the scatterplot.

The plot updates interactively based on the applied filters, helping users identify trends and insights.

---

### Missing Data Tab
This tab provides a barplot showing the percentage of missing values for selected variables. Users can:
- Use a slider to filter variables based on their percentage of missing data (e.g., show only variables with 0-25% missing data).
- Choose specific variables to include in the barplot using a checkbox selection.
- View dynamically updated barplots with missing data percentages labeled on each bar for clarity.

This feature allows users to analyze data completeness and identify gaps in the dataset effectively.

---

## File Directory

The project files are structured as follows:

- `README.md`: This file provides an overview of the project, its features, and instructions for running the app.
- `app.R`: The main source code file for the Shiny app. This file contains both the UI and server logic to run the application.
- `rsconnect/shinyapps.io/juliekmunkvad/`: A folder containing deployment-related files for publishing the app to ShinyApps.io.
- 
---

## How to Run the App

### Option 1: Run Online

The app is hosted on ShinyApps.io for convenient access. Open the link below in your browser to launch the app:

[Gaming Meets Data: Steam Insights on ShinyApps.io]([https://your-shinyapp-url.shinyapps.io/SteamGamesExplorer/](https://juliekmunkvad.shinyapps.io/assignment-b3-juliekmunkvad/))

---

### Option 2: Run Locally in RStudio

To run the app locally, follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/stat545ubc-2024/assignment-b3-juliekmunkvad.git

2. Ensure that the required packages are installed:
   install.packages(c("shiny", "tidyverse", "DT", "datateachr"))

3. Open the app.R file in RStudio.
   
4. Click the "Run App" button to launch the application.
