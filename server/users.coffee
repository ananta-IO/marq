Accounts.onCreateUser (options, user) ->
	user.profile = options.profile || {}
	user.karma = 0
	user.viewQuestionCount = 0
	user.answerQuestionCount = 0
	user.askQuestionCount = 0
	user.postCommentCount = 0
	user.castVoteCount = 0
	user.answeredQuestionIds = []
	user.skippedQuestionIds = []
	user.createdAt = new Date

	
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


	if user.services.facebook
		# get profile data from Facebook
		result = Meteor.http.get "https://graph.facebook.com/me",
			params:
				access_token: user.services.facebook.accessToken
		# if successfully obtained facebook profile, save it off
		if not result.error and result.data
			user.profile.facebook = result.data  
			user.karma = 101
			

	if user.services.google
		# get profile data from Google
		result = Meteor.http.get "https://www.googleapis.com/oauth2/v1/userinfo?alt=json",
			params:
				access_token: user.services.google.accessToken
		# if successfully obtained google profile, save it off
		if not result.error and result.data
			user.profile.google = result.data
			user.karma = 101


	return user