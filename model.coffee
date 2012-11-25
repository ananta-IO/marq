## Marq -- data model
## Loaded on both the client and the server

###############################################################################
## Questions

# Each question is represented by a document in the Questions collection:
#   owner: user id
#   question: String
#   answerChoices: Array of possible answers like ["yes", "no", "don't care"]
#   answers: Array of objects like {user: userId, answer: "yes", createdAt: new Date} (or "no"/"don't care")
#   answeredBy: Array of user ids like ["1", "2", "3"]
#   answerCount: Integer count of answers
#   votes: Array of objects like {user: userId, vote: "for", createdAt: new Date} (or "against")
#   voteTally: Integer count of for votes minus against votes
#   createdAt: new Date
Questions = new Meteor.Collection("questions")

Questions.allow
  insert: (userId, question) ->
    false # no cowboy inserts -- use createParty method
  
  update: (userId, questions, fields, modifier) ->
    false
    # _.all questions, (question) ->
    #   return false  if userId isnt question.owner # not the owner
    #   allowed = ["question", "answerChoices"]
    #   return false  if _.difference(fields, allowed).length # tried to write to forbidden field
      
    #   # A good improvement would be to validate the type of the new
    #   # value of the field (and if a string, the length.) In the
    #   # future Meteor will have a schema system to makes that easier.
    #   true

  remove: (userId, questions) ->
    not _.any(questions, (question) ->
      # deny if not the owner, or if other people are going
      question.owner isnt userId or question.answerCount > 0
    )

countAnswers = (question) ->
  question.answers.length || 0

tallyAnswers = (question) ->
  tally = {}
  _.each question.answers, (ans) ->
    if tally[ans.answer] then tally[ans.answer] += 1 else tally[ans.answer] = 1
  tally

objectifyAnswerChoices = (answerChoices) ->
  _.map(answerChoices, (ac, i) -> {order: i+1, placeholder: ac, value: ac})

Meteor.methods
  # options should include: question, answerChoices
  createQuestion: (options) ->
    options = options or {}
    throw new Meteor.Error(400, "Question can't be blank")  unless typeof options.question is "string" and options.question.length
    throw new Meteor.Error(413, "Question is too long")  if options.question and options.question.length > 140
    throw new Meteor.Error(413, "Add at least one more answer choice")  if options.answerChoices and options.answerChoices.length > 0 and options.answerChoices.length < 2
    throw new Meteor.Error(403, "Log in to ask a question")  unless @userId
    throw new Meteor.Error(400, "You have already asked this question")  if Questions.findOne({ owner: @userId, question: options.question })
    
    Questions.insert
      owner: @userId
      question: options.question
      answerChoices: if options.answerChoices and options.answerChoices.length > 0 then options.answerChoices else ["yes", "no", "don't care"]
      answers: []
      answeredBy: []
      answerCount: 0
      votes: []
      voteTally: 0
      createdAt: new Date

  # options should include: questionId, answer
  answerQuestion: (options) ->
    options = options or {}
    throw new Meteor.Error(403, "Log in to answer this question")  unless @userId
    question = Questions.findOne(options.questionId)
    throw new Meteor.Error(404, "No such question")  unless question
    throw new Meteor.Error(400, "You have already answered this question")  if _.contains(_.pluck(question.answers, 'user'), @userId)
    throw new Meteor.Error(400, "Answer can't be blank")  unless typeof options.answer is "string" and options.answer.length
    throw new Meteor.Error(400, "Invalid answer")  unless _.contains(question.answerChoices, options.answer)
    # add new answer entry
    Questions.update options.questionId, { 
      $push: { answeredBy: @userId, answers: { user: @userId, answer: options.answer, createdAt: new Date }},
      $inc: { answerCount: 1 }
    }


  # options should include: questionId, vote
  rateQuestion: (options) ->
    options = options or {}
    throw new Meteor.Error(403, "Log in to rate this question")  unless @userId
    question = Questions.findOne(options.questionId)
    throw new Meteor.Error(404, "No such question")  unless question
    throw new Meteor.Error(400, "You have already rated this question")  if _.contains(_.pluck(question.votes, 'user'), @userId)
    throw new Meteor.Error(400, "Vote can't be blank")  unless typeof options.vote is "string" and options.vote.length
    throw new Meteor.Error(400, "Invalid rating")  unless _.contains(['for', 'against'], options.vote)
    if options.vote == 'for' then incValue = 1 else incValue = -1
    # add new vote entry
    Questions.update options.questionId, { 
      $push: { votes: { user: @userId, vote: options.vote, createdAt: new Date }},
      $inc: { voteTally: incValue }
    }


###############################################################################
## Users
  