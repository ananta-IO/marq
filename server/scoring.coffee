# "secret" server code to recalculate scores
updateScore = (collection, id) ->
	object = collection.findOne(id)
	
	# use baseScore if defined, if not just use the number of votes
	# note: for transition period, also use votes if there are more votes than baseScore
	baseScore = Math.max(object.voteTally or 0, object.baseScore or 0)
	
	# now multiply by 'age' exponentiated
	# FIXME: timezones <-- set by server or is getTime() ok?
	ageInHours = (new Date().getTime() - new Date(object.createdAt).getTime()) / (60 * 60 * 1000)
	
	# HN algorithm (same as Bindle)
	newScore = baseScore / Math.pow(ageInHours + 2, 1.3)
	newScore = 999  if object.sticky
	collection.update id,
		$set:
			score: newScore


Meteor.startup ->
	scoreInterval = 30 # getSetting("scoreUpdateInterval") or 30
	
	# recalculate scores every N seconds
	if scoreInterval > 0
		intervalId = Meteor.setInterval(->
			
			# console.log('tick ('+scoreInterval+')')

			Questions.find().forEach (question) ->
				updateScore Questions, question._id

		, scoreInterval * 1000)