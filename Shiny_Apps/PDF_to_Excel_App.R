################################################################################
# Shiny App PDF Reader
################################################################################

# packages
library(shiny) # create R Shiny Apps
library(pdftools) # read PDF data into R
library(openxlsx) # create MS Excel output5
library(shinythemes) # nicer themes as default theme is rather boring
library(shinyWidgets) # extra widgets
library(dplyr) # data manipulation
library(stringi) # string manipulation

################################################################################

##########################
# R function to clean code is added here - is executed with every new Shiny session!
##########################

clean_code <- function(x) {
    
    text <-   stri_split_lines(x) %>%
        unlist()
    
    DealStatus <- text[grep("our ref",text)-1]
    
    Statuscheck <- ifelse(grepl("C A N C E L L A T I O N", DealStatus),
                          yes = "CANCELLED",                                     
                          no = "NEW")                                            
    
    # buy/sell
    pat_buy <- 'for you by order and for account of'                                             
    buy_sell <- gsub(" :", "", gsub("we ", "", gsub(pat_buy, "", text[grepl(pat_buy, text)])))  
    
    # date
    pat_sd <- "s/d"
    date <- gsub(" : ", "", gsub(".*s/d", "", text[grepl(pat_sd, text)]))
    date <- as.Date(date, "%d.%m.%Y")                                                            
    
    # Betrag / Währung
    pat_val <- "total consideration"                                                            
    value <- text[grepl(pat_val, text)]
    
    number <- as.numeric(gsub("[^0-9.]", "",  gsub(",", ".", gsub("\\.", "", value))))           
    
    operation_currency <- gsub("[^[:alnum:] ]", "", 
                               gsub(" ", "", gsub("[[:digit:]]+", "",                                    
                                                  gsub("total consideration", "", value)), fixed = TRUE))
    
    # create final output
    result <- data.frame(Transaction_Type = buy_sell,
                         Currency = operation_currency,
                         Amount = number,
                         Value_date = date,
                         Operation_status = Statuscheck,
                         stringsAsFactors = FALSE)
    return(result)
    
}

##########################

# define user interface for Shiny app here
ui <- fluidPage(theme = shinytheme("flatly"), # use a theme to make application nicer
    titlePanel(span("Read PDF to Excel R Shiny App",
                    style = "color: #007f32; font-weight: bold")),
    # create user interface on sidebar to handle user inputs
    sidebarLayout(
        sidebarPanel(
            width = 3, # change default for nicer application
            fileInput('file', 'PDF auswählen und Daten importieren',
                      accept = c(".pdf")
            ),
            textInput("t1","Output Directory definieren", 
                      value = paste0("C:/Users/thoma/Desktop/File_", 
                                     format(Sys.Date(), "%d.%m.%Y"),
                                     ".xlsx")),
            # downloadButton("dl", "Download"), # excluded because action button works better for export!
            h5("Export"),
            actionButton("go","Export to Excel!"),
            actionButton("open","Open Output!"),
            actionButton("delete","Delete Output!"),
            h5("Version 1.0")
            
        ),
        # create main table to show results after data cleansing to user
        mainPanel(h3("Vorschau Output Alle Deals"),
                  DT::dataTableOutput('table'),
                  h3("Vorschau Output Deals Fremdwährungen"),
                  DT::dataTableOutput('table1'))
    ),
    
    # define main background for whole user interface for nicer appereance
    setBackgroundColor("#f6f6f6"),
    
    # set footer - not optimal solution, but currently nothing else available
    hr(),
    print("~~~DISCLAIMER: BETA VERSION NOT TESTED~~~")
)

# Define server logic for Shiny app here
server <- function(input, output, session) {
    
    # read data in app from user defined PDF input
    # apply function to clean the data and prepare output data.frame
    mydata <- reactive({
        
        inFile <- input$file
        
        # stop if user input is empty
        if (is.null(inFile))
            return(NULL)
        
        # read PDF into application on R server. Use function from pdftools package
        # to handle PDF input correctly. ONLY WORKS WITH PDF!
        tbl <- pdftools::pdf_text(inFile$datapath)
        
        # use function to clean data on user input
        tbl <- clean_code(tbl)
        
        return(tbl)
        
    })
    
    # Fremdwährungen - ACHTUNG CODE SOLLTE AUF VORHERIGES OBJEKT FILTERN UM REDUNDANZ ZU VERMEIDEN! TO FIX!!
    mydata1 <- reactive({
        
        inFile <- input$file
        
        # stop if user input is empty
        if (is.null(inFile))
            return(NULL)
        
        # read PDF into application on R server. Use function from pdftools package
        # to handle PDF input correctly. ONLY WORKS WITH PDF!
        tbl <- pdftools::pdf_text(inFile$datapath)
        
        # use function to clean data on user input
        tbl <- clean_code(tbl) %>% 
            filter(Currency != "EUR") %>% # exclude transactions in EUR
            arrange(Value_date, Operation_status, Transaction_Type, Currency) # filter data
        
        return(tbl)
        
    })
    
    # show data in output panel for all currencies
    output$table <- DT::renderDataTable({
        mydata()
    })
    
    # show data in output panel for filtered and ordered foreign currencies
    output$table1 <- DT::renderDataTable({
        mydata1()
    })
    
    # use user defined input to create output path
    output_path <- reactive(input$t1)
    
    # export to Excel via action button
    observeEvent(input$go, {
        openxlsx::write.xlsx(mydata(), file = output_path())
        showNotification("Output erstellt!", duration = NULL, 
                         type = "warning", closeButton = TRUE)
        # use additional message from shinyWidgets package to enhance user experience!
        sendSweetAlert(
            session,
            title = "Output erstellt!",
            text = "",
            type = "success"
        )
    })
    
    # open created output file via file.show command
    observeEvent(input$open, {
        file.show(output_path())
    })
    
    # delete created output file via unlink function --> could also use direct system call to delete file
    observeEvent(input$delete, {
        unlink(output_path())
        sendSweetAlert(
            session,
            title = "Output gelöscht!",
            text = "",
            type = "warning"
        )
    })
    
}

# Run the application 
shinyApp(ui = ui, 
         server = server)

################################################################################
