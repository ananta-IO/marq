# analyticsRequest = ->  
#	# Mixpanel
#	if (mixpanelId = getSetting("mixpanelId")) and window.mixpanel.length is 0
#		mixpanel.init mixpanelId
#		if Meteor.user()
#			currentUserEmail = getCurrentUserEmail()
#			mixpanel.people.identify currentUserEmail
#			mixpanel.people.set
#				username: getDisplayName(Meteor.user())
#				$last_login: new Date()
#				$created: moment(Meteor.user().createdAt)._d
#				$email: currentUserEmail

#			mixpanel.register
#				username: getDisplayName(Meteor.user())
#				createdAt: moment(Meteor.user().createdAt)._d
#				email: currentUserEmail

#			mixpanel.name_tag currentUserEmail
 	
#	# GoSquared
#	if goSquaredId = getSetting("goSquaredId")
#		GoSquared.acct = goSquaredId
#		GoSquaredInit()
 	
#	# Intercom
#	if (intercomId = getSetting("intercomId")) and Meteor.user()
#		window.intercomSettings =
#			app_id: intercomId
#			email: currentUserEmail
#			created_at: moment(Meteor.user().createdAt).unix()
#			custom_data:
#				"profile link": "http://" + document.domain + "/users/" + Meteor.user()._id

#			widget:
#				activator: "#Intercom"
#				use_counter: true
#				activator_html: (obj) ->
#					obj.activator_html_functions.brackets()

#		IntercomInit()