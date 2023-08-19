defmodule BibleEx.RefParser do
  @moduledoc """
  Parses any general string for Bible references.
  """
  alias BibleEx.BibleData
  alias BibleEx.Reference

  @doc ~S"""
  use the parse_references() function to retrieve all the Bible references found in a string.

  ## Examples
      iex> alias BibleEx.RefParser
      iex> RefParser.parse_references("John 3:16")

      [
        %BibleEx.Reference{
          book: "John",
          book_names: %{abbr: "JOH", name: "John", osis: "John", short: "Jn"},
          book_number: 43,
          reference: "John 3:16",
          reference_type: :verse,
          ...
        }
      ]

      iex> RefParser.parse_references("I hope Matt 2:4 and James 5:1-5 get parsed")

      [
        %BibleEx.Reference{
          book: "Matthew",
          book_names: %{abbr: "MAT", name: "Matthew", osis: "Matt", short: "Mt"},
          book_number: 40,
          reference: "Matthew 2:4",
          reference_type: :verse,
          ...
        },
        %BibleEx.Reference{
          book: "James",
          book_names: %{abbr: "JAM", name: "James", osis: "Jas", short: "Jas"},
          book_number: 59,
          reference: "James 5:1-5",
          reference_type: :verse_range,
          ...
        }
      ]

      iex> RefParser.parse_references("This sentence contains two references. One that spans chapters, John 3:16-4:3, found in the book of John, and another one in the same book.")

      [
        %BibleEx.Reference{
          book: "John",
          book_names: %{abbr: "JOH", name: "John", osis: "John", short: "Jn"},
          book_number: 43,
          reference: "John 3:16 - 4:3",
          reference_type: :chapter_range,
          ...
        },
        %BibleEx.Reference{
          book: "John",
          book_names: %{abbr: "JOH", name: "John", osis: "John", short: "Jn"},
          book_number: 43,
          reference: "John",
          reference_type: :chapter_range,
          ...
        }
      ]
  """

  def parse_references(string) when is_binary(string) do
    books_matched =
      Regex.scan(full_regex(), string)
      |> Enum.map(fn x ->
        x
      end)

    Enum.map(books_matched, fn x ->
      cond do
        # book name only i.e. ["genesis ", "genesis"]
        length(x) == 2 and String.trim(Enum.at(x, 0)) == Enum.at(x, 1) ->
          Reference.new(book: String.trim(Enum.at(x, 0)))

        # book with chapter only i.e. ["Judges 19", "Judges", "19"]
        length(x) == 3 ->
          Reference.new(
            book: String.trim(Enum.at(x, 1)),
            start_chapter: String.to_integer(Enum.at(x, 2)),
            start_verse: nil,
            end_chapter: nil,
            end_verse: nil
          )

        # book with chapter and verse i.e. ["Jn 3:16", "Jn", "3", "16"]
        # also covers chapter-only edge case where user enters `James 1 - 2` i.e. ["James 1 - 2", "James", "1", "2"]

        # NOTE: in elixir `James 1 - 2` generates ["james 1 - 2", "james", "1", "", "2"]

        length(x) == 4 ->
          # book with chapter and verse i.e. ["Jn 3:16", "Jn", "3", "16"]
          Reference.new(
            book: String.trim(Enum.at(x, 1)),
            start_chapter: String.to_integer(Enum.at(x, 2)),
            start_verse: String.to_integer(Enum.at(x, 3)),
            end_chapter: nil,
            end_verse: nil
          )

        # John 4:5-10
        # iOS     ["John 4:5-10", "John", "4", "5", "10"]
        # elixir  ["John 4:5-10", "John", "4", "5", "10"]

        length(x) == 5 ->
          ref = String.trim(Enum.at(x, 0))
          # chapter-only reference -- also covers `em-dash` case
          # # NOTE: in elixir `James 1 - 2` generates ["james 1 - 2", "james", "1", "", "2"]

          cond do
            String.contains?(ref, ":") ->
              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: String.to_integer(Enum.at(x, 3)),
                end_chapter: nil,
                end_verse: String.to_integer(Enum.at(x, 4))
              )

            String.contains?(ref, ".") ->
              # ["James 1.2 -  2", "James", "1", "2", "2"]

              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: String.to_integer(Enum.at(x, 3)),
                end_chapter: nil,
                end_verse: nil
              )

            String.contains?(ref, "-") or String.contains?(ref, "—") ->
              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: nil,
                end_chapter: String.to_integer(Enum.at(x, 4)),
                end_verse: nil
              )

            true ->
              # should never get here?

              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: String.to_integer(Enum.at(x, 3)),
                end_chapter: nil,
                end_verse: String.to_integer(Enum.at(x, 4))
              )
          end

        length(x) == 6 ->
          # A reference that spans multiple chapters. i.e. ["John 3:16-4:3", "John", "3", "16", "4", "3"]

          Reference.new(
            book: String.trim(Enum.at(x, 1)),
            start_chapter: String.to_integer(Enum.at(x, 2)),
            start_verse: String.to_integer(Enum.at(x, 3)),
            end_chapter: String.to_integer(Enum.at(x, 4)),
            end_verse: String.to_integer(Enum.at(x, 5))
          )

        true ->
          nil
      end
    end)
  end

  defp full_regex() do
    all_book_names =
      Enum.map(BibleData.book_names(), fn x ->
        x
      end)
      |> List.flatten()

    variants = Map.keys(BibleData.variants())

    all_searchable = all_book_names ++ variants

    reg_books = Enum.join(all_searchable, "\\b|\\b")

    {:ok, regex} =
      Regex.compile("(\\b#{reg_books}\\b) *(\\d+)?[ :.]*(\\d+)?[— -]*(\\d+)?[ :.]*(\\d+)?", [
        :caseless
      ])

    regex
  end
end
