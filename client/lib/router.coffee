(->

	Meteor.Router.add
		"/": "questionsAnswer"
		"/questions": "questionsListAnswered"
		"/questions/new": "questionsNew"
		"/questions/answer": "questionsAnswer"
		"/profile": "questionsListMine"
	
	### START

	# XXX: could we just work this out programmatically based on the name?
	#   -- fix this along with the general problem of subscription mess
	PAGE_SUBS =
		posts_top: "topPostsReady"
		posts_new: "newPostsReady"
		posts_pending: "pendingPostsReady"
		posts_digest: "digestPostsReady"
		post_page: "singlePostReady"
		post_edit: "singlePostReady"
		comment_page: "commentReady"
		comment_reply: "commentReady"
		comment_edit: "commentReady"

	
	# specific router functions
	digest = (year, month, day) ->
		if typeof day is "undefined"
			
			# we can get into an infinite reactive loop with the subscription filter
			# if we keep setting the date even when it's barely changed
			Session.set "currentDate", new Date()  if new Date() - Session.get("currentDate") > 60 * 1000
		else
			Session.set "currentDate", new Date(year, month - 1, day)
		
		# a manual version of awaitSubscription; the sub can be loading
		# with a new day, but the data is already there (as the subscription is 
		# for three days)
		if postsForSub.digestPosts().length is 0 and Session.equals(PAGE_SUBS["post_digest"], false)
			"loading"
		else
			"posts_digest"

	post = (id, commentId) ->
		Session.set "selectedPostId", id
		Session.set "scrollToCommentId", commentId  if typeof commentId isnt "undefined"
		
		# XXX: should use the Session for these
		# on post page, we show the comment tree
		Session.set "showChildComments", true
		"post_page"

	post_edit = (id) ->
		Session.set "selectedPostId", id
		"post_edit"

	comment = (id) ->
		Session.set "selectedCommentId", id
		"comment_page"

	comment_reply = (id) ->
		Session.set "selectedCommentId", id
		"comment_reply"

	comment_edit = (id) ->
		Session.set "selectedCommentId", id
		"comment_edit"

	
	# XXX: do these two really not want to set it to undefined (or null)?
	user_profile = (id) ->
		Session.set "selectedUserId", id  if typeof id isnt `undefined`
		"user_profile"

	user_edit = (id) ->
		Session.set "selectedUserId", id  if typeof id isnt `undefined`
		"user_edit"

	
	# XXX: not sure if the '/' trailing routes are needed any more
	Meteor.Router.add
		"/": "posts_top"
		"/top": "posts_top"
		"/top/": "posts_top"
		"/top/:page": "posts_top"
		"/new": "posts_new"
		"/new/": "posts_new"
		"/new/:page": "posts_new"
		"/pending": "posts_pending"
		"/digest/:year/:month/:day": digest
		"/digest": digest
		"/digest/": digest
		"/test": "test"
		"/signin": "user_signin"
		"/signup": "user_signup"
		"/submit": "post_submit"
		"/invite": "no_invite"
		"/posts/deleted": "post_deleted"
		"/posts/:id/edit": post_edit
		"/posts/:id/comment/:comment_id": post
		"/posts/:id/": post
		"/posts/:id": post
		"/comments/deleted": "comment_deleted"
		"/comments/:id": comment
		"/comments/:id/reply": comment_reply
		"/comments/:id/edit": comment_edit
		"/settings": "settings"
		"/admin": "admin"
		"/categories": "categories"
		"/users": "users"
		"/account": "user_edit"
		"/forgot_password": "user_password"
		"/users/:id": user_profile
		"/users/:id/edit": user_edit
		"/:year/:month/:day": digest

	Meteor.Router.filters
		requireLogin: (page) ->
			if Meteor.loggingIn()
				"loading"
			else if Meteor.user()
				page
			else
				"user_signin"

		canView: (page) ->
			error = canView(Meteor.user(), true)
			return page  if error is true
			
			# a problem.. make sure we are logged in
			return "loading"  if Meteor.loggingIn()
			
			# otherwise the error tells us what to show.
			error

		canPost: (page) ->
			error = canPost(Meteor.user(), true)
			return page  if error is true
			
			# a problem.. make sure we are logged in
			return "loading"  if Meteor.loggingIn()
			
			# otherwise the error tells us what to show.
			error

		canEdit: (page) ->
			if page is "comment_edit"
				item = Comments.findOne(Session.get("selectedCommentId"))
			else
				item = Posts.findOne(Session.get("selectedPostId"))
			error = canEdit(Meteor.user(), item, true)
			return page  if error is true
			
			# a problem.. make sure the item has loaded and we have logged in
			return "loading"  if not item or Meteor.loggingIn()
			
			# otherwise the error tells us what to show.
			error

		isLoggedOut: (page) ->
			(if Meteor.user() then "already_logged_in" else page)

		isAdmin: (page) ->
			(if isAdmin(Meteor.user()) then page else "no_rights")

		awaitSubscription: (page) ->
			(if Session.equals(PAGE_SUBS[page], true) then page else "loading")

		
		# if the user is logged in but their profile isn't filled out enough
		requireProfile: (page) ->
			user = Meteor.user()
			if user and not Meteor.loggingIn() and not userProfileComplete(user)
				Session.set "selectedUserId", user._id
				"user_email"
			else
				page

		
		# if we are on a page that requires a post, as set in selectedPostId
		requirePost: (page) ->
			if Posts.findOne(Session.get("selectedPostId"))
				page
			else unless Session.get("postReady")
				"loading"
			else
				"not_found"

	
	# 
	Meteor.Router.filter "requireProfile"
	Meteor.Router.filter "awaitSubscription",
		only: ["posts_top", "posts_new", "posts_pending"]

	Meteor.Router.filter "requireLogin",
		only: ["comment_reply", "post_submit"]

	Meteor.Router.filter "canView",
		only: ["posts_top", "posts_new", "posts_digest"]

	Meteor.Router.filter "isLoggedOut",
		only: ["user_signin", "user_signup"]

	Meteor.Router.filter "canPost",
		only: ["posts_pending", "comment_reply", "post_submit"]

	Meteor.Router.filter "canEdit",
		only: ["post_edit", "comment_edit"]

	Meteor.Router.filter "requirePost",
		only: ["post_page", "post_edit"]

	Meteor.Router.filter "isAdmin",
		only: ["posts_pending", "users", "settings", "categories", "admin"]

	Meteor.startup ->
		Meteor.autorun ->
			
			# grab the current page from the router, so this re-runs every time it changes
			Meteor.Router.page()
			console.log "------ Request start --------"
			
			# openedComments is an Array that tracks which comments
			# have been expanded by the user, to make sure they stay expanded
			Session.set "openedComments", null
			Session.set "requestTimestamp", new Date()
			
			# currentScroll stores the position of the user in the page
			Session.set "currentScroll", null
			document.title = getSetting("title")
			
			# set all errors who have already been seen to not show anymore
			clearSeenErrors()
			
			# log this request with mixpanel, etc
			analyticsRequest()
			
			# if there are any pending events, log them too
			if eventBuffer = Session.get("eventBuffer")
				_.each eventBuffer, (e) ->
					console.log "in buffer: ", e
					trackEvent e.event, e.properties

	END ###

)()