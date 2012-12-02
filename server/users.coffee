Accounts.onCreateUser (options, user) ->
	user.profile = options.profile || {}
	user.karma = 0
	
	# users start pending and need to be invited
	user.isInvited = false
	
	if options.email
		user.profile.email = options.email
		
	if user.profile.email
		user.email_hash = CryptoJS.MD5(user.profile.email.trim().toLowerCase()).toString()
	
	unless user.profile.name
		user.profile.name = user.username
	
	# if this is the first user ever, make them an admin
	unless Meteor.users.find().count()
		user.isAdmin = true

	trackEvent('new user', {username: user.username, email: user.profile.email})

	return user