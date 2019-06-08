// Convert data
function conversor2(d) {
    d.season = +d.season;
    d.actual = +d.actual;
    d.adjusted = +d.adjusted;
    d.residual = +d.residual;
    return d;
}

// dimensions and margins of the svg
var width2 = 600,
    height2 = 400;
var margin = {top: 30, right: 100, bottom: 80, left: 60};
// pad para alejar eje x
var padX = 20;

// datos
var data2 = []

function loadData2()
{
    d3.csv("http://localhost:8000/data/resid_to_js.csv", function(data){
        data2.push(conversor2(data));
    }).then( function() {
        DrawChart2();
    });
}

// jquery - cuando todo el documento esta cargado ejecuta la funcion loadData
$(document).ready(loadData2);


function DrawChart2() {

  // team y season default
  //var team = "Atlanta Hawks",
    //  season = 2009;
  // dimensions of the plot
  var width2p = width2 - margin.left - margin.right;
  var height2p = height2 - margin.top - margin.bottom;
  // version modificada para alejar eje X
  var height2pm = height2p + padX;
  var width2pm = width2p + padX;
  // all teams
  var teamOptions = d3.map(data2, function(d) {return d.team;}).keys().sort();
  // all seasons
  var seasonOptions = d3.map(data2, function(d) {return d.season;}).keys().sort();

  var team = teamOptions[0],
      season = seasonOptions[0];

  // svg
  var svg = d3.select("#chart2")
              .append("svg")
              .attr("width", width2)
              .attr("height", height2);
  var xScale, yScale;
  // Grupo
  svg.append('g')
     .classed('chart2', true)
     .attr('transform', "translate(" + margin.left + "," + margin.top + ")");
  // Grupo para los nombres del scatter (para no confundirlos con text de labels)
     svg.append('g')
        .classed('chart2names', true)
        .attr('transform', "translate(" + margin.left + "," + margin.top + ")");
  // Team dropdown
  d3.select("#selectTeam")
    .selectAll('option')
  	.data(teamOptions)
    .enter()
 	  .append('option')
    .text(function (d) { return d; })
    .attr("value", function (d) { return d; })
    // .classed('selected', function(d) {
    //   return d === team;
    // })



    teamSelection = d3.select("#selectTeam")
        .on('change', function() {
      // team = d;
      // team = d3.select("#selectTeam").node().value;
      team = d3.select(this)
               //.select("select")
               .property("value");
             
      updateChart()
    });
  // Season dropdown
      d3.select("#selectSeason")
    .selectAll('option')
    .data(seasonOptions)
    .enter()
    .append('option')
    .text(function (d) { return d; })
    .attr("value", function (d) { return d; })

      seasonSelection = d3.select("#selectSeason")
        .on('change', function() {
      // team = d;
      // team = d3.select("#selectTeam").node().value;
      season = d3.select(this)
               //.select("select")
               .property("value");
             
      updateChart()
    });


  // Axis labels
  d3.select('svg g.chart2')
    .append('text')
    .attr('id', 'xLabel')
    .attr('x', width2p/2 + padX)
    .attr('y', height2pm + 40)
    .attr('text-anchor', 'middle')
    .text("Actual salary");
  d3.select('svg g.chart2')
    .append('text')
    .attr('id', 'yLabel')
    .attr('x', -height2p/2)
    .attr('y', -40)
    .attr('transform', 'rotate(-90)')
    .attr('text-anchor', 'middle')
    .text('Expected salary');





  // Render plot

  updateScales();
  // // Render points
  // d3.select('svg g.chart2')
  //   .selectAll('circle')
  //   .data(data2.filter(function(row)
  //                     {return row['season']==season && row['team']==team;}))
  //   .enter()
  //   .append('circle')
  //   .attr("cx", function(d) { return xScale(d.actual) })
  //   .attr("cy", function(d) { return yScale(d.adjusted) })
  //   .attr("r", 7)
  //   .style("fill", "#69b3a2")
  // Render diagonal line
  d3.select('svg g.chart2')
    .append("line")
    .data(data2.filter(function(row)
                      {return row['season']==season && row['team']==team;}))
    .attr("x1", xScale(max_tot))
    .attr("y1", yScale(max_tot))
    .attr("x2", xScale(min_tot)+padX)
    .attr("y2", yScale(min_tot))
    .attr("stroke-width", 2)
    .attr("stroke", "rgb(255,200,100)")
    .attr("stroke-dasharray", "5,5");

  // Render names in scatterplot
  d3.select('svg g.chart2names')
    .selectAll('text')
    //.data(data2.filter(function(row)
    //                  {return row['season']==season && row['team']==team;}))
    //.join("text")
    //.attr("x", d => xScale(d.actual))
    //.attr("y", d => yScale(d.adjusted))
    //.text(d => d.player)
    //.attr("font-family", "sans-serif")
    //.attr("font-size", 10);

  updateChart();
  // updateMenus();

  // Render axes
  d3.select('svg g.chart2')
    .append("g")
    .attr('transform', "translate("+ padX + ","+ height2pm +")")
    .attr('id', 'xAxis')
    .call(d3.axisBottom(xScale));
  d3.select('svg g.chart2')
    .append("g")
    .attr('id', 'yAxis')
    .attr('transform', 'translate(0, 0)')
    .call(d3.axisLeft(yScale));


  // FUNCTIONS
  function updateScales() {
    dataFilter = data2.filter(function(row)
                      {return row['season']==season && row['team']==team;})
    max_x = d3.max(dataFilter, function(d) {return d.actual;} )
    min_x = d3.min(dataFilter, function(d) {return d.actual;} )
    max_y = d3.max(dataFilter, function(d) {return d.adjusted;} )
    min_y = d3.min(dataFilter, function(d) {return d.adjusted;} )
    max_tot = d3.max([max_x,max_y]);
    min_tot = d3.min([min_x,min_y]);    
    xScale = d3.scaleLinear()
               .domain([min_tot, max_tot])
               .range([padX, width2pm]);
    yScale = d3.scaleLinear()
               .domain([min_tot, max_tot])
               .range([height2p, 0]);
  }

  function updateChart() {
    console.log(team);
    console.log(season)


    updateScales();
    dataFilter = data2.filter(function(row) {return row['season']==season && row['team']==team;})

    console.log(dataFilter)
    // update names in scatterplot

// Define the div for the tooltip
var div = d3.select("body").append("div") 
    .attr("class", "tooltip")       
    .style("opacity", 0);


    unames = d3.select('svg g.chart2names')
      .selectAll('text')
      .data(dataFilter);

      unames.exit()
            .remove()

     unames.enter()
     .append("text")
     .merge(unames) 
      .transition()
      .duration(500)
      // .ease('quad_out')
      .attr("x", d => xScale(d.actual))
      .attr("y", d => yScale(d.adjusted))
      .text(d => d.player)
      .attr("font-family", "sans-serif")
      .attr("font-size", 10);

      d3.select('svg g.chart2names')
      .selectAll('text')
      .on("mouseover", function(d) {    
            console.log('MOUSEOVEPAPA');
              
            div
            .html(d.player + "<br/>" + d3.format(".3n")(d.actual))  
                .style("left", (d3.event.pageX) + "px")   
                .style("top", (d3.event.pageY + 15) + "px");

            div.transition()    
                .duration(200)    
                .style("opacity", .9);        
            })          
        .on("mouseout", function(d) {   
            div.transition()    
                .duration(500)    
                .style("opacity", 0); 
        });
      ;
    // Update the axes
    d3.select('svg g.chart2 #xAxis')
      .transition()
      .call(d3.axisBottom(xScale));
    d3.select('svg g.chart2 #yAxis')
      .transition()
      .call(d3.axisLeft(yScale));
  }

}
