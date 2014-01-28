

class LogView



  constructor: (@options={}) ->
    @terminal = $("div.log-terminal")
    @terminal_list = $("<ul class='list-unstyled'></ul>")
    @indicator = $("#network-indicator")
    @terminal.append(@terminal_list)

    # set the marker
    @last_from = 0

    # Setup the jsonp handler
    window.logjam_handler = _.bind(@handleLogResponse, this)

    @findStartingPositions()

  findStartingPositions: ->
    $.ajax "http://#{@options.elasticsearch_address}/logjam-#{moment().format('YYYY.MM')}/_stats",
      dataType: 'jsonp'
      jsonp: 'callback'
      success: _.bind(@handleStartingPositions, this)
    return

  handleStartingPositions: (data) ->
    @last_from = data._all.primaries.docs.count
    @pollLogLines()
    return


  pollLogLines: ->
    @indicator.show()
    $.ajax "http://#{@options.elasticsearch_address}/logjam-#{moment().format('YYYY.MM')}/_search",
      data: 
        sort: "@timestamp:asc"
        size: @options.batch_size
        from: @last_from
      dataType: 'jsonp'
      jsonp: 'callback'
      jsonpCallback: 'logjam_handler'
      # success: _.bind(@handleLogResponse, this)
      # complete: _.bind(@logResponseComplete, this)
    return

  handleLogResponse: (data) ->
    @indicator.hide()
    @last_from = @last_from + data.hits.hits.length

    isAtBottom = @isScrolledToBottom()

    for hit in data.hits.hits
      @terminal_list.append HandlebarsTemplates.log_line
        pretty_time: moment(hit._source['@timestamp']).format("MMM D HH:mm:ss")
        datetime: hit._source['@timestamp']
        system: hit._source.tag
        message: hit._source.message

    # Only scroll to the bottom if they were *at* the bottom of the page
    @tailScroll() if isAtBottom

    window.setTimeout _.bind(@pollLogLines, this), @options.refresh_logs
    return

  isScrolledToBottom: ->
    height = @terminal.get(0).scrollHeight
    scrollTop = @terminal.get(0).scrollTop
    outerHeight = @terminal.outerHeight()
    return (height - scrollTop) == outerHeight

  tailScroll: ->
    height = @terminal.get(0).scrollHeight
    @terminal.animate({scrollTop: height}, 100)
    return

  logResponseComplete: ->
    # window.setTimeout(_.bind(@pollLogLines, this), 5000)
    return



window.LogView = LogView