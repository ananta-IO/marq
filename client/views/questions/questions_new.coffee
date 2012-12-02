Template.questionsNew.events 
	"click button.save": (event, template) ->
		event.preventDefault()
		Session.set("questionsNewAlert", null)
		question = $.trim(template.find("textarea.question").value)# Session.get 'question'
		answerChoices = Session.get 'answerChoices'
		Meteor.call "createQuestion", {
			question: question
			answerChoices: answerChoices
		}, (error, question) ->
			if error
				Session.set("questionsNewAlert", {type: 'error', message: error.reason})
			else
				Session.set("questionsNewAlert", {type: 'success', message: 'Question successfully asked. We will automatically show your question to randomly selected people. You can improve your results by inviting your friends.', dismiss: true})
				Session.set("question", '')
				Session.set("answerChoices", null)
	
	"click .answer-choice-wrap .remove": (event, template) ->
		event.preventDefault()
		Session.set 'answerChoices', _.without(Session.get('answerChoices'), event.currentTarget.getAttribute('data-value'))

	"keypress textarea.question, keypress input.answer-choice": (event, template) ->
		if (event.which == 13) then $(event.target).focusNextInputField()

	"blur textarea.question": (event, template) ->
		Session.set 'question', $.trim(event.currentTarget.value)

	"blur input.answer-choice": (event, template) ->
		Session.set 'answerChoices', _.without(_.uniq(_.map(template.findAll("input.answer-choice"), (el) -> $.trim(el.value))), '')


Template.questionsNew.alert = ->
	Session.get "questionsNewAlert"

Template.questionsNew.question = ->
	Session.get "question"

Template.questionsNew.objectifiedAnswerChoices = ->
	answerChoices = Session.get 'answerChoices'
	if answerChoices and answerChoices.length > 0
		objectifiedAnswerChoices = objectifyAnswerChoices(answerChoices)
		objectifiedAnswerChoices.push({order: answerChoices.length+1, placeholder: 'add another response', value: ''}, {order: answerChoices.length+2, placeholder: 'press enter to add another', value: ''})
	else
		objectifiedAnswerChoices = [{order: 1, placeholder: 'yes', value: ''}, {order: 2, placeholder: 'no', value: ''}, {order: 3, placeholder: "don't care", value: ''}]
	objectifiedAnswerChoices