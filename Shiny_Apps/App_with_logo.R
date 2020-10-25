library(shiny)

ui <- fluidPage(
  
  titlePanel(title=div(img(src="C:/Users/User/Desktop/shiny/Shiny_Apps/logo.jpg")))
  
  # titlePanel(title=tags$a(href='http://www.nhl.com/',
  #                         tags$img(src='nhl.jpg',height='50',width='50')))
)

server <- function(input, output, session){
  
}

shinyApp(ui, server)