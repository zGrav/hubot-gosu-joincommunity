# Description:
#   Join a community via name
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot join community <name> - Makes me join a GOSU community if you're the owner of it.
#

module.exports = (robot) ->

    robot.hear /join community (.*)/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user,'admin')
            console.log(msg)
            console.log(escape(msg.match[1]))
            #TODO
            msg.reply "Joined community with name: placeholder"
        else
            msg.reply "Sorry, but you don't have permission to run this command."
