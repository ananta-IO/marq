# ** questionsAnswer **

Template.questionsAnswer.events
	# skip/next question
	"click .next-question": (event, template) ->
		event.preventDefault()
		AnswerableQuestions.goForward({skip: true})

	# previous question
	"click .previous-question": (event, template) ->
		event.preventDefault()
		AnswerableQuestions.goBack()

# Current/Primary Question
Template.questionsAnswer.question = ->
	AnswerableQuestions.currentQuestion()

# Previous Question
Template.questionsAnswer.previousQuestion = ->
	AnswerableQuestions.previousQuestion()

# Next Question
Template.questionsAnswer.nextQuestion = ->
	AnswerableQuestions.nextQuestion()

# Render
Template.questionsAnswer.rendered = ->
	Mousetrap.bind 'right', () ->
		AnswerableQuestions.goForward({skip: true})
	Mousetrap.bind 'left', () ->
		AnswerableQuestions.goBack()

	$('.flip').css 'height', $('.main-answer-view').outerHeight()
	# $('.flip p').css 'margin-top', $('.main-answer-view').outerHeight()/2

# Helper class to manage the flipbook of answerable questions indexed in the session and presented to the current user
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


# ** question **

Template.question.events
	# answer
	"click button.answer": (event, template) ->
		event.preventDefault()
		Session.set("questionAlert", null)
		# TODO: fetch id from template
		questionId = AnswerableQuestions.currentId()
		answer = event.currentTarget.getAttribute('data-answer')
		
		Meteor.call "answerQuestion", {
			questionId: questionId
			answer: answer
		}, (error, question) ->
			if error
				Session.set("questionAlert", {type: 'error', message: error.reason})
			else
				# Session.set("questionsAnswerAlert", {type: 'success', message: 'Thanks for your response. Please rate this question.', dismiss: true})

	# vote
	"click button.vote": (event, template) ->
		event.preventDefault()
		Session.set("questionAlert", null)
		# TODO: fetch id from template
		questionId = AnswerableQuestions.currentId()
		vote = event.currentTarget.getAttribute('data-vote')
		
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

Template.question.alert = ->
	Session.get "questionAlert"

Template.question.currentUserHasAnswered = (questionId) ->
	currentUserHasAnswered(questionId)

Template.question.voted = (questionId) ->
	Votes.findOne({ownerId: Meteor.userId(), questionId: questionId})?

Template.question.vote = (questionId) ->
	vote = Votes.findOne({ownerId: Meteor.userId(), questionId: questionId})
	if vote
		if vote.vote == 1
			'yes'
		else
			'no'
	else
		'you have not rated this yet'

# TODO: make this take the quesitonId insead of assuming currentId()
Template.question.isUsersAnswer = (answer) ->
	ans = Answers.findOne({ ownerId: Meteor.userId(), questionId: AnswerableQuestions.currentId() })
	ans? and ans.answer == answer

# TODO: make this take the quesitonId insead of assuming currentId()
Template.question.rendered = ->
	# if AnswerableQuestions.userHasAnsweredCurrent()
	dataSet = []
	_.map AnswerableQuestions.currentQuestion().answersTally, (value, key) ->
		dataSet.push {legendLabel: key, magnitude: value, link: "#"}
	drawPie("questionsAnswerPie", dataSet, "#question-#{AnswerableQuestions.currentId()} .chart", "colorScale20", 10, 100, 30, 0)

