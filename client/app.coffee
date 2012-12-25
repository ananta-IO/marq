# ** Users **

Meteor.subscribe('currentUser')
Meteor.subscribe('allUsers')


# ** Questions **

Meteor.subscribe('allQuestions')

# QUESTIONS_PER_PAGE = 3

# # name <- the name of various session vars that will be set:
# #  - 'nameReady' <- is the subscription loading or ready?
# #  - 'nameLimit' <- how many of this type are we currently displaying?
# # options:
# #   - find <- how to find the items
# #   - sort <- how to sort them
# #   - perPage <- how many to display per-page
# #   - 
# questionsForSub = {}
# setupQuestionSubscription = (name, options) ->
#	readyName = "#{name}Ready"
#	limitName = "#{name}Limit"

#	if options.perPage and !Session.get(limitName)
#		Session.set(limitName, options.perPage)

#	# setup the subscription
#	Meteor.autosubscribe () ->
#		Session.set(readyName, false)

#		findOptions =
#			sort: options.sort
#			limit: options.perPage and Session.get(limitName)

#		find = if _.isFunction(options.find) then options.find() else options.find
#		Meteor.subscribe 'questions', find or {}, findOptions, name, () ->
#			Session.set(readyName, true)

#	# setup a function to find the relevant questions (+deal with mm's lack of limit)
#	questionsForSub[name] = () ->
#		find = if _.isFunction(options.find) then options.find() else options.find
#		orderedQuestions = Questions.find(find or {}, {sort: options.sort})
#		if options.perPage
#			limitDocuments(orderedQuestions, Session.get(limitName))
#		else
#			orderedQuestions

# setupQuestionSubscription 'singleQuestion',
#	find: () -> Session.get('selectedQuestionId')

# setupQuestionSubscription 'answerQuestions',
#	find: { $or : [ { answers: { $size: 0 } } , { answeredBy : { $ne : @userId } }] }
#	sort: { sort: { voteTally: -1, createdAt: -1 } }
#	perPage: QUESTIONS_PER_PAGE

# setupQuestionSubscription 'answeredQuestions',
#	# find: {}  # TODO
#	sort: {score: -1}
#	perPage: QUESTIONS_PER_PAGE

# setupQuestionSubscription 'askedQuestions',
#	# find: {}  # TODO
#	sort: {score: -1}
#	perPage: QUESTIONS_PER_PAGE



# ** Answers **

Meteor.subscribe('myAnswers')
# Meteor.subscribe('allAnswers')


# ** Votes **

Meteor.subscribe('myVotes')
# Meteor.subscribe('allVotes')


# ** Comments **

# Meteor.subscribe('allComments')