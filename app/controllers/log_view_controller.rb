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

    if params[:q].present? && params[:q].size > 0
      query[:query] = {
        query_string: {
          default_field: "message",
          query: params[:q]
        }
      }
    end

    if params[:system].present?
      query[:post_filter] = {
        term: { 
          tag: params[:system] 
        }
      }
    end

    response = es_client.search index: es_index, body: query

    render json: response

  end

end
