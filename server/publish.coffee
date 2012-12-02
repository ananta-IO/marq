Meteor.publish 'currentUser', ->
	Meteor.users.find(@userId)

Meteor.publish 'allUsers', ->
	if @userId and isAdminById(@userId)
		# if user is admin, publish all fields
		Meteor.users.find()
	else
		Meteor.users.find({}, {fields:
			secret_id: false
			isAdmin: false
			emails: false
			notifications: false
			'profile.email': false
			'services.twitter.accessToken': false
			'services.twitter.accessTokenSecret': false
			'services.twitter.id': false
			'services.facebook.accessToken': false
			'services.facebook.accessTokenSecret': false
			'services.facebook.id': false
			'services.password': false
		})


Meteor.startup ->
	# code to run on server at startup


Meteor.publish "questions", ->
	Questions.find()