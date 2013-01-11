getSetting = (setting) ->
	settings = Settings.find().fetch()[0]
	if settings then settings[setting] else ''

scrollToTop = ->
	$("html, body").animate({ scrollTop: 0 }, 400)