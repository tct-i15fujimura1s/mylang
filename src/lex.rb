Token = Struct.new(:name, :value)

def open_group(tokens, nests, symbol_open, state)
  nests << symbol_open
  tokens << symbol_open
  stack << state
end

def close_group(tokens, nests, symbol_open, symbol_close)
  while nests.last != symbol_open
    if nests.is_a? Integer
      tokens << :tEND
      nests.pop
    else
      # 異なる種類の括弧
      raise "括弧が閉じられていません: #{nests.last}"
    end
  end
  tokens << symbol_close
  nests.pop
  stack.pop
end


def tokenize(src, **props = {:tabstop => 4})
  tokens = []
  state = :head
  nests = []
  stack = []
  current_indent = 0


  src = src.chars << :EOF
  i, length = 0, src.length
  while i < length
    c = src[i]
    case state
    when :head
      case c
      when ' '; current_indent += 1
      when ?\t'; current_indent += props[:tabstop]
      when ?\n'; current_indent = 0
      else
        i -= 1
        if nests.empty?
          tokens << :tBEGIN if current_indent > 0
        else
          while nests.last > current_indent
            tokens << :tEND
            nests.pop
          end
          ln = nests.last
          if 
          elsif ln < current_indent
            tokens << :tBEGIN
            nests << current_indent
          end
        end
        current_indent = 0
        state = :mid
      end
    when :mid
      case c
      when :EOF; state = :END
      when ?; ; tokens << ?;
      when ?\n
        tokens << ';'
        state = :head
      when ?( ; open_group tokens, nests, ?(, state
      when ?) ; state = close_group tokens, nests, ?(, ?)
      when ?[ ; open_group tokens, nests, ?[, state
      when ?] ; state = close_group tokens, nests, ?[, ?]
      when ?{ ; open_group tokens, nests, ?{, state
      when ?} ; state = close_group tokens, nests, ?{, ?}
      when ?' ; state = :s_quote; stack << [] << i + 1
      when ?" ; state = :d_quote; stack << [] << i + 1
      when ?0 ; state = :zero
      when ?1..?9 ; state = :decimal; stack << c.to_i
      end
    when :s_quote
      case c
      when :EOF
        raise "文字列が終了していません: " + pos(src, stack.pop)
      when ?'
        state = :mid
        beg, p = *stack.pop(2)
        tokens << (p << src[beg ... i])
      when ?\\
        beg = stack.pop
        stack[-2] << src[beg ... i] << src[i += 1]
        stack << i + 1
      end
    when :d_quote
      case c
      when :EOF
        raise "文字列が終了していません: " + pos(src, stack.pop)
      when ?"
        state = :mid
        beg, p = *stack.pop(2)
        tokens << (p << src[beg ... i])
      when ?\\
        state = :d_quote_escape
        beg = stack.pop
        stack[-2] << src[beg ... i]
        stack << i+1
      when ?#
        state = :d_quote_expand_begin
        beg = stack.pop
        stack[-2] << src[beg ... i]
        stack << tokens.size
      end
    when :d_quote_expand_begin
      case c
      when ?{
        open_group tokens, nests, ?{, :d_quote_expand_end
      when ?(
        open_group tokens, nests, ?{, :d_quote_expand_end
      when ?[
        open_group tokens, nests, ?{, :d_quote_expand_end
      #when #ident
      #  #TODO
      end
    when :d_quote_expand_end
      toks = tokens.slice! stack.pop..-1
      stack[-1] << toks #FIXME
      stack << (i -= 1)
      state = :d_quote
    when :zero
      case c
      when ?0..?9 ; state = :decimal; stack << c.to_i
      when ?b, ?B ; state = :binary; stack << 0
      when ?o, ?O ; state = :octal; stack << 0
      when ?x, ?X ; state = :hexadecimal; stack << 0
      when ?n, ?N ; state = :mid; tokens << Token[:natural, 0]
      when ?d, ?D ; state = :mid; tokens << Token[:integer, 0]
      when ?i, ?I ; state = :mid; tokens << Token[:complex, 0]
      when ?f, ?F ; state = :mid; tokens << Token[:float, 0]
      when ?. ; state = :decimal_point; stack << 1 << 0
      else state = :mid; tokens << Token[:number, 0]; i -= 1
      end
    when :decimal
      case c
      when ?0..?9 ; stack[-1] = stack[-1] * 10 + c.to_i
      when ?n, ?N ; state = :mid; tokens << Token[:natural, 0]
      when ?d, ?D ; state = :mid; tokens << Token[:integer, 0]
      when ?i, ?I ; state = :mid; tokens << Token[:complex, 0]
      when ?f, ?F ; state = :mid; tokens << Token[:float, 0]
      when ?. ; state = :decimal_point; x = stack.pop; stack << 1 << x
      when ?_
      else state = :mid; tokens << Token[:number, stack.pop]; i -= 1
      end
    when :decimal_point
      case c
      when ?0..?9 ; stack[-1] += (stack[-2] *= 0.1) * c.to_i
      when ?i, ?I ; state = :mid; tokens << Token[:complex, 0]
      when ?f, ?F ; state = :mid; tokens << Token[:float, 0]
      when ?_
      else state = :mid; tokens << Token[:number, stack.pop]; i -= 1
      end
    when :binary
      case c
      when ?0, ?1 ; stack[-1] = stack[-1] << 1 | c.to_i
      when ?n, ?N ; state = :mid; tokens << Token[:natural, 0]
      when ?d, ?D ; state = :mid; tokens << Token[:integer, 0]
      when ?i, ?I ; state = :mid; tokens << Token[:complex, 0]
      when ?f, ?F ; state = :mid; tokens << Token[:float, 0]
      when ?. ; state = :binary_point; x = stack.pop; stack << 1 << x
      else ?_state = :mid; tokens << Token[:number, stack.pop]; i -= 1
      end
    when :binary_point
      case c
      when ?0..?1 ; stack[-1] += (stack[-2] *= 0.5) * c.to_i
      when ?2..?9 ; raise "Unexpected digit in binary"
      when ?i, ?I ; state = :mid; tokens << Token[:complex, 0]
      when ?f, ?F ; state = :mid; tokens << Token[:float, 0]
      when ?_
      else state = :mid; tokens << Token[:number, stack.pop]; i -= 1
      end
    when :octal
      case c
      when ?0..?7; stack[-1] = stack[-1] << 3 | c.to_i
      when ?8, ?9; raise "Unexpected digit in octal"
      when ?n, ?N ; state = :mid; tokens << Token[:natural, 0]
      when ?d, ?D ; state = :mid; tokens << Token[:integer, 0]
      when ?i, ?I ; state = :mid; tokens << Token[:complex, 0]
      when ?f, ?F ; state = :mid; tokens << Token[:float, 0]
      when ?. ; state = :octal_point; x = stack.pop; stack << 1 << x
      else ?_state = :mid; tokens << Token[:number, stack.pop]; i -= 1
      end
    when :octal_point
      case c
      when ?0..?7 ; stack[-1] += (stack[-2] *= 0.125) * c.to_i
      when ?8, ?9 ; raise "Unexpected digit in octal"
      when ?i ; state = :mid; tokens << Token[:complex, 0]
      when ?f ; state = :mid; tokens << Token[:float, 0]
      when ?_
      else state = :mid; tokens << Token[:number, stack.pop]; i -= 1
      end
    when :hexadecimal
      case c
      when ?0..?9, ?a..?f; stack[-1] = stack[-1] << 4 | c.to_i(16)
      when ?n ; state = :mid; tokens << Token[:natural, 0]
      when ?i ; state = :mid; tokens << Token[:complex, 0]
      when ?. ; state = :octal_point; x = stack.pop; stack << 1 << x
      else ?_state = :mid; tokens << Token[:number, stack.pop]; i -= 1
      end
    when :octal_point
      case c
      when ?0..?7 ; stack[-1] += (stack[-2] *= 0.125) * c.to_i
      when ?8, ?9 ; raise "Unexpected digit in octal"
      when ?i ; state = :mid; tokens << Token[:complex, 0]
      when ?f ; state = :mid; tokens << Token[:float, 0]
      when ?_
      else state = :mid; tokens << Token[:number, stack.pop]; i -= 1
      end
