Template.questionsDialog.events 
	# close
	"click .done": (event, template) ->
		event.preventDefault()
		Session.set("showQuestionsDialog", false)

openQuestionsDialog = (questionId) ->
	Session.set("questionsDialogQuestionId", questionId)
	Session.set("showQuestionsDialog", true)

Template.questionsDialog.question = ->
	QuestionList.currentQuestion()

# Template.questionsDialog.rendered = ->
#	QuestionList.namespace = "questionsDialog"

Template.questionsDialog.created = ->
	QuestionList.namespace = "questionsDialog"
	QuestionList.initialize({questionId: Session.get("questionsDialogQuestionId")})