// Convert data
function conversor(d) {
    d.x = +d.x;
    d.y = +d.y;
    d.lower = +d.lower;
    d.upper = +d.upper;
    return d;
}

// dimensions and margins of the svg
var width = 600,
    height = 400;
var margin = {top: 0, right: 30, bottom: 30, left: 60};

// datos
var data1 = []

function loadData1()
{
    d3.csv("./data/effects.csv", function(data){
        data1.push(conversor(data));
    }).then( function() {
        DrawChart1();
    });
}

// jquery - cuando todo el documento esta cargado ejecuta la funcion loadData1
$(document).ready(loadData1);

console.log(data1)

function DrawChart1() {

  // dimensions of the plot
  var widthp = width - margin.left - margin.right;
  var heightp = height - margin.top - margin.bottom;
  // variables x posibles en el menu (siempre description)
  var xAxisOptions = d3.map(data1, function(d) {return d.description;}).keys();
  // variable x default
  var xAxis = "Age";
  // var xAxis = xAxisOptions[0];

  // svg
  var svg = d3.select("#chart1")
              .append("svg")
              .attr("width", width)
              .attr("height", height);
  var xScale, yScale;
  // grupo
  svg.append('g')
     .classed('chart1', true)
     .attr('transform', "translate(" + margin.left + "," + margin.top + ")");
  // Build menus
  d3.select('#x-axis-menu')
    .style('margin-top', margin.top+'px')
    .style('height', heightp+"px")
    .selectAll('li')
    .data(xAxisOptions)
    .enter()
    .append('li')
    .text(function(d) {return d;})
    .classed('selected', function(d) {
      return d === xAxis;
    })
    .on('click', function(d) {
      xAxis = d;
      updateChart1();
      updateMenus1();
    })
    ;
  // Confidence interval
  d3.select('svg g.chart1')
    .append('path')
    .attr('id', 'confidence');
  // Line
  d3.select('svg g.chart1')
    .append('path')
    .attr('id', 'line');
  // Axis labels
  d3.select('svg g.chart1')
    .append('text')
    .attr('id', 'xLabel')
    .attr('x', widthp/2)
    .attr('y', heightp + 40)
    .attr('text-anchor', 'middle')
    .text(xAxis);
  d3.select('svg g.chart1')
    .append('text')
    .attr('id', 'yLabel')
    .attr('x', -60)
    .attr('y', -20)
    // .attr('transform', 'rotate(-90)')
    // .attr('text-anchor', 'middle')
    .text('Expected change in salary (millions of dollars)');

  // Render plot

  updateScales1();
  // Render confidence interval
  d3.select('#confidence')
    .datum(data1.filter(function(row) {return row['description'] == xAxis;}))
    .attr("fill", "rgb(255,235,200)")
    .attr("stroke", "none")
    .attr("d", d3.area()
                 .x(function(d) { return xScale(d.x) })
                 .y0(function(d) { return yScale(d.upper) })
                 .y1(function(d) { return yScale(d.lower) })
          )
  // Render line
  d3.select('#line')
    .datum(data1.filter(function(row) {return row['description'] == xAxis;}))
    .attr("fill", "none")
    .attr("stroke", "rgb(0,122,51)")
    .attr("stroke-width", 1.5)
    .attr("d", d3.line()
                 // .curve(d3.curveBasis)
                 .x(function(d) { return xScale(d.x) })
                 .y(function(d) { return yScale(d.y) })
          )
  updateChart1(true);
  updateMenus1();
  // Render axes
  d3.select('svg g.chart1')
    .append("g")
    .attr('transform', "translate(0,"+ heightp +")")
    .attr('id', 'xAxis')
    .call(d3.axisBottom(xScale));
  d3.select('svg g.chart1')
    .append("g")
    .attr('id', 'yAxis')
    .attr('transform', 'translate(0, 0)')
    .call(d3.axisLeft(yScale));


  // FUNCTIONS
  function updateScales1() {
    max_y = d3.max(data1, function(d) {return d.upper;} )
    min_y = d3.min(data1, function(d) {return d.lower;} )
    dataFilter = data1.filter(function(row) {return row['description'] == xAxis;})
    max_x = d3.max(dataFilter, function(d) {return d.x;} )
    min_x = d3.min(dataFilter, function(d) {return d.x;} )
    xScale = d3.scaleLinear()
               .domain([min_x, max_x])
               .range([0, widthp]);
    yScale = d3.scaleLinear()
               .domain([min_y, max_y])
               .range([heightp, 0]);
  }

  function updateChart1(init) {
    updateScales1();
    dataFilter = data1.filter(function(row) {return row['description'] == xAxis;})
    // Update confidence interval
    d3.select('#confidence')
      .datum(dataFilter)
      .transition()
      .duration(500)
      .attr("d", d3.area()
                   .x(function(d) { return xScale(d.x) })
                   .y0(function(d) { return yScale(d.upper) })
                   .y1(function(d) { return yScale(d.lower) })
           )
    // Update line
    d3.select('#line')
      .datum(dataFilter)
      .transition()
      .duration(500)
      .attr("d", d3.line()
                   // .curve(d3.curveBasis)
                   .x(function(d) { return xScale(d.x) })
                   .y(function(d) { return yScale(d.y) })
           )
    // Update the axes
    d3.select('svg g.chart1 #xAxis')
      .transition()
      .call(d3.axisBottom(xScale));
    d3.select('svg g.chart1 #yAxis')
      .transition()
      .call(d3.axisLeft(yScale));
    // Update axis labels
    d3.select('svg g.chart1 #xLabel')
      .text(xAxis);
  }

  function updateMenus1() {
    d3.select('#x-axis-menu')
      .selectAll('li')
      .classed('selected', function(d) {  return d === xAxis;});
  }

}
