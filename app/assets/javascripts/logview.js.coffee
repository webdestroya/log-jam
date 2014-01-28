

class LogView



  constructor: ->
    @terminal = $("div.log-terminal")
    @terminal_list = $("<ul class='list-unstyled'></ul>")
    @indicator = $("#network-indicator")
    @terminal.append(@terminal_list)
    @last_from = 0
    # Setup the jsonp handler
    window.logjam_handler = _.bind(@handleLogResponse, this)

    @findStartingPositions()

  findStartingPositions: ->
    $.ajax "http://localhost:9200/logjam-#{moment().format('YYYY.MM')}/_stats",
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
    $.ajax "http://localhost:9200/logjam-#{moment().format('YYYY.MM')}/_search",
      data: 
        sort: "@timestamp:asc"
        size: 100
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
      time = moment(hit._source['@timestamp']).format("MMM D HH:mm:ss")
      message = $("<span>").text(hit._source.message).html()
      @terminal_list.append("<li><time datetime=\"#{hit._source['@timestamp']}\">#{time}</time><span class='system'>#{hit._source.tag}</span><span class='message'>#{message}</span></li>")

    @tailScroll() if isAtBottom
    window.setTimeout(_.bind(@pollLogLines, this), 5000)
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