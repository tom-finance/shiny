
library(shiny)
library(shinyWidgets)



ui <- fluidPage(
  
    # Application title
  titlePanel("Action Button Doubt app"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("n1","Number 1",value = NULL,min = 0,max = 50),
      numericInput("n2","Number 2",value = NULL,min = 0,max = 50),
      numericInput("n3","Number 3",value = NULL,min = 0,max = 50),
      textInput("t1","Text 1",value = NULL),
      actionButton("go","Simulate")
    ),
    
    
    mainPanel(
      DT::dataTableOutput("out")
    )
  ),
  setBackgroundColor("orange")

)


server <- function(input, output) {
  
  Value1 <- reactive(input$n1 + 10)
  Value2 <- reactive(input$n2 + 20)
  Value3 <- reactive(input$n3 + 30)
  
  restab <- eventReactive(input$go,{
    DT::datatable(data.frame(Value1(),Value2(),Value3(),input$t1))
  })
  output$out <- DT::renderDataTable(restab())
}

shinyApp(ui = ui, server = server)
