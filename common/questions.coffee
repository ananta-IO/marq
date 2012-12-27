## Questions
# Each question is represented by a document in the Questions collection:
#   owner: user id
#   question: String
#   answerChoices: Array of possible answers like ["yes", "no", "don't care"]
#   answersTally: Object with the breakdown for each answer choice like {ansChoice0: 3, ansChoice1: 89, ansChoice3: 0}
#   answerCount: Integer count of answers
#   voteTally: Integer count of for votes minus against votes
#   score: Integer count of the aggregate score of a question
#   createdAt: new Date
Questions = new Meteor.Collection("questions")

Questions.allow
	insert: (userId, question) ->
		false # no cowboy inserts -- use createQuestion method
	
	update: (userId, questions, fields, modifier) ->
		false
		# _.all questions, (question) ->
		#   return false  if userId isnt question.owner # not the owner
		#   allowed = ["question", "answerChoices"]
		#   return false  if _.difference(fields, allowed).length # tried to write to forbidden field
			
		#   # A good improvement would be to validate the type of the new
		#   # value of the field (and if a string, the length.) In the
		#   # future Meteor will have a schema system to makes that easier.
		#   true

	remove: (userId, questions) ->
		not _.any(questions, (question) ->
			!canRemoveQuestion(userId, question)
		)

objectifyAnswerChoices = (answerChoices) ->
	_.map(answerChoices, (ac, i) -> {order: i+1, placeholder: ac, value: ac})

unansweredQuestions = (limit = 3) ->
	answeredQuestionIds = Meteor.user().answeredQuestionIds or []
	skippedQuestionIds = Meteor.user().skippedQuestionIds or []
	ids = _.union(answeredQuestionIds, skippedQuestionIds)
	questions = Questions.find(
		{ _id: { $nin : ids } }
		{ sort: { voteTally: -1, createdAt: -1 } }
	).fetch().slice(0, limit)
	unless questions.length > 0
		questions = Questions.find(
			{ _id: { $nin : answeredQuestionIds } }
			{ sort: { voteTally: -1, createdAt: -1 } }
		).fetch().slice(0, limit)
	questions 

Meteor.methods
	# options should include: question, answerChoices
	createQuestion: (options) ->
		options = options or {}
		
		throw new Meteor.Error(403, "Log in to ask a question")  unless @userId
		throw new Meteor.Error(400, "Question can't be blank")  unless typeof options.question is "string" and options.question.length
		throw new Meteor.Error(413, "Question is too long (140 characters max)")  if options.question and options.question.length > 140
		throw new Meteor.Error(413, "Add at least one more answer choice")  if options.answerChoices and options.answerChoices.length > 0 and options.answerChoices.length < 2
		throw new Meteor.Error(413, "Too many answer choice (5 max)")  if options.answerChoices and options.answerChoices.length > 5
		throw new Meteor.Error(413, "At least one answer choice is too long (90 characters max)")  if options.answerChoices and _.contains(_.map(options.answerChoices, (ac) -> ac.length > 90 ), true)
		throw new Meteor.Error(400, "You have already asked this question")  if Questions.findOne({ ownerId: @userId, question: options.question })
		
		answerChoices = if options.answerChoices and options.answerChoices.length > 0 then options.answerChoices else ["yes", "no", "don't care"]
		answersTally = {}
		_.each answerChoices, (ac) ->
			answersTally[ac] = 0

		Questions.insert
			ownerId: @userId
			question: options.question
			answerChoices: answerChoices
			answersTally: answersTally
			answerCount: 0
			voteTally: 0
			score: 0
			createdAt: new Date


	# options should include: questionId
	skipQuestion: (options) ->
		options = options or {}

		throw new Meteor.Error(403, "Log in to skip this question")  unless Meteor.userId()
		question = Questions.findOne(options.questionId)
		throw new Meteor.Error(404, "No such question")  unless question

		unless options.questionId in Meteor.user().skippedQuestionIds
			Meteor.users.update @userId, {
				$push: { skippedQuestionIds: options.questionId }
			}


	# options should include: questionId, answer
	answerQuestion: (options) ->
		options = options or {}

		# the validations are performed in createAnswer so this must happen first
		Meteor.call "createAnswer", options

		updateData =
			$inc: { answerCount: 1 }
		updateData.$inc["answersTally.#{options.answer}"] = 1
		Questions.update options.questionId, updateData
	


	# options should include: questionId, vote
	rateQuestion: (options) ->
		options = options or {}
		if options.vote == 'for' then options.incValue = 1 
		if options.vote == 'against' then options.incValue = -1

		# the validations are performed in createVote so this must happen first
		Meteor.call "createVote", options

		Questions.update options.questionId, {
			$inc: { voteTally: options.incValue }
		}
