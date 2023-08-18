defmodule BibleEx.RefParser do
  alias BibleEx.BibleData
  alias BibleEx.Reference

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

  def full_regex() do
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
