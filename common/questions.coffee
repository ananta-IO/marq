## Questions
# Each question is represented by a document in the Questions collection:
#   ownerId: String user id
#   question: String
#   embedId: String embed id
#   embedHtml: String of embed iframe html
#   imageUri: String
#   answerChoices: Array of possible answers like ["yes", "no", "don't care"]
#   answersTally: Object with the breakdown for each answer choice like {ansChoice0: 3, ansChoice1: 89, ansChoice3: 0}
#   answerCount: Integer count of answers
#   skipCount: Integer count of number of users who skipped this
#	viewCount: Integer count of number of users who have viewed this
#   voteTally: Integer count of for votes minus against votes
#   voteCount: Integer count of votes
#   commentCount: Integer count of comments
#   score: Float count of the sytem calculated score of a question, taking age into account
#   baseScore: Float count of the static score (before age is counted)
#   createdAt: new Date
Questions = new Meteor.Collection("questions")


objectifyAnswerChoices = (answerChoices) ->
	_.map(answerChoices, (ac, i) -> {order: i+1, placeholder: ac, value: ac})

unansweredQuestionIds = (limit = 3) ->
	if Meteor.user()
		answeredQuestionIds = Meteor.user().answeredQuestionIds or []
		skippedQuestionIds = Meteor.user().skippedQuestionIds or []
		ids = _.union(answeredQuestionIds, skippedQuestionIds)

		questionIds = _.pluck(Questions.find(
			{ _id: { $nin : ids } }
			{ sort: { score: -1 }, fields: { score: true } }
		).fetch(), '_id')
		unless questionIds.length > 0
			questionIds = _.pluck(Questions.find(
				{ _id: { $nin : answeredQuestionIds } }
				{ sort: { score: -1 }, fields: { score: true } }
			).fetch(), '_id') 
	else
		questionIds = _.pluck(Questions.find(
			{}
			{ sort: { score: -1 }, fields: { score: true } }
		).fetch(), '_id')
	questionIds or= []
	questionIds = questionIds.slice(0, limit) if limit?
	questionIds

answeredQuestionIds = () ->
	if Meteor.user()
		ids = Meteor.user().answeredQuestionIds or []
	else
		[]


Questions.allow
	insert: (userId, question) ->
		false # no cowboy inserts -- use createQuestion method
	
	update: (userId, questions, fields, modifier) ->
		isAdminById(userId)
		# _.all questions, (question) ->
		#   return false  if userId isnt question.owner # not the owner
		#   allowed = ["question", "answerChoices"]
		#   return false  if _.difference(fields, allowed).length # tried to write to forbidden field
			
		#   # A good improvement would be to validate the type of the new
		#   # value of the field (and if a string, the length.) In the
		#   # future Meteor will have a schema system to makes that easier.
		#   true

	remove: (userId, questions) ->
		if isAdminById(userId)
			true
		else
			not _.any(questions, (question) ->
				!canRemoveQuestion(userId, question)
			)


Meteor.methods
	# options should include: question, embedId, imageUri, answerChoices
	createQuestion: (options) ->
		options = options or {}
		options.imageUri or= null
		
		throw new Meteor.Error(403, "Sign in to ask a question")  unless @userId
		throw new Meteor.Error(400, "Question can't be blank")  unless typeof options.question is "string" and options.question.length
		throw new Meteor.Error(413, "Question is too long (140 characters max)")  if options.question and options.question.length > 140
		throw new Meteor.Error(413, "Add at least one more response choice")  if options.answerChoices and options.answerChoices.length > 0 and options.answerChoices.length < 2
		throw new Meteor.Error(413, "Too many answer choice (5 max)")  if options.answerChoices and options.answerChoices.length > 5
		throw new Meteor.Error(413, "At least one answer choice is too long (90 characters max)")  if options.answerChoices and _.contains(_.map(options.answerChoices, (ac) -> ac.length > 90 ), true)
		throw new Meteor.Error(400, "You have already asked this question")  if Questions.findOne({ ownerId: @userId, question: options.question })
		
		embedHtml = if options.embedId and (embed = Embeds.findOne(options.embedId)) then embed.html else null
		answerChoices = if options.answerChoices and options.answerChoices.length > 0 then options.answerChoices else ["yes", "no", "don't care"]
		answersTally = {}
		_.each answerChoices, (ac) ->
			answersTally[ac] = 0

		Questions.insert
			ownerId: @userId
			question: options.question
			embedId: options.embedId
			embedHtml: embedHtml
			imageUri: options.imageUri
			answerChoices: answerChoices
			answersTally: answersTally
			answerCount: 0
			skipCount: 0
			viewCount: 0
			voteTally: 0
			voteCount: 0
			commentCount: 0
			score: 0
			baseScore: 0
			createdAt: new Date

		Meteor.users.update Meteor.userId(), {
			$inc: { askQuestionCount: 1 }
		}


	# options should include: questionId
	viewQuestion: (options) ->
		options = options or {}

		if Meteor.userId()?
			question = Questions.findOne(options.questionId)
			view = Views.findOne({ ownerId: Meteor.userId(), questionId: options.questionId })
			if question? and !view?
				Views.insert 
					ownerId: Meteor.userId()
					questionId: options.questionId
					createdAt: new Date
				Questions.update options.questionId, {
					$inc: { viewCount: 1 }
				}
				Meteor.users.update Meteor.userId(), {
					$inc: { viewQuestionCount: 1 }
				}


	# options should include: questionId
	skipQuestion: (options) ->
		options = options or {}

		throw new Meteor.Error(403, "Sign in to skip this question")  unless Meteor.userId()
		question = Questions.findOne(options.questionId)
		throw new Meteor.Error(404, "No such question")  unless question

		unless options.questionId in Meteor.user().skippedQuestionIds
			Meteor.users.update Meteor.userId(), {
				$push: { skippedQuestionIds: options.questionId }
			}
			Questions.update options.questionId, {
				$inc: { skipCount: 1 }
			}


	# options should include: questionId, answer
	answerQuestion: (options) ->
		options = options or {}

		# The validations are performed in createAnswer so this must happen first
		Meteor.call "createAnswer", options

		updateData =
			$inc: { answerCount: 1 }
		updateData.$inc["answersTally.#{options.answer}"] = 1
		Questions.update options.questionId, updateData
	

	# options should include: questionId, vote
	rateQuestion: (options) ->
		options = options or {}
		if options.vote == 'for' 
			options.incValue = 1
			options.karma = 3
		else if options.vote == 'against'
			options.incValue = -1
			options.karma = -1
		else
			options.incValue = 0
			options.karma = 0

		# The validations are performed in createVote so this must happen first
		Meteor.call "createVote", options

		options.votePower = 1 + (Meteor.user().karma/100)
		options.incBaseScore = options.votePower * options.incValue

		Questions.update options.questionId, {
			$inc: { voteTally: options.incValue, voteCount: 1, baseScore: options.incBaseScore }
		}


	# options should include: questionId, comment
	commentOnQuestion: (options) ->
		options = options or {}

		# The validations are performed in createComment so this must happen first
		Meteor.call "createComment", options

		Questions.update options.questionId, {
			$inc: { commentCount: 1 }
		}
		
