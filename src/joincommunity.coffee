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
#   hubot join community <id> - Lists all messages with interval set to channels
#

module.exports = (robot) ->

    robot.hear /join community (.*)/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user,'admin')
            console.log(msg)
            #TODO
            msg.reply "Joined community with name: placeholder"
        else
            msg.reply "Sorry, but you don't have permission to run this command."
