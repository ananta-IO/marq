## Users
isAdminById = (userId) ->
	user = Meteor.users.findOne(userId)
	user and isAdmin(user)

isAdmin = (user) ->
	if !user or typeof user is 'undefined'
		false
	else
		!!user.isAdmin