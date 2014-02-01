class LogStatsController < ApplicationController
  def systems
    response = es_client.search index: es_index, body: {
      facets: { tag: { terms: { field: "tag"} } }
    }

    stats_resp = es_client.indices.stats index: es_index

    resp = {
      facets: response['facets']['tag']['terms'],
      total_lines: stats_resp['_all']['primaries']['docs']['count'],
      #other: stats_resp
    }
    render json: resp
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    render json: {status: 404}, status: 404
  end

  def stats
  end

  def clear_index
    es_client.indices.delete index: es_index
    render json: {status: 'ok'}
  end
end
