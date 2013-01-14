Template.body.showQuestionsDialog = ->
	Session.get("showQuestionsDialog")

Template.body.notLoggedIn = ->
	!Meteor.userId()?