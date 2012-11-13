## Marq -- data model
## Loaded on both the client and the server

###############################################################################
## Questions

# Each question is represented by a document in the Questions collection:
#   owner: user id
#   question: String
#   answerChoices: Array of possible answers like ["yes", "no", "don't care"]
#   answers: Array of objects like {user: userId, answer: "yes"} (or "no"/"don't care")
Questions = new Meteor.Collection("questions")

Questions.allow
  insert: (userId, question) ->
    return false; # no cowboy inserts -- use createParty method
  
  update: (userId, questions, fields, modifier) ->
    _.all questions, (question) ->
      return false  if userId isnt question.owner # not the owner
      allowed = ["question", "answerChoices"]
      return false  if _.difference(fields, allowed).length # tried to write to forbidden field
      
      # A good improvement would be to validate the type of the new
      # value of the field (and if a string, the length.) In the
      # future Meteor will have a schema system to makes that easier.
      true

  remove: (userId, questions) ->
    not _.any(questions, (question) ->
      # deny if not the owner, or if other people are going
      question.owner isnt userId or answerCount(question) > 0
    )

answerCount = (question) ->
  question.answers.length || 0

Meteor.methods
  # options should include: question, answerChoices
  createQuestion: (options) ->
    options = options or {}
    throw new Meteor.Error(400, "question can't be blank")  unless typeof options.question is "string" and options.question.length
    throw new Meteor.Error(413, "Question too long")  if options.question.length > 140
    throw new Meteor.Error(403, "You must be logged in")  unless @userId
    
    Questions.insert
      owner: @userId
      question: options.question
      answerChoices: ["yes", "no", "don't care"]
      answers: []

###############################################################################
## Users
  