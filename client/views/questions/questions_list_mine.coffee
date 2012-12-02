Template.questionsListMine.events 
	"click .questions-list .remove": (event, template) ->
		event.preventDefault()
		Questions.remove(event.currentTarget.getAttribute('data-questionId'))

	"click .questions-list .view-question": (event, template) ->
		event.preventDefault()
		openQuestionsDialog(event.currentTarget.getAttribute('data-questionId'))


Template.questionsListMine.questions = ->
	Questions.find({ owner: @userId }, { sort: { voteTally: -1, createdAt: -1 } })

Template.questionsListMine.questionCount = ->
	Questions.find({ owner: @userId }, { sort: { voteTally: -1, createdAt: -1 } }).count()

Template.questionsListMine.canRemove = ->
	@owner == Meteor.userId() and @.answerCount == 0