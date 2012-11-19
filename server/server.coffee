Meteor.startup ->
	# code to run on server at startup

# Meteor.publish "directory", ->
#	Meteor.users.find {},
#		fields:
#			emails: 1
#			profile: 1


# Meteor.publish "parties", ->
#	Parties.find $or: [
#		public: true
#	,
#		invited: @userId
#	,
#		owner: @userId
#	]

Meteor.publish "questions", ->
	Questions.find()