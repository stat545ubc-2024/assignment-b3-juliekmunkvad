library(shiny)
library(tidyverse)
library(DT)
library(datateachr)

# Prepare the dataset and calculate the percentage of missing values
sg_data <- steam_games %>%
  mutate(all_reviews = ifelse(all_reviews == "NaN", NA, all_reviews)) %>% # Replace invalid "NaN" with NA
  filter(!is.na(all_reviews)) %>% # Filter out rows with missing "all_reviews"
  separate(all_reviews, into = c("review_text", "review_count", "positive_percent"), 
           sep = ",\\s*\\(|\\)\\s*,\\s*-\\s*|%", # Split "all_reviews" into three components
           extra = "drop", 
           remove = FALSE) %>%
  mutate(
    review_count = as.numeric(gsub(",", "", review_count)),  # Convert review_count to numeric
    positive_percent = as.numeric(positive_percent), # Convert positive_percent to numeric
    year = as.numeric(format(as.Date(release_date, format = "%b %d, %Y"), "%Y")) # Extract release year
  )

# Calculate the percentage of missing values for each variable
missing_data <- sg_data %>%
  summarise_all(~ mean(is.na(.)) * 100) %>% # Calculate missing percentages
  pivot_longer(cols = everything(), names_to = "variable", values_to = "missing_percentage") # Reshape data

# User Interface
ui <- fluidPage(
  titlePanel("Gaming Meets Data: Steam Insights"), # Application title
  
  sidebarLayout(
    sidebarPanel(
      # Dynamically show filters based on the active tab
      conditionalPanel(
        condition = "input.tabs == 'Table'", # Filters for the Table tab
        textInput("search_name", "Search by game name:", value = ""),
        sliderInput("positive_filter", "Filter games by positive reviews percentage:", 
                    min = 0, max = 100, value = c(0, 100)),
        numericInput("min_reviews", "Minimum number of reviews:", value = 0, min = 0)
      ),
      conditionalPanel(
        condition = "input.tabs == 'Scatterplot'", # Filters for the Scatterplot tab
        numericInput("scatter_year", "Filter by release year:", value = NA, min = 1981),
        sliderInput("review_count_range", "Filter by number of reviews:", 
                    min = min(sg_data$review_count, na.rm = TRUE), 
                    max = max(sg_data$review_count, na.rm = TRUE), 
                    value = c(50, 5000)),
        checkboxGroupInput("review_category", "Filter by review category:", 
                           choices = unique(sg_data$review_text), 
                           selected = unique(sg_data$review_text))
      ),
      conditionalPanel(
        condition = "input.tabs == 'Missing Data'", # Filters for the Missing Data tab
        sliderInput("missing_filter", 
                    "Filter variables by missing percentage:", 
                    min = 0, max = 100, value = c(0, 100)),
        checkboxGroupInput("selected_variables", 
                           "Choose variables to display:", 
                           choices = unique(missing_data$variable), 
                           selected = unique(missing_data$variable))
      )
    ),
    
    mainPanel(
      tabsetPanel(
        id = "tabs", # ID to track the active tab
        tabPanel("Table", DT::dataTableOutput("games_table")), # Table display
        tabPanel("Scatterplot", plotOutput("scatter_plot")), # Scatterplot display
        tabPanel("Missing Data", plotOutput("missing_data_plot")) # Barplot for missing values
      )
    )
  )
)

# Server logic
server <- function(input, output, session) {
  
  # Dynamically render UI based on the active tab
  output$filter_ui <- renderUI({
    if (input$tabs == "Table") {
      tagList(
        textInput("search_name", "Search by game name:", value = ""),
        sliderInput("positive_filter", "Filter games by positive reviews percentage:", 
                    min = 0, max = 100, value = c(0, 100)),
        numericInput("min_reviews", "Minimum number of reviews:", value = 0, min = 0)
      )
    } else if (input$tabs == "Scatterplot") {
      tagList(
        numericInput("scatter_year", "Filter by release year:", value = NA, min = 1981),
        sliderInput("review_count_range", "Filter by number of reviews:", 
                    min = min(sg_data$review_count, na.rm = TRUE), 
                    max = max(sg_data$review_count, na.rm = TRUE), 
                    value = c(50, 5000)),
        checkboxGroupInput("review_category", "Filter by review category:", 
                           choices = unique(sg_data$review_text), 
                           selected = unique(sg_data$review_text))
      )
    }
  })
  
  # Filtered data for the table
  filtered_table_data <- reactive({
    req(input$tabs == "Table") # Ensure filtering only occurs when the Table tab is active
    sg_data %>%
      filter(
        positive_percent >= input$positive_filter[1],
        positive_percent <= input$positive_filter[2],
        review_count >= input$min_reviews,
        if (input$search_name != "") {
          str_detect(name, regex(input$search_name, ignore_case = TRUE))
        } else {
          TRUE
        }
      )
  })
  
  # Filtered data for the scatterplot
  filtered_scatter_data <- reactive({
    req(input$tabs == "Scatterplot") # Ensure filtering only occurs when the Scatterplot tab is active
    sg_data %>%
      filter(
        if (!is.na(input$scatter_year)) {
          year == input$scatter_year
        } else {
          TRUE
        },
        review_text %in% input$review_category,
        review_count >= input$review_count_range[1],
        review_count <= input$review_count_range[2]
      )
  })
  
  # Filtered data for the missing data barplot
  filtered_missing_data <- reactive({
    req(input$tabs == "Missing Data") # Ensure filtering only occurs when the Missing Data tab is active
    missing_data %>%
      filter(
        missing_percentage >= input$missing_filter[1],
        missing_percentage <= input$missing_filter[2],
        variable %in% input$selected_variables
      )
  })
  
  # Render the table
  output$games_table <- DT::renderDataTable({
    req(input$tabs == "Table") # Ensure the table only updates when its tab is active
    filtered_table_data() %>%
      select(name, review_text, review_count, positive_percent, release_date, year) %>%
      datatable(
        options = list(pageLength = 10, autoWidth = TRUE),
        rownames = FALSE
      )
  })
  
  # Render the scatterplot
  output$scatter_plot <- renderPlot({
    req(input$tabs == "Scatterplot") # Ensure the scatterplot only updates when its tab is active
    filtered <- filtered_scatter_data()
    
    ggplot(filtered, aes(x = review_count, y = positive_percent)) +
      geom_point(alpha = 0.7, color = "darkorange") +
      labs(
        title = "Relationship Between Review Count and Positive Percent",
        x = "Number of Reviews",
        y = "Positive Reviews (%)"
      ) +
      theme_minimal()
  })
  
  # Render the barplot for missing data
  output$missing_data_plot <- renderPlot({
    req(input$tabs == "Missing Data") # Ensure the barplot only updates when its tab is active
    filtered <- filtered_missing_data()
    
    ggplot(filtered, aes(x = reorder(variable, -missing_percentage), y = missing_percentage)) +
      geom_bar(stat = "identity", fill = "darkorange") +
      geom_text(aes(label = paste0(round(missing_percentage, 1), "%")), 
                hjust = -0.1, size = 3) + # Add percentages on bars
      coord_flip() + # Flip axes for readability
      labs(
        title = "Missing Data Percentage by Variable",
        x = "Variable",
        y = "Missing Percentage (%)"
      ) +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5)) # Center the title
  })
}

# Start the Shiny app
shinyApp(ui = ui, server = server)
