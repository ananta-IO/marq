## Votes
# Each vote is represented by a document in the Votes collection:
#	ownerId: String user id
#	questionId: String question id
#	vote: Integer (1 or -1)
#   createdAt: new Date
Votes = new Meteor.Collection("votes")

Votes.allow
	insert: (userId, vote) ->
		false # no cowboy inserts -- use createvote method
	
	update: (userId, votes, fields, modifier) ->
		false

	remove: (userId, votes) ->
		false

Meteor.methods
	# DO NOT call this directly. Should be called by rateQuestion
	# options should include: vote, questionId, incValue
	createVote: (options) ->
		options = options or {}

		throw new Meteor.Error(403, "Log in to rate this question")  unless @userId
		question = Questions.findOne(options.questionId)
		throw new Meteor.Error(404, "No such question")  unless question
		vote = Votes.findOne({ownerId: @userId, questionId: options.questionId})
		throw new Meteor.Error(400, "You have already rated this question")  if vote
		throw new Meteor.Error(400, "Vote can't be blank")  unless typeof options.vote is "string" and options.vote.length
		throw new Meteor.Error(400, "Invalid rating")  unless _.contains(['for', 'against'], options.vote)	
		
		Votes.insert
			ownerId: @userId
			questionId: options.questionId
			vote: options.incValue
			createdAt: new Date

		Meteor.users.update Meteor.userId(), {
			$inc: { castVoteCount: 1 }
		}

		# Only inc the karma of the owner if the voter is not the owner of the question
		if question.ownerId != Meteor.userId()
			Meteor.users.update question.ownerId, {
				$inc: { karma: options.karma }
			}