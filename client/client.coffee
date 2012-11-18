# TODO: figure out how to store additional user info in the user profile and then ask for these additional scopes
# Accounts.ui.config
#   requestPermissions:
#     facebook: ["user_about_me", "user_activities", "user_birthday", "user_checkins", "user_education_history", "user_interests", "user_likes", "friends_likes", "user_work_history", "email"]


Template.newQuestion.events 
	"click .save": (event, template) ->
		question = template.find("input.question").value
		answerChoices = _.without(_.map(template.findAll("input.answer-choice"), (el) -> el.value), '')
		Meteor.call "createQuestion", {
			question: question
			answerChoices: answerChoices
		}, (error, question) ->
			if error
				Session.set("createQuestionError", error.reason)
			else
				Session.set("createQuestionError", null)

Template.newQuestion.error = ->
	Session.get "createQuestionError"


Template.listQuestions.questions = ->
	Questions.find()

Template.listQuestions.questionCount = ->
	Questions.find().count()