analytics = analytics or []
analytics.load = (apiKey) ->
    script = document.createElement("script")
    script.type = "text/javascript"
    script.async = true
    script.src = ((if "https:" is document.location.protocol then "https://" else "http://")) + "d2dq2ahtl5zl1z.cloudfront.net" + "/analytics.js/v1/" + apiKey + "/analytics.min.js"
    first = document.getElementsByTagName("script")[0]
    first.parentNode.insertBefore script, first
    factory = (type) ->
        ->
            analytics.push [type].concat(Array::slice.call(arguments, 0))

    methods = ["identify", "track"]
    i = 0

    while i < methods.length
        analytics[methods[i]] = factory(methods[i])
        i++
        
analyticsRequest = ->
    segementIoId = getSetting('segmentIoId')
    if segementIoId
        analytics.load(segementIoId)

        Meteor.autorun ->
            user = Meteor.user()
            if user and user.profile and user.profile.facebook and user.answerQuestionCount and user.askQuestionCount     
                analytics.identify user._id,
                    name: user.profile.name
                    email: user.profile.facebook.email
                    username: user.profile.facebook.username
                    gender: user.profile.facebook.gender
                    birthday: user.profile.facebook.birthday
                    locale: user.profile.facebook.locale
                    timezone: user.profile.facebook.timezone
                    bio: user.profile.facebook.bio
                    quotes: user.profile.facebook.quotes
                    education: user.profile.facebook.education
                    work: user.profile.facebook.work
                    inspirationalPeople: user.profile.facebook.inspirational_people
                    createdAt: user.createdAt
                    karma: user.karma
                    answerQuestionCount: user.answerQuestionCount
                    askQuestionCount: user.askQuestionCount