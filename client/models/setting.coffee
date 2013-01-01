Setting = FormModel.extend(
	blankSchema:
		segmentIoId: 'g2x35t4' 

	init: (options) ->
		@_super Settings, options
		@overwriteTitle "segmentIoId", "Segment.io ID"
)

# Setting = FormModel.extend(
#	blankSchema:
#		requireViewInvite: false
#		requirePostInvite: false
#		requirePostsApproval: false
#		title: ""
#		theme: ""
#		footerCode: ""
#		analyticsCode: ""
#		tlkioChannel: ""
#		mixpanelId: ""
#		proxinoKey: ""
#		goSquaredId: ""
#		veroAPIKey: ""
#		veroSecret: ""
#		intercomId: ""
#		logoUrl: ""
#		logoHeight: ""
#		logoWidth: ""
#		scoreUpdateInterval: ""
#		landingPageText: ""
#		afterSignupText: ""
#		notes: ""

#	init: (options) ->
#		@_super Settings, options
#		@overwriteTitle "requireViewInvite", "Require Invite to view?"
#		@overwriteTitle "requirePostInvite", "Require Invite to post?"
#		@overwriteTitle "requirePostsApproval", "Posts must be approved by admin?"
#		@overwriteTitle "title", "Site Title"
#		@overwriteTitle "tlkioChannel", "<a href=\"http://tlk.io/\">Tlk.io</a> Channel"
#		@overwriteTitle "mixpanelId", "<a href=\"http://mixpanel.com/\">Mixpanel</a> ID"
#		@overwriteTitle "proxinoKey", "<a href=\"http://proxino.com/\">Proxino</a> key"
#		@overwriteTitle "goSquaredId", "<a href=\"http://gosquared.com/\">GoSquared</a> ID"
#		@overwriteTitle "intercomId", "<a href=\"http://intercom.io/\">Intercom</a> ID"
#		@overwriteTitle "veroAPIKey", "<a href=\"http://getvero.com/\">Vero</a> API key"
#		@overwriteTitle "veroSecret", "<a href=\"http://getvero.com/\">Vero</a> secret"
#		@overwriteTitle "logoUrl", "Logo URL"
#		@overwriteType "footerCode", "textarea"
#		@overwriteType "analyticsCode", "textarea"
#		@overwriteType "landingPageText", "textarea"
#		@overwriteType "afterSignupText", "textarea"
#		@overwriteType "notes", "textarea"
#		@makeSelect "theme", ["Default", "Ascndr", "Telescope"]
# )