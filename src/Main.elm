module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Keyed as Keyed



---- MODEL ----


type alias Model =
    { uid : Int
    , inputValue : String
    , editInputValue : String
    , taskList : List Task
    }


type alias Task =
    { id : Int
    , description : String
    , isCompleted : Bool
    , editing : Bool
    }


newTask : String -> Int -> Task
newTask desc id =
    { id = id
    , description = desc
    , isCompleted = False
    , editing = False
    }


emptyTask : Task
emptyTask =
    { id = 0
    , description = ""
    , isCompleted = False
    , editing = False
    }


init : ( Model, Cmd Msg )
init =
    ( { uid = 0
      , inputValue = ""
      , editInputValue = ""
      , taskList =
            []
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = UpdateInput String
    | AddTask Task
    | RemoveTask Int
    | EditTask Int
    | SaveTask Int
    | OnEditTask String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateInput value ->
            ( { model | inputValue = value }, Cmd.none )

        AddTask _ ->
            ( { model
                | uid = model.uid + 1
                , inputValue = ""
                , taskList =
                    if String.isEmpty model.inputValue then
                        model.taskList

                    else
                        model.taskList ++ [ newTask model.inputValue model.uid ]
              }
            , Cmd.none
            )

        RemoveTask id ->
            ( { model | taskList = List.filter (\t -> t.id /= id) model.taskList }, Cmd.none )

        EditTask id ->
            ( { model
                | taskList =
                    List.map
                        (\t ->
                            if t.id == id then
                                { t | editing = True }

                            else
                                t
                        )
                        model.taskList
                , editInputValue = .description (Maybe.withDefault emptyTask (List.head (List.filter (\t -> t.id == id) model.taskList)))
              }
            , Cmd.none
            )

        OnEditTask value ->
            ( { model | editInputValue = value }, Cmd.none )

        SaveTask id ->
            ( { model
                | taskList =
                    List.map
                        (\t ->
                            if t.id == id then
                                { t | editing = False, description = model.editInputValue }

                            else
                                t
                        )
                        model.taskList
              }
            , Cmd.none
            )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Welcome todo list app" ]
        , viewInput "text" "Add new task" model.inputValue UpdateInput
        , button [ onClick (AddTask (newTask model.inputValue 1)) ] [ text "Add" ]
        , taskListView model
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


taskListView : Model -> Html Msg
taskListView model =
    Keyed.ul [ class "todo-list" ] <|
        List.map (taskView model.editInputValue) model.taskList


taskView : String -> Task -> ( String, Html Msg )
taskView editInputValue task =
    ( String.fromInt task.id
    , if task.editing == True then
        li []
            [ input [ type_ "text", value editInputValue, onInput OnEditTask ] []
            , button [ onClick (SaveTask task.id) ] [ text "Save" ]
            , button [ onClick (RemoveTask task.id) ] [ text "Delete" ]
            ]

      else
        li []
            [ span [] [ text task.description ]
            , button [ onClick (EditTask task.id) ] [ text "Edit" ]
            , button [ onClick (RemoveTask task.id) ] [ text "Delete" ]
            ]
    )



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
