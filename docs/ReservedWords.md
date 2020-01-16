# 予約語

いくつかの予約語はブロックをとることができます。
```
Foo := class
  static f(x: Int) := x + 1
  static
    g(x: Int) := x * 2
    h(x: Int) := g(f(x))
```

上の例では、`f`,`g`,`h`のいずれもstaticスコープに宣言されました。
