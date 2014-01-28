class LogViewController < ApplicationController
  def index

    @settings = {
      elasticsearch_address: "#{SETTINGS['elasticsearch']['host']}:#{SETTINGS['elasticsearch']['port']}",
      refresh_logs: SETTINGS['refresh_logs'].to_i,
      batch_size: SETTINGS['batch_size'].to_i
    }

    render layout: 'base'
  end
end
