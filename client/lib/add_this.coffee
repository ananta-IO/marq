initAddThis = ->
	script = '//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-4e07edfe1206c99f'
	if window.addthis then window.addthis = null
	$.getScript script#, () -> addthis.init()