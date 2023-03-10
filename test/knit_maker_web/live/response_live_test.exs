defmodule KnitMakerWeb.ResponseLiveTest do
  use KnitMakerWeb.ConnCase

  import Phoenix.LiveViewTest
  import KnitMaker.ParticipantsFixtures

  @create_attrs %{json: %{}, participant_id: "some participant_id", text: "some text", value: 42}
  @update_attrs %{json: %{}, participant_id: "some updated participant_id", text: "some updated text", value: 43}
  @invalid_attrs %{json: nil, participant_id: nil, text: nil, value: nil}

  defp create_response(_) do
    response = response_fixture()
    %{response: response}
  end

  describe "Index" do
    setup [:create_response]

    test "lists all responses", %{conn: conn, response: response} do
      {:ok, _index_live, html} = live(conn, ~p"/responses")

      assert html =~ "Listing Responses"
      assert html =~ response.participant_id
    end

    test "saves new response", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/responses")

      assert index_live |> element("a", "New Response") |> render_click() =~
               "New Response"

      assert_patch(index_live, ~p"/responses/new")

      assert index_live
             |> form("#response-form", response: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#response-form", response: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/responses")

      html = render(index_live)
      assert html =~ "Response created successfully"
      assert html =~ "some participant_id"
    end

    test "updates response in listing", %{conn: conn, response: response} do
      {:ok, index_live, _html} = live(conn, ~p"/responses")

      assert index_live |> element("#responses-#{response.id} a", "Edit") |> render_click() =~
               "Edit Response"

      assert_patch(index_live, ~p"/responses/#{response}/edit")

      assert index_live
             |> form("#response-form", response: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#response-form", response: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/responses")

      html = render(index_live)
      assert html =~ "Response updated successfully"
      assert html =~ "some updated participant_id"
    end

    test "deletes response in listing", %{conn: conn, response: response} do
      {:ok, index_live, _html} = live(conn, ~p"/responses")

      assert index_live |> element("#responses-#{response.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#responses-#{response.id}")
    end
  end

  describe "Show" do
    setup [:create_response]

    test "displays response", %{conn: conn, response: response} do
      {:ok, _show_live, html} = live(conn, ~p"/responses/#{response}")

      assert html =~ "Show Response"
      assert html =~ response.participant_id
    end

    test "updates response within modal", %{conn: conn, response: response} do
      {:ok, show_live, _html} = live(conn, ~p"/responses/#{response}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Response"

      assert_patch(show_live, ~p"/responses/#{response}/show/edit")

      assert show_live
             |> form("#response-form", response: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#response-form", response: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/responses/#{response}")

      html = render(show_live)
      assert html =~ "Response updated successfully"
      assert html =~ "some updated participant_id"
    end
  end
end
