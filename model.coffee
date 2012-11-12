## Marq -- data model
## Loaded on both the client and the server

###############################################################################
## Questions

# Each question is represented by a document in the Questions collection:
#   creator: user id
#   question: String
#   answerChoices: Array of possible answers like ["yes", "no", "don't care"]
#   answers: Array of objects like {user: userId, answer: "yes"} (or "no"/"don't care")
Questions = new Meteor.Collection("questions");

Meteor.methods
  # options should include: title, description, x, y, public
  createParty: (options) ->
    options = options or {}
    throw new Meteor.Error(400, "Required parameter missing")  unless typeof options.question is "string" and options.question.length
    throw new Meteor.Error(413, "Question too long")  if options.question.length > 140
    throw new Meteor.Error(403, "You must be logged in")  unless @userId
    Questions.insert
      creator: @userId
      question: options.question

###############################################################################
## Users
  