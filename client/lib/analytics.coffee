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
        if analytics.load
            # console.log "analytics load"
            analytics.load(segementIoId)

        Meteor.autorun ->
            user = Meteor.user()
            # console.log "try ident", user
            if analytics.identify? and user? and user._id? and user.profile? and (user.profile.facebook? or user.profile.google? or user.profile.name? or user.profile.email?) and user.answerQuestionCount? and user.askQuestionCount? and user.castVoteCount? and user.postCommentCount? and user.viewQuestionCount?
                # console.log "analytics identify"
                analytics.identify user._id,
                    name: getName(user)
                    email: getEmail(user)
                    username: getUsername(user)
                    gender: getGender(user)
                    birthday: getBirthday(user)
                    locale: getLocale(user)
                    timezone: getTimezone(user)
                    bio: getBio(user)
                    quotes: JSON.stringify(getQuotes(user))
                    education: JSON.stringify(getEducation(user))
                    work: JSON.stringify(getWork(user))
                    inspirationalPeople: JSON.stringify(getInspirationalPeople(user))
                    createdAt: user.createdAt
                    lastSeen: (new Date)
                    karma: user.karma
                    answerQuestionCount: user.answerQuestionCount
                    askQuestionCount: user.askQuestionCount
                    castVoteCount: user.castVoteCount
                    postCommentCount: user.postCommentCount
                    viewQuestionCount: user.viewQuestionCount
                    avatar: getAvatarUri(user)
                    syncedAccount: JSON.stringify(getSyncedAccounts(user))
