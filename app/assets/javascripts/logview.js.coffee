

class LogView



  constructor: (@options={}) ->
    @terminal = $("div.log-terminal")
    @terminal_list = $("<ul class='list-unstyled'></ul>")
    @indicator = $("#network-indicator")
    @facets_div = $("#facets")
    @terminal.append(@terminal_list)

    # set the marker
    @last_from = 0

    $("a[data-log-action='tail']").click _.bind(@clickTailAction, this)
    @getSystemsList()
    @findStartingPositions()

  findStartingPositions: ->
    $.ajax "http://#{@options.elasticsearch_address}/logjam-#{moment().format('YYYY.MM')}/_stats",
      dataType: 'jsonp'
      jsonp: 'callback'
      success: _.bind(@handleStartingPositions, this)
    return

  handleStartingPositions: (data) ->
    @last_from = Math.max(data._all.primaries.docs.count - @options.batch_size, 0)
    @pollLogLines()
    
    return

  getSystemsList: ->
    $.ajax "/stats/systems.json",
      success: _.bind(@processSystemsResponse, this)
    return

  processSystemsResponse: (data) ->
    # console.log(data.facets)
    @facets_div.html HandlebarsTemplates.facets(data)
    return


  pollLogLines: ->
    @indicator.show()

    $.ajax "/poll.json",
      data:
        size: @options.batch_size
        from: @last_from
      success: _.bind(@handleLogResponse, this)
    return

  handleLogResponse: (data) ->
    @indicator.hide()
    @last_from = @last_from + data.hits.hits.length

    isAtBottom = @isScrolledToBottom()

    for hit in data.hits.hits
      @terminal_list.append HandlebarsTemplates.log_line
        pretty_time: moment(hit.fields['@timestamp']).format("MMM D HH:mm:ss")
        datetime: hit.fields['@timestamp']
        system: hit.fields.tag
        message: hit.fields.message

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

  clickTailAction: (event) ->
    event.preventDefault()
    @tailScroll()
    return

  logResponseComplete: ->
    # window.setTimeout(_.bind(@pollLogLines, this), 5000)
    return



window.LogView = LogView