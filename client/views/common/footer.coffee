Template.footer.helpers
	year: ->
		new Date().getFullYear()

Template.footer.rendered = ->
	unless window.addthis
		initAddThis()
	else
		addthis.toolbox(@find(".addthis_toolbox"))

	$toolbox = $(@find("#footer .addthis_toolbox"))
	if $toolbox
		buttons = $toolbox.children("a")
		pre = 99
		cur = 0
		hover = false
		time = 2000
		$(buttons).fadeTo(0, 0.4);
		$(buttons).hide()
		transitionButtons = () =>
			cur = if (pre+1) < buttons.length then (pre+1) else 0
			$(buttons[pre]).fadeOut(500)
			$(buttons[cur]).fadeIn(500)
			pre = cur
			recur = () =>
				if hover
					wait time, () => recur()
				else
					transitionButtons()
			wait time, () => recur()
		transitionButtons()

		$toolbox.live
			mouseenter: =>
				hover = true
				$(buttons[cur]).fadeTo(300, 1.0);
			mouseleave: =>
				hover = false
				$(buttons[cur]).fadeTo(300, 0.4);
		.tooltip
			title: 'share this page'
			placement: 'top'
			delay: 
				show: 800