# 型スコープ
```
A := enum
  Foo
  Bar

f(x: A) := do
  puts x

a := A.Foo
b: A := Foo     # 型スコープの使用
f Foo           # 型スコープの使用
```
