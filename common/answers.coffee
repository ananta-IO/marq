## Answers
# Each answer is represented by a document in the Answers collection:
#	ownerId: String user id
#	questionId: String question id
#	answer: String
#   createdAt: Date
Answers = new Meteor.Collection("answers")

Answers.allow
	insert: (userId, answer) ->
		false # no cowboy inserts -- use createAnswer method
	
	update: (userId, answers, fields, modifier) ->
		false

	remove: (userId, answers) ->
		false

Meteor.methods
	# DO NOT call this directly. Should be called by answerQuestion
	# options should include: answer, questionId
	createAnswer: (options) ->
		options = options or {}
		
		throw new Meteor.Error(403, "Log in to answer this question")  unless @userId
		question = Questions.findOne(options.questionId)
		throw new Meteor.Error(404, "No such question")  unless question
		throw new Meteor.Error(400, "You have already answered this question")  if _.contains(Meteor.user().answeredQuestionIds, options.questionId)
		throw new Meteor.Error(400, "Answer can't be blank")  unless typeof options.answer is "string" and options.answer.length
		throw new Meteor.Error(400, "Invalid answer")  unless _.contains(question.answerChoices, options.answer)

		Answers.insert
			ownerId: @userId
			questionId: options.questionId
			answer: options.answer
			createdAt: new Date

		Meteor.users.update @userId, {
			$push: { answeredQuestionIds: options.questionId }
		}

