# TODO: figure out how to store additional user info in the user profile and then ask for these additional scopes
# Accounts.ui.config
#   requestPermissions:
#     facebook: ["user_about_me", "user_activities", "user_birthday", "user_checkins", "user_education_history", "user_interests", "user_likes", "friends_likes", "user_work_history", "email"]


Template.newQuestion.events 
	"click .save": (event, template) ->
		question = Session.get 'question'
		answerChoices = Session.get 'answerChoices'
		Meteor.call "createQuestion", {
			question: question
			answerChoices: answerChoices
		}, (error, question) ->
			if error
				Session.set("createQuestionError", error.reason)
			else
				Session.set("createQuestionError", null)
				Session.set("question", null)
				Session.set("answerChoices", null)
	
	"click .answer-choice-wrap .remove": (event, template) ->
		Session.set 'answerChoices', _.without(Session.get('answerChoices'), event.currentTarget.getAttribute('data-value'))

	"blur input.question": (event, template) ->
		Session.set 'question', template.find("input.question").value

	"blur input.answer-choice": (event, template) ->
		Session.set 'answerChoices', _.without(_.uniq(_.map(template.findAll("input.answer-choice"), (el) -> el.value)), '')


Template.newQuestion.error = ->
	Session.get "createQuestionError"

Template.newQuestion.question = ->
	Session.get "question"

Template.newQuestion.objectifiedAnswerChoices = ->
	answerChoices = Session.get 'answerChoices'
	if answerChoices and answerChoices.length > 0
		objectifiedAnswerChoices = objectifyAnswerChoices(answerChoices)
		objectifiedAnswerChoices.push({order: answerChoices.length+1, placeholder: 'possible answer', value: ''}, {order: answerChoices.length+2, placeholder: 'another possible answer', value: ''})
		# Session.set("objectifiedAnswerChoices", objectifiedAnswerChoices)

		# answerChoices = template.findAll("input.answer-choice")
		# answerChoices[answerChoices.length - 2].focus
	else
		objectifiedAnswerChoices = [{order: 1, placeholder: 'yes', value: ''}, {order: 2, placeholder: 'no', value: ''}, {order: 3, placeholder: "don't care", value: ''}]
		# Session.set("objectifiedAnswerChoices", objectifiedAnswerChoices)
	
	objectifiedAnswerChoices


Template.listQuestions.questions = ->
	Questions.find()

Template.listQuestions.questionCount = ->
	Questions.find().count()