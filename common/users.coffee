## Users
# Each user is represented by a document in the Users collection:
#	answers: array of answer ids that this user owns
#	comments: array of comment ids that this user owns
#	questions: array of question ids that this user owns
#	answeredQuestions: array of question ids that this user has answered
#	skippedQuestions: array of question ids that this user has skipped
#	profile: object
#	 - facebook: object with all the user's facebook data
#    - TODO: sync with more demographic info i.e. Twitter and Linkedin
#   createdAt: new Date

isAdminById = (userId) ->
	user = Meteor.users.findOne(userId)
	user and isAdmin(user)

isAdmin = (user) ->
	if !user or typeof user is 'undefined'
		false
	else
		!!user.isAdmin