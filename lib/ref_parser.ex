defmodule BibleEx.RefParser do
  @moduledoc """
  Parses any general string for Bible references.
  """
  alias BibleEx.BibleData
  alias BibleEx.Reference

  def parse_references(string) when is_binary(string) do
    books_matched =
      Regex.scan(full_regex(), string)
      |> Enum.reject(fn [full, book | _] ->
        norm = String.downcase(String.trim(book))

        not (
          Map.has_key?(BibleData.books(), norm) or
          Map.has_key?(BibleData.osis_books(), norm) or
          Map.has_key?(BibleData.shortened_books(), norm) or
          Map.has_key?(BibleData.variants(), norm)
        )
      end)

    # If you want to be absolutely sure Joseph is gone:
    # IO.inspect(books_matched, label: "books_matched")

    Enum.map(books_matched, fn x ->
      cond do
        length(x) == 2 and String.trim(Enum.at(x, 0)) == Enum.at(x, 1) ->
        # Reference.new(book: String.trim(Enum.at(x, 0)))
        book_name = String.trim(Enum.at(x, 0))

        # let Reference.new resolve book_number via BibleData
        base = Reference.new(book: book_name)

        # if Reference.new produced book_number, you can fill defaults there;
        # otherwise, you can call a helper that uses BibleData.last_verse/0.
        base

        length(x) == 3 ->
          Reference.new(
            book: String.trim(Enum.at(x, 1)),
            start_chapter: String.to_integer(Enum.at(x, 2)),
            start_verse: nil,
            end_chapter: nil,
            end_verse: nil
          )

        length(x) == 4 ->
          Reference.new(
            book: String.trim(Enum.at(x, 1)),
            start_chapter: String.to_integer(Enum.at(x, 2)),
            start_verse: String.to_integer(Enum.at(x, 3)),
            end_chapter: nil,
            end_verse: nil
          )

        length(x) == 5 ->
          ref = String.trim(Enum.at(x, 0))

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
              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: String.to_integer(Enum.at(x, 3)),
                end_chapter: nil,
                end_verse: String.to_integer(Enum.at(x, 4))
              )
          end

        length(x) == 6 ->
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
    canonical_book_keys = Map.keys(BibleData.books())
    osis_keys           = Map.keys(BibleData.osis_books())
    shortened_keys      = Map.keys(BibleData.shortened_books())
    variant_keys        = Map.keys(BibleData.variants())

    all_searchable =
      (canonical_book_keys ++ osis_keys ++ shortened_keys ++ variant_keys)
      |> Enum.map(&String.downcase/1)
      |> Enum.uniq()
      |> Enum.sort_by(&String.length/1, :desc)

    book_alternation =
      all_searchable
      |> Enum.map(&Regex.escape/1)
      |> Enum.join("|")

    pattern = """
    (?<![A-Za-z0-9])          # left boundary
    (#{book_alternation})     # 1: book
    (?![A-Za-z])              # do not allow extra letters immediately after book
    \\s*
    (?:
      (\\d+)
      (?:\\s*[.:]\\s*(\\d+))?
      (?:
        \\s*[—-]\\s*
        (?:
          (\\d+)
          (?:\\s*[.:]\\s*(\\d+))?
          |
          (\\d+)
        )
      )?
    )?
    """


    {:ok, regex} = Regex.compile(pattern, "xiu")
    regex
  end


end
