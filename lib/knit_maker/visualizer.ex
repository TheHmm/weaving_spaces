defmodule KnitMaker.Visualizer do
  import Pat

  alias KnitMaker.Participants
  alias KnitMaker.Events

  @final_width 60

  @online_pattern from_string("10\n10\n10\n10")
  @onsite_pattern from_string("1111111111\n0000000000")

  def render(event_id) do
    event = Events.get_event!(event_id)

    # for padding
    width = @final_width - 0

    # between patterns
    sep = new(width, 1)
    sep2 = sep |> border_top(from_string("10"))

    question_lookup = Map.new(event.questions, &{&1.name, &1})
    responses = Participants.grouped_responses_by_event(event_id)

    {event_date, event_title} = event_data(event, width)

    concat_v([
      stripes_count_h(width, responses["online"][0] || 0, @online_pattern),
      sep,
      event_title,
      sep,
      abstract_answer(responses["connected"], width),
      sep,
      sep2,
      sep,
      emotion_image(responses["emotion"], width),
      sep,
      sep2,
      sep,
      pixels(question_lookup["pixels"], width),
      sep,
      sep2,
      sep,
      event_date,
      sep,
      stripes_count_v(width, responses["online"][1] || 0, @onsite_pattern)
    ])
  end

  defp pixels(question, width) do
    Participants.get_pixels(question)
    |> double()
    |> fit(width, nil, bg: "0")
  end

  defp emotion_image(nil, width), do: new(width, 1, "0")

  defp emotion_image(response, width) do
    emotion = response |> max_answer() || 0
    from_file("knit_images/emotion#{emotion}.png") |> fit(width, nil, bg: "0")
  end

  defp stripes_count_h(width, count, pat) do
    per_row = div(width, pat.w)

    full_row = repeat_h(pat, per_row) |> fit(width, pat.h, bg: "0", pos: :left)
    full_rows = count |> div(per_row)

    full_rows =
      if full_rows > 0 do
        1..full_rows |> Enum.map(fn _ -> full_row end)
      else
        []
      end

    last_row_count = rem(count, per_row)
    last_row = repeat_h(pat, last_row_count) |> fit(width, pat.h, pos: :left, bg: "0")

    #    new(width, rows * pat.h)
    (full_rows ++ [last_row])
    |> Enum.with_index()
    |> Enum.map(fn {pat, i} ->
      if rem(i, 2) == 1 do
        pat |> pad_left(1, "0") |> fit(width, pat.h, pos: :left, bg: "0")
      else
        pat
      end
    end)
    |> concat_v()
  end

  defp stripes_count_v(width, count, pat) do
    per_row = div(width, pat.w)

    full_row = invert_repeat(pat, per_row) |> concat_h() |> fit(width, pat.h, bg: "0", pos: :left)
    full_rows = count |> div(per_row)

    full_rows =
      if full_rows > 0 do
        1..full_rows |> Enum.map(fn _ -> full_row end)
      else
        []
      end

    last_row_count = rem(count, per_row)

    last_row =
      invert_repeat(pat, last_row_count) |> concat_h() |> fit(width, pat.h, pos: :left, bg: "0")

    #    new(width, rows * pat.h)
    (full_rows ++ [last_row])
    |> concat_v()
  end

  defp invert_repeat(pat, count) do
    for i <- 1..count do
      if rem(i, 2) == 0 do
        pat
      else
        invert(pat)
      end
    end
  end

  defp max_answer(lookup) do
    Enum.sort_by(lookup, &elem(&1, 1))
    |> List.last()
    |> then(&elem(&1, 0))
  end

  defp event_data(event, width) do
    title =
      new_text(event.name, font: :knit)
      |> fit(width, nil, bg: "0")

    date =
      new_text(event.description, font: :knit)
      |> fit(width, nil, bg: "0")

    {date, title}
  end

  defp abstract_answer(nil, width), do: new(width, 1, "0")

  defp abstract_answer(lookup, width) do
    IO.inspect(lookup, label: "lookup")

    Enum.sort_by(lookup, &elem(&1, 1))
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {{answer, _value}, size} ->
      answer_file = "knit_images/a#{answer}s#{size}.png"
      IO.inspect(answer_file, label: "answer_file")

      from_file(answer_file)
    end)
    |> concat_v()
    |> fit(width, nil, bg: "0")
  end

  defp answer_texts(nil, width), do: new(width, 1, "0")

  defp answer_texts(lookup, width) do
    IO.inspect(lookup, label: "lookup")

    Enum.sort_by(lookup, &elem(&1, 1))
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {{answer, _value}, size} ->
      answer_file = "knit_images/a#{answer}s#{size}.png"
      IO.inspect(answer_file, label: "answer_file")

      from_file(answer_file)
    end)
    |> concat_v()
    |> fit(width, nil, bg: "0")
  end
end
