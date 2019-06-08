// Convert data
function conversor2(d) {
    d.season = +d.season;
    d.actual = +d.actual;
    d.fitted = +d.fitted;
    d.residual = +d.residual;
    return d;
}

// dimensions and margints of the svg
var widthtop = 500,
    heighttop = 400;
var margint = {top: 0, right: 20, bottom: 80, left: 170};
// pad para alejar eje x
var padXtop = 0;

// datos
var DataTop = []

function loadDataTop()
{
    d3.csv("./data/residuals_top.csv", function(data){
        DataTop.push(conversor2(data));
    }).then( function() {
        DrawChartTop();
    });
}

// jquery - cuando todo el documento esta cargado ejecuta la funcion loadData
$(document).ready(loadDataTop);


function DrawChartTop() {

  // team y season default
  //var team = "Atlanta Hawks",
    //  season = 2009;
  // dimensions of the plot
  var widthtopp = widthtop - margint.left - margint.right;
  var heighttopp = heighttop - margint.top - margint.bottom;
  // version modificada para alejar eje X
  var heighttoppm = heighttopp + padXtop;
  var widthtoppm = widthtopp + padXtop;

    // svg
  var svg = d3.select("#chart-top")
              .append("svg")
              .attr("width", widthtop)
              .attr("height", heighttop);
  var xScale, yScale;
  // Grupo
  svg.append('g')
     .classed('chart-top', true)
     .attr('transform', "translate(" + margint.left + "," + margint.top + ")");



  // Axis labels
  d3.select('svg g.chart-top')
    .append('text')
    .attr('id', 'xLabel')
    .attr('x', widthtopp/2 + padXtop)
    .attr('y', heighttoppm + 40)
    .attr('text-anchor', 'middle')
    .text("Value of Overpayment (millions of dollars)");


  // Render plot
    /* max_x = d3.max(DataTop, function(d) {return d.residual;} )*/
    xScale = d3.scaleLinear()
               .domain([0, 19])
               .range([padXtop, widthtoppm]);
    yScale = d3.scaleBand()
               .domain(DataTop.map(function (d) {return d.id;} ))
               .range([0, heighttopp])
               .padding(0.2);

   // Render bars
   rects = d3.select('svg g.chart-top')
         .selectAll('rect')
         .data(DataTop)
         .enter()
         .append('rect')
         .attr("class", "bartop")
         //.style("fill", "rgb(100,195,165)") IN CSS
         .attr('x', function (d) {
         return padXtop;/*xScale(d.actual);*/
     })
         .attr('y', function (d, i) {
         return yScale(d.id);
     })
         .attr('height', function (d) {
         return yScale.bandwidth();
     })
         .attr('width', function (d) {
         return xScale(d.residual);
     });

  // Render axes
  d3.select('svg g.chart-top')
    .append("g")
    .attr('transform', "translate("+ padXtop + ","+ heighttoppm +")")
    .attr('id', 'xAxis')
    .call(d3.axisBottom(xScale));
  d3.select('svg g.chart-top')
    .append("g")
    .attr('id', 'yAxis')
    .attr('transform', 'translate(0, 0)')
    .call(d3.axisLeft(yScale));

  // Tooltip
  var div = d3.select("body").append("div")
      .attr("class", "tooltip-top")
      .style("opacity", 0);

  d3.select('svg g.chart-top')
    .selectAll('rect')
    .on("mouseover", function(d) {
          div
          .html("<b>" + d.team + "</b>"  + "<br/>" +
            "Actual Salary: " + d3.format(".3n")(d.actual) + "<br/>"  +
            "Expected Salary: " + d3.format(".3n")(d.fitted) + "<br/>"  +
            "Residual: "  +  d3.format(".3n")(d.residual) )
              .style("left", (d3.event.pageX) + "px")
              .style("top", (d3.event.pageY + 10) + "px");
          div.transition()
              .duration(200)
              .style("opacity", .9);
          })
      .on("mouseout", function(d) {
          div.transition()
              .duration(500)
              .style("opacity", 0);
      });


}
