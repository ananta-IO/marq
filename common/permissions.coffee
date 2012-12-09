canRemoveQuestion = (userId, question) ->
	question.owner == userId and question.answerCount == 0