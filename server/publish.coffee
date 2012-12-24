# ** Users **

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
			'profile.facebook': false
			'services.twitter.accessToken': false
			'services.twitter.accessTokenSecret': false
			'services.twitter.id': false
			'services.facebook.accessToken': false
			'services.facebook.accessTokenSecret': false
			'services.facebook.id': false
			'services.password': false
		})


# ** Questions **

Meteor.publish "allQuestions", ->
	Questions.find()

# Meteor.publish 'questions', (find, options, subName) ->
#	collection = Questions.find(find, options)
#	collectionArray = collection.fetch()

#	# if this is a single question subscription but no question ID is passed, just return an empty collection
#	if subName is "singleQuestion" and _.isEmpty(find)
#		collection = null
#		collectionArray = []

#	collection

# Meteor.publish 'question', (id) ->
#	Questions.find(id)



# ** Answers **

# Meteor.publish "allAnswers", ->
#	Answers.find()


# ** Votes **

# Meteor.publish "allVotes", ->
#	Votes.find()


# ** Comments **

# Meteor.publish "allComments", ->
#	Comments.find()