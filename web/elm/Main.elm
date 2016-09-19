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
import String exposing (..)


----- ## Model


type alias Model =
    { newMessage : String
    , messages : List ChatMessage
    , socket : Phoenix.Socket.Socket Msg
    , username : String
    }


type alias ChatMessage =
    { username : String
    , body : String
    }


initModel : Model
initModel =
    { newMessage = ""
    , messages = []
    , socket = initSocket
    , username = "Anonymous"
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
    | SetUsername String



---- ## Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetUsername name ->
            { model | username = name } ! []

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
                    JE.object [ ( "body", JE.string model.newMessage ), ( "user", JE.string (setDefaultUsername <| String.trim model.username) ) ]

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


chatMessageDecoder : JD.Decoder ChatMessage
chatMessageDecoder =
    JD.object2 ChatMessage
        (JD.oneOf
            [ ("user" := JD.string)
            , JD.succeed "anonymous"
            ]
        )
        ("body" := JD.string)


setDefaultUsername : String -> String
setDefaultUsername name =
    if String.isEmpty name then
        "Anonymous"
    else
        name



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
        [ label [ class "chat-label" ] [ text "User Name:" ]
        , input [ type' "text", class "chat-username", id "chat-username", value model.username, onInput SetUsername ] []
        , div [ type' "text", class "chat-window", id "messages" ] (viewMessages model)
        , form [ onSubmit SendMessage ]
            [ input [ type' "text", class "chat-input", id "chat-input", placeholder "New Message", onInput SetNewMessage, value model.newMessage ] []
            ]
        ]


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.Extra.message JoinChannel )


viewMessages : Model -> List (Html msg)
viewMessages model =
    List.map viewMessage (List.reverse model.messages)


viewMessage : ChatMessage -> Html msg
viewMessage chatMessage =
    div [] [ text (chatMessage.username ++ ": " ++ chatMessage.body) ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.socket PhoenixMsg
