## Views
# Each view is represented by a document in the Views collection:
#	ownerId: String user id
#	questionId: String question id
#   createdAt: new Date
Views = new Meteor.Collection("views")

Views.allow
	insert: (userId, view) ->
		false # no cowboy inserts -- use createView method
	
	update: (userId, views, fields, modifier) ->
		false

	remove: (userId, views) ->
		false

# Meteor.methods
#	# DO NOT call this directly. Should be called by rateQuestion
#	# options should include: vote, questionId, incValue
#	createView: (options) ->
#		options = options or {}

#		#TODO?
