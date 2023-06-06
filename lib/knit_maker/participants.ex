defmodule KnitMaker.Participants do
  @moduledoc """
  The Participants context.
  """

  import Ecto.Query, warn: false
  alias KnitMaker.Repo

  alias KnitMaker.Participants.Response
  alias KnitMaker.Events.Question

  @doc """
  Returns the list of responses.

  ## Examples

      iex> list_responses()
      [%Response{}, ...]

  """
  def list_responses do
    Repo.all(Response)
  end

  def list_responses_by_event_and_participant(event_id, participant_id) do
    from(r in Response,
      where:
        r.event_id == ^event_id and
          r.participant_id == ^participant_id,
      select: r
    )
    |> Repo.all()
  end

  def grouped_responses_by_event(event_id) do
    from(r in Response,
      join: q in assoc(r, :question),
      where: r.event_id == ^event_id,
      select: {q.name, r.value, count(r.id)},
      group_by: [q.name, r.value]
    )
    |> Repo.all()
    |> Enum.group_by(&elem(&1, 0))
    |> Map.new(fn {q, group} ->
      {q, group |> Map.new(fn {_q, k, v} -> {k, v} end)}
    end)
  end

  def get_event_stats(event_id) do
    from(r in Response,
      select: %{
        participant_count: count(fragment("distinct ?", r.participant_id)),
        answer_count: count(r.id)
      },
      where: r.event_id == ^event_id
    )
    |> Repo.one()
  end

  @doc """
  Gets a single response.

  Raises `Ecto.NoResultsError` if the Response does not exist.

  ## Examples

      iex> get_response!(123)
      %Response{}

      iex> get_response!(456)
      ** (Ecto.NoResultsError)

  """
  def get_response!(id), do: Repo.get!(Response, id)

  @doc """
  Creates a response.
  """
  def create_response(%Question{} = question, attrs \\ %{}, on_conflict \\ nil) do
    result =
      %Response{question_id: question.id, event_id: question.event_id}
      |> Response.changeset(attrs)
      |> Repo.insert()

    with {:error, %{errors: [participant_id: {_, [constraint: :unique, constraint_name: _]}]}} <-
           result do
      participant_id = attrs["participant_id"]

      [response] =
        from(r in Response,
          where:
            r.event_id == ^question.event_id and r.question_id == ^question.id and
              r.participant_id == ^participant_id
        )
        |> Repo.all()

      Repo.delete!(response)

      attrs =
        case on_conflict do
          nil -> attrs
          fun -> fun.(response, attrs)
        end

      create_response(question, attrs)
    end
  end

  @doc """
  Updates a response.

  ## Examples

      iex> update_response(response, %{field: new_value})
      {:ok, %Response{}}

      iex> update_response(response, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_response(%Response{} = response, attrs) do
    response
    |> Response.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a response.

  ## Examples

      iex> delete_response(response)
      {:ok, %Response{}}

      iex> delete_response(response)
      {:error, %Ecto.Changeset{}}

  """
  def delete_response(%Response{} = response) do
    Repo.delete(response)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking response changes.

  ## Examples

      iex> change_response(response)
      %Ecto.Changeset{data: %Response{}}

  """
  def change_response(%Response{} = response, attrs \\ %{}) do
    Response.changeset(response, attrs)
  end

  def get_pixels(%Question{} = q) do
    get_pixels(q.id, q.config["width"], q.config["height"])
  end

  def get_pixels(question_id, w, h) do
    pixels =
      from(r in Response,
        where: r.question_id == ^question_id,
        select: r.json["pixels"]
      )
      |> Repo.all()
      |> Enum.flat_map(&Jason.decode!/1)
      |> Enum.sort()
      |> Map.new(fn [_date, x, y, p] -> {{x, y}, p} end)

    Pat.new(w, h) |> Pat.mass_put_pixels(pixels)
  end
end
