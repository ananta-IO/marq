getSetting = (setting) ->
	settings = Settings.find().fetch()[0]
	if settings then settings[setting] else ''