settingsForm = undefined
Template.settings.helpers
	generateSettingsForm: (setting) ->
		Meteor.defer ->
			settingsForm = new DatabaseForm()
			settingsForm.generateFor setting, "#json-form"


	noSettings: ->
		!Settings.findOne()?

	setting: ->
		setting = Settings.find().fetch()[0]
		new Setting(setting) or new Setting()

Template.settings.events = "click input[type=submit]": (e) ->
	e.preventDefault()
	throw "You must be logged in."  unless Meteor.user()
	settingsForm.submit (->
		alert "Settings have been created"
	), (error) ->
		console.log error  if error
		alert "Settings have been updated"
