# TODO: figure out how to store additional user info in the user profile and then ask for these additional scopes
# Accounts.ui.config
#   requestPermissions:
#     facebook: ["user_about_me", "user_activities", "user_birthday", "user_checkins", "user_education_history", "user_interests", "user_likes", "friends_likes", "user_work_history", "email"]

Template.hello.greeting = ->
  "Welcome to marq. It's Grrrreat!"

Template.hello.events "click input": ->    
  # template data, if any, is available in 'this'
  console.log "You pressed the button"  if typeof console isnt "undefined"