# TODO: figure out how to store additional user info in the user profile and then ask for these additional scopes
# Accounts.ui.config
#   requestPermissions:
#     facebook: ["user_about_me", "user_activities", "user_birthday", "user_checkins", "user_education_history", "user_interests", "user_likes", "friends_likes", "user_work_history", "email"]

Meteor.subscribe('questions')


Template.answerQuestion.question = ->
	Questions.findOne( { $or : [ { answers: { $size: 0 } } , {"answers.user" : { $ne : @userId } }] }, { sort: { voteTally: -1, createdAt: -1 } } )


Template.newQuestion.events 
	"click button.save": (event, template) ->
		event.preventDefault()
		question = Session.get 'question'
		answerChoices = Session.get 'answerChoices'
		Meteor.call "createQuestion", {
			question: question
			answerChoices: answerChoices
		}, (error, question) ->
			if error
				Session.set("newQuestionAlert", {type: 'error', message: error.reason})
			else
				Session.set("newQuestionAlert", {type: 'success', message: 'Success.', dismiss: true})
				Session.set("question", '')
				Session.set("answerChoices", null)
	
	"click .answer-choice-wrap .remove": (event, template) ->
		event.preventDefault()
		Session.set 'answerChoices', _.without(Session.get('answerChoices'), event.currentTarget.getAttribute('data-value'))

	"blur textarea.question": (event, template) ->
		Session.set 'question', $.trim(event.currentTarget.value)

	"blur input.answer-choice": (event, template) ->
		Session.set 'answerChoices', _.without(_.uniq(_.map(template.findAll("input.answer-choice"), (el) -> $.trim(el.value))), '')


Template.newQuestion.alert = ->
	Session.get "newQuestionAlert"

Template.newQuestion.question = ->
	Session.get "question"

Template.newQuestion.objectifiedAnswerChoices = ->
	answerChoices = Session.get 'answerChoices'
	if answerChoices and answerChoices.length > 0
		objectifiedAnswerChoices = objectifyAnswerChoices(answerChoices)
		objectifiedAnswerChoices.push({order: answerChoices.length+1, placeholder: 'add another answer choice', value: ''}, {order: answerChoices.length+2, placeholder: 'add another answer choice', value: ''})
	else
		objectifiedAnswerChoices = [{order: 1, placeholder: 'yes', value: ''}, {order: 2, placeholder: 'no', value: ''}, {order: 3, placeholder: "don't care", value: ''}]
	objectifiedAnswerChoices


Template.listQuestions.events 
	"click .questions-list .remove": (event, template) ->
		event.preventDefault()
		Questions.remove(event.currentTarget.getAttribute('data-questionId'))


Template.listQuestions.questions = ->
	Questions.find({}, {sort: {createdAt: -1}})

Template.listQuestions.questionCount = ->
	Questions.find().count()