# ** questionsAnswer **

Template.questionsAnswer.events
	# skip/next question
	"click .next-question": (event, template) ->
		event.preventDefault()
		Session.set("questionAlert", null)
		QuestionList.goForward({skip: true})
		scrollToTop()
		analytics.track 'question next click',
			questionId: QuestionList.currentId()

	# skip/next unanswered question
	"click .next-unanswered-question": (event, template) ->
		event.preventDefault()
		Session.set("questionAlert", null)
		QuestionList.goToNextUnanswered()
		scrollToTop()
		analytics.track 'question next unanswered click',
			questionId: QuestionList.currentId()

	# previous question
	"click .previous-question": (event, template) ->
		event.preventDefault()
		Session.set("questionAlert", null)
		QuestionList.goBack()
		scrollToTop()
		analytics.track 'question previous click',
			questionId: QuestionList.currentId()

	# previous unanswered question
	"click .previous-unanswered-question": (event, template) ->
		event.preventDefault()
		Session.set("questionAlert", null)
		QuestionList.goToPreviousUnanswered()
		scrollToTop()
		analytics.track 'question previous unanswered click',
			questionId: QuestionList.currentId()

Template.questionsAnswer.helpers
	# Current/Primary Question
	question: ->
		QuestionList.currentQuestion()

	voted: (questionId) ->
		Votes.findOne({ownerId: Meteor.userId(), questionId: questionId})?

	# Previous Question
	previousQuestion: ->
		QuestionList.previousQuestion()

	# Next Question
	nextQuestion: ->
		QuestionList.nextQuestion()

# Render
Template.questionsAnswer.rendered = ->
	QuestionList.namespace = "questionsAnswer"

	Mousetrap.bind 'right', () ->
		Session.set("questionAlert", null)
		QuestionList.goForward({skip: true})
		scrollToTop()
		analytics.track 'question next keyboard',
			questionId: QuestionList.currentId()
	Mousetrap.bind 'left', () ->
		Session.set("questionAlert", null)
		QuestionList.goBack()
		scrollToTop()
		analytics.track 'question previous keyboard',
			questionId: QuestionList.currentId()
	Mousetrap.bind 'shift+right', () ->
		Session.set("questionAlert", null)
		QuestionList.goToNextUnanswered()
		scrollToTop()
		analytics.track 'question next unanswered keyboard',
			questionId: QuestionList.currentId()
	Mousetrap.bind 'shift+left', () ->
		Session.set("questionAlert", null)
		QuestionList.goToPreviousUnanswered()
		scrollToTop()
		analytics.track 'question previous unanswered keyboard',
			questionId: QuestionList.currentId()

	wait 2000, =>
		$('.flip').css 'height', $('.main-answer-view').outerHeight()

	QuestionList.addQuestionsIfLow()

# Created
Template.questionsAnswer.created = ->
	Meteor.startup ->
		Meteor.autorun ->
			QuestionList.namespace = "questionsAnswer"
			QuestionList.initialize()

# Helper class to manage the currently active questions in the session
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
				analytics.track 'question answered error',
					questionId: questionId
					answer: answer
					error: error
			else
				# Session.set("questionAlert", {type: 'success', message: 'Thanks for your response. Please rate this question.', dismiss: true})
				$.scrollTo('.answer-choices', 400)
				analytics.track 'question answered success',
					questionId: questionId
					answer: answer

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
				Session.set("questionAlert", {type: 'error', message: error.reason})
				# QuestionList.goToNextUnanswered()
				analytics.track 'question rated error',
					questionId: questionId
					vote: vote
					error: error
			else
				# Session.set("questionAlert", {type: 'success', message: 'Thanks for your feedback. Please respond to another question.', dismiss: true})
				# QuestionList.goToNextUnanswered()
				$.scrollTo('.comments', 400)
				analytics.track 'question rated success',
					questionId: questionId
					vote: vote

	# comment
	"keypress textarea.new-comment": (event, template) ->
		if (event.which == 13 and !event.shiftKey)
			event.preventDefault()
			Session.set("questionAlert", null)
			# TODO: fetch id from template, put it in a hidden form field
			questionId = QuestionList.currentId()
			comment = template.find("textarea.new-comment").value
			Meteor.call "commentOnQuestion", {
				questionId: questionId
				comment: comment
			}, (error, question) ->
				if error
					Session.set("questionAlert", {type: 'error', message: error.reason})
					analytics.track 'question commented error',
						questionId: questionId
						comment: comment
						error: error
				else
					Session.set("questionAlert", null)
					template.find("textarea.new-comment").value = null
					analytics.track 'question commented success',
						questionId: questionId
						comment: comment

Template.question.helpers
	alert: ->
		Session.get "questionAlert"

	currentUserHasAnswered: (questionId) ->
		currentUserHasAnswered(questionId)

	showMeta: (questionId) ->
		not Meteor.userId() or currentUserHasAnswered(questionId)

	voted: (questionId) ->
		Votes.findOne({ownerId: Meteor.userId(), questionId: questionId})?

	vote: (questionId) ->
		vote = Votes.findOne({ownerId: Meteor.userId(), questionId: questionId})
		if vote
			if vote.vote == 1
				'it is'
			else
				'it is not'
		else
			'you have not rated this yet'

	# TODO: make this take the quesitonId insead of assuming currentId()
	isUsersAnswer: (answer) ->
		ans = Answers.findOne({ ownerId: Meteor.userId(), questionId: QuestionList.currentId() })
		ans? and ans.answer == answer

	# TODO: make this take the quesitonId insead of assuming currentId()
	anyComments: ->
		Comments.find(
			{ questionId: QuestionList.currentId() }
			{ sort: { createdAt: 1 } }
		).count() > 0

	# TODO: make this take the quesitonId insead of assuming currentId()
	comments: ->
		Comments.find(
			{ questionId: QuestionList.currentId() }
			{ sort: { createdAt: 1 } }
		)

	isCurrentUsersComment: (ownerId) ->
		ownerId == Meteor.userId()

Template.question.created = ->
	question = QuestionList.currentQuestion()
	if question
		analytics.track 'question viewed',
			questionId: question._id
			question: question.question
			answerChoices: question.answerChoices

# TODO: make this take the quesitonId insead of assuming currentQuestion()
Template.question.rendered = ->
	# Track view
	options = { questionId: QuestionList.currentId() }
	Meteor.call 'viewQuestion', options

	# TODO: make sure the template is loaded
	wait 1500, () =>
		$(window).resize =>
			$iframe = $('#embed-html iframe')
			width = $('#embed-html').innerWidth()
			resizeIframe($iframe, width)
		$(window).resize()
		$("textarea.new-comment").autosize()

	if not Meteor.userId() or currentUserHasAnswered(QuestionList.currentId())
		# Append D3 graph
		dataSet = []
		_.map QuestionList.currentQuestion().answersTally, (value, key) ->
			dataSet.push {legendLabel: key, magnitude: value, link: "#"}
		drawPie("questionsAnswerPie", dataSet, "#question-#{QuestionList.currentId()} .chart", "colorScale20", 10, 100, 30, 0)

		# Treat comments like a chat
		$pastComments = $(".past-comments")
		$pastComments.scrollTo($pastComments.find(".comment").last())

