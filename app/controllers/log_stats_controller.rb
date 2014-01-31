class LogStatsController < ApplicationController
  def systems
    response = es_client.search index: "logjam-#{Time.zone.now.strftime("%Y.%m")}", body: {
      facets: { tag: { terms: { field: "tag"} } }
    }

    resp = {
      facets: response['facets']['tag']['terms']
    }
    render json: resp
  end

  def stats
  end
end
