class LiveController < WebsocketRails::BaseController
  def test_connect
    puts "connected"
  end

  def test_disconnect
    puts "disconnected"
  end
end
