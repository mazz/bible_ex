defmodule BibleEx.Librarian do
  require Logger
  alias BibleEx.BibleData

  # Returns the book number from a string.

  def find_book_number(book: book) do
    book_lower = String.downcase(book)

    cond do
      book_lower == "" ->
        nil

      BibleData.books()[book_lower] ->
        BibleData.books()[book_lower]

      BibleData.osis_books()[book_lower] ->
        BibleData.osis_books()[book_lower]

      BibleData.shortened_books()[book_lower] ->
        BibleData.shortened_books()[book_lower]

      BibleData.variants()[book_lower] ->
        BibleData.variants()[book_lower]

      true ->
        nil
    end
  end

  # Validate that a book is in the bible, does not validate mispellings.

  def check_book(book: book) do
    book_lower = String.downcase(book)

    Map.has_key?(BibleData.books(), book_lower) ||
      Map.has_key?(BibleData.osis_books(), book_lower) ||
      Map.has_key?(BibleData.shortened_books(), book_lower)
  end

  # Returns the osis, abbr, name, and short versions of a book title.

  def get_book_names(book: book) do
    found_book =
      case BibleEx.typeof(book) do
        "binary" ->
          find_book_number(book: book)

        "number" ->
          book

        "nil" ->
          nil

        "atom" ->
          nil
      end

    case found_book do
      nil ->
        %{}

      found_book ->
        # book_names = BibleData.book_names()

        list = Enum.at(BibleData.book_names(), found_book - 1)
        # list = Enum.at(book_names, found_book - 1)

        Map.merge(%{}, %{
          osis: Enum.at(list, 0),
          abbr: Enum.at(list, 1),
          name: Enum.at(list, 2),
          short: Enum.at(list, 3)
        })
    end
  end

  # Gets the last verse number in a specified book or book or chapter.

  def get_last_verse_number(book: book) do
    get_last_verse_number(book: book, chapter: nil)
  end

  def get_last_verse_number(book: book, chapter: chapter) do
    found_book =
      case BibleEx.typeof(book) do
        "binary" ->
          find_book_number(book: book)

        "number" ->
          book
      end

    # dbg(found_book)

    case found_book do
      nil ->
        nil

      _found_book_not_nil ->
        # BibleData.lastVerse[foundBook - 1][foundChapter - 1];

        found_chapter =
          case chapter do
            nil ->
              # BibleData.lastVerse[foundBook - 1].count;
              length(Enum.at(BibleData.last_verse(), found_book - 1))

            found ->
              found
          end

        if length(Enum.at(BibleData.last_verse(), found_book - 1)) < found_chapter ||
             found_chapter < 1 do
          nil
        else
          book = Enum.at(BibleData.last_verse(), found_book - 1)
          Enum.at(book, found_chapter - 1)
        end
    end
  end

  # /// Returns the number for the last chapter within a book.
  # internal static func getLastChapterNumber(book: Any) -> Int? {
  #     var foundBook: Int?
  #     if (book is String) {
  #         if let book = book as? String {
  #             foundBook = findBookNumber(book: book);
  #         }
  #     }
  #     if let foundBook = foundBook {
  #         if (foundBook > BibleData.lastVerse.count) {
  #             return nil
  #         } else {
  #             return BibleData.lastVerse[foundBook - 1].count
  #         }
  #     } else {
  #         return nil
  #     }
  # }

  def get_last_chapter_number(book: book) do
    found_book =
      case BibleEx.typeof(book) do
        "binary" ->
          find_book_number(book: book)

        "number" ->
          book
      end

    if found_book > BibleData.last_verse() do
      nil
    else
      length(Enum.at(BibleData.last_verse(), found_book - 1))
    end
  end

  def get_last_verse(book: book) do
    get_last_verse(book: book, chapter: nil)
  end

  def get_last_verse(book: book, chapter: chapter) do
    book_number =
      case BibleEx.typeof(book) do
        "binary" ->
          find_book_number(book: book)

        "number" ->
          book
      end

    # book_names = get_book_names(book: book_number)

    # book_name = book_names.name

    book_chapter =
      case chapter do
        nil ->
          length(Enum.at(BibleData.last_verse(), book_number - 1))

        chapter ->
          chapter
      end

    book_names = get_book_names(book: book)

    case Map.get(book_names, :name, nil) do
      nil ->
        nil

      book_name ->
        BibleEx.Verse.new(
          book: book_name,
          chapter_number: book_chapter,
          verse_number: get_last_verse_number(book: book_number, chapter: book_chapter)
        )
    end

    # verse =
    #   if Enum.at(BibleData.last_verse(), book_number - 1) < book_chapter || book_chapter < 1 do
    #     BibleEx.Verse.new(book, book_chapter, 1)
    #   else
    #     1
    #   end
  end

  def get_verses(book: book, chapter: chapter) do
    get_verses(book: book, chapter: chapter, start_verse: nil, end_verse: nil)
  end

  def get_verses(book: book, chapter: chapter, start_verse: start_verse, end_verse: end_verse) do
    dbg(chapter)

    book_number =
      case BibleEx.typeof(book) do
        "binary" ->
          find_book_number(book: book)

        "number" ->
          book
      end

    case chapter do
      nil ->
        nil

      chapter ->
        # check if chapter is out of range
        dbg(chapter)

        start_verse =
          if !is_nil(start_verse) do
            start_verse
          else
            1
          end

        end_verse =
          if !is_nil(end_verse) do
            end_verse
          else
            BibleData.last_verse()
            |> Enum.at(book_number - 1)
            |> Enum.at(chapter - 1)
          end

        case start_verse > end_verse do
          true ->
            nil

          false ->
            # very_last_verse =
            #   BibleData.last_verse()
            #   |> Enum.at(book_number - 1)
            #   |> Enum.at(chapter - 1)

            dbg(end_verse)

            case end_verse do
              nil ->
                nil

              last_verse ->
                book_names = get_book_names(book: book)

                case Map.get(book_names, :name, nil) do
                  nil ->
                    nil

                  book_name ->
                    Enum.map(start_verse..last_verse, fn x ->
                      BibleEx.Verse.new(
                        book: book_name,
                        chapter_number: chapter,
                        verse_number: x
                      )
                    end)
                end
            end
        end
    end
  end

  # Returns a Chapter? object that corresponds to the
  # last chapter within a book.

  def get_last_chapter(book: book) do
    found_book =
      case BibleEx.typeof(book) do
        "binary" ->
          find_book_number(book: book)

        "number" ->
          book
      end

    if found_book > BibleData.last_verse() do
      nil
    else
      book_names = get_book_names(book: book)

      case Map.get(book_names, :name, nil) do
        nil ->
          nil

        book_name ->
          last_chapter = length(Enum.at(BibleData.last_verse(), found_book - 1))
          BibleEx.Chapter.new(book: book_name, chapter_number: last_chapter)
      end
    end
  end

  def get_chapters(book: book) do
    get_chapters(book: book, start_chapter: nil, end_chapter: nil)
  end

  def get_chapters(book: book, start_chapter: start_chapter) do
    get_chapters(book: book, start_chapter: start_chapter, end_chapter: nil)
  end

  def get_chapters(book: book, start_chapter: start_chapter, end_chapter: end_chapter) do
    found_book =
      case BibleEx.typeof(book) do
        "binary" ->
          find_book_number(book: book)

        "number" ->
          book
      end

    if found_book > BibleData.last_verse() do
      nil
    else
      book_names = get_book_names(book: book)

      case Map.get(book_names, :name, nil) do
        nil ->
          nil

        book_name ->
          case start_chapter > end_chapter do
            true ->
              nil

            false ->
              # if start_chapter is nil, start at beginning of book
              start_chapter =
                if is_nil(start_chapter) do
                  1
                else
                  start_chapter
                end

              # if end_chapter is nil, use start chapter
              end_chapter =
                if is_nil(end_chapter) do
                  start_chapter
                  # length(Enum.at(BibleData.last_verse(), found_book - 1))
                else
                  end_chapter
                end

              # if either are outside of range then bring them back to book limit
              start_chapter =
                if start_chapter < 1 do
                  1
                else
                  start_chapter
                end

              end_chapter =
                if end_chapter > length(Enum.at(BibleData.last_verse(), found_book - 1)) do
                  length(Enum.at(BibleData.last_verse(), found_book - 1))
                else
                  end_chapter
                end

              dbg(start_chapter)
              dbg(end_chapter)

              # if !is_nil(start_chapter) and !is_nil(end_chapter) do
              Enum.map(start_chapter..end_chapter, fn x ->
                BibleEx.Chapter.new(book: book_name, chapter_number: x)
              end)
          end

          # else
          #   nil
          # end
      end
    end
  end

  def identify_reference_type(book: book) do
    identify_reference_type(
      book: book,
      start_chapter: nil,
      start_verse: nil,
      end_chapter: nil,
      end_verse: nil
    )
  end

  def identify_reference_type(
        book: book,
        start_chapter: start_chapter
      ) do
    identify_reference_type(
      book: book,
      start_chapter: start_chapter,
      start_verse: nil,
      end_chapter: nil,
      end_verse: nil
    )
  end

  def identify_reference_type(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse
      ) do
    identify_reference_type(
      book: book,
      start_chapter: start_chapter,
      start_verse: start_verse,
      end_chapter: nil,
      end_verse: nil
    )
  end

  def identify_reference_type(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse,
        end_chapter: end_chapter
      ) do
    identify_reference_type(
      book: book,
      start_chapter: start_chapter,
      start_verse: start_verse,
      end_chapter: end_chapter,
      end_verse: nil
    )
  end

  def identify_reference_type(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse,
        end_chapter: end_chapter,
        end_verse: end_verse
      ) do
    dbg(start_chapter)
    dbg(end_chapter)
    dbg(start_verse)
    dbg(end_verse)

    reference_type = nil

    reference_type =
      cond do
        is_nil(start_chapter) and is_nil(end_chapter) ->
          if !is_nil(start_verse) do
            if !is_nil(end_verse) do
              :verse_range
            else
              :verse
            end
          else
            :book
          end

        !is_nil(start_chapter) and !is_nil(end_chapter) and start_chapter != end_chapter ->
          :chapter_range

        !is_nil(start_chapter) and (is_nil(end_chapter) or end_chapter == start_chapter) ->
          if !is_nil(start_verse) do
            if !is_nil(end_verse) do
              :verse_range
            else
              :verse
            end
          else
            :chapter
          end

        !is_nil(start_verse) and !is_nil(end_verse) ->
          :verse_range

        !is_nil(start_verse) ->
          :verse

        true ->
          nil
      end

    # reference_type =
    #   if is_nil(start_chapter) and is_nil(end_chapter) do
    #     :book
    #   else
    #     if !is_nil(start_chapter) and !is_nil(end_chapter) and start_chapter != end_chapter do
    #       :chapter_range
    #     else
    #       if !is_nil(start_chapter) and (is_nil(end_chapter) or end_chapter == start_chapter) do
    #         :chapter
    #       else
    #         if !is_nil(start_verse) and !is_nil(end_verse) do
    #           :verse_range
    #         else
    #           if !is_nil(start_verse) do
    #             :verse
    #           else
    #             reference_type
    #           end
    #         end
    #       end
    #     end
    #   end

    reference_type
  end

  def verify_reference(book: book) when not is_nil(book) do
    # dbg(book)
    verified = true

    dbg(verified)

    found_book =
      case BibleEx.typeof(book) do
        "binary" ->
          find_book_number(book: book)

        "number" ->
          book
      end

    # dbg(found_book)
    # if (!(foundBook > 0 && BibleData.lastVerse.count >= foundBook)) {
    #   return false;
    # }

    # dbg(verified)

    verified =
      if !(found_book > 0 and length(BibleData.last_verse()) >= found_book) do
        false
      else
        verified
      end

    verified
  end

  def verify_reference(book: book, start_chapter: start_chapter) when not is_nil(book) do
    # dbg(book)
    verified = true

    dbg(verified)

    found_book =
      case BibleEx.typeof(book) do
        "binary" ->
          find_book_number(book: book)

        "number" ->
          book
      end

    # dbg(found_book)
    # if (!(foundBook > 0 && BibleData.lastVerse.count >= foundBook)) {
    #   return false;
    # }

    # dbg(verified)

    verified =
      if !(found_book > 0 and length(BibleData.last_verse()) >= found_book) do
        false
      else
        verified
      end

    # dbg(verified)

    ## if book is not verified at this point, short-circuit

    verified =
      case verified do
        true ->
          if !is_nil(start_chapter) do
            # dbg(found_book)
            books_last_verse = length(BibleData.last_verse() |> Enum.at(found_book - 1))

            if !(start_chapter > 0 and books_last_verse >= start_chapter) do
              false
            else
              verified
            end
          else
            verified
          end

        false ->
          false
      end

    # dbg(verified)

    verified
  end

  def verify_reference(book: book, start_chapter: start_chapter, start_verse: start_verse)
      when not is_nil(book) do
    # dbg(book)
    verified = true

    dbg(verified)

    found_book =
      case BibleEx.typeof(book) do
        "binary" ->
          find_book_number(book: book)

        "number" ->
          book
      end

    # dbg(found_book)
    # if (!(foundBook > 0 && BibleData.lastVerse.count >= foundBook)) {
    #   return false;
    # }

    # dbg(verified)

    verified =
      if !(found_book > 0 and length(BibleData.last_verse()) >= found_book) do
        false
      else
        verified
      end

    # dbg(verified)

    ## if book is not verified at this point, short-circuit

    verified =
      case verified do
        true ->
          if !is_nil(start_chapter) do
            # dbg(found_book)
            books_last_verse = length(BibleData.last_verse() |> Enum.at(found_book - 1))

            if !(start_chapter > 0 and books_last_verse >= start_chapter) do
              false
            else
              verified
            end
          else
            verified
          end

        false ->
          false
      end

    # dbg(verified)

    verified =
      case !is_nil(start_verse) do
        true ->
          # book_list =
          #   BibleData.last_verse()
          #   |> Enum.at(found_book - 1)

          # dbg(book_list)

          if !is_nil(start_chapter) do
            books_last_verse_books_start_chapter =
              BibleData.last_verse()
              |> Enum.at(found_book - 1)
              |> Enum.at(start_chapter - 1)

            if !(start_verse > 0 and
                   books_last_verse_books_start_chapter >= start_verse) do
              false
            else
              verified
            end
          else
            false
          end

        false ->
          verified
      end

    # dbg(verified)

    verified
  end

  def verify_reference(book: book, start_chapter: start_chapter, end_verse: end_verse)
      when not is_nil(book) do
    # dbg(book)
    verified = true

    dbg(verified)

    found_book =
      case BibleEx.typeof(book) do
        "binary" ->
          find_book_number(book: book)

        "number" ->
          book
      end

    # dbg(found_book)
    # if (!(foundBook > 0 && BibleData.lastVerse.count >= foundBook)) {
    #   return false;
    # }

    # dbg(verified)

    verified =
      if !(found_book > 0 and length(BibleData.last_verse()) >= found_book) do
        false
      else
        verified
      end

    # dbg(verified)

    ## if book is not verified at this point, short-circuit

    verified =
      case verified do
        true ->
          if !is_nil(start_chapter) do
            # dbg(found_book)
            books_last_verse = length(BibleData.last_verse() |> Enum.at(found_book - 1))

            if !(start_chapter > 0 and books_last_verse >= start_chapter) do
              false
            else
              verified
            end
          else
            verified
          end

        false ->
          false
      end

    # dbg(verified)

    verified =
      case !is_nil(end_verse) do
        true ->
          # dbg(verified)

          very_last_verse =
            BibleData.last_verse()
            |> Enum.at(found_book - 1)
            |> Enum.at(start_chapter - 1)

          # dbg(very_last_verse)
          # dbg(end_verse)

          if end_verse <= 0 or very_last_verse < end_verse do
            # dbg(verified)
            false
          else
            # dbg(verified)
            # verified
            if is_nil(start_chapter) and is_nil(end_verse) do
              # dbg(verified)
              false
            else
              # dbg(verified)
              verified
            end
          end

        false ->
          # dbg(verified)
          verified
      end

    # dbg(verified)

    verified
  end

  def verify_reference(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse,
        end_chapter: end_chapter
      )
      when not is_nil(book) do
    ## end_chapter alone is always a bad reference because the end_verse must be included
    false
  end

  def verify_reference(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse,
        end_chapter: end_chapter,
        end_verse: end_verse
      )
      when not is_nil(book) do
    # dbg(book)
    # dbg(start_chapter)
    verified = true

    dbg(verified)

    found_book =
      case BibleEx.typeof(book) do
        "binary" ->
          find_book_number(book: book)

        "number" ->
          book
      end

    # dbg(found_book)
    # if (!(foundBook > 0 && BibleData.lastVerse.count >= foundBook)) {
    #   return false;
    # }

    # dbg(verified)

    verified =
      if !(found_book < 1 or (found_book > 0 and length(BibleData.last_verse()) >= found_book)) do
        false
      else
        verified
      end

    # dbg(verified)

    # if (startChapter != nil) {
    #     if let startChapter = startChapter {
    #         if (!(startChapter > 0 &&
    #               BibleData.lastVerse[foundBook - 1].count >= startChapter)) {
    #             return false;
    #         }
    #         if mutEndChapter != nil {
    #             if let mutEndChapter = mutEndChapter {
    #                 if startChapter > mutEndChapter {
    #                     return false
    #                 }
    #             }
    #         }
    #     }
    # } else if (mutEndChapter != nil || endVerse != nil) {
    #     return false;
    # }

    verified =
      if !is_nil(start_chapter) do
        # books_last_verse = length(BibleData.last_verse()[found_book - 1])
        books_last_verse = length(BibleData.last_verse() |> Enum.at(found_book - 1))

        if !(start_chapter > 0 and books_last_verse >= start_chapter) do
          false
        else
          verified
        end

        if !is_nil(end_chapter) and start_chapter > end_chapter do
          false
        else
          verified
        end
      else
        if !is_nil(end_chapter) or !is_nil(end_verse) do
          false
        else
          verified
        end
      end

    dbg(verified)
    # if (startVerse != nil) {

    #     if let startVerse = startVerse {
    #         if (!(startVerse > 0 &&
    #               BibleData.lastVerse[foundBook - 1][startChapter! - 1] >= startVerse)) {
    #             return false;
    #         }
    #     }
    #     if endVerse != nil {
    #         if let endVerse = endVerse {
    #             if let startVerse = startVerse {
    #                 if startVerse > endVerse {
    #                     return false
    #                 }
    #             }
    #         }
    #     }
    # }

    ## TODO: instead of if !is_nil(start_verse) do
    ## put a case do here

    # case !is_nil(start_verse) do

    # end
    verified =
      case !is_nil(start_verse) do
        true ->
          books_last_verse_books_start_chapter =
            BibleData.last_verse()
            |> Enum.at(found_book - 1)
            |> Enum.at(start_chapter - 1)

          # dbg(books_last_verse_books_start_chapter)

          if !(start_verse > 0 and books_last_verse_books_start_chapter >= start_verse) do
            false
          else
            # Logger.debug(
            # "negated if !(start_verse > 0 and books_last_verse_books_start_chapter >= start_verse) do"
            # )
            # dbg(verified)
            verified
          end

          if !is_nil(end_verse) and !is_nil(start_verse) do
            if start_verse > end_verse do
              false
            else
              # dbg(verified)
              # Logger.debug("negated !is_nil(end_verse) && !is_nil(start_verse)")
              verified
            end
          else
            verified
          end

        false ->
          verified
      end

    # dbg(verified)
    # if (mutEndChapter != nil) {
    #     if let mutEndChapter = mutEndChapter {
    #         if (!(BibleData.lastVerse[foundBook - 1].count >= mutEndChapter)) {
    #             return false;
    #         }
    #     }
    # }

    verified =
      case !is_nil(end_chapter) do
        true ->
          books_last_verse = length(BibleData.last_verse() |> Enum.at(found_book - 1))

          if !(books_last_verse >= end_chapter) do
            false
          else
            verified
          end

        false ->
          verified
      end

    dbg(verified)
    # if (endVerse != nil) {
    #     if let endVerse = endVerse {
    #         if (mutEndChapter == nil) {
    #             return false;
    #         }
    #         if let mutEndChapter = mutEndChapter {
    #             if (!(endVerse > 0 && BibleData.lastVerse[foundBook - 1][mutEndChapter - 1] >= endVerse)) {
    #                 return false;
    #             }
    #         }

    #         if (mutEndChapter == nil && startVerse == nil) {
    #             return false;
    #         }
    #         if let startVerse = startVerse {
    #             if  (endVerse < startVerse) {
    #                 return false;
    #             }
    #         }
    #     }

    # }

    verified =
      case !is_nil(end_verse) do
        true ->
          dbg(verified)

          case is_nil(end_chapter) do
            true ->
              dbg(verified)
              false

            false ->
              dbg(verified)

              very_last_verse =
                BibleData.last_verse()
                |> Enum.at(found_book - 1)
                |> Enum.at(end_chapter - 1)

              dbg(very_last_verse)

              if end_verse > 0 and
                   very_last_verse >= end_verse do
                dbg(verified)
                verified
              else
                dbg(verified)
                # verified
                if is_nil(end_chapter) and is_nil(start_verse) do
                  dbg(verified)
                  false
                else
                  dbg(verified)

                  if end_verse < start_verse do
                    dbg(verified)
                    false
                  else
                    dbg(verified)
                    verified
                  end

                  # verified
                end
              end
          end

        false ->
          dbg(verified)
          verified
      end

    dbg(verified)

    verified
  end

  def create_reference_string(book: book) do
    nil
  end

  def create_reference_string(book: book, start_chapter: start_chapter) do
    # dbg(book)
    reference = ""

    reference =
      case !is_nil(book) and !is_nil(start_chapter) do
        true ->
          reference <> book <> " #{start_chapter}"

        false ->
          reference
      end

    if(reference == "", do: nil, else: reference)
  end

  def create_reference_string(book: book, start_chapter: start_chapter, start_verse: start_verse) do
    # dbg(book)
    reference = ""

    reference =
      case !is_nil(book) and !is_nil(start_chapter) do
        true ->
          # dbg(reference)
          reference = reference <> book <> " #{start_chapter}"
          # dbg(reference)

          case !is_nil(start_verse) do
            true ->
              # dbg(reference)
              reference = reference <> ":#{start_verse}"

            # dbg(reference)

            false ->
              # dbg(reference)
              reference
              # dbg(reference)
          end

        false ->
          # dbg(reference)
          reference
      end

    if(reference == "", do: nil, else: reference)
  end

  def create_reference_string(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse,
        end_chapter: end_chapter
      ) do
    # dbg(book)
    reference = ""

    reference =
      case !is_nil(book) and !is_nil(start_chapter) do
        true ->
          # dbg(reference)
          reference = reference <> book <> " #{start_chapter}"
          # dbg(reference)

          if !is_nil(start_verse) and !is_nil(end_chapter) and end_chapter != start_chapter do
            # true ->
            # dbg(reference)
            reference = reference <> ":#{start_verse}"
            reference = reference <> " - #{end_chapter}"
            # dbg(reference)

            end_chapter_last_verse = get_last_verse_number(book: book, chapter: end_chapter)

            if !is_nil(end_chapter_last_verse) do
              reference = reference <> ":#{end_chapter_last_verse}"
              reference
            else
              reference
            end

            # if !is_nil(end)
          else
            reference =
              if !is_nil(end_chapter) and end_chapter != start_chapter do
                # dbg(reference)
                reference = reference <> "-#{end_chapter}"
                # # dbg(reference)
                reference
              else
                # dbg(reference)
                reference
              end

            # dbg(reference)
            reference
          end

        false ->
          # dbg(reference)
          reference
      end

    if(reference == "", do: nil, else: reference)
  end

  def create_reference_string(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse,
        end_chapter: end_chapter,
        end_verse: end_verse
      ) do
    # dbg(book)

    reference = ""

    reference =
      case !is_nil(book) and !is_nil(start_chapter) do
        true ->
          dbg(reference)
          reference = reference <> book <> " #{start_chapter}"
          dbg(reference)

          if !is_nil(start_verse) and !is_nil(end_chapter) and end_chapter != start_chapter do
            # true ->
            dbg(reference)
            reference = reference <> ":#{start_verse}"
            reference = reference <> " - #{end_chapter}"
            dbg(reference)

            if !is_nil(end_verse) do
              reference = reference <> ":#{end_verse}"
              reference
            else
              end_chapter_last_verse = get_last_verse_number(book: book, chapter: end_chapter)

              if !is_nil(end_chapter_last_verse) do
                reference = reference <> ":#{end_chapter_last_verse}"
                reference
              else
                reference
              end
            end

            # if !is_nil(end)
          else
            reference =
              if !is_nil(end_verse) and is_nil(start_verse) do
                reference = reference <> ":1"
                dbg(reference)
                reference
              else
                if !is_nil(start_verse) do
                  reference = reference <> ":#{start_verse}"
                  dbg(reference)
                  reference
                else
                  dbg(reference)
                  reference
                end
              end

            reference =
              if !is_nil(end_chapter) do
                dbg(reference)
                dbg(start_chapter)
                dbg(start_verse)
                dbg(end_chapter)
                dbg(end_verse)

                reference =
                  if is_nil(start_verse) and is_nil(end_verse) do
                    # when only rendering chapter range
                    dbg(reference)

                    # when it's the same chapter, do not show range
                    reference =
                      if start_chapter != end_chapter do
                        dbg(reference)
                        reference = reference <> "-#{end_chapter}"
                      else
                        dbg(reference)
                        reference
                      end

                    dbg(reference)
                    reference
                  else
                    # when rendering chapter:verse - chapter:verse range
                    dbg(reference)

                    if start_chapter != end_chapter do
                      # reference = reference <> "-#{end_chapter}"
                      reference = reference <> " - #{end_chapter}"
                    else
                      dbg(reference)
                      reference
                    end

                    reference
                  end

                reference
              else
                dbg(reference)
                reference
              end

            reference =
              if !is_nil(end_verse) do
                dbg(reference)
                dbg(start_chapter)
                dbg(start_verse)
                dbg(end_chapter)
                dbg(end_verse)

                reference =
                  if !is_nil(start_verse) do
                    dbg(reference)
                    reference = reference <> "-#{end_verse}"
                  else
                    dbg(reference)

                    reference =
                      if !is_nil(end_chapter) do
                        reference = reference <> " - #{end_chapter}:#{end_verse}"
                      else
                        reference = reference <> ":#{end_verse}"
                      end
                  end

                dbg(reference)
                # reference = reference <> ":1"
                reference
              else
                dbg(reference)
                reference
              end

            # if !is_nil(end_chapter) and end_chapter != start_chapter do
            #   # dbg(reference)
            #   reference = reference <> "-#{end_chapter}"
            #   # # dbg(reference)
            # else
            #   # dbg(reference)
            #   reference
            # end

            dbg(reference)
            reference
          end

        false ->
          dbg(reference)
          dbg(book)
          dbg(start_chapter)
          dbg(start_verse)
          dbg(end_chapter)
          dbg(end_verse)

          reference =
            if is_nil(start_chapter) and is_nil(start_verse) do
              dbg(reference)
              book
            else
              dbg(reference)
              reference
            end

          dbg(reference)
          reference
      end

    if(reference == "", do: nil, else: reference)
  end
end

# public init(book: String,
#      startChapter: Int? = nil,
#      startVerse: Int? = nil,
#      endChapter: Int? = nil,
#      endVerse: Int? = nil) {

#     self._bookNames = Librarian.getBookNames(book: book)

#     var fullBookName: String
#     if let swapBook = _bookNames["name"] {
#         fullBookName = swapBook
#     } else {
#         fullBookName = book
#     }

#     startChapterNumber = startChapter ?? 1

#     if let startChapter = startChapter {
#         self.startChapter = Chapter(book: fullBookName, chapterNumber: startChapter)
#     } else {
#         self.startChapter = Chapter(book: fullBookName, chapterNumber: 1)
#     }

#     self.startVerseNumber = startVerse ?? 1

#     if let startVerse = startVerse {
#         self.startVerse = Verse(book: fullBookName, chapterNumber: startChapter, verseNumber: startVerse)
#     } else {
#         self.startVerse = Verse(book: fullBookName, chapterNumber: 1, verseNumber: 1)
#     }

#     self.endChapterNumber = endChapter ?? startChapter ?? Librarian.getLastChapterNumber(book: fullBookName)

#     if let endChapter = endChapter {
#         self.endChapter = Chapter(book: fullBookName, chapterNumber: endChapter)
#     } else {
#         if let startChapter = startChapter {
#             self.endChapter = Chapter(book: fullBookName, chapterNumber: startChapter)
#         } else {
#             self.endChapter = Librarian.getLastChapter(book: fullBookName)
#         }
#     }

#     self.endVerseNumber = endVerse ?? startVerse ?? Librarian.getLastVerseNumber(book: fullBookName, chapter: endChapter)

#     if let endVerse = endVerse {
#         self.endVerse = Verse(book: fullBookName, chapterNumber: startChapter, verseNumber: endVerse)

#     } else {
#         if let startVerse = startVerse {
#             self.endVerse = Verse(book: fullBookName, chapterNumber: startChapter, verseNumber: startVerse)
#         } else {
#             self.endVerse = Librarian.getLastVerse(book: fullBookName, chapter: startChapter)
#         }
#     }

#     self.reference = Librarian.createReferenceString(book: fullBookName,
#                                                      startChapter: startChapterNumber,
#                                                      startVerse: startVerse,
#                                                      endChapter: endChapter,
#                                                      endVerse: endVerse
#     )

#     self.referenceType = Librarian.identifyReferenceType(book: fullBookName,
#                                                          startChapter: startChapterNumber,
#                                                          startVerse: startVerse,
#                                                          endChapter: endChapter,
#                                                          endVerse: endVerse
#     )

#     self.isValid = Librarian.verifyReference(book: fullBookName,
#                                              startChapter: startChapterNumber,
#                                              startVerse: startVerse,
#                                              endChapter: endChapter,
#                                              endVerse: endVerse
#     )

#     self.book = fullBookName

# }
