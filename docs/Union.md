# Union型
```
Union<A, B, C, ...>
or
A | B | C | ...
```

`Union`は直和型です。複数の型のうちのいずれかであることを表します。

## 型の判定
```
A <> B => (A | B) <> A and (A | B) <> B
A <= C and B <= C => (A | B) <= C
```

## 値を取り出す
型変換によって構成する型に変換することができます。失敗する可能性があるので、`as`ではなく`as?`を使います。

```
x: Boolean | Int := 1
x as Boolean          # エラー
p (x as? Boolean)     #=> Null
p (x as? Int)         #=> Optional(1): Int?
```

### `Int | String` を受け取る関数の例
```
def plusOne(x: Int | String): Int | String := do
  return \
    if n? := x as? Int
      x + 1
    elsif s? := x as? String
      x + "+1"
```

この関数は、`Int`を受け取ったらそれに1を足して返し、`String`を受け取ったらそれに`"+1"`を足して返します。
