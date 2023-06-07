defmodule KnitMaker.EventsTest do
  use KnitMaker.DataCase

  alias KnitMaker.Events
  alias KnitMaker.Repo

  describe "events" do
    alias KnitMaker.Events.Event

    import KnitMaker.EventsFixtures

    @invalid_attrs %{description: nil, image_url: nil, name: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      %{id: id} = event = event_fixture()
      assert %Event{id: ^id} = Events.get_event!(event.id)
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{
        slug: "some-slug",
        description: "some description",
        image_url: "some image_url",
        name: "some name"
      }

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.description == "some description"
      assert event.image_url == "some image_url"
      assert event.name == "some name"
    end

    test "create_event/1 with question assocs" do
      valid_attrs = %{
        slug: "a",
        name: "a",
        questions: [
          %{
            rank: 1,
            q_config: %{"a" => 1},
            title: "x",
            type: "choices",
            name: "x"
          }
        ]
      }

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      event = Repo.preload(event, :questions)

      assert [%{q_config: %{"a" => 1}}] = event.questions

      assert %{name: "a", questions: [_]} = Event.raw(event)
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()

      update_attrs = %{
        description: "some updated description",
        image_url: "some updated image_url",
        name: "some updated name"
      }

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.description == "some updated description"
      assert event.image_url == "some updated image_url"
      assert event.name == "some updated name"
    end

    test "update_event/2 with invalid data returns error changeset" do
      %{id: id} = event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert %Event{id: ^id} = Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end

  describe "questions" do
    alias KnitMaker.Events.Question

    import KnitMaker.EventsFixtures

    @invalid_attrs %{code: nil, q_config: nil, description: nil, rank: nil, title: nil, type: nil}

    test "list_questions returns all questions" do
      event = event_fixture()

      question1 = question_fixture(event)
      question2 = question_fixture(event)
      assert Events.list_questions(event) == [question1, question2]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Events.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      valid_attrs = %{
        name: "some_code",
        code: "some code",
        q_config: %{},
        v_config: %{"a" => 1},
        description: "some description",
        rank: 42,
        title: "some title",
        q_type: "choices"
      }

      event = event_fixture()
      assert {:ok, %Question{} = question} = Events.create_question_for_event(event, valid_attrs)

      assert question.event_id == event.id
      assert question.code == "some code"
      assert question.q_config == %{}
      assert question.v_config == %{"a" => 1}
      assert question.description == "some description"
      assert question.rank == 42
      assert question.title == "some title"
      assert question.q_type == "choices"
      assert question.v_type == "patterns-1"
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Events.create_question_for_event(event_fixture(), @invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()

      update_attrs = %{
        name: "updated_name",
        code: "some updated code",
        config: %{},
        description: "some updated description",
        rank: 43,
        title: "some updated title",
        type: "choices"
      }

      assert {:ok, %Question{} = question} = Events.update_question(question, update_attrs)
      assert question.code == "some updated code"
      assert question.q_config == %{}
      assert question.description == "some updated description"
      assert question.rank == 43
      assert question.title == "some updated title"
      assert question.q_type == "choices"
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_question(question, @invalid_attrs)
      assert question == Events.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Events.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Events.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Events.change_question(question)
    end
  end
end
