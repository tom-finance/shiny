library(shiny)

ui <- fluidPage(
  
  titlePanel(title=div(img(src="logo.jpg", height="5%", width="5%"), 
                       "Shiny PDF Cleaning App with R"))
  
)

server <- function(input, output){
  
}

shinyApp(ui, server)


# check this out
# https://stackoverflow.com/questions/50348886/resize-embedding-image-in-shiny-app