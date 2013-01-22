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

currentUserHasAnswered = (questionId) ->
	_.contains(answeredQuestionIds(), questionId)

getUsername = (user) ->
	if user.profile.username
		user.profile.username
	else if user.profile.facebook and user.profile.facebook.username 
		user.profile.facebook.username
	else
		getName user

getName = (user) ->
	if user.profile.name
		user.profile.name
	else if user.profile.facebook and user.profile.facebook.name 
		user.profile.facebook.name
	else if user.profile.google and user.profile.google.name 
		user.profile.google.name
	else
		"anonymous"

getEmail = (user) ->
	if user.profile.email
		user.profile.email
	else if user.profile.facebook and user.profile.facebook.email 
		user.profile.facebook.email
	else if user.profile.google and user.profile.google.email 
		user.profile.google.email
	else
		""

getGender = (user) ->
	if user.profile.gender
		user.profile.gender
	else if user.profile.facebook and user.profile.facebook.gender 
		user.profile.facebook.gender
	else if user.profile.google and user.profile.google.gender 
		user.profile.google.gender
	else
		""

getBirthday = (user) ->
	if user.profile.birthday
		user.profile.birthday
	else if user.profile.facebook and user.profile.facebook.birthday 
		user.profile.facebook.birthday
	else if user.profile.google and user.profile.google.birthday 
		user.profile.google.birthday
	else
		""

getLocale = (user) ->
	if user.profile.locale
		user.profile.locale
	else if user.profile.facebook and user.profile.facebook.locale 
		user.profile.facebook.locale
	else if user.profile.google and user.profile.google.locale 
		user.profile.google.locale
	else
		""

getTimezone = (user) ->
	if user.profile.timezone
		user.profile.timezone
	else if user.profile.facebook and user.profile.facebook.timezone 
		user.profile.facebook.timezone
	else if user.profile.google and user.profile.google.timezone 
		user.profile.google.timezone
	else
		""

getBio = (user) ->
	if user.profile.bio
		user.profile.bio
	else if user.profile.facebook and user.profile.facebook.bio 
		user.profile.facebook.bio
	else if user.profile.google and user.profile.google.bio 
		user.profile.google.bio
	else
		""

getQuotes = (user) ->
	if user.profile.quotes
		user.profile.quotes
	else if user.profile.facebook and user.profile.facebook.quotes 
		user.profile.facebook.quotes
	else if user.profile.google and user.profile.google.quotes 
		user.profile.google.quotes
	else
		""

getEducation = (user) ->
	if user.profile.education
		user.profile.education
	else if user.profile.facebook and user.profile.facebook.education 
		user.profile.facebook.education
	else if user.profile.google and user.profile.google.education 
		user.profile.google.education
	else
		{}

getWork = (user) ->
	if user.profile.work
		user.profile.work
	else if user.profile.facebook and user.profile.facebook.work 
		user.profile.facebook.work
	else if user.profile.google and user.profile.google.work 
		user.profile.google.work
	else
		{}

getInspirationalPeople = (user) ->
	if user.profile.inspirational_people
		user.profile.inspirational_people
	else if user.profile.facebook and user.profile.facebook.inspirational_people 
		user.profile.facebook.inspirational_people
	else if user.profile.google and user.profile.google.inspirational_people 
		user.profile.google.inspirational_people
	else
		{}

getAvatarUri = (user) ->
	if user.profile.avatarUri
		user.profile.avatarUri
	else if user.profile.facebook and user.profile.facebook.id 
		"http://graph.facebook.com/#{user.profile.facebook.id}/picture?width=200&height=200"
	else if user.profile.google and user.profile.google.picture 
		user.profile.google.picture
	else
		"/assets/BlankProfileImage.jpg"

getSyncedAccounts = (user) ->
	accounts = []
	if user.services
		accounts.push('facebook') if user.services.facebook
		accounts.push('twitter') if user.services.twitter
		accounts.push('google') if user.services.google
		accounts.push('github') if user.services.github
	accounts
