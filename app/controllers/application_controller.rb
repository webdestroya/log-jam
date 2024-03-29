class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def es_client
    @es_client ||= Elasticsearch::Client.new log: false, hosts: "#{SETTINGS['elasticsearch']['host']}:#{SETTINGS['elasticsearch']['port']}"
  end

  def es_index
    @es_index ||= Time.zone.now.utc.strftime SETTINGS['elasticsearch']['index_format']
  end

end
