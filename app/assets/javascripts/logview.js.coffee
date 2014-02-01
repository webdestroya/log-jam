

class LogView



  constructor: (@options={}) ->
    @terminal = $("div.log-terminal")
    @terminal_list = $("<ul class='list-unstyled'></ul>")
    @indicator = $("#network-indicator")
    @facets_div = $("#facets")
    @terminal.append(@terminal_list)

    @log_message = $("div.log-info-message")

    # Store which systems to filter to
    @system_filter = []

    @search_input = $("#search")

    @search_input.keydown _.bind(@searchKeyDown, this)
    @query_filter = ""

    # set the marker
    @last_from = 0
    @start_from = 0
    @logs_loaded = false

    $("a[data-log-action='tail']").click _.bind(@clickTailAction, this)

    @getSystemsList()

  searchKeyDown: (event) ->
    if event.keyCode == 13
      @filterLogs()
    return

  filterLogs: ->
    @query_filter = @search_input.val()

    @last_from = @start_from
    @terminal_list.html ""

    return

  filterSystems: ->
    sys_list = @facets_div.find("span.selected a.filter-system")

    @system_filter = []

    if sys_list.length == 0
      @terminal_list.find('li').show()
      return

    @terminal_list.find('li').hide()

    for elm in @facets_div.find("span.selected a.filter-system")
      sys = $(elm).data('system')
      @system_filter.push sys
      @terminal_list.find("li[data-system='#{sys}']").show()
    return

  # findStartingPositions: ->
  #   $.ajax "/stats/systems.json",
  #     success: _.bind(@handleStartingPositions, this)
  #     error: _.bind(@handleInitError, this)
  #   return

  handleInitError: (data) ->
    if data.status == 404
      @log_message.text("No log lines have been added yet!")
    else
      @log_message.text("There was a problem with Elasticsearch")
    @log_message.show()

    window.setTimeout _.bind(@getSystemsList, this), 5000

    return

  handleStartingPositions: (data) ->
    return if @logs_loaded

    @log_message.hide()
    @logs_loaded = true

    # @last_from = Math.max(data._all.primaries.docs.count - @options.batch_size, 0)
    @last_from = Math.max(data.total_lines - @options.batch_size, 0)
    @start_from = @last_from
    @pollLogLines()
    
    return

  getSystemsList: ->
    $.ajax "/stats/systems.json",
      success: _.bind(@processSystemsResponse, this)
      error: _.bind(@handleInitError, this)
    return

  processSystemsResponse: (data) ->

    @handleStartingPositions(data)

    @facets_div.html HandlebarsTemplates.facets(data)
    @facets_div.find('a').click _.bind(@clickSystemFilter, this)

    if @system_filter.length > 0
      for sys in @system_filter
        @facets_div.find("span[data-system='#{sys}']").addClass("selected")

    window.setTimeout _.bind(@getSystemsList, this), 15000

    return

  clickSystemFilter: (event) ->
    event.preventDefault()

    $(event.target).parent().toggleClass "selected"

    @filterSystems()

    return


  pollLogLines: ->
    @indicator.show()

    $.ajax "/poll.json",
      data:
        size: @options.batch_size
        from: @last_from
        q: @query_filter
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
        filtered: !@isSystemAllowed(hit.fields.tag)

      # if !@isSystemAllowed(hit.fields.tag)
      #   console.log("Filtered: #{hit.fields.tag}")

    # Only scroll to the bottom if they were *at* the bottom of the page
    @tailScroll() if isAtBottom

    window.setTimeout _.bind(@pollLogLines, this), @options.refresh_logs
    return

  isSystemAllowed: (system) ->
    return @system_filter.length == 0 || @system_filter.indexOf(system) != -1

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



window.LogView = LogView