module Main exposing (..)

import Cmd.Extra
import Html exposing (..)
import Html.Attributes exposing (class, id, type', placeholder, value)
import Html.App as App
import Html.Events exposing (onInput, onSubmit)
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))
import Phoenix.Socket
import Phoenix.Push
import Phoenix.Channel


----- ## Model


type alias Model =
    { newMessage : String
    , messages : List String
    , socket : Phoenix.Socket.Socket Msg
    }


initModel : Model
initModel =
    { newMessage = ""
    , messages = []
    , socket = initSocket
    }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "new_msg" "room:lobby" ReceiveChatMessage


type Msg
    = JoinChannel
    | SetNewMessage String
    | SendMessage
    | ReceiveChatMessage JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)



---- ## Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        JoinChannel ->
            let
                channel =
                    Phoenix.Channel.init "room:lobby"

                ( socket, command ) =
                    Phoenix.Socket.join channel model.socket
            in
                ( { model | socket = socket }, Cmd.map PhoenixMsg command )

        SetNewMessage string ->
            { model | newMessage = string } ! []

        ReceiveChatMessage json ->
            case JD.decodeValue chatMessageDecoder json of
                Ok decoded ->
                    { model | messages = decoded :: model.messages } ! []

                Err error ->
                    model ! []

        SendMessage ->
            let
                payload =
                    JE.object [ ( "body", JE.string model.newMessage ) ]

                push' =
                    Phoenix.Push.init "new_msg" "room:lobby"
                        |> Phoenix.Push.withPayload payload

                ( socket, command ) =
                    Phoenix.Socket.push push' model.socket
            in
                ( { model | newMessage = "", socket = socket }, Cmd.map PhoenixMsg command )

        PhoenixMsg msg ->
            let
                ( socket, command ) =
                    Phoenix.Socket.update msg model.socket
            in
                ( { model | socket = socket }, Cmd.map PhoenixMsg command )


chatMessageDecoder : JD.Decoder String
chatMessageDecoder =
    "body" := JD.string



-----## View


main : Program Never
main =
    App.program
        { init = init
        , subscriptions = subscriptions
        , view = view
        , update = update
        }


view : Model -> Html Msg
view model =
    div []
        [ div [ type' "text", class "chat-window", id "messages" ]
            (List.map viewMessages (List.reverse model.messages))
        , form [ onSubmit SendMessage ]
            [ input [ type' "text", class "chat-input", id "chat-input", placeholder "New Message", onInput SetNewMessage, value model.newMessage ] []
            ]
        ]


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.Extra.message JoinChannel )


viewMessages : String -> Html msg
viewMessages msg =
    div [] [ text msg ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.socket PhoenixMsg
