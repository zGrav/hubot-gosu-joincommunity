# Description:
#   Join a community via id or name
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

existing = []

class Functions

    searchArray: (key, arr) ->
        i = 0

        while i < arr.length
            if arr[i].id == key
                return true
            i++
        return false

     loadHubIDs: ->
         i = 0

         while i < global.channels_by_index.length
             if channels_by_index[i].hub_id != undefined
                 existing.push(global.channels_by_index[i].hub_id)
             i++

module.exports = (robot) ->

    robot.hear /join community (.*)/i, (msg) ->
        funcs = new Functions

        funcs.loadHubIDs()

        if msg.envelope.message.text.indexOf('direct') > -1
            msg.send "Sorry, cannot run this command in a private channel, please run it in a public channel in order to verify your permissions."
            return

        hubID = msg.match[1]
        hubID = hubID.substring(hubID.lastIndexOf('/') + 1)

        existingidx = existing.indexOf(hubID)

        robot.http(global.api + "/hub/#{hubID}")
        .headers('Accept': 'application/json', 'Content-Type': 'application/json', 'X-Token': global.user_token)
        .get() (err, res, body) ->
            try
                result = JSON.parse(body)

                hubName = result.hub.title
                hubOwner = result.hub.owner_id
                userID = msg.envelope.user.id

                if msg.envelope.user.is_moderator or hubOwner == userID
                    if existingidx != -1
                        msg.send "Already in this community!"
                        return
                    else
                        query = {
                            "hub_id": hubID
                            "user_id": global.user_id
                        }

                        string_query = JSON.stringify(query)
                        content_length = string_query.length

                        robot.http(global.api + "/hub/#{hubID}/join")
                        .headers('Accept': 'application/json', 'Content-Type': 'application/json', 'Content-Length': content_length, 'X-Token': global.user_token)
                        .post(string_query) (err, res, body) ->
                            try
                              if res.statusCode isnt 200
                                  robot.logger.error "Oh no! We errored under API :( - Response Code: #{res.statusCode}"
                                  return

                              msg.send "Joined community with name: #{hubName}"

                              query = {
                                  "username": global.username,
                                  "password": global.password,
                                  "agent_id": global.agent_id,
                                  "agent_name": global.agent_name,
                                  "agent_type": global.agent_type
                              }

                              string_query = JSON.stringify(query)
                              content_length = string_query.length

                              robot.http(global.api + '/auth/login')
                              .headers('Accept': 'application/json', 'Content-Type': 'application/json', 'Content-Length': content_length)
                              .post(string_query) (err, res, body) ->
                                  try
                                    result = JSON.parse(body)

                                    l = 0
                                    while l < result.user.channels.length
                                        if result.user.channels[l].type == 2 or result.user.channels[l].type == 3 or result.user.channels[l].type == 4 or result.user.channels[l].type == 5
                                            if funcs.searchArray(result.user.channels[l].id, global.channels_by_index) == false
                                                global.channels_by_index.push(title: result.user.channels[l].title, id: result.user.channels[l].id, hub_id: result.user.channels[l].hub_id, type: result.user.channels[l].type, ts: null)
                                        l++
                                  catch error
                                    robot.logger.error "Oh no! We errored :( - #{error} - API Response Code: #{res.statusCode}"
                            catch error
                                robot.logger.error "Oh no! We errored :( - #{error} - API Response Code: #{res.statusCode}"
                else
                    msg.send "Sorry, but you don't have permission to run this command."

            catch error
                @robot.logger.error "Oh no! We errored :( - #{error} - API Response Code: #{res.statusCode}"
