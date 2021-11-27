library(shiny)

# List that holds x and y coordinates of the two points of original line
line1 = list(c(100, 0), c(0, 0))
line2 = list(c(0, 0), c(50, 50*sqrt(3)))
line3 = list(c(50, 50*sqrt(3)), c(100, 0))

# How many times should the line be transformed
number_of_iterations = 10

# Return points A, B and C
# C is the tip of a equilateral triangle constructed from middle third of original AB
# new A and B are first and second third of original AB
make_triangle = function(point_a, point_b){
  a_x = point_a[1] + (point_b[1] - point_a[1]) / 3
  a_y = point_a[2] + (point_b[2] - point_a[2]) / 3
  b_x = point_a[1] + 2 * ((point_b[1] - point_a[1]) / 3)
  b_y = point_a[2] + 2 * ((point_b[2] - point_a[2]) / 3)
  c_x = (0.5 * (b_x - a_x) - (sqrt(3) / 2) * (b_y - a_y)) + a_x
  c_y = (sqrt(3) / 2) * (b_x - a_x) + 0.5 * (b_y - a_y) + a_y
  list(c(a_x, a_y), c(b_x, b_y), c(c_x, c_y))
}

next_iteration = function(arr){
  len = length(arr)
  for (i in 0:(len-2)){
    triangle = make_triangle(arr[[4*i+1]], arr[[4*i+2]])
    arr = append(arr, list(triangle[[2]]), after = 4*i+1)
    arr = append(arr, list(triangle[[3]]), after = 4*i+1)
    arr = append(arr, list(triangle[[1]]), after = 4*i+1)
  }
  arr
} 


draw_line = function(arr, col){
  x_number_values = c()
  y_number_values = c()
  for (p in arr){
    x_number_values = append(x_number_values, p[1])
    y_number_values = append(y_number_values, p[2])
  }
  plot(x_number_values, y_number_values, type="l", 
       xaxt="n", yaxt="n", xlab="", ylab="", col=col)
  len = length(arr) / 3
  text(arr[[1]][1], arr[[1]][2], "A", col="steelblue", cex=2, pos=1)
  text(arr[[1+len]][1], arr[[1+len]][2], "B", col="steelblue", cex=2, pos=1)
  text(arr[[1+2*len]][1], arr[[1+2*len]][2], "C", col="steelblue", cex=2, pos=1)
  title(main="Koch Curve")
}

####### make an animation html
ui = fluidPage(
  titlePanel("Snowflack"),
  sidebarLayout(
    sidebarPanel(
      numericInput("x_A", "A点的横坐标", 100),
      numericInput("y_A", "A点的纵坐标", 0),
      numericInput("x_B", "B点的横坐标", 0),
      numericInput("y_B", "B点的纵坐标", 0),
      numericInput("x_C", "C点的横坐标", 50),
      numericInput("y_C", "C点的纵坐标", 50*sqrt(3)),
      sliderInput("iterations", "Iterations", 0, 6, 3, 1)
    ),
    mainPanel(
      plotOutput("plot", width = "600px", height = "600px")
    )
  )
)


server = function(input, output){
  output$plot = renderPlot({
    line1 = list(c(input$x_A, input$y_A), c(input$x_B, input$y_B))
    line2 = list(c(input$x_B, input$y_B), c(input$x_C, input$y_C))
    line3 = list(c(input$x_C, input$y_C), c(input$x_A, input$y_A))
    x_number_values = c()
    y_number_values = c()
    for (p in c(line1,line2, line3)){
      x_number_values = append(x_number_values, p[1])
      y_number_values = append(y_number_values, p[2])
    }
    if (input$iterations == 0){
      points = c(line1, line2, line3)
      line1 = next_iteration(line1)
      line2 = next_iteration(line2)
      line3 = next_iteration(line3)
      points_ = c(line1, line2, line3)
      draw_line(points_, "white")
      lines(x_number_values, y_number_values)
    }else{
      for (i in 1:input$iterations){
        line1 = next_iteration(line1)
        line2 = next_iteration(line2)
        line3 = next_iteration(line3)
      }
      
      points = c(line1, line2, line3)
      draw_line(points, "black")
    }
  })
}

app = shinyApp(ui, server)
runApp(app)


