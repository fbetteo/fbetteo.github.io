// Convert data
function conversor2(d) {
    d.season = +d.season;
    d.actual = +d.actual;
    d.fitted = +d.fitted;
    d.residual = +d.residual;
    return d;
}

// dimensions and marginbs of the svg
var widthbottom = 500,
    heightbottom = 400;
var marginb = {top: 0, right: 170, bottom: 80, left: 20};
// pad para alejar eje x
var padXbottom = 0;

// datos
var Databottom = []

function loadDatabottom()
{
    d3.csv("./data/residuals_bottom.csv", function(data){
        Databottom.push(conversor2(data));
    }).then( function() {
        DrawChartbottom();
    });
}

// jquery - cuando todo el documento esta cargado ejecuta la funcion loadData
$(document).ready(loadDatabottom);


function DrawChartbottom() {

  // dimensions of the plot
  var widthbottomp = widthbottom - marginb.left - marginb.right;
  var heightbottomp = heightbottom - marginb.top - marginb.bottom;
  // version modificada para alejar eje X
  var heightbottompm = heightbottomp + padXbottom;
  var widthbottompm = widthbottomp + padXbottom;

    // svg
  var svg = d3.select("#chart-bottom")
              .append("svg")
              .attr("width", widthbottom)
              .attr("height", heightbottom);
  var xScale, yScale;
  // Grupo
  svg.append('g')
     .classed('chart-bottom', true)
     .attr('transform', "translate(" + marginb.left + "," + marginb.top + ")");

  // Axis labels
  d3.select('svg g.chart-bottom')
    .append('text')
    .attr('id', 'xLabel')
    .attr('x', widthbottomp/2 + padXbottom)
    .attr('y', heightbottompm + 40)
    .attr('text-anchor', 'middle')
    .text("Value of Underpayment (millions of dollars)");

  // Render plot
    xScale = d3.scaleLinear()
               .domain([-19, 0])
               .range([padXbottom, widthbottompm]);
    yScale = d3.scaleBand()
               .domain(Databottom.map(function (d) {return d.id;} ))
               .range([0, heightbottomp])
               .padding(0.2);

   // render bars
   rects = d3.select('svg g.chart-bottom')
         .selectAll('rect')
         .data(Databottom)
         .enter()
         .append('rect')
         //.style("fill", "rgb(250,140,100)") in CSS
         .attr("class","barbottom")
         .attr('x', function (d) {
         return xScale(d.residual);/*xScale(d.actual);*/
     })
         .attr('y', function (d, i) {
         return yScale(d.id);
     })
         .attr('height', function (d) {
         return yScale.bandwidth();
     })
         .attr('width', function (d) {
         return widthbottompm - xScale(d.residual) ;
     });

  // Render axes
  d3.select('svg g.chart-bottom')
    .append("g")
    .attr('transform', "translate("+ padXbottom + ","+ heightbottompm +")")
    .attr('id', 'xAxis')
    .call(d3.axisBottom(xScale));
  d3.select('svg g.chart-bottom')
    .append("g")
    .attr('id', 'yAxis')
    .attr('transform', "translate("+ widthbottomp +",0)")
    .call(d3.axisRight(yScale));

  // Tooltip
  var div = d3.select("body").append("div")
      .attr("class", "tooltip-bottom")
      .style("opacity", 0);

  d3.select('svg g.chart-bottom')
    .selectAll('rect')
    .on("mouseover", function(d) {
          div
          .html("<b>" + d.team + "</b>"  + "<br/>" +
            "Actual Salary: " + d3.format(".3n")(d.actual) + "<br/>"  +
            "Expected Salary: " + d3.format(".3n")(d.fitted) + "<br/>"  +
            "Residual: "  +  d3.format(".3n")(d.residual) )
              .style("left", (d3.event.pageX) + "px")
              // .style("left", widthbottompm+xScale(d.residual)-130 + "px")
              .style("top", (d3.event.pageY) + "px");
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
