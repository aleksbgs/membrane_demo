defmodule RecordingDemo.Signaling.JSPeer do
  @moduledoc false

  use Membrane.WebRTC.Server.Peer
  alias Membrane.WebRTC.Server.Room
  alias RecordingDemo.{Recording, Signaling}
  require Logger

  @impl true
  def parse_request(_request) do
    room_name = UUID.uuid1()
    Logger.info("New client peer, room: #{room_name}")
    {:ok, _pid} = Room.start_supervised(%Room.Options{module: Signaling.Room, name: room_name})
    {:ok, %{}, %{room_name: room_name}, room_name}
  end

  @impl true
  def on_init(_context, auth_data, _options) do
    {:ok, %{room_name: auth_data.metadata.room_name}}
  end

  @impl true
  def on_receive(%{event: "record"}, _context, state) do
    {:ok, _pid} = Recording.Pipeline.start_link(%{room: state.room_name})
    {:ok, state}
  end

  @impl true
  def on_receive(message, context, state) do
    super(message, context, state)
  end

  @impl true
  def on_terminate(_context, state) do
    Logger.info("Terminating client peer, room: #{state.room_name}")
  end
end
