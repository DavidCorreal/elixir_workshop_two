defmodule MathChallenger.Memory.MemoryTasks do

  import MathChallenger.Memory.MemoryUtils

  defp selected_letters(map_alphabet)  do
    vocales = get_vowels(map_alphabet, [])
    consonants = get_consonants(map_alphabet, [])
    Enum.concat(vocales, consonants)
  end

  def init_game do
    sel_letters = selected_letters(alphabet_map())
    solved = load_board(sel_letters)

    nickname = IO.gets("Nickname: ") |> String.trim()
    game(board(), solved, nickname, 3, 0, 0, [])
  end

  defp game(board_on, solved_board, player, lifes, acc_v, acc_c, coordenadas) when lifes > 0 and acc_v < 3 and acc_c < 3  do
    #Información del juego
    IO.puts("Player: #{player}")
    IO.puts("Lives: #{lifes}")
    IO.puts("Vowels:  #{acc_v}")
    IO.puts("Consonants:  #{acc_c}")
    IO.puts(board_on)

    #Pedido por teclado
    ing_pair = IO.gets("Input a pair x,y: ")
               |> String.trim
               |> String.split(",")
               |> Enum.map(&String.to_integer/1)
               |> List.to_tuple

    #Las coordenadas recibidas, invertirlas.
    ing_pair_r = ing_pair |> Tuple.to_list |> Enum.reverse |> List.to_tuple
    new_cord = coordenadas_ingresadas(coordenadas, ing_pair_r, ing_pair)


    #Construyendo los pares {{letra1, posicion1},{letra2,posicion2}} que corresponde a la coordenada ingresada.
    {pair1, pair2} = raw_positions(Map.keys(solved_board),Map.values(solved_board))
                     |> Enum.filter(fn {k,_v} -> k ==  elem(ing_pair, 0) or k == elem(ing_pair, 1) end) |> List.to_tuple

    #Mostrar la selección en el tablero utilizando lo anterior
    IO.puts(reveal_cards(board_on, pair1, pair2))

    #Ver si el par ingresado es correcto, ver si corresponde a vocal o consonante, incrementar el respectivo contador y actualizar el estado del par a :found

    case {letras_iguales(pair1, pair2), es_consonante(pair1), Enum.member?(coordenadas, ing_pair)} do
      #Controlar que si el par es correcto, no volverlo a cubrir, debe quedar revelado.
      {true, true, _}  -> respuesta_correcta("Has encontrado un par de consonantes.\n",
                                              reveal_cards(board_on, pair1, pair2), solved_board, player, lifes, acc_v, acc_c+1, new_cord)
      {true, _, _} -> respuesta_correcta("Has encontrado un par de vocales.\n",
                                              reveal_cards(board_on, pair1, pair2), solved_board, player, lifes, acc_v+1, acc_c, new_cord)
      #Controlar si vuelve a ingresar la misma coordenada ya encontrada, mostrando un mensaje apropiado
      {_,_,true} -> intento_errado("Ya ingresaste este valor.\n", board_on, solved_board, player, lifes-1, acc_v, acc_c, new_cord)
      #Controlar si el par no es válido, mostrando un mensaje apropiado
      _ -> intento_errado("Sigue intentando.\n", board_on, solved_board, player, lifes-1, acc_v, acc_c, new_cord)
    end

  end

  defp game(_, _, _, lifes, acc_v, acc_c, coordenadas) when lifes == 0, do: {:gameover, :finished}

  defp game(_, _, _, _, acc_v, acc_c, coordenadas), do: {:winner}

  defp intento_errado(mensaje, board_on, solved_board, player, lifes, acc_v, acc_c, new_cord) do
    IO.puts(mensaje)
    game(board_on, solved_board, player, lifes, acc_v, acc_c, new_cord)
  end

  defp respuesta_correcta(mensaje, board_on, solved_board, player, lifes, acc_v, acc_c, new_cord) do
    IO.puts(mensaje)
    {:found}
    ##RECURCION llamado del mismo metodo hasta completar una tarea en este caso hasta que gane o se acaben las vidas
    game(board_on, solved_board, player, lifes, acc_v, acc_c, new_cord)
  end

  defp coordenadas_ingresadas(lista, cord1, cord2) do
    [cord1, cord2 | lista]
  end

  defp letras_iguales({_, letra1}, {_, letra2}) do
    String.downcase(letra1) == String.downcase(letra2)
  end

  defp es_consonante({_, letra}) do
    consonantes = String.graphemes("bcdfghjklmnpqrstvwxyz")
    Enum.member?(consonantes, letra)
  end

  defp reveal_cards(board_on, pair1, pair2) do
    p1 = to_string(elem(pair1, 0))
    p2 = to_string(elem(pair2, 0))
    String.replace(board_on, "-"<>p1<>"-", elem(pair1, 1)) |> String.replace("-"<>p2<>"-", elem(pair2,1))

  end

end

#c("lib/memory/memory_tasks.ex")
