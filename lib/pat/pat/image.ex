defmodule Pat.Image do
  @type row() :: String.t()

  @spec from_pixels(Pixels.t()) :: Pat.t()
  def from_pixels(pixels) do
    rows = pixel_data_to_pattern_string(pixels.data, <<>>)
    %Pat{data: to_string(rows), w: pixels.width, h: pixels.height}
  end

  defp pixel_data_to_pattern_string(
         <<r::size(8), _g::size(8), _b::size(8), _a::size(8), rest::binary>>,
         acc
       ) do
    case r > 0 do
      true -> pixel_data_to_pattern_string(rest, <<acc::binary, ?0>>)
      false -> pixel_data_to_pattern_string(rest, <<acc::binary, ?1>>)
    end
  end

  defp pixel_data_to_pattern_string(<<>>, acc) do
    acc
  end
end
