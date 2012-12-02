Template.questionsAnswer.events 
	# answer
	"click button.answer": (event, template) ->
		event.preventDefault()
		Session.set("questionsAnswerAlert", null)
		questionId = $("#answer-question").attr('data-question')
		answer = event.currentTarget.getAttribute('data-answer')
		#
		Meteor.call "answerQuestion", {
			questionId: questionId
			answer: answer
		}, (error, question) ->
			if error
				Session.set("questionsAnswerAlert", {type: 'error', message: error.reason})
			else
				Session.set("questionsAnswerAlert", null)
				# Session.set("questionsAnswerAlert", {type: 'success', message: 'Thanks for your response. Please rate this question.', dismiss: true})
				Session.set("previousQuestionId", questionId)

	# vote
	"click button.vote": (event, template) ->
		event.preventDefault()
		Session.set("questionsAnswerAlert", null)
		questionId = $("#rate-question").attr('data-question')
		vote = event.currentTarget.getAttribute('data-vote')
		#
		Meteor.call "rateQuestion", {
			questionId: questionId
			vote: vote
		}, (error, question) ->
			if error
				Session.set("questionsAnswerAlert", {type: 'error', message: error.reason})
			else
				Session.set("questionsAnswerAlert", null)
				# Session.set("questionsAnswerAlert", {type: 'success', message: 'Thanks for your feedback. Please respond to another question.', dismiss: true})
				Session.set("previousQuestionId", null)


Template.questionsAnswer.question = ->
	# Questions.findOne( { $or : [ { answers: { $size: 0 } } , {"answers.user" : { $ne : @userId } }] }, { sort: { voteTally: -1, createdAt: -1 } } )
	Questions.findOne( { $or : [ { answers: { $size: 0 } } , { answeredBy : { $ne : @userId } }] }, { sort: { voteTally: -1, createdAt: -1 } } )

Template.questionsAnswer.alert = ->
	Session.get "questionsAnswerAlert"

Template.questionsAnswer.previousQuestion = ->
	Questions.findOne(Session.get("previousQuestionId"))

Template.questionsAnswer.rendered = ->
	question = Questions.findOne(Session.get("previousQuestionId"))
	answersTally = tallyAnswers(question)
	dataSet = []
	_.map answersTally, (value, key) ->
		dataSet.push {legendLabel: key, magnitude: value, link: "#"}
	drawPie("questionsAnswerPie", dataSet, "#answer-question .chart", "colorScale20", 10, 100, 30, 0)
