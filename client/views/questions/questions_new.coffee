Template.questionsNew.events 
	"click button.save": (event, template) ->
		event.preventDefault()
		Session.set("questionsNewAlert", null)

		question = $.trim(template.find("textarea.question").value)
		Session.set 'question', question
		embedId = Session.get "new question embed id"
		imageUri = Session.get "new question image uri"
		answerChoices = _.without(_.uniq(_.map(template.findAll("input.answer-choice"), (el) -> $.trim(el.value))), '')
		Session.set 'answerChoices', answerChoices
		Meteor.call "createQuestion", {
			question: question
			embedId: embedId
			imageUri: imageUri
			answerChoices: answerChoices
		}, (error, object) ->
			if error
				Session.set("questionsNewAlert", {type: 'error', message: error.reason})
				analytics.track 'question asked error',
					question: question
					embedId: embedId
					imageUri: imageUri
					answerChoices: JSON.stringify(answerChoices)
					error: error
				Accounts._loginButtonsSession.set('dropdownVisible', true) unless Meteor.user()
			else
				Session.set("questionsNewAlert", {type: 'success', message: 'Question successfully asked. We will automatically show your question to randomly selected people. You can improve your results by sharing this with your friends.', dismiss: true})
				Session.set("question", '')
				Session.set("answerChoices", null)
				Session.set "new question embed id", null
				Session.set "new question embed uri", null
				Session.set "new question image uri", null
				Session.set "questionRemainingChars", (140 - $(event.target).val().length)
				Session.set "resetFpWidget", (new Date())
				analytics.track 'question asked success',
					question: question
					embedId: embedId
					imageUri: imageUri
					answerChoices: JSON.stringify(answerChoices)
	
	"keyup #new-question-embed-uri": (event, template) ->
		if (event.which == 13) then $('input.answer-choice').first().focus()

	"paste #new-question-embed-uri, keyup #new-question-embed-uri, blur #new-question-embed-uri": (event, template) ->
		if Meteor.user()
			uri = $.trim(event.currentTarget.value)
			if uri.length > 0 and uri != Session.get "new question embed uri"
				embed = Meteor.call "createEmbed", {
					uri: uri
				}, (error, id) ->
					if error
						Session.set("questionsNewAlert", {type: 'error', message: error.reason})
						Session.set "new question embed id", null
						Session.set "new question embed uri", uri
					else
						Session.set "questionsNewAlert", null
						Session.set "new question embed id", id
						Session.set "new question embed uri", uri
			else if uri.length == 0
				Session.set "questionsNewAlert", null
				Session.set "new question embed id", null
				Session.set "new question embed uri", null
		else
			Session.set("questionsNewAlert", {type: 'error', message: "Sign in to embed that"})
			Accounts._loginButtonsSession.set('dropdownVisible', true)
	
	"change #new-question-image": (event) ->
		Session.set "new question image uri", event.fpfile.url

	"click #preview-image .remove": (event, template) ->
		event.preventDefault()
		Session.set "new question image uri", null

	"click .answer-choice-wrap .remove": (event, template) ->
		event.preventDefault()
		Session.set("questionsNewAlert", null)
		Session.set 'answerChoices', _.without(Session.get('answerChoices'), event.currentTarget.getAttribute('data-value'))

	"keyup textarea.question": (event, template) ->
		Session.set("questionsNewAlert", null)
		Session.set 'question', $.trim(event.currentTarget.value)
		Session.set "questionRemainingChars", (140 - $(event.target).val().length)

	"keyup input.answer-choice": (event, template) ->
		Session.set("questionsNewAlert", null)
		Session.set 'answerChoices', _.without(_.uniq(_.map(template.findAll("input.answer-choice"), (el) -> $.trim(el.value))), '')
		if (event.which == 13) then $(event.target).focusNextInputField()

Template.questionsNew.alert = ->
	Session.get "questionsNewAlert"

Template.questionsNew.question = ->
	Session.get "question"

Template.questionsNew.isLoggedIn = ->
	Meteor.userId()

Template.questionsNew.questionRemainingChars = ->
	Session.get "questionRemainingChars"

Template.questionsNew.embedHtml = ->
	Session.get "new question embed uri"

Template.questionsNew.embedHtml = ->
	embed = Embeds.findOne(Session.get "new question embed id")
	if embed then embed.html else null

Template.questionsNew.resetFpWidget = ->
	Session.get "resetFpWidget"

Template.questionsNew.imageUri = ->
	Session.get "new question image uri"

Template.questionsNew.objectifiedAnswerChoices = ->
	answerChoices = Session.get 'answerChoices'
	if answerChoices and answerChoices.length > 0
		objectifiedAnswerChoices = objectifyAnswerChoices(answerChoices)
		objectifiedAnswerChoices.push({order: answerChoices.length+1, placeholder: 'add another response', value: ''}, {order: answerChoices.length+2, placeholder: 'press enter to add another', value: ''})
		while objectifiedAnswerChoices.length > 5
			objectifiedAnswerChoices.pop()
	else
		objectifiedAnswerChoices = [{order: 1, placeholder: 'yes', value: ''}, {order: 2, placeholder: 'no', value: ''}, {order: 3, placeholder: "don't care", value: ''}]
	objectifiedAnswerChoices

Template.questionsNew.created = ->
	questionLength = if Session.get("question") then Session.get("question").length else 0
	Session.set "questionRemainingChars", (140 - questionLength)

Template.questionsNew.rendered = ->
	$(@find("#answer-choices .choices")).sortable
		axis: 'y'
		cursor: 'move'
		update: (e, ui) =>
			Session.set 'answerChoices', _.without(_.uniq(_.map(@findAll("input.answer-choice"), (el) -> $.trim(el.value))), '')
	wait 1500, () =>
		unless @find(".pick-image-widget")
			filepicker.constructWidget(@find("#new-question-image"))
		# Resize iframes
		$(window).resize =>
			$iframe = $(@find('iframe'))
			width = $(@find('#embed-html')).innerWidth()
			resizeIframe($iframe, width)
		$(window).resize()


