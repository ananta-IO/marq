## Comments
# Each comment is represented by a document in the Comments collection:
#	ownerId: String user id
#	ownerName: String user name
#	questionId: String question id
#	comment: String
#	votes: Object
#		- ownerId: String user id
#		- vote: Integer only 1 for now (just up votes)
#		- createdAt: new Date
#   createdAt: new Date
Comments = new Meteor.Collection("comments")

Comments.allow
	insert: (userId, vote) ->
		false # no cowboy inserts -- use createvote method
	
	update: (userId, comments, fields, modifier) ->
		false

	remove: (userId, comments) ->
		false

Meteor.methods
	# DO NOT call this directly. Should be called by commentOnQuestion
	# options should include: questionId, comment
	createComment: (options) ->
		options = options or {}

		throw new Meteor.Error(403, "Log in to comment on this question")  unless @userId
		question = Questions.findOne(options.questionId)
		throw new Meteor.Error(404, "No such question")  unless question
		throw new Meteor.Error(400, "Comment can't be blank")  unless typeof options.comment is "string" and options.comment.length
		fiveMinAgo = new Date((new Date).getTime() - 5*60000) # Date 5 minutes ago
		# Only check for duplicate posts in the last 5 minutes
		comment = Comments.findOne({ownerId: @userId, questionId: options.questionId, comment: options.comment, createdAt: { $gte: fiveMinAgo } })
		throw new Meteor.Error(400, "You have already posted this comment")  if comment
		
		Comments.insert
			ownerId: @userId
			ownerName: getUsername(Meteor.user())
			questionId: options.questionId
			comment: options.comment
			votes: {}
			createdAt: new Date

		Meteor.users.update Meteor.userId(), {
			$inc: { postCommentCount: 1 }
		}
