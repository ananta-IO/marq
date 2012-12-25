canRemoveQuestion = (userId, question) ->
	question.ownerId == userId and question.answerCount == 0