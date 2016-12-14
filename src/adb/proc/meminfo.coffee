{EventEmitter} = require 'events'
split = require 'split'

Parser = require '../parser'

class MemStat extends EventEmitter

  constructor: (@sync) ->
    @interval = 1000
    @memStats = this._emptyMemStats()
    @_ignore = {}
    @_timer = setInterval =>
      this.update()
    , @interval
    this.update()

  end: ->
    clearInterval @_timer
    @sync.end()
    @sync = null

  update: ->
    new Parser(@sync.pull '/proc/meminfo')
      .readAll()
      .then (out) =>
        this._parse out
      .catch (err) =>
        this._error err
        return

  _parse: (out) ->
    stats = @_emptyStats()
    data = out.toString()
    data.split(/\n/g).forEach (line) ->
      line = line.split(':')
      if line.length < 2
        return
      stats[line[0]] = parseInt(line[1].trim(), 10)
      stats
    this._set stats

  _set: (stats) ->
    loads = stats
    found = true
    if found
      @emit 'load', loads
      @stats = stats

  _error: (err) ->
    this.emit 'error', err

  _emptyMemStats: ->
    {}

module.exports = MemStat
