defmodule KnitMaker.Visualizer do
  import Pat

  alias KnitMaker.Participants
  alias KnitMaker.Events.Event

  @top_pattern from_string("10\n10\n10\n10")
  @bottom_pattern from_string("1111111111\n0000000000")

  def render(%Event{} = event, participant_id) do
    event = KnitMaker.Repo.preload(event, :questions)
    # for padding
    width = event.knitting_width

    # between patterns
    sep = from_string("00\n01\n10\n00") |> repeat_h(ceil(width / 2)) |> fit(width, nil)

    responses = Participants.grouped_responses_by_event(event.id, participant_id)

    {event_date, event_title} = event_data(event, width)

    {border_questions, other_questions} =
      event.questions |> Enum.split_with(&(&1.v_type == "border-count"))

    border_tops =
      border_questions
      |> Enum.map(fn q ->
        [
          stripes_count_h(
            width,
            responses[q.id][0] || 0,
            safe_pattern(q.v_config["top_pattern"]) || @top_pattern
          ),
          sep
        ]
      end)

    border_bottoms =
      border_questions
      |> Enum.map(fn q ->
        [
          sep,
          stripes_count_v(
            width,
            responses[q.id][1] || 0,
            safe_pattern(q.v_config["bottom_pattern"]) || @bottom_pattern
          )
        ]
      end)
      |> Enum.reverse()

    other_questions =
      other_questions
      |> Enum.map(fn q ->
        case q.v_type do
          "emoji" -> emoji(responses[q.id], width)
          "patterns-all" -> patterns_all(responses[q.id], width)
          "pixel" -> pixel(q, participant_id, width)
          "gridfill" -> gridfill(responses[q.id], width, 24)
          "gridfill-double" -> gridfill(responses[q.id], div(width, 2), 12) |> double()
          "textbars" -> textbars(q, responses[q.id], width, false)
          "textbar" -> textbars(q, responses[q.id], width, true)
          _ -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.intersperse(sep)

    concat_v(
      [
        border_tops,
        event_title,
        sep,
        other_questions,
        sep,
        event_date,
        border_bottoms
      ]
      |> List.flatten()
    )
  end

  defp pixel(question, participant_id, width) do
    Participants.get_pixels(question, participant_id)
    |> double()
    |> fit(width, nil, bg: "0")
  end

  defp emoji(nil, width), do: new(width, 1, "0")

  defp emoji(response, width) do
    emotion = response |> max_answer() || 0
    from_file("knit_images/emotion#{emotion}.png") |> fit(width, nil, bg: "0")
  end

  defp gridfill(nil, width, _), do: new(width, 1, "0")

  defp gridfill(response, width, height) do
    total = Map.values(response) |> Enum.sum()

    base_pattern = from_string("10\n01")

    pats =
      Map.values(response)
      |> Enum.map(fn v ->
        ceil(v / total * width)
      end)
      |> Enum.with_index()
      |> Enum.map(fn {w, idx} ->
        pat = base_pattern |> stretch_v(idx + 1)

        pat
        |> repeat_v(ceil(height / pat.h))
        |> repeat_h(ceil(w / pat.w))
        |> fit(w, height, pos: :top_left)
      end)

    concat_h(pats)
    |> fit(width, nil, bg: "0")
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
    title = new_text(event.name, font: :knit, width: width, bg: "0", align: :left)
    date = new_text(event.date, font: :knit, width: width, bg: "0", align: :left)

    {date, title}
  end

  defp patterns_all(nil, width), do: new(width, 1, "0")

  defp patterns_all(lookup, width) do
    Enum.sort_by(lookup, &elem(&1, 1))
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {{answer, _value}, size} ->
      answer_file = "knit_images/a#{answer}s#{size}.png"

      img = from_file(answer_file)

      img
      |> repeat_h(ceil(width / img.w))
      |> fit(width, nil, bg: "0")
    end)
    |> Enum.intersperse(new(width, 1, "0"))
    |> concat_v()
  end

  defp textbars(_q, nil, width, _only_first), do: new(width, 1, "0")

  defp textbars(q, responses, width, only_first) do
    total = Enum.reduce(responses, 0, fn {_, c}, acc -> c + acc end)

    texts =
      q.q_config["answers"]
      |> Enum.with_index()
      |> Enum.map(fn {answer_text, idx} ->
        percentage =
          case total > 0 do
            true -> (responses[idx] || 0) / total
            false -> 0
          end

        {answer_text, percentage}
      end)
      |> Enum.sort_by(&(-elem(&1, 1)))
      |> Enum.map(fn {answer_text, percentage} ->
        text =
          new_text(answer_text, font: :knit)
          |> fit(width, nil, bg: "0", pos: :left)

        if percentage > 0.0 do
          bar = new(width, ceil(percentage * text.h), "0")

          text |> overlay(bar, :bottom, :xor)
        else
          text
        end
      end)

    if only_first do
      List.first(texts)
    else
      texts
      |> Enum.intersperse(new(width, 1, "0"))
      |> concat_v()
    end
  end

  defp safe_pattern(input) do
    try do
      Pat.from_string(input)
    catch
      _, _ ->
        nil
    end
  end
end
