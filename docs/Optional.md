# Optional型
Optional型は、成功もしくは失敗を表します。成功の場合はその値を得ることができます。`Optional<A>`と`A?`は同じ意味です。

## `Optional`とoptional
`Optional`型の値に後置`?`演算子を適用すると、optionalになります。これは値として扱うことができます。

```
x: Int? := Optional(1)
y?: Int := x? + 1
# y := x.map(n -> n + 1) と同じ意味
```

## `Null`と`null`
`null`は値ではありませんが、`Optional`型の値のように扱われます。この型のようなものを仮に`optional`と呼ぶことにします。`null`は式の中では以下のように評価されます。

1. `optional`として扱われることができます。その場合`null`のままです。
2. `Optional`として扱われることができます。その場合`Null`に変換されます。
3. `Optional`または`optional`として扱えない場合、型エラーが出る代わりにその式はスキップされます。

```
x?: Int := null         # (1) xにはNullが代入されます。
y: Int? := null         # (2) yにはNullが代入されます。
z: Int := null          # (3) zは定義されません。式全体がスキップされます。
```

## 値の作り方
```
# (a)
n: Int? := Optional(1)
x: Int? := n? + 1

# (b)
n?: Int := 1
x?: Int := n? + 1
```

## if文における使用
```
def map<A, B>(f: A => B, x?: A) := do
  if a? := x?
    return Optional(f(a))
  else
