################################################################################
# R Shiny App
################################################################################

# packages
library(shiny)
library(readxl)
library(pdftools)
library(openxlsx)
library(shinythemes)

#####################################

# function to clean data
analyseData = function(data){
  # Do some analysis
  # ....
  #Give output in the format:
  analysedData = head(data, 5)
  
  return(analysedData)
}
#####################################

runApp(
  list(
    ui = fluidPage(theme = shinytheme("flatly"),
      titlePanel(title=div(img(src="logo.jpg", height="5%", width="5%"), 
                           "Shiny PDF Cleaning App with R")),
      sidebarLayout(
        sidebarPanel(
          fileInput('file1', 'Choose PDF file',
                    accept = c(".pdf")
          ),
          downloadButton("dl", "Download")
        ),
        mainPanel(
          tableOutput('contents'))
      )
    ),
    
    server = function(input, output){
      
      # read user input data into application
      mydata <- reactive({
        
        req(input$file1)
        
        inFile <- input$file1
        
        tbl <- pdf_data(inFile$datapath)[[1]]
        
        return(tbl)
      })
      
      # show output after application of cleansing function to data
      output$contents <- renderTable({
        analyseData(mydata())
      })
      
      
      # download file
      output$dl <- downloadHandler(
        filename = function() {
          paste0("example", ".xlsx")
        },
        content = function(file) {
          openxlsx::write.xlsx(analyseData(mydata()), file = file)
        }
      )
      
    }
  )
)

