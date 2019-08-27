library(googleVis)
library(ggplot2)
library(shiny)
library(shinythemes)
library(plotly)
library(DT)
library(countrycode)
library(shinydashboard)

data <- read.csv("Data.csv")
contin<-read.csv("Continents.csv")
normal<-read.csv("normal.csv")
outs<-read.csv("outlier.csv")


initGeomap <- '
<script type="text/javascript" src="http://www.google.com/jsapi"></script>
<script type="text/javascript">
google.load("visualization", "1", { packages:["geomap"] }); 
</script>'
mycss <- "
.irs-bar,
.irs-bar-edge,
.irs-single,
.irs-grid-pol {
  background: black;
  border-color: red;
}"
ui<-fluidPage(theme = shinytheme("journal"),
              
              titlePanel(strong("LIFE EXPECTANCY ANALYSIS")),
              #setBackgroundImage(src = "BG.jpg"),
              mainPanel(
                tabsetPanel(
                  tabPanel(strong("OVERVIEW"),
                           tags$style(mycss),
                           h3(strong("A linear growth of Average Life Expectency of Different Continents Around the world over the years.")),
                           h5("Motion Chart explaining the growth in the Life expectancy of different continents around the world"),
                           h5("Click on the play button below to start the motion chart"),
                           HTML(initGeomap),
                           htmlOutput("gvis"),
                           fluidRow(column(1),column(10,box(width = 10,title = "The Details",status = "warning",solidHeader = FALSE,collapsible = FALSE,
                                                            p("The Motion Chart Above displays the growth of life expectancy over the years.
                                              Each Bubble represents a pirticular Continent.
                                              The bubbles are colored on the basis of the continents.
                                              The play button starts the motion chart over the years.
                                              ")
                           )
                           )
                           ),
                           tags$style(type="text/css",
                                      ".shiny-output-error { visibility: hidden; }",
                                      ".shiny-output-error:before { visibility: hidden; }"),
                           h2(strong("The Comparison- Radar Chart and Table")),
                           h4("Below is a Radar Chart Comparison of two pirticular Countries"),
                           h3(strong("Please select an Year.")),
                           sliderInput(inputId = "Ye", label = "YEAR",min = 1980, max = 2004,value = 1995),
                           h3(strong("Do you wish to remove the outliers ?")),
                           radioButtons(inputId="out",
                                        label = "Choice",
                                        list("With Outliers","Remove Outliers")),
                           h3(strong("Please select any Two Countries to compare")),
                           div(style="display:inline-block",selectizeInput(inputId = "co1", label = "Country-1",choices = data$Country)),
                           div(style="display:inline-block",selectizeInput(inputId = "co2", label = "Country-2",choices = data$Country)),
                           fluidRow(
                             column( 
                               width = 3,plotlyOutput("radar")),
                             column(width = 2),
                             column(
                               width = 7,DT::dataTableOutput("mytable"))
                           )
                           #plotlyOutput("radar"),
                           #DT::dataTableOutput("mytable")
                  ),
                  tabPanel(strong("THE WORLD"),
                           h2("A Coropleth Map displaying the average BMI around the world"),
                           h5("Please Click on a Country to view the details of the country"),
                           sliderInput(inputId = "Y4", label = "SELECT YEAR",min = 1980, max = 2004,value = 1995),
                           plotlyOutput("geop"),
                           strong(textOutput("bc")),
                           fluidRow(
                             column( 
                               width = 3,plotlyOutput("radar2")),
                             column(width = 2),
                             column(
                               width = 7,DT::dataTableOutput("mytable2"))
                           )
                           
                           
                           
                  ),
                  tabPanel(strong("IN THE MOTION"),
                           tabsetPanel(
                             tabPanel("SUGAR EFFECTS",
                                      h2(strong("Motion Chart delivering the effects of sugar on BMI")),
                                      h5("Please Click on the play button below to start the Motion Chart"),
                                      HTML(initGeomap),
                                      htmlOutput("gvis3"),
                                      fluidRow(column(1),
                                               column(
                                                 10,
                                                 box(
                                                   width = 12.5,title = "The Details",status = "warning",solidHeader = FALSE,collapsible = FALSE,
                                                   p("The Motion Chart Above displays the effects of sugar consumption and average BMI of humans.
                                              Each Bubble represents a pirticular country.
                                              The size of the bubble is the population of the country.
                                              The bubbles are colored on the basis of the continents.")
                                                 )
                                               )
                                      )
                                      
                                      
                             ),
                             tabPanel("THE LIFESPAN",
                                      h2("Motion Chart delivering the effects of GDP on Life Expectency on humans"),
                                      h3("Do you wish to remove the outlying Countries for better visualization ?"),
                                      radioButtons(inputId="out1",
                                                   label = "Data Selection",
                                                   list("With Outliers","Remove Outliers")),
                                      h5("Please Click on the play button below to start the Motion Chart"),
                                      HTML(initGeomap),
                                      htmlOutput("gvis4"),
                                      fluidRow(column(1),column(10,box(width = 10,title = "The Details",status = "warning",solidHeader = FALSE,collapsible = FALSE,
                                                                       p("The Motion Chart Above displays the effects of GDP on the Life Expectancy of humans.
                                              Each Bubble represents a pirticular country.
                                              The size of the bubble is the population of the country.
                                              The bubbles are colored on the basis of the continents.
                                              The play button starts the motion chart over the years.
                                              The option of removing the outlier is also provided if you wish to clearify the visualization.
                                              ")
                                      )
                                      )
                                      )
                             ))),
                  tabPanel(strong("THE PREDICTION"),
                           h2("Predict life expectency"),
                           h3("Select an Year For the scatter Plot below"),
                           sliderInput(inputId = "Y3", label = "Select Year",min = 1980, max = 2004,value = 1995),
                           h3("Life Expectency vs the BMI"),
                           plotlyOutput("scatter"),
                           fluidRow(column(1),column(10,box(width = 10,title = "The Scatter Plot",status = "warning",solidHeader = FALSE,collapsible = FALSE,
                                                            p("The Scatter Plot Above Displays the The Average BMI's of countries and the consecutive Life Expectancy. 
                                                            The points are color clustered on the basis of the BMI of the Country from purple(LOW BMI) to Yellow(HIGH BMI).
                                                            The Scatter Plot above is just for visualizing the corelation between BMI and life Expectancy for the prediction below.
                                              ")
                           )
                           )
                           ),
                           h3("Prediction using Multiple Linear Regression"),
                           h4("Let's predict your expected life-span using the following details"),
                           radioButtons(inputId="gen",
                                        label = "select your gender",
                                        list("Male","Female")),
                           selectInput("cou","Enter your Country",choices = data$Country),
                           sliderInput(inputId = "bmi", label = "enter Your BMI",min = 14, max = 32,value = 19),
                           strong(textOutput("prediction")),
                           tags$head(tags$style("#prediction{color: Green;
                                 font-size: 20px;
                                 font-style: bold;
                                 }"
                           )
                           ),
                           fluidRow(column(1),column(10,box(width = 10,title = "The Model",status = "warning",solidHeader = FALSE,collapsible = FALSE,
                                                            p("The Life Expectancy is based on many different factors. But using our database we can realize some useful variables exploiting the life 
                                                            expectancy. We have used the 'Years', 'Country' , 'the BMI' and 'Gender' as our predictors
                                              ")
                           )
                           )
                           )
                           
                  )
                  
                ))
)
server <- function(input, output,session) {
  
  
  output$selected_var <- renderText({ 
    paste("Coropleth representation for the Average BMI around the world for the year-", input$y1)
  })
  
  output$gvis <- reactiveText(function(){
    
    G3 <- gvisMotionChart(data = data, "Continent", "Year", 
                          options=list(width=1000, height=600))
    c(G3$html$chart,paste("\n<script type=\"text/javascript\">drawChart",
                          G3$chartid,"();</script>\n",sep="")
    )
    
  })
  td<-observe({
    x<-input$out
    if (x=="Remove Outliers"){
      td<-outs
      updateSelectInput(session, "co1",label = "Country-1",choices = td$Country)
      updateSelectInput(session, "co2",label = "Country-2",choices = td$Country)
    }
    else{
      td<-normal
      updateSelectInput(session, "co1",label = "Country-1",choices = td$Country)
      updateSelectInput(session, "co2",label = "Country-2",choices = td$Country)
    }
  })
  output$radar <- renderPlotly({
    if(input$out=="Remove Outliers"){td<-outs}
    else{td<-normal}
    if((input$co1!='')&(input$co2!='')){
      x<-td[which(td$Country==input$co1 & td$Year==input$Ye),]
      n<-x[ ,!(colnames(x) == "Year") & !(colnames(x) == "Country")& !(colnames(x) == "Continent")]
      y<-td[which(td$Country==input$co2 & td$Year==input$Ye),]
      m<-y[ ,!(colnames(y) == "Year") & !(colnames(y) == "Country")& !(colnames(y) == "Continent")]
      
      plot_ly(type = 'scatterpolar',
              fill = 'toself'
      ) %>%
        add_trace(
          r = as.numeric(as.vector(n[1,])),
          theta = colnames(n),
          name =  x$Country
        ) %>%
        add_trace(
          r = as.numeric(as.vector(m[1,])),
          theta = colnames(m),
          name = y$Country
        ) %>%
        layout(autosize = F, width = 400, height = 400, margin = m,
               polar = list(
                 radialaxis = list(
                   visible = T,
                   range = c(0,1)
                   
                 )
               )
        )}
    
    else {  h1("Select Both Countries")}
  })
  output$mytable<- DT::renderDataTable({
    if(input$out=="Remove Outliers"){
      td<-data
      if((input$co1!='')&(input$co2!='')){
        x<-td[which(td$Country==input$co1 & td$Year==input$Ye),]
        n<-x[ ,!(colnames(x) == "Year") & !(colnames(x) == "Country")& !(colnames(x) == "Continent")]
        y<-td[which(td$Country==input$co2 & td$Year==input$Ye),]
        m<-y[ ,!(colnames(y) == "Year") & !(colnames(y) == "Country")& !(colnames(y) == "Continent")]
        total <- rbind(x,y)
        total<-t(total)
        #colnames(total)<-" "
        colnames(total) <- c("Country-1","Country-2")
        #print(x)
        return(total) 
      }
      else{NULL}
    }
    else{
      td<-data
      if((input$co1!='')&(input$co2!='')){
        x<-td[which(td$Country==input$co1 & td$Year==input$Ye),]
        n<-x[ ,!(colnames(x) == "Year") & !(colnames(x) == "Country")& !(colnames(x) == "Continent")]
        y<-td[which(td$Country==input$co2 & td$Year==input$Ye),]
        m<-y[ ,!(colnames(y) == "Year") & !(colnames(y) == "Country")& !(colnames(y) == "Continent")]
        total <- rbind(x,y)
        total<-t(total)
        #colnames(total)<-" "
        colnames(total) <- c("Country-1","Country-2")
        
        return(total)
      }
      else{NULL}
    }
  })
  output$gvis3 <- reactiveText(function(){
    x=subset(data, select = -c(Female_BMI,Male_BMI,GDP,Life_Expectency))
    
    gx1 = gvisMotionChart(data=x, 
                          idvar="Country", 
                          timevar="Year",
                          chartid="Noq",
                          xvar = "Sugar",
                          yvar = "Av_BMI",
                          colorvar = "Continent",
                          sizevar = "Population",options=list(width=1000, height=600))
    c(gx1$html$chart,paste("\n<script type=\"text/javascript\">drawChart",
                           gx1$chartid,"();</script>\n",sep="")
    )
  })
  output$gvis4 <- reactiveText(function(){
    if(input$out1 == "With Outliers"){
      s1<-subset(data, select = -c(Sugar,Female_BMI,Male_BMI,Av_BMI))
      G3 <- gvisMotionChart(data=s1, 
                            idvar="Country", 
                            timevar="Year",
                            chartid="x",
                            xvar = "GDP",
                            yvar = "Life_Expectency",
                            colorvar = "Continent",
                            sizevar = "Population",options=list(width=1000, height=600))
      c(G3$html$chart,paste("\n<script type=\"text/javascript\">drawChart",
                            G3$chartid,"();</script>\n",sep="")
      )
    }
    else
    {
      s1<-subset(data, select = -c(Sugar,Female_BMI,Male_BMI,Av_BMI))
      s1<-s1[!(s1$Country=="Rwanda") & !(s1$Country=="United Arab Emirates"),]
      G3 <- gvisMotionChart(data=s1, 
                            idvar="Country", 
                            timevar="Year",
                            chartid="x",
                            xvar = "GDP",
                            yvar = "Life_Expectency",
                            colorvar = "Continent",
                            sizevar = "Population",options=list(width=1000, height=600))
      c(G3$html$chart,paste("\n<script type=\"text/javascript\">drawChart",
                            G3$chartid,"();</script>\n",sep="")
      )
    }
    
    
  })
  output$scatter <- renderPlotly({
    x<-data[which(data$Year==input$Y3),]
    plot_ly(data = x , x=x$Av_BMI, y=x$Life_Expectency,color = x$Av_BMI,
            text = ~paste("BMI:",x$Av_BMI,'<br>LIFE Expectency:', x$Life_Expectency,'<br>Country:', x$Country))%>% layout(title = 'BMI VS Life Expectency',
                                                                                                                          xaxis = list(title = 'Body Mass Index'),
                                                                                                                          yaxis = list(title = 'Life Expectency'))
    
  })
  
  output$prediction <- renderText({ 
    if (input$gen=="Female"){
      xf=subset(data, select = -c(Sugar,Male_BMI,Population,GDP,Av_BMI,Continent))
      linears<-lm(xf$Life_Expectency~.,data = xf)
      x1 <- data.frame("Year" = 2019, "Country" = input$cou, "Female_BMI" = as.numeric(input$bmi))
      paste("Congratulations \n Your Predicted Average lifespan is",round(predict(linears,x1),1),"Years during the year",2019)
    }
    else{
      xm=subset(data, select = -c(Sugar,Female_BMI,Population,GDP,Av_BMI,Continent))
      linears<-lm(xm$Life_Expectency~.,data = xm)
      x1 <- data.frame("Year" = 2019, "Country" = input$cou, "Male_BMI" = as.numeric(input$bmi))
      paste("Congratulations \n Your Predicted Average lifespan is",round(predict(linears,x1),1),"Years during the year",2019)
      
    }
  })
  
  # mc<- observe(event_data("plotly_click"))
  
  output$bc<-renderText({
    d <-event_data("plotly_click",source = "geop")
    if (is.null(d)) {
      paste("Please click on a Contry on the Map Above") }
    else {
      paste("Details shown below")}
  })
  ###
  output$radar2 <- renderPlotly({
    d <-event_data("plotly_click",source = "geop")
    d<-d$pointNumber+1
    if(!is.null(d)){
      cat(d)
      x<-normal[which(data$Year==input$Y4),]
      #print(x)
      rownames(x) <- NULL
      #print(x)
      x<-x[d,]
      #print(x)
      n<-x[ ,!(colnames(x) == "Year") & !(colnames(x) == "Country")& !(colnames(x) == "Continent")& !(colnames(x) == "A")& !(colnames(x) == "Av_BMI")]
      plot_ly(type = 'scatterpolar',
              fill = 'toself'
      ) %>%add_trace(
        r = as.numeric(as.vector(n[1,])),
        theta = colnames(n),
        name =  x$Country
      ) %>%
        layout(autosize = F, width = 400, height = 400, margin = 2,
               
               polar = list(
                 radialaxis = list(
                   visible = T,
                   range = c(0,1)
                   #%>%layout(autosize = F, width = 500, height = 500, margin = m)
                   
                 )
               )
        )}
    
    else {  h1("Select Both Countries")}
  })
  ###
  
  output$geop <- renderPlotly({
    x<-data[which(data$Year==input$Y4),]
    x["CODE"]<-countrycode(x$Country, 'country.name', 'iso3c')
    l <- list(color = toRGB("grey"), width = 0.5)
    g <- list(showframe = FALSE,showcoastlines = FALSE,projection = list(type = 'Mercator'))
    #p <- plot_ly(source = "geop") %>% 
    p<-plot_geo(x,source = "geop") %>%add_trace(z = x$Av_BMI, color = x$Av_BMI, colors = 'Reds',
                                                text =paste("<b>",x$Country,"<b><BR>BMI:",x$Av_BMI,"<BR>Sugar:",x$Sugar,"MGs","<BR>Life Expectency:",x$Life_Expectency," Years","<BR>Population:",x$Population,"<BR>GDP:",x$GDP,"Billions"), 
                                                locations = x$CODE, marker = list(line = l)
    ) %>%
      colorbar(title = 'BMI Range ') %>%
      layout(
        title = 'Average BMI aroud the world',
        geo = g
      )
    p
  })
  output$mytable2<- DT::renderDataTable({
    
    d <-event_data("plotly_click",source = "geop")
    d<-d$pointNumber+1
    if(!is.null(d)){
      b<-data[which(data$Year==input$Y4),]
      rownames(b) <- NULL
      b<-b[d,]
      b<-t(b)
      colnames(b)<-" "
      return(b)
      
    }
  })
}
shinyApp(ui, server)
