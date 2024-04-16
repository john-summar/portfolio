library(shiny)
library(fpp3)
library(plotly)
library(ggplot2)

vols_path <- "https://docs.google.com/spreadsheets/d/1uNlvFCNpC3YqyURTfLURbgWC5zc4mkpN9sFUUn-AXGI/export?format=csv"
vols <- read.csv(vols_path)
names(vols) <- c('month', 'interest')
vols <- vols %>% 
  mutate(month = yearmonth(month)) %>% 
  tsibble()


ui <- fluidPage(
  titlePanel("Tennessee Volunteer Football Google Interest"),
  
  mainPanel(
    h6("This app will take you through google search interest in Tennessee Football since January
       of 2004. The full series will be shown at the top and the dropdown bar will allow you to 
       choose to see a seasonal chart, autocorrelation plot, or decomposition charts additionally.
       To interact with the app, please select the any chart you would like from the drop down. You may also
       select if you would like to see where some of your favorite UT quarterbacks pushed 
       Vols football up the google charts by clicking the button next to the yes or no answer choice.", align = "center")
  ),
  radioButtons(inputId = "radio_button",
                 label = "Would you like to see where some of the top UT quarterbacks fall on this series?",
                 choices = c("Yes", "No"),
                 selected = "No"),
  
  
  plotOutput("time_series_plot"),
  mainPanel("Note:",
            h6(align = "center"),
            textOutput("time_series_note")
  ),
  
  selectInput(inputId = "dropdown",
              label = "Select Chart Type",
              choices = c("Seasonality", "Autocorrelation", "Decomposition")),
  
  
  mainPanel(
    h6("Here is your selected plot:",
       align = "left")
  ),
  
  
  plotOutput("selection_plot"),
  mainPanel("Your selected plot note:",
            h6(align = "center"),
            textOutput("selection_plot_note")
  )
)

server <- function(input, output, session) {
  
  output$time_series_plot <- renderPlot({
    if(input$radio_button == "No") {
      vols %>% 
        autoplot(interest)
    } else if(input$radio_button == "Yes") {
      vols %>% 
        autoplot(interest) +
        annotate("text", x = yearmonth("2023-9"), y = 55, 
                 label = "Joe Milton",
                 hjust = 1, vjust = 1, angle = 0, size = 4, color = "orange") +
        
        annotate("text", x = yearmonth("2022-10"), y = 103,
                 label = "Hendon Hooker",
                 hjust = 1, vjust = 1, angle = 0, size = 4, color = "orange") +
        
        annotate("text", x = yearmonth("2016-10"), y = 76,
                 label = "Josh Dobbs",
                 hjust = 0, vjust = .25, angle = 0, size = 4, color = "orange") +
        
        annotate("text", x = yearmonth("2014-9"), y = 40,
                 label = "Nathan Peterman",
                 hjust = 0, vjust = .25, angle = 0, size = 4, color = "orange") +
        
        annotate("text", x = yearmonth("2010-9"), y = 37,
                 label = "Tyler Bray",
                 hjust = 0, vjust = .25, angle = 0, size = 4, color = "orange")+
        
        annotate("text", x = yearmonth("2005-9"), y = 47,
                 label = "Erik Ainge",
                 hjust = 0, vjust = .25, angle = 0, size = 4, color = "orange")
    }
  })
  
  output$time_series_note <- renderText({
    "     It seems as though there isn't an overpowering trend in this series as a whole. However, the
             seasonality gets more multiplicative as it progresses."
  })
  
  output$selection_plot <- renderPlot({
    if (input$dropdown == "Seasonality") {
      vols %>% 
        gg_season(interest)
    } else if (input$dropdown == "Autocorrelation") {
      vols %>% 
        ACF(interest) %>% 
        autoplot()
    } else if (input$dropdown == "Decomposition") {
      vols %>% 
        model(X_13ARIMA_SEATS(interest ~ x11())) %>% 
        components() %>% 
        autoplot()
    }
  })
  
  output$selection_plot_note <- renderText({
    if (input$dropdown == "Seasonality") {
      "     It seems as though there is a spike in Google searches beginning in August and ending in
      December, which aligns with the football season."
    } else if (input$dropdown == "Autocorrelation") {
      "     It becomes very apparent that there isn't a very strong trend in Vols football searches, but there is high seasonality. You would like to see
      an upwards trend that would mean the team is getting a lot of attention,and probably getting better over the years, but unfortunately
      it has not been that way for a while."
    } else if (input$dropdown == "Decomposition") {
      "     You can see that the SEATS decomposition gives multiplicative seasonality, no overall trend, and a bit of
      randomness as the trend moves on."
    }
  })
}

shinyApp(ui, server)
