# # ** Handlebars helpers **
# Handlebars.registerHelper "canView", (action) ->
#	action = (if (typeof action isnt "string") then null else action)
#	canView Meteor.user(), action

# Handlebars.registerHelper "canPost", (action) ->
#	action = (if (typeof action isnt "string") then null else action)
#	canPost Meteor.user(), action

# Handlebars.registerHelper "canComment", (action) ->
#	action = (if (typeof action isnt "string") then null else action)
#	canComment Meteor.user(), action

# Handlebars.registerHelper "canUpvote", (collection, action) ->
#	action = (if (typeof action isnt "string") then null else action)
#	canUpvote(Meteor.user())
#	collection
#	action

# Handlebars.registerHelper "canDownvote", (collection, action) ->
#	action = (if (typeof action isnt "string") then null else action)
#	canDownvote Meteor.user(), collection, action

Handlebars.registerHelper "isAdmin", (showError) ->
	if isAdmin(Meteor.user())
		true
	else
		alert "Sorry, you do not have access to this page"  if (typeof showError is "string") and (showError is "true")
		false

# Handlebars.registerHelper "canEdit", (collectionName, item, action) ->
#	action = (if (typeof action isnt "string") then null else action)
#	collection = (if (typeof collectionName isnt "string") then Posts else eval_(collectionName))
#	console.log item
 	
#	# var itemId = (collectionName==="Posts") ? Session.get('selectedPostId') : Session.get('selectedCommentId');
#	# var item=collection.findOne(itemId);
#	item and canEdit(Meteor.user(), item, action)
