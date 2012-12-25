Template.questionsListAnswered.events 
	"click .questions-list .view-question": (event, template) ->
		event.preventDefault()
		openQuestionsDialog(event.currentTarget.getAttribute('data-questionId'))
		
Template.questionsListAnswered.questions = ->
	answeredQuestionIds = Meteor.user().answeredQuestionIds or []
	Questions.find({ _id: { $in: answeredQuestionIds } }, { sort: { voteTally: -1, createdAt: -1 } })

Template.questionsListAnswered.answer = (question) ->
	ans = Answers.findOne({ ownerId: Meteor.userId(), questionId: question._id })
	ans.answer if ans

Template.questionsListAnswered.questionCount = ->
	answeredQuestionIds = Meteor.user().answeredQuestionIds or []
	Questions.find({ _id: { $in: answeredQuestionIds } }, { sort: { voteTally: -1, createdAt: -1 } }).count()
