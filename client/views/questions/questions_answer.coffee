# ** questionsAnswer **

Template.questionsAnswer.events
	# skip/next question
	"click .next-question": (event, template) ->
		event.preventDefault()
		Session.set("questionAlert", null)
		QuestionList.goForward({skip: true})

	# skip/next unanswered question
	"click .next-unanswered-question": (event, template) ->
		event.preventDefault()
		Session.set("questionAlert", null)
		QuestionList.goToNextUnanswered()

	# previous question
	"click .previous-question": (event, template) ->
		event.preventDefault()
		Session.set("questionAlert", null)
		QuestionList.goBack()

	# previous unanswered question
	"click .previous-unanswered-question": (event, template) ->
		event.preventDefault()
		Session.set("questionAlert", null)
		QuestionList.goToPreviousUnanswered()

# Current/Primary Question
Template.questionsAnswer.question = ->
	QuestionList.currentQuestion()

# Previous Question
Template.questionsAnswer.previousQuestion = ->
	QuestionList.previousQuestion()

# Next Question
Template.questionsAnswer.nextQuestion = ->
	QuestionList.nextQuestion()

# Render
Template.questionsAnswer.rendered = ->
	QuestionList.namespace = "questionsAnswer"

	Mousetrap.bind 'right', () ->
		Session.set("questionAlert", null)
		QuestionList.goForward({skip: true})
	Mousetrap.bind 'left', () ->
		Session.set("questionAlert", null)
		QuestionList.goBack()
	Mousetrap.bind 'shift+right', () ->
		Session.set("questionAlert", null)
		QuestionList.goToNextUnanswered()
	Mousetrap.bind 'shift+left', () ->
		Session.set("questionAlert", null)
		QuestionList.goToPreviousUnanswered()

	$('.flip').css 'height', $('.main-answer-view').outerHeight()
	wait 2000, =>
		$('.flip').css 'height', $('.main-answer-view').outerHeight()

	QuestionList.addQuestionsIfLow()

# Created
Template.questionsAnswer.created = ->
	Meteor.startup ->
		Meteor.autorun ->
			QuestionList.namespace = "questionsAnswer"
			QuestionList.initialize()

# Helper class to manage the flipbook of answerable questions indexed in the session and presented to the current user
class QuestionList

	@namespace: 'default'

	@initialize: (questionId = null) ->
		if questionId
			@questionIds([questionId])
			@questionIndex(0)
		else if _.isEmpty(@questionIds())
			ids = answeredQuestionIds() or []
			index = ids.length
			@questionIds(ids)
			@findAndAppendMoreQuestions()
			if index > 0 then @questionIndex(index - 1) else @questionIndex(0)
			if @nextId()? then @questionIndex(index)

	@findAndAppendMoreQuestions: ->
		@questionIds(_.union(@questionIds(), unansweredQuestionIds(3)))

	@addQuestionsIfLow: ->
		if !@nextId(2)? then @findAndAppendMoreQuestions()

	@questionIds: (ids = false) ->
		unless ids == false then Session.set("#{@namespace}-questionIds", ids)
		Session.get("#{@namespace}-questionIds") or []

	@questionIndex: (index = false) ->
		unless index == false then Session.set("#{@namespace}-questionIndex", index)
		Session.get("#{@namespace}-questionIndex") or 0

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
		@addQuestionsIfLow()
		if @nextId(1)? then @questionIndex(@questionIndex() + 1)
		@currentId()

	@goBack: ->
		index = @questionIndex()
		if index > 0 then @questionIndex(index - 1)
		@currentId()

	@goToNextUnanswered: ->
		@goForward({skip: true}) if @nextId(1)? 
		@goForward({skip: true}) while currentUserHasAnswered(@currentId()) and @nextId(1)? 

	@goToPreviousUnanswered: ->
		@goBack() if @previousId(1)?
		@goBack() while currentUserHasAnswered(@currentId()) and @previousId(1)?        


# ** question **

Template.question.events
	# answer
	"click button.answer": (event, template) ->
		event.preventDefault()
		Session.set("questionAlert", null)
		# TODO: fetch id from template
		questionId = QuestionList.currentId()
		answer = event.currentTarget.getAttribute('data-answer')
		
		Meteor.call "answerQuestion", {
			questionId: questionId
			answer: answer
		}, (error, question) ->
			if error
				Session.set("questionAlert", {type: 'error', message: error.reason})
			else
				# Session.set("questionAlert", {type: 'success', message: 'Thanks for your response. Please rate this question.', dismiss: true})

	# vote
	"click button.vote": (event, template) ->
		event.preventDefault()
		Session.set("questionAlert", null)
		# TODO: fetch id from template
		questionId = QuestionList.currentId()
		vote = event.currentTarget.getAttribute('data-vote')
		
		Meteor.call "rateQuestion", {
			questionId: questionId
			vote: vote
		}, (error, question) ->
			if error
				# Session.set("questionAlert", {type: 'error', message: error.reason})
				QuestionList.goToNextUnanswered()
			else
				# Session.set("questionAlert", {type: 'success', message: 'Thanks for your feedback. Please respond to another question.', dismiss: true})
				QuestionList.goToNextUnanswered()

	# comment
	"keyup input.new-comment": (event, template) ->
		if (event.which == 13)
			event.preventDefault()
			Session.set("questionAlert", null)
			# TODO: fetch id from template, put it in a hidden form field
			questionId = QuestionList.currentId()
			comment = template.find("input.new-comment").value
			Meteor.call "commentOnQuestion", {
				questionId: questionId
				comment: comment
			}, (error, question) ->
				if error
					Session.set("questionAlert", {type: 'error', message: error.reason})
				else
					Session.set("questionAlert", null)
					template.find("input.new-comment").value = null

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
			'it is'
		else
			'it is not'
	else
		'you have not rated this yet'

# TODO: make this take the quesitonId insead of assuming currentId()
Template.question.isUsersAnswer = (answer) ->
	ans = Answers.findOne({ ownerId: Meteor.userId(), questionId: QuestionList.currentId() })
	ans? and ans.answer == answer

# TODO: make this take the quesitonId insead of assuming currentId()
Template.question.anyComments = ->
	Comments.find(
		{ questionId: QuestionList.currentId() }
		{ sort: { createdAt: 1 } }
	).count() > 0

# TODO: make this take the quesitonId insead of assuming currentId()
Template.question.comments = ->
	Comments.find(
		{ questionId: QuestionList.currentId() }
		{ sort: { createdAt: 1 } }
	)

Template.question.isCurrentUsersComment = (ownerId) ->
	ownerId == Meteor.userId()

# TODO: make this take the quesitonId insead of assuming currentQuestion()
Template.question.rendered = ->
	# Track view
	options = { questionId: QuestionList.currentId() }
	Meteor.call 'viewQuestion', options

	if currentUserHasAnswered(QuestionList.currentId())
		# Append D3 graph
		dataSet = []
		_.map QuestionList.currentQuestion().answersTally, (value, key) ->
			dataSet.push {legendLabel: key, magnitude: value, link: "#"}
		drawPie("questionsAnswerPie", dataSet, "#question-#{QuestionList.currentId()} .chart", "colorScale20", 10, 100, 30, 0)

		# Treat comments like a chat
		div = @find(".past-comments")
		div.scrollTop = div.scrollHeight

