Template.questionsListAnswered.events 
	"click .questions-list .view-question": (event, template) ->
		event.preventDefault()
		openQuestionDialog(event.currentTarget.getAttribute('data-questionId'))
		
Template.questionsListAnswered.questions = ->
	Questions.find({ answeredBy: @userId }, { sort: { voteTally: -1, createdAt: -1 } })

Template.questionsListAnswered.answer = (question) ->
	ans = _.find question.answers, (ans) -> ans.user == @userId
	ans.answer

Template.questionsListAnswered.questionCount = ->
	Questions.find({ answeredBy: @userId }, { sort: { voteTally: -1, createdAt: -1 } }).count()
