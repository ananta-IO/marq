# http://bl.ocks.org/2212156
drawPie = (pieName, dataSet, selectString, colors, margin, outerRadius, innerRadius, sortArcs) ->
	
	# pieName => A unique drawing identifier that has no spaces, no "." and no "#" characters.
	# dataSet => Input Data for the chart, itself.
	#		exampleDataSet = [
	#			{legendLabel: "Legend String 1", magnitude: 51, link: "http://www.if4it.com"},
	#			{legendLabel: "Legend String 2", magnitude: 21, link: "http://www.if4it.com/glossary.html"},
	#			{legendLabel: "Legend String 3", magnitude: 31, link: "http://www.if4it.com/resources.html"},
	#			{legendLabel: "Legend String 4", magnitude: 14, link: "http://www.if4it.com/taxonomy.html"},
	#			{legendLabel: "Legend String 5", magnitude: 19, link: "http://www.if4it.com/disciplines.html"},
	#			{legendLabel: "Legend String 6", magnitude: 47, link: "http://www.if4it.com"},
	#			{legendLabel: "Legend String 7", magnitude: 27, link: "http://www.if4it.com/glossary.html"}];
	#
	# selectString => String that allows you to pass in
	#           a D3 select string.
	# colors => String to set color scale.  Values can be...
	#           => "colorScale10"
	#           => "colorScale20"
	#           => "colorScale20b"
	#           => "colorScale20c"
	# margin => Integer margin offset value.
	# outerRadius => Integer outer radius value.
	# innerRadius => Integer inner radius value.
	# sortArcs => Controls sorting of Arcs by value.
	#              0 = No Sort.  Maintain original order.
	#              1 = Sort by arc value size.
	
	# Color Scale Handling...
	colorScale = d3.scale.category20c()
	switch colors
		when "colorScale10"
			colorScale = d3.scale.category10()
		when "colorScale20"
			colorScale = d3.scale.category20()
		when "colorScale20b"
			colorScale = d3.scale.category20b()
		when "colorScale20c"
			colorScale = d3.scale.category20c()
		else
			colorScale = d3.scale.category20c()

	canvasWidth = 700
	pieWidthTotal = outerRadius * 2
	pieCenterX = outerRadius + margin / 2
	pieCenterY = outerRadius + margin / 2
	legendBulletOffset = -70
	legendVerticalOffset = outerRadius - margin
	legendTextOffset = 20
	textVerticalSpace = 20

	canvasHeight = 0
	pieDrivenHeight = outerRadius * 2 + margin * 2
	legendTextDrivenHeight = (dataSet.length * textVerticalSpace) + margin * 2
	# Autoadjust Canvas Height
	if pieDrivenHeight >= legendTextDrivenHeight
		canvasHeight = pieDrivenHeight
	else
		canvasHeight = legendTextDrivenHeight

	x = d3.scale.linear().domain([0, d3.max(dataSet, (d) ->
		d.magnitude
	)]).rangeRound([0, pieWidthTotal])
	y = d3.scale.linear().domain([0, dataSet.length]).range([0, (dataSet.length * 20)])


	synchronizedMouseOver = ->
		arc = d3.select(this)
		indexValue = arc.attr("index_value")
		arcSelector = "." + "pie-" + pieName + "-arc-" + indexValue
		selectedArc = d3.selectAll(arcSelector)
		selectedArc.style "fill", "Maroon"
		bulletSelector = "." + "pie-" + pieName + "-legendBullet-" + indexValue
		selectedLegendBullet = d3.selectAll(bulletSelector)
		selectedLegendBullet.style "fill", "Maroon"
		textSelector = "." + "pie-" + pieName + "-legendText-" + indexValue
		selectedLegendText = d3.selectAll(textSelector)
		selectedLegendText.style "fill", "Maroon"

	synchronizedMouseOut = ->
		arc = d3.select(this)
		indexValue = arc.attr("index_value")
		arcSelector = "." + "pie-" + pieName + "-arc-" + indexValue
		selectedArc = d3.selectAll(arcSelector)
		colorValue = selectedArc.attr("color_value")
		selectedArc.style "fill", colorValue
		bulletSelector = "." + "pie-" + pieName + "-legendBullet-" + indexValue
		selectedLegendBullet = d3.selectAll(bulletSelector)
		colorValue = selectedLegendBullet.attr("color_value")
		selectedLegendBullet.style "fill", colorValue
		textSelector = "." + "pie-" + pieName + "-legendText-" + indexValue
		selectedLegendText = d3.selectAll(textSelector)
		selectedLegendText.style "fill", "Blue"

	tweenPie = (b) ->
		b.innerRadius = 0
		i = d3.interpolate(
			startAngle: 0
			endAngle: 0
		, b)
		(t) ->
			arc i(t)
	
	# Create a drawing canvas...
	canvas = d3.select(selectString)
		.append("svg:svg") #create the SVG element inside the <body>
		.data([dataSet]) #associate our data with the document
		.attr("width", canvasWidth) #set the width of the canvas
		.attr("height", canvasHeight) #set the height of the canvas
		.append("svg:g") #make a group to hold our pie chart
		.attr("transform", "translate(" + pieCenterX + "," + pieCenterY + ")") # Set center of pie
	
	
	# Define an arc generator. This will create <path> elements for using arc data.
	arc = d3.svg.arc()
		.innerRadius(innerRadius) # Causes center of pie to be hollow
		.outerRadius(outerRadius)
	
	# Define a pie layout: the pie angle encodes the value of dataSet.
	# Since our data is in the form of a post-parsed CSV string, the
	# values are Strings which we coerce to Numbers.
	pie = d3.layout.pie().value((d) ->
		d.magnitude
	).sort((a, b) ->
		if sortArcs is 1
			b.magnitude - a.magnitude
		else
			null
	)

	# Select all <g> elements with class slice (there aren't any yet)
	arcs = canvas.selectAll("g.slice")
		# Associate the generated pie data (an array of arcs, each having startAngle,
		# endAngle and value properties) 
		.data(pie)
		# This will create <g> elements for every "extra" data element that should be associated
		# with a selection. The result is creating a <g> for every object in the data array
		# Create a group to hold each slice (we will have a <path> and a <text>      # element associated with each slice)
		.enter().append("svg:a")
		.attr("xlink:href", (d) -> 
			d.data.link 
		).append("svg:g")
		.attr("class", "slice") #allow us to style things in the slices (like text)
		# Set the color for each slice to be chosen from the color function defined above
		# This creates the actual SVG path using the associated data (pie) with the arc drawing function
		.style("stroke", "White")
		.attr("d", arc)
	
	arcs.append("svg:path")
		# Set the color for each slice to be chosen from the color function defined above
		# This creates the actual SVG path using the associated data (pie) with the arc drawing function
		.attr("fill", (d, i) ->
			colorScale i
		).attr("color_value", (d, i) ->
			colorScale i # Bar fill color...
		).attr("index_value", (d, i) ->
			"index-" + i
		).attr("class", (d, i) ->
			"pie-" + pieName + "-arc-index-" + i
		).style("stroke", "White")
		.attr("d", arc)
		.on("mouseover", synchronizedMouseOver)
		.on("mouseout", synchronizedMouseOut)
		.transition()
		# .ease("bounce")
		.duration(1000)
		.delay((d, i) ->
			i * 50
		).attrTween "d", tweenPie
	
	# Computes the angle of an arc, converting from radians to degrees.
	angle = (d) ->
		a = (d.startAngle + d.endAngle) * 90 / Math.PI - 90
		(if a > 90 then a - 180 else a)

	# Add a magnitude value to the larger arcs, translated to the arc centroid and rotated.
	arcs.filter((d) ->
		d.endAngle - d.startAngle > .2
	).append("svg:text")
		.attr("dy", ".35em")
		.attr("text-anchor", "middle")
		#.attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")rotate(" + angle(d) + ")"; })
		.attr("transform", (d) -> #set the label's origin to the center of the arc
			#we have to make sure to set these before calling arc.centroid
			d.outerRadius = outerRadius # Set Outer Coordinate
			d.innerRadius = innerRadius # Set Inner Coordinate
			"translate(" + arc.centroid(d) + ")rotate(" + angle(d) + ")"
		).style("fill", "White")
		.style("font", "normal 12px Arial").text (d) ->
			d.data.magnitude
		
	# Plot the bullet circles...
	canvas.selectAll("circle")
		.data(dataSet).enter().append("svg:circle") # Append circle elements
		.attr("cx", pieWidthTotal + legendBulletOffset).attr("cy", (d, i) ->
			i * textVerticalSpace - legendVerticalOffset
		).attr("stroke-width", ".5")
		.style("fill", (d, i) ->
			colorScale i # Bullet fill color
		).attr("r", 5)
		.attr("color_value", (d, i) ->
			colorScale i # Bar fill color...
		).attr("index_value", (d, i) ->
			"index-" + i
		).attr("class", (d, i) ->
			"pie-" + pieName + "-legendBullet-index-" + i
		).on("mouseover", synchronizedMouseOver)
		.on "mouseout", synchronizedMouseOut
	
	# Create hyper linked text at right that acts as label key...
	canvas.selectAll("a.legend_link")
		.data(dataSet) # Instruct to bind dataSet to text elements
		.enter().append("svg:a") # Append legend elements
		.attr("xlink:href", (d) ->
			d.link
		).append("text")
		.attr("text-anchor", "center")
		.attr("x", pieWidthTotal + legendBulletOffset + legendTextOffset)
		#.attr("y", function(d, i) { return legendOffset + i*20 - 10; })
		#.attr("cy", function(d, i) {    return i*textVerticalSpace - legendVerticalOffset; } )
		.attr("y", (d, i) ->
			i * textVerticalSpace - legendVerticalOffset
		).attr("dx", 0)
		.attr("dy", "5px") # Controls padding to place text in alignment with bullets
		.text((d) ->
			d.legendLabel 
		).attr("color_value", (d, i) ->
			colorScale i # Bar fill color...
		).attr("index_value", (d, i) ->
			"index-" + i
		).attr("class", (d, i) ->
			"pie-" + pieName + "-legendText-index-" + i
		).style("fill", "Blue").style("font", "normal 1.5em Arial").on("mouseover", synchronizedMouseOver).on "mouseout", synchronizedMouseOut