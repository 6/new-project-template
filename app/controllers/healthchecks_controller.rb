class HealthchecksController < ApplicationController
  def show
    response = {
      'message': 'Hola!',
      'database_time': database_time.iso8601,
      'server_time': server_time.iso8601,
    }
    render json: response
  end

  private

  def database_time
    Time.parse(ActiveRecord::Base.connection.execute('select now()').first['now'])
  end

  def server_time
    Time.now
  end
end
