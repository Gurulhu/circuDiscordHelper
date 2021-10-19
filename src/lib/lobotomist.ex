defmodule Lobotomist.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def find_card(msg) do
    for card <- Regex.scan(~r/\[\[([\w\s]+?)\]\]/,msg.content) do
      #Regex.scan returns a list of tuples like: [ {"[[card]]", "card"} ], so we get only the last element of each tuple.
      card = List.last(card)

      {:ok, response} = Finch.build(:get, "https://api.scryfall.com/cards/named?fuzzy=#{String.replace(card," ", "+")}")
      |> Finch.request(LobotomistFinch)

      case response.status do
        200 ->
          with response <- Jason.decode!(response.body) do
            case Map.has_key?(response, "card_faces") do
              true ->
                for face <- Map.get(response, "card_faces") do
                  Map.get(face, "image_uris")
                  |> Map.get("large")
                  |> (&(Api.create_message(msg.channel_id,&1))).()
                end

              false ->
                Map.get(response, "image_uris")
                |> Map.get("large")
                |> (&(Api.create_message(msg.channel_id,&1))).()
              end
          end

        404 ->
          Api.create_message(msg.channel_id,"I got no info on \"#{card}\".")

        _ ->
          Api.create_message(msg.channel_id,"Something went horribly wrong.")

      end
    end
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    unless msg.author.id == Nostrum.Cache.Me.get().id do
      case msg.type do
        #DEFAULT MESSAGE
        0 ->
          case msg.content do

            "!primer" ->
              with {:ok, primer } <- Application.fetch_env(:lobotomist, :primer) do
                Api.create_message(msg.channel_id, primer)
              end

            _ ->
              find_card(msg)

          end

        #GUILD_MEMBER_JOIN
        7 ->
          with {:ok, greetings } <- Application.fetch_env(:lobotomist, :greetings) do
            Enum.random(greetings)
            |> String.replace("%s", msg.author.username)
            |> (&(Api.create_message(msg.channel_id,&1))).()
          end

        _ ->
          :noop
        end

      end
  end

  def handle_event({:MESSAGE_REACTION_ADD, msg, _ws_state}) do
    IO.inspect("MESSAGE_REACTION_ADD")
  end

  def handle_event(_event) do
    :noop
  end
end
