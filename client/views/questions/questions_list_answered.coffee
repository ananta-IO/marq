Template.questionsListAnswered.events 
	"click .questions-list .view-question": (event, template) ->
		event.preventDefault()
		openQuestionsDialog(event.currentTarget.getAttribute('data-questionId'))
		
Template.questionsListAnswered.questions = ->
	ids = answeredQuestionIds()
	Questions.find(
		{ _id: { $in : ids } }
		{ sort: { score: 1 } }
	)

Template.questionsListAnswered.answer = (questionId) ->
	ans = Answers.findOne({ ownerId: Meteor.userId(), questionId: questionId })
	ans.answer if ans

Template.questionsListAnswered.questionCount = ->
	answeredQuestionIds().length
