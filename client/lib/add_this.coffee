initAddThis = (addthis_share = true) ->
	addthis_share
	script = '//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-50f37661618b7f63'
	if window.addthis then window.addthis = null
	$.getScript script#, () -> addthis.init()