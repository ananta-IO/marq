Template.questionsListMine.events 
	"click .questions-list .remove": (event, template) ->
		event.preventDefault()
		questionId = event.currentTarget.getAttribute('data-questionId')
		Questions.remove(questionId)
		analytics.track 'question delete',
			questionId: questionId

	"click .questions-list .view-question": (event, template) ->
		event.preventDefault()
		questionId = event.currentTarget.getAttribute('data-questionId')
		openQuestionsDialog(questionId)
		analytics.track 'question view asked',
			questionId: questionId


Template.questionsListMine.questions = ->
	Questions.find({ ownerId: Meteor.userId() }, { sort: { voteTally: -1, createdAt: -1 } })

Template.questionsListMine.questionCount = ->
	Questions.find({ ownerId: Meteor.userId() }, { sort: { voteTally: -1, createdAt: -1 } }).count()

Template.questionsListMine.canRemove = ->
	canRemoveQuestion(Meteor.userId(), @)