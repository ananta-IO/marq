## Users
# Each user is represented by a document in the Users collection:
#	answeredQuestionIds: array of question ids that this user has answered
#	skippedQuestionIds: array of question ids that this user has skipped
#	profile: object
#	 - facebook: object with all the user's facebook data
#    - TODO: sync with more demographic info i.e. Twitter and Linkedin
#   karma: Integer tally of cumulative site wide reputation. Question quality. Achievments unlocked. Etc.
#   createdAt: new Date

isAdminById = (userId) ->
	user = Meteor.users.findOne(userId)
	user and isAdmin(user)

isAdmin = (user) ->
	if !user or typeof user is 'undefined'
		false
	else
		!!user.isAdmin