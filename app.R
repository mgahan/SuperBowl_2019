
# Bring in libraries
library(data.table)
library(shiny)
library(dygraphs)

# Read in data
commercial_data <- readRDS("./commercial_data.rds")

# Inputs
keywords <- commercial_data[, .N, keyby=.(keyword)]

# Build ui
ui <- fluidPage(
  titlePanel("Superbowl 2019 Commercials"),

  # Create a new Row in the UI for selectInputs
  fluidRow(
    column(4,
        selectInput("keyword_par","Google Keyword:",keywords, "maroon 5")
    )
  ),
	
  # Create a new row for the table.
  dygraphOutput("spikeplot")
)

# Build server
server <- function(input, output) {

  # Filter data based on selections
  output$spikeplot <- renderDygraph({
		
  	# Subset data
  	commercial_data_key <- commercial_data[keyword==input$keyword_par, .(timestamp, hits)]
  	
  	# Build plot
  	outplot <- dygraph(commercial_data_key, main=paste0("Google Search Intensity: ", input$keyword_par)) %>%
  		dyOptions(useDataTimezone = TRUE)
		
  	outplot
  })
}

# Run app
app_out <- shinyApp(ui = ui, server = server)
