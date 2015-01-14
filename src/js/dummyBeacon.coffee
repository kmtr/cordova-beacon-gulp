beacon = require './beacon'
module.exports.ProximityImmediate = beacon.ProximityImmediate
module.exports.ProximityNear = beacon.ProximityNear
module.exports.ProximityFar = beacon.ProximityFar
module.exports.ProximityUnknown = beacon.ProximityUnknown
module.exports.fire = (uuid, proximity, major, minor, rssi)->
  pluginResult = {
    "beacons": [
      {
        "uuid": uuid,
        "proximity": proximity,
        "major": major,
        "minor": minor
        "rssi": rssi,
      }
    ],
    "eventType": "didRangeBeaconsInRegion",
    "region": {
      "typeName": "BeaconRegion",
      "uuid": uuid,
      "identifier": "playSpace"
    }
  }

  log = JSON.stringify pluginResult
  event = document.createEvent "HTMLEvents"
  event.initEvent pluginResult.eventType, true, true
  event.pluginResult = pluginResult
  window.dispatchEvent event

module.exports.multiFire = (beacons)->
  if not beacons or beacons.length == 0
    return

  pr = arrayToPluginResult(beacons)
  firstBeacon = pr[0]
  pluginResult = {
    "beacons" : pr,
    "eventType": "didRangeBeaconsInRegion",
    "region": {
      "typeName": "BeaconRegion",
      "uuid": firstBeacon.uuid,
      "identifier": "playSpace"
    }
  }
  log = JSON.stringify pluginResult
  event = document.createEvent "HTMLEvents"
  event.initEvent pluginResult.eventType, true, true
  event.pluginResult = pluginResult
  window.dispatchEvent event

arrayToPluginResult = (beacons)->
  pluginResult = ((b)->
    {
          "uuid": b[0],
          "proximity": b[1],
          "major": b[2],
          "minor": b[3]
          "rssi": b[4],
    })(b) for b in beacons
