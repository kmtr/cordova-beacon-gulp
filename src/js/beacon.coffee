ProximityNear = 'ProximityNear'
ProximityFar = 'ProximityFar'
ProximityImmediate = 'ProximityImmediate'
ProximityUnknown = 'ProximityUnknown'

throwEvent = (pluginResult) ->
  log = JSON.stringify pluginResult
  cordova.plugins.locationManager.appendToDeviceLog log
  event = document.createEvent "HTMLEvents"
  event.initEvent pluginResult.eventType, true, true
  event.pluginResult = pluginResult
  window.dispatchEvent event

iBeaconDelegate = ->
  delegate = new cordova
    .plugins
    .locationManager
    .Delegate()
    .implement {
      didDetermineStateForRegion: throwEvent
      didStartMonitoringForRegion: throwEvent
      didExitRegion: throwEvent
      didEnterRegion: throwEvent
      didRangeBeaconsInRegion: throwEvent
    }
  cordova.plugins.locationManager.setDelegate delegate
  cordova.plugins.locationManager.requestAlwaysAuthorization()

createBeacon = (uuid, identifier)->
  b = new cordova.plugins.locationManager.BeaconRegion(
    identifier,
    uuid,
  )

startMonitoring = (b)->
  cordova.plugins.locationManager
    .startMonitoringForRegion b
    .fail(console.error)
    .done()

stopMonitoring = (b)->
  cordova.plugins.locationManager
    .stopMonitoringForRegion b
    .fail(console.error)

startRanging = (b)->
  cordova.plugins.locationManager
    .startRangingBeaconsInRegion b
    .fail(console.error)
    .done()

stopRanging = (b)->
  cordova.plugins.locationManager
    .stopRangingBeaconsInRegion b
    .fail(console.error)
    .done()

handleBeacon = (target, major, minor, callbacks)->
  mmTest = (bMajor, bMinor)->
    if major? and (major != bMajor) then return false
    if minor? and (minor != bMinor) then return false
    true
      
  window.addEventListener 'didRangeBeaconsInRegion', (e)->
    match = false
    for b in e.pluginResult.beacons when mmTest(b.major, b.minor)
      match = true
      if callbacks.WhenEverCb?
        callbacks.WhenEverCb b.uuid, b.major, b.minor, b.proximity

      cb = null
      switch b.proximity
        when ProximityImmediate
          cb = callbacks.ImmediateCb
        when ProximityNear
          cb = callbacks.NearCb
        when ProximityFar
          cb = callbacks.FarCb
        when ProximityUnknown
          cb = callbacks.UnknownCb
      if cb? then cb b.uuid, b.major, b.minor
    if not match and callbacks.UnmatchCb? then callbacks.UnmatchCb()

isCordova = (typeof cordova != 'undefined')

#exports
module.exports.ProximityImmediate = ProximityImmediate
module.exports.ProximityNear = ProximityNear
module.exports.ProximityFar = ProximityFar
module.exports.ProximityUnknown = ProximityUnknown
module.exports.iBeaconDelegate = iBeaconDelegate
module.exports.createBeacon = createBeacon
module.exports.startMonitoring = startMonitoring
module.exports.stopMonitoring = stopMonitoring
module.exports.startRanging = startRanging
module.exports.stopRanging = stopRanging
module.exports.handleBeacon = handleBeacon

#load dummyBeacon if Cordova is not loaded.
if not isCordova then window.dummyBeacon = require './dummyBeacon'
