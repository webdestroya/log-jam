class LogViewController < ApplicationController
  def index

    @settings = {
      elasticsearch_address: "#{SETTINGS['elasticsearch']['host']}:#{SETTINGS['elasticsearch']['port']}",
      refresh_logs: SETTINGS['refresh_logs'].to_i,
      batch_size: SETTINGS['batch_size'].to_i
    }

    render layout: 'base'
  end

  def poll
    batch_size = params[:size] || SETTINGS['batch_size']
    from = params[:from] || "0"

    query = {
      sort: [{"@timestamp" => {order: 'asc'}}],
      size: batch_size.to_i,
      from: from.to_i,
      fields: ['@timestamp', 'tag', 'message'],
      explain: false
    }

    response = es_client.search index: "logjam-#{Time.zone.now.strftime("%Y.%m")}", body: query

    render json: response

  end

end
