library(shiny)
library(tidyverse)
library(shinythemes)
library(plotly)
library(ggplot2)
library(shinydashboard)
library(dplyr)
library(semantic.dashboard)

data <- read.csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2018/2018-09-04/fastfood_calories.csv")

restaurants <- sort(unique(data$restaurant))
items <- sort(unique(data$item))


ui <- fluidPage(
  titlePanel("KNOW YOUR FAST FOODS"),
  tags$style(HTML("
    body {
            background-color: Black;
            color: white;
            }")),
  helpText("Take a look at how your favourite items fare in terms of their nutrients."),
  theme = shinytheme("slate"),

  sidebarPanel(
    img(src="https://media.istockphoto.com/photos/delivery-fast-food-concept-picture-id1309966291?b=1&k=20&m=1309966291&s=170667a&w=0&h=nQRyZ0JbKJADh9vIONle7NDsdQta2jeNwu3HgQjjGWM=",width="100%")

    ),
           br(),

    mainPanel(
      tabsetPanel(
        id = "tabs",
        tabPanel(
          title = "Comparison",
          br(),
          h3("How healthy is your favourite fast food restaurant? Lets compare!!"),

          selectInput(
            inputId = "rest", label = "Restaurant Name",
            choices = restaurants, multiple = T
          ),
          br(),
           plotOutput("plot", width = "700px", height = "700px"),


),
br(),

tabPanel(
  title = "Protein Distribution",
           br(),

           h3("Have a look at the protein distribution in these food items!"),
           selectInput(
             inputId = "item", label = "Pick any item",
             choices = items, multiple = F
           ),
           br(),

           plotOutput("protein_plot", width = "400px", height = "400px"),
),
br(),

tabPanel(
  title = "Cholesterol Quantity",
           h3("Pick a restaurant  from the below options to see their top 5 items with the highest cholesterol"),
  radioButtons("choice", "Choice:",
               c("Mcdonalds",
                 "Chick Fil-A",
                 "Sonic",
                 "Arbys",
                 "Burger King",
                 "Subway",
                 "Taco Bell"
               )),

  # br() element to introduce extra vertical spacing ----
  br(),

  plotOutput("chol_plot", width = "700px", height = "700px"),
),

br(),
tabPanel(
  title = "About",
    fluidRow(
      column(10,
             div(class = "about",
                 uiOutput('about'))
      )
    )
  ),

includeCSS("styles.css")
)
)
)



server <- function(input, output, session) {
  output$plot <- renderPlot({
    rest <- req(input$rest)
    data %>%
      filter(restaurant %in% rest) %>%
      ggplot(aes(x = total_fat, y = calories, colour = restaurant , group =item)) +
      labs(title="Total Fat vs Calories in restaurants")+
      xlab("Total Fat")+
      ylab("Calories") +
      geom_line() +
      geom_point() +
      facet_wrap(vars(restaurant), ncol = 1)
  })

  output$protein_plot <- renderPlot({

    protein_content <- reactive({
        # MODIFY CODE BELOW: Filter for the selected item
        data %>%
        filter(item == input$item) %>%
        select(protein)
    })

    ggplot(protein_content()) +
      aes(x =protein,fill=input$item) +
      geom_histogram(bins = 30L) +
      scale_fill_hue() +
      theme_minimal()
  })



  output$chol_plot <- renderPlot({

    top_5_items <- reactive({
      data %>%
        # MODIFY CODE BELOW: Filter for the selected rest
        filter(restaurant == input$choice) %>%
        head(sort(cholesterol,decreasing=TRUE),n=5)
    })

    # Plot top 5 names
    ggplot(top_5_items(), aes(x = item, y = cholesterol, fill=item))+
      geom_col() +
       coord_flip()
  })

    output$about <- renderUI({
      knitr::knit("about.Rmd", quiet = TRUE) %>%
        markdown::markdownToHTML(fragment.only = TRUE) %>%
        HTML()
    })
}

shinyApp(ui = ui, server = server)
