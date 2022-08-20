library(shiny)
library(tidyverse)
library(shinythemes)
library(plotly)
library(shinydashboard)

data <- read.csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2018/2018-09-04/fastfood_calories.csv")

restaurants <- sort(unique(data$restaurant))
items <- sort(unique(data$item))


ui <- fluidPage(
  tags$h2("KNOW YOUR FAST FOODS",
          style="color:yellow;text-align:center"),
  theme = shinytheme("superhero"),
           h3("How healthy is your favourite fast food restaurant? Lets compare!!"),

           selectInput(
             inputId = "rest", label = "Restaurant Name",
             choices = restaurants, multiple = T
           ),
           plotOutput("plot", width = "800px", height = "800px"),
           br(),

           h3("Have a look at the protein distribution in these foods!"),

           selectInput(
             inputId = "item", label = "Item Name",
             choices = items, multiple = F
           ),
           plotOutput("protein_plot", width = "400px", height = "400px"),

           h3("Pick an item from the below options to see its nutrient breakdown"),
  radioButtons("choice", "Choice:",
               c("Big Mac" = "big",
                 "Spicy Deluxe" = "spi",
                 "Whopper with Cheese" = "whopper",
                 "Footlong B.L.T." = "foot",
                 "Shredded Chicken Burrito" = "burrito")),

  # br() element to introduce extra vertical spacing ----
  br(),

  plotOutput("nutrient_plot", width = "400px", height = "400px"),


    fluidRow(
      column(10,
             div(class = "about",
                 uiOutput('about'))
      )
    ),


includeCSS("styles.css")
)




server <- function(input, output, session) {
  output$plot <- renderPlot({
    rest <- req(input$rest)
    data %>%
      filter(restaurant %in% rest) %>%
      ggplot(aes(x = total_fat, y = calories, colour = restaurant , group =item)) +
      labs(title="Total fat and calories in restaurants")+
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

  output$nutrient_plot <- renderPlot({
    F <- data %>% filter(item%in%c("Big Mac","Spicy Deluxe","Whopper with Cheese","Footlong B.L.T.","Shredded Chicken Burrito"))
    ggplot(F) +
      aes(x = input$item, y= sugar, fill = sugar) +
      geom_col() +
      scale_fill_hue() +
      theme_minimal()
  })




    output$about <- renderUI({
      knitr::knit("about.Rmd", quiet = TRUE) %>%
        markdown::markdownToHTML(fragment.only = TRUE) %>%
        HTML()
    })
}

shinyApp(ui = ui, server = server)
