Template.userLoggedIn.events
	"click #logout": (event, template) ->
		Meteor.logout (error) ->
			if error
				# faliure
			else
				# success