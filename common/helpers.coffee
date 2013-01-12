getSetting = (setting) ->
	settings = Settings.find().fetch()[0]
	if settings then settings[setting] else ''

scrollToTop = ->
	$("html, body").animate({ scrollTop: 0 }, 400)

resizeIframe = ($iframe, newWidth) ->
	width = $iframe.attr('width')
	height = $iframe.attr('height')
	aspectRatio = height/width
	$iframe.attr('width', newWidth)
	$iframe.attr('height', newWidth*aspectRatio)