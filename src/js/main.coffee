window.beacon = require './beacon'
window.$ = require 'jquery'

uuid = '00000000-752F-1001-B000-001C4D1A3E36'
identifier = 'playSpace'

document.addEventListener 'deviceready', ()->
  beacon.iBeaconDelegate()
  newBeacon = beacon.createBeacon(uuid, identifier)
  beacon.startMonitoring(newBeacon)
  beacon.startRanging(newBeacon)

$(document).ready ()->
  $logView = $('#logView')
  log = (beaconInfo)->
    line = ''
    for i in beaconInfo
      line += '-'
      line += i
    $logView.append line
    $logView.append '<br>'

  beacon.handleBeacon $logView, null, null, {
    WhenEverCb: (uuid, major, minor, proximity)-> log [uuid, major, minor, proximity]
    NearCb: (uuid, major, minor)-> log [uuid, major, minor, 'NearCb']
  }

