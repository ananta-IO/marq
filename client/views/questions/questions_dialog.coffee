Template.questionsDialog.events 
	# close
	"click .done": (event, template) ->
		event.preventDefault()
		Session.set("showQuestionsDialog", false)

openQuestionsDialog = (questionId) ->
	Session.set("questionsDialogQuestionId", questionId)
	Session.set("showQuestionsDialog", true)

Template.questionsDialog.question = ->
	Questions.findOne(Session.get("questionsDialogQuestionId"))

Template.questionsDialog.rendered = ->
	question = Questions.findOne(Session.get("questionsDialogQuestionId"))
	answersTally = tallyAnswers(question)
	dataSet = []
	_.map answersTally, (value, key) ->
		dataSet.push {legendLabel: key, magnitude: value, link: "#"}
	drawPie("questionsDialogPie", dataSet, ".question-dialog .chart", "colorScale20", 10, 100, 30, 0)
