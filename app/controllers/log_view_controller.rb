class LogViewController < ApplicationController
  def index

    @settings = {
      elasticsearch_address: "#{SETTINGS['elasticsearch']['host']}:#{SETTINGS['elasticsearch']['port']}",
      refresh_logs: SETTINGS['refresh_logs'].to_i,
      batch_size: SETTINGS['batch_size'].to_i
    }

    render layout: 'base'
  end

  def facets
    response = es_client.search index: "logjam-#{Time.zone.now.strftime("%Y.%m")}", body: {
      facets: { tag: { terms: { field: "tag"} } }
    }

    render json: response
  end

  private

  def es_client
    @es_client ||= Elasticsearch::Client.new log: false
  end
end
