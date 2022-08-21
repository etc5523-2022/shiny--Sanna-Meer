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
  helpText("Take a look at how your favourite items fare in terms of nutrients."),
  theme = shinytheme("superhero"),

  sidebarPanel(
    img(src="data:image/jpeg;base64,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",width="100%")

    ),
           br(),

    mainPanel(
      tabsetPanel(
        id = "tabs",
        tabPanel(
          title = "Plot1",
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
  title = "Plot2",
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
  title = "Plot2",
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

    fluidRow(
      column(10,
             div(class = "about",
                 uiOutput('about'))
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
      labs(title="Total fat vs calories in restaurants")+
      xlab("Total Fat")+
      ylab("Calories") +
      geom_line() +
      geom_point() +
      facet_wrap(vars(restaurant), ncol = 1)
  })

  output$protein_plot <- renderPlot({
    F <- data %>% filter(restaurant%in%c("Taco Bell","Arbys","Chick Fil-A","Dairy Queen","Mcdonalds"))
    ggplot(F) +
      aes(x = protein, fill = input$item) +
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
