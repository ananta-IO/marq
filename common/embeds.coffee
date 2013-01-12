## Embeds
# Each embed is represented by a document in the Embeds collection:
#   ownerId: String user id
#   uri: String
#   data: Object returned by embedly oembed API
#   html: String
#   createdAt: new Date
Embeds = new Meteor.Collection("embeds")


Embeds.allow
	insert: (userId, embed) ->
		false # no cowboy inserts -- use createEmbed method
	
	update: (userId, embeds, fields, modifier) ->
		false

	remove: (userId, embeds) ->
		false


Meteor.methods
	# options should include: uri
	createEmbed: (options) ->
		options = options or {}
		data = {}

		throw new Meteor.Error(403, "Log in to embed this link")  unless @userId
		
		if Meteor.isServer
			result = Meteor.http.get "http://api.embed.ly/1/oembed",
				params:
					key: getSetting("embedlyKey")
					url: options.uri
					maxwidth: 640
					maxheight: 480
					format: 'json'
			# if successfully obtained embedly data
			if not result.error and result.data and result.data.html
				data = result.data
			else
				throw new Meteor.Error(400, "Link could not be embeded. Please try another link.")

		Embeds.insert
			ownerId: @userId
			uri: options.uri
			data: data
			html: data.html
			createdAt: new Date


