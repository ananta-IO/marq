## Settings
# Each setting is represented by a document in the Settings collection:
#	ownerId: String user id
#	questionId: String question id
#   createdAt: new Date
Settings = new Meteor.Collection("settings")

Settings.allow
	insert: (userId, setting) ->
		isAdminById(userId)
	
	update: (userId, settings, fields, modifier) ->
		isAdminById(userId)

	remove: (userId, settings) ->
		isAdminById(userId)

# Meteor.methods