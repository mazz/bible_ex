defmodule BibleEx.RefParser do
  alias BibleEx.BibleData
  alias BibleEx.Reference

  def parse_references(string) when is_binary(string) do
    books_matched =
      Regex.scan(full_regex(), string)
      |> Enum.map(fn x ->
        x
      end)

    # dbg(indexes)
    dbg(books_matched)

    Enum.map(books_matched, fn x ->
      dbg(x)

      cond do
        # book name only i.e. ["genesis ", "genesis"]
        length(x) == 2 and String.trim(Enum.at(x, 0)) == Enum.at(x, 1) ->
          dbg(x)
          Reference.new(book: String.trim(Enum.at(x, 0)))

        # book with chapter only i.e. ["Judges 19", "Judges", "19"]
        length(x) == 3 ->
          dbg(x)

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
          dbg(x)

          ref = String.trim(Enum.at(x, 0))

          dbg(ref)

          # # NOTE: in iOS `James 1 - 2` generates ["James 1 - 2", "James", "1", "2"]
          # if String.contains?(ref, "-") or
          #      (String.contains?(ref, "—") and !String.contains?(ref, ":")) do
          #   Reference.new(
          #     book: String.trim(Enum.at(x, 1)),
          #     start_chapter: String.to_integer(Enum.at(x, 2)),
          #     start_verse: String.to_integer(Enum.at(x, 3)),
          #     end_chapter: nil,
          #     end_verse: nil
          #   )
          # else
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
          dbg(x)
          ref = String.trim(Enum.at(x, 0))
          # chapter-only reference -- also covers `em-dash` case
          # # NOTE: in elixir `James 1 - 2` generates ["james 1 - 2", "james", "1", "", "2"]

          cond do
            String.contains?(ref, ":") ->
              dbg(x)

              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: String.to_integer(Enum.at(x, 3)),
                end_chapter: nil,
                end_verse: String.to_integer(Enum.at(x, 4))
              )

            String.contains?(ref, ".") ->
              # ["James 1.2 -  2", "James", "1", "2", "2"]
              dbg(x)

              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: String.to_integer(Enum.at(x, 3)),
                end_chapter: nil,
                end_verse: nil
              )

            String.contains?(ref, "-") or String.contains?(ref, "—") ->
              dbg(x)

              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: nil,
                end_chapter: String.to_integer(Enum.at(x, 4)),
                end_verse: nil
              )

            true ->
              # should never get here?
              dbg(x)

              Reference.new(
                book: String.trim(Enum.at(x, 1)),
                start_chapter: String.to_integer(Enum.at(x, 2)),
                start_verse: String.to_integer(Enum.at(x, 3)),
                end_chapter: nil,
                end_verse: String.to_integer(Enum.at(x, 4))
              )
          end

        # if String.contains?(ref, "-") or
        #      (String.contains?(ref, "—") and !String.contains?(ref, ":")) do
        #   dbg(x)

        # if String.contains?(ref, "-") or (String.contains?(ref, "—") do
        #   if String.contains?(ref, ":")) do

        #   end
        # else

        # end

        # else
        #   dbg(x)
        #   # book with chapter and verse and range i.e. ["Jn 3:16-18", "Jn", "3", "16", "18"]
        #   Reference.new(
        #     book: String.trim(Enum.at(x, 1)),
        #     start_chapter: String.to_integer(Enum.at(x, 2)),
        #     start_verse: String.to_integer(Enum.at(x, 3)),
        #     end_chapter: nil,
        #     end_verse: nil
        #   )
        # end

        length(x) == 6 ->
          # A reference that spans multiple chapters. i.e. ["John 3:16-4:3", "John", "3", "16", "4", "3"]
          dbg(x)

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

    # dbg(references)
  end

  def full_regex() do
    all_book_names =
      Enum.map(BibleData.book_names(), fn x ->
        x
      end)
      |> List.flatten()

    variants = Map.keys(BibleData.variants())
    # dbg(variants)

    all_searchable = all_book_names ++ variants
    # dbg(all_searchable)

    reg_books = Enum.join(all_searchable, "\\b|\\b")

    # dbg(reg_books)

    {:ok, regex} =
      Regex.compile("(\\b#{reg_books}\\b) *(\\d+)?[ :.]*(\\d+)?[— -]*(\\d+)?[ :.]*(\\d+)?", [
        :caseless
      ])

    # dbg(regex)

    regex
  end
end
