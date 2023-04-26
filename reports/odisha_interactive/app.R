#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

odisha2011 <- readRDS("Odisha2011_points.rds")
odisha2011 <- odisha2011 |> dplyr::select(-(1:3))
odisha.dists <- unique(odisha2011$dist_name)
namesselect <- names(odisha2011)[6:12]
#odisha2011 <- odisha2011 |> dplyr::filter(dist_name %in% c("Bargarh", "Jharsuguda", "Sambalpur"))

# water

# water <- readRDS("groundwater.rds")
# #water$year |> hist()
# water.dists <- water$DISTRICT_NAME |> unique()
# water <- water[!is.na(water$LATITUDE), ]
# library(measurements)
# conv_unit(water$LATITUDE[[1]], from = "deg_min_sec", to = "dec_deg")
# sp::char2dms(water$LATITUDE[[1]])
# st_as_sf(water, coords = c("LONGITUDE", "LATITUDE"))
# 

library(shiny)
library(sf)
library(tmap)
library(leaflet) # for the interactive map
library(ggplot2)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Villages in Odisha (Census 2011)"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            # sliderInput("bins",
            #             "HAS NO USE FOR NOW:",
            #             min = 1,
            #             max = 50,
            #             value = 30),
            selectInput("district", "Choose district",
                        choices = odisha.dists),
            # selectInput("district.water", "Choose district (water)",
            #             choices = water.dists),
            selectInput("histselect", "Histogram variable (default: population)",
                        choices = namesselect),
            checkboxInput("allvaluestmap", "Show all values for each village?", value = FALSE)
        ),

        # Show a plot of the generated map
        mainPanel(
          #p(),
          h5("You can select different types of maps by clicking on the layer inside the panel."), 
          tmapOutput("mapplot_leaflet"),
          p(),
          plotOutput("histogram")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    # output$mapplot_leaflet <- renderTmap({
    #     tmapsave <- tm_shape(odisha2011) + tm_dots()
    #     tmap_leaflet(tmapsave, in.shiny = TRUE)
    # })
    output$mapplot_leaflet <- renderTmap({
      odisha2011 <- odisha2011 |> dplyr::filter(dist_name == input$district)
      if (input$allvaluestmap == FALSE){
        tm_shape(odisha2011) + tm_dots(input$histselect, style = "quantile")
      } else {
        tm_shape(odisha2011) + tm_dots()
      }
    })
    
    output$histogram <- renderPlot({
      ggplot(data = odisha2011 |> dplyr::filter(dist_name == input$district)) + geom_histogram(aes_string(x = input$histselect)) + 
        theme_minimal() + ggtitle(paste("Distribution of ", input$histselect, " in ", input$district, ":"))
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)

