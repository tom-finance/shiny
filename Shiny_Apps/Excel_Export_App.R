library(shiny)
library(openxlsx)
library(writexl)
library(tidyverse)



ui <- fluidPage(
  downloadButton("dl", "Download")
)

server <- function(input, output) {
  data1 <- mtcars[, c(1, 2)] %>% head() 
  
  # Creating a workbook for user to download
  wb <- createWorkbook()
  addWorksheet(wb, sheetName = "sheet1")
  writeData(wb, sheet = 1, x = data1, startCol = 1, startRow = 1)
 
  output$dl <- downloadHandler(
    filename = function() {
      paste0("example", ".xlsx")
    },
    content = function(file) {
      saveWorkbook(wb, file = file, overwrite = TRUE)
    }
  )
}
shinyApp(ui, server)