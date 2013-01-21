Template.questionsShow.helpers
	question: ->
		Questions.findOne(Session.get('selectedQuestionId'))

# Created
Template.questionsShow.created = ->
	Meteor.startup ->
		Meteor.autorun ->
			QuestionList.namespace = "questionsShow"
			QuestionList.initialize({questionId: Session.get('selectedQuestionId')})