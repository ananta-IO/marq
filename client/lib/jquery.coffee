$.fn.focusNextInputField = ->
	@each ->
		fields = $(this).parents("form:eq(0),body").find("input,textarea,select")
		index = fields.index(this)
		fields.eq(index + 1).focus()  if index > -1 and (index + 1) < fields.length
		false
