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
        hubID = msg.match[1]
        hubID = hubID.substring(hubID.lastIndexOf('/') + 1)

        robot.http(global.api + "/hub/#{hubID}")
        .headers('Accept': 'application/json', 'Content-Type': 'application/json', 'X-Token': global.user_token)
        .get() (err, res, body) ->
            try
                result = JSON.parse(body)

                hubName = result.hub.title
                hubOwner = result.hub.owner_id
                userID = msg.user.id
                console.log(msg)
                console.log(userID)

                if robot.auth.hasRole(msg.envelope.user,'admin') or hubOwner == userID
                    #TODO join
                    msg.reply "Joined community with name: #{hubName}"
                else
                    msg.reply "Sorry, but you don't have permission to run this command."

            catch error
                @robot.logger.error "Oh no! We errored :( - #{error} - API Response Code: #{res.statusCode}"
