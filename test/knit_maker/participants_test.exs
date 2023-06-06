defmodule KnitMaker.ParticipantsTest do
  use KnitMaker.DataCase

  alias KnitMaker.Participants

  import KnitMaker.EventsFixtures

  describe "responses" do
    alias KnitMaker.Participants.Response

    import KnitMaker.ParticipantsFixtures

    @invalid_attrs %{json: nil, participant_id: nil, text: nil, value: nil}

    test "list_responses/0 returns all responses" do
      q = question_fixture()
      response = response_fixture(q)
      assert Participants.list_responses() == [response]
    end

    test "get_response!/1 returns the response with given id" do
      response = response_fixture(question_fixture())
      assert Participants.get_response!(response.id) == response
    end

    test "create_response/1 with valid data creates a response" do
      valid_attrs = %{
        json: %{},
        participant_id: "some participant_id",
        text: "some text",
        value: 42
      }

      question = question_fixture()

      assert {:ok, %Response{} = response} = Participants.create_response(question, valid_attrs)
      assert response.question_id == question.id
      assert response.json == %{}
      assert response.participant_id == "some participant_id"
      assert response.text == "some text"
      assert response.value == 42
    end

    test "create_response/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Participants.create_response(question_fixture(), @invalid_attrs)
    end

    test "update_response/2 with valid data updates the response" do
      response = response_fixture(question_fixture())

      update_attrs = %{
        json: %{},
        participant_id: "some updated participant_id",
        text: "some updated text",
        value: 43
      }

      assert {:ok, %Response{} = response} = Participants.update_response(response, update_attrs)
      assert response.json == %{}
      assert response.participant_id == "some updated participant_id"
      assert response.text == "some updated text"
      assert response.value == 43
    end

    test "update_response/2 with invalid data returns error changeset" do
      response = response_fixture(question_fixture())
      assert {:error, %Ecto.Changeset{}} = Participants.update_response(response, @invalid_attrs)
      assert response == Participants.get_response!(response.id)
    end

    test "delete_response/1 deletes the response" do
      response = response_fixture(question_fixture())
      assert {:ok, %Response{}} = Participants.delete_response(response)
      assert_raise Ecto.NoResultsError, fn -> Participants.get_response!(response.id) end
    end

    test "change_response/1 returns a response changeset" do
      response = response_fixture(question_fixture())
      assert %Ecto.Changeset{} = Participants.change_response(response)
    end

    test "response update" do
      question = question_fixture()

      a = %{
        "json" => %{
          "pixels" => [
            ["2023-05-21 21:45:30.001447Z", 0, 0, "1"]
          ]
        },
        "participant_id" => "a"
      }

      {:ok, _} = Participants.create_response(question, a)

      a2 = %{
        "json" => %{
          "pixels" => [
            ["2023-05-21 21:45:30.001447Z", 0, 0, "1"],
            ["2023-05-21 21:45:34.901371Z", 0, 1, "1"]
          ]
        },
        "participant_id" => "a"
      }

      {:ok, _} = Participants.create_response(question, a2)
    end

    test "get pixel data" do
      question = question_fixture()

      a = %{
        "json" => %{
          "pixels" => [
            ["2023-05-21 21:45:30.001447Z", 0, 0, "1"],
            ["2023-05-21 21:45:34.901371Z", 0, 1, "1"]
          ]
        },
        "participant_id" => "a"
      }

      {:ok, _} = Participants.create_response(question, a)

      assert %Pat{} = Participants.get_pixels(question.id, 10, 10)
    end

    test "event_stats" do
      event = event_fixture()
      question = question_fixture(event)

      {:ok, _} = Participants.create_response(question, %{participant_id: "a", value: 42})
      {:ok, _} = Participants.create_response(question, %{participant_id: "b", value: 42})
      {:ok, _} = Participants.create_response(question, %{participant_id: "c", value: 43})

      assert %{participant_count: 3} =
               Participants.get_event_stats(event.id) |> IO.inspect(label: "u")
    end

    test "grouped_responses_by_event" do
      event = event_fixture()
      question = question_fixture(event)

      {:ok, _} = Participants.create_response(question, %{participant_id: "a", value: 42})
      {:ok, _} = Participants.create_response(question, %{participant_id: "b", value: 42})
      {:ok, _} = Participants.create_response(question, %{participant_id: "c", value: 43})

      g = Participants.grouped_responses_by_event(event.id)

      assert %{"question" => %{42 => 2, 43 => 1}} = g
    end
  end
end
