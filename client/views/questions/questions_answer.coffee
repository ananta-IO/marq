Template.questionsAnswer.events
	# skip/next question
	"click a.next-question": (event, template) ->
		event.preventDefault()
		AnswerableQuestions.goForward({skip: true})

	# previous question
	"click a.previous-question": (event, template) ->
		event.preventDefault()
		AnswerableQuestions.goBack()

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
				# Session.set("questionsAnswerAlert", {type: 'success', message: 'Thanks for your response. Please rate this question.', dismiss: true})

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
				# Session.set("questionsAnswerAlert", {type: 'error', message: error.reason})
				AnswerableQuestions.goToNextUnanswered()
			else
				# Session.set("questionsAnswerAlert", {type: 'success', message: 'Thanks for your feedback. Please respond to another question.', dismiss: true})
				AnswerableQuestions.goToNextUnanswered()


Template.questionsAnswer.question = ->
	AnswerableQuestions.currentQuestion()

Template.questionsAnswer.alert = ->
	Session.get "questionsAnswerAlert"

Template.questionsAnswer.answered = ->
	AnswerableQuestions.userHasAnsweredCurrent()

Template.questionsAnswer.isUsersAnswer = (answer) ->
	ans = Answers.findOne({ ownerId: Meteor.userId(), questionId: AnswerableQuestions.currentId() })
	ans? and ans.answer == answer

Template.questionsAnswer.rendered = ->
	Mousetrap.bind 'right', () ->
		AnswerableQuestions.goForward({skip: true})
	Mousetrap.bind 'left', () ->
		AnswerableQuestions.goBack()

	AnswerableQuestions.initialize()
	if AnswerableQuestions.userHasAnsweredCurrent()
		dataSet = []
		_.map question.answersTally, (value, key) ->
			dataSet.push {legendLabel: key, magnitude: value, link: "#"}
		drawPie("questionsAnswerPie", dataSet, "#answer-question .chart", "colorScale20", 10, 100, 30, 0)


class AnswerableQuestions
	@initialize: ->
		if _.isEmpty(@questionIds())
			@questionIds(_.pluck(unansweredQuestions(3), '_id'))
			@questionIndex(0)

	@questionIds: (ids = false) ->
		unless ids == false then Session.set("answerableQuestionIds", ids)
		Session.get("answerableQuestionIds") or []

	@questionIndex: (index = false) ->
		unless index == false then Session.set("answerableQuestionIndex", index)
		Session.get("answerableQuestionIndex") or 0

	@currentId: ->
		@questionIds()[@questionIndex()]
	@currentQuestion: ->
		Questions.findOne(@currentId())
	@userHasAnsweredCurrent: ->
		_.contains(Meteor.user().answeredQuestionIds, @currentId())

	@nextId: (inc = 1) ->
	   @questionIds()[@questionIndex() + inc] 
	@nextQuestion: (inc = 1) ->
		Questions.findOne(@nextId(inc))

	@previousId: (inc = 1) ->
	   @questionIds()[@questionIndex() - inc]
	@previousQuestion: (inc = 1) ->
		Questions.findOne(@previousId(inc))

	@goForward: (options) ->
		options or= {}
		if options.skip == true then Meteor.call "skipQuestion", { questionId: @currentId() }
		if @nextId(2)? then @questionIds(_.union(@questionIds(), _.pluck(unansweredQuestions(3), '_id')))
		if @nextId(1)? then @questionIndex(@questionIndex() + 1)
		@currentId()  
	@goToNextUnanswered: ->
		@goForward() while @userHasAnsweredCurrent() and @nextId(1)?        

	@goBack: ->
		index = @questionIndex() - 1
		if index >= 0 then @questionIndex(index)
		@currentId()
