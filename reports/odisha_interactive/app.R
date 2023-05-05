# QUICK APP BY ALEX TO VISUALIZE ODISHA VILLAGES

# power considerations:

# From Astha:
# Rayagada: 42 per 100 women
# Kandhamal: 43 per 100 women
# Nababarangpur: 47 per 100 women
# Kalahandi: 37 per 100 women
# The average for these four high mortality districts is 42 per 100 women. (For whole of Odisha, this is 36 per 100)
# Elisa, target: Kandhamal, Narbangapur, and Kalahandi, Rayagada as well as average mortality in Odisha

# ILC MDE adjustment (from GW proposal december)
# However, the benefit of ILC is that it is likely to have near 100% take-up. This does not reduce the MDE directly, but it means that we would expect a larger mortality effect, reducing the overall probability of a false negative result. We therefore rescale the MDEs for ILC studies to be comparable to the MDE for coupon studies, by multiplying it by the ratio of the expected take-up between ILC and coupons.

# from meta_helpers.R file:
back_out_MDE_reduction_2proptest_cluster <- function(n_cluster, n_per_cluster, MR, power_choice = .8, ICC_choice = .01, ...) {
  # i wanna get out the MDE, like in the individual case
  # first i compute the proportion that I can detect, given parameters
  # https://rdrr.io/cran/clusterPower/man/cpa.binary.html
  # we could also build in a CV for clustersize if wanted
  # BUG IN EARLY VERSIONS IN NOVEMBER: ncluster is PER condition, so it has to be divided 2
  power.out <- clusterPower::cpa.binary(nclusters = n_cluster/2, nsubjects = n_per_cluster, ICC = ICC_choice, p1 = MR, p1inc = TRUE, power = .8,
                                        tol = .Machine$double.eps^.5, ...)
  # just back out the MDE now
  (1 - power.out[[1]] / MR) * 1e2
}



# POWER end --------------------------------------
odisha2011 <- readRDS("Odisha2011_points.rds")
odisha2011 <- odisha2011 |> dplyr::select(-(1:3))
odisha.dists <- unique(odisha2011$dist_name) |> sort()
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
library(stars)

u5mr <- stars::read_stars("india_under5_mean_2017.tif")

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
            checkboxInput("allvaluestmap", "Show all values for each village?", value = FALSE),
            checkboxInput("u5raster", "Display U5MR raster?", value = TRUE),
            
            # POWER STARTS HERE
            hr(),
            numericInput("MR_ind", "MR (per 1,000)", value = 70, min = 0, max = 99),
            hr(),
            numericInput("clusize_ind", "clustersize (preg. mothers, c. 40p100 women, 20% of total pop?)", value = 200, min = 0, max = 1e3),
            numericInput("clu_ind", "number of clusters", min = 0, max = 10e3, value = 2e3),
            numericInput("clu_icc", "ICC (intra-cluster corr.)", value = 0.01, min = 0, max = 1),
            numericInput("clu_CV", "CV clustersize (optional)", value = 0, min = 0, max = 10)
        ),

        # Show a plot of the generated map
        mainPanel(
          #p(),
          h5("You can select different types of maps by clicking on the layer inside the panel."), 
          tmapOutput("mapplot_leaflet"),
          p(),
          plotOutput("histogram"),
          p(),
          h3("Power:"),
          verbatimTextOutput("clusterpowertext")
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
        if (input$u5raster == TRUE) {tm_shape(odisha2011) + tm_dots(input$histselect, style = "quantile") + tm_shape(u5mr) + tm_raster(n = 10, style = "equal", palette = "-magma", alpha = .5)} else {
          tm_shape(odisha2011) + tm_dots(input$histselect, style = "quantile")
        }
      } else {
        if (input$u5raster == TRUE) {tm_shape(odisha2011) + tm_dots() + tm_shape(u5mr) + tm_raster(n = 10, style = "equal", palette = "-magma", alpha = .5)} else {
          tm_shape(odisha2011) + tm_dots()
        }
      }
    })
    
    output$histogram <- renderPlot({
      
      # get the mean and SD of the selected variable
      mean_input <- odisha2011 |> sf::st_drop_geometry() |> dplyr::filter(dist_name == input$district) |> dplyr::summarise(mean(.data[[input$histselect]], na.rm = T)) |> round()
      sd_input   <- odisha2011 |> sf::st_drop_geometry() |> dplyr::filter(dist_name == input$district) |> dplyr::summarise(sd(.data[[input$histselect]], na.rm = T)) |> round()
      # also total pop
      sum_input <- odisha2011 |> sf::st_drop_geometry() |> dplyr::filter(dist_name == input$district) |> dplyr::summarise(sum(.data[[input$histselect]], na.rm = T)) |> round()
      n_input   <- odisha2011 |> sf::st_drop_geometry() |> dplyr::filter(dist_name == input$district) |> dplyr::summarise(dplyr::n())
      
      ggplot(data = odisha2011 |> dplyr::filter(dist_name == input$district)) + geom_histogram(aes_string(x = input$histselect)) + 
        theme_minimal() + ggtitle(paste("Distribution of ", input$histselect, " in ", input$district, ". Number of villages:", n_input," | mean:", mean_input, " | CV:", round(sd_input/mean_input, 2), " | total:", sum_input))
    })
    
    output$clusterpowertext <- renderPrint({
      
      
      MDE_indclu  <- (back_out_MDE_reduction_2proptest_cluster(n_cluster = input$clu_ind, n_per_cluster = input$clusize_ind, MR = input$MR_ind/1e3, CV = input$clu_CV)/100)
      
      cat("MDE is", MDE_indclu, " with a total sample size of", input$clu_ind*input$clusize_ind, " \n 
          to be comparable to coupon MDE (inidivudal randomization), rescale by the expected takeup ratio (30/90?)")
        # Selectivity ", input$selectivity*100,
        #   "%, ILCadjusted MDE:", input$ILC_effect, 
        #   "x, attrition:", input$attrition, 
        #   "%, ICC: ", input$clu_icc, ".")
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)

