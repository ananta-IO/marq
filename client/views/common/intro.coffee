Template.intro.rendered = ->
	$(@find(".login-button")).tooltip
		title: "New users instantly earn 101 karma<br/>And we promise not to mess with your Facebook"
		placement: 'top'
		# trigger: 'hover'
		html: 'true'
		delay: 
			show: 0
			hide: 1000