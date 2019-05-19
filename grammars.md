ver0.1.0

## コメント
```
# これはコメントです
#から行末までがコメントになります
(#
  複数行のコメントです
  (# ネストできます #)
#)
```

## 制御構文

### if-elif-else
```
if x % 3 == 0 and x % 5 == 0
  print! "FizzBuzz"
elif x % 3 == 0
  print! "Fizz"
elif x % 5 == 0
  print! "Buzz"
else
  print! x

if y < 0, y = 0 # 単一行
```

### case
```
case m
  0 -> n + 1
  _ -> A(m-1, A(m, n-1))
```

### do-while
```
var x = 1
do
  x += 1
  while x < 9
  print! x

do while n > 0
  n >>= 1
```

## ＊数
定数、変数には値を入れることができる
関数には式を入れることができる

### 定数
```
val x = 1
val x: Int = 1
val x @defer: Int # 遅延代入 (定義時に代入しない場合、@defer注釈を付けないとエラーになります)
```

### 変数
```
var x = 1
var x: Int = 1
var x: Int
```

### 関数
```
c = 1     # 定数関数。定数と定数関数の違いは、正格評価か、遅延評価かです
f x = x   # 恒等関数
f(x: Int) = x # Int型のみ
f(x: Int, y: String) = (x as String) + y # 複数の異なる型の引数
f(x, y: Int): Int = x + y # 複数の同じ型の引数
k x y = x # カリー化

# 複数行の定義
max(x, y) =
  if x < y
    return y
  return x

# 多重定義
fib 0 = 0
fib 1 = 1
fib[n > 1](n: Int) = fib(n - 1) + fib(n - 2)

# 副作用のある関数
_count = 0
count! = # 副作用のある関数で、名前の末尾が!でない場合は、@sideEffect注釈を付けないとエラーになります
  c = _count
  _count += 1
  return c
```

### ラムダ式
```
succ = x -> x + 1
add = (x, y) -> x + y
curriedAdd = x -> y -> x + y
addInt = (x, y: Int) -> x + y
```

## モジュール
他のモジュールに組み込んだりもできる
インスタンスメソッドを持つこともできる (Javaでいうabstract class)
```
ModA = module
  val ::staticConst1 = 1
  ::staticMethod1(x) = ...
  
  var _var1 = 1 # 名前の先頭が_のとき、自動的にprivateになる
  var _var2 @public = 1 # @public注釈によって強制public化
  var var3 =
  
  _con1 = 1 # private定数
  con2 = 2 # public定数
  con3 @protected = 3 # protected定数

ModA.staticConst1
```

### クラス
newできるモジュール
```
Counter = class
  var _count
  construct!(init: Int) = # コンストラクタconstruct!
    _count = init
  count! =
    c = _count
    _count += 1
    return c
```

### 継承
```
Foo = class
  name = "Foo"
  action! = print! "foooo!"

# Fooから継承したnameをオーバーライド
Bar = class
  < Foo
    name @override = "Bar"
    action! @override = print! "boo!"

# メソッドの継承元を明示しない場合
Baz = class < Foo
  name @override = "Baz"

# Bar#action!, Baz#nameを使うと明示する (衝突するので、明示しないとエラー)
BazBar = class
  < Baz
    name
    
  < Bar
    action!
```

## インポート
```
import "openssl"
import "./example1"
import "openssl" as OSSL
import {Cipher} from "openssl"
```

## エクスポート
```
import "std"
export main! _ = std.out.print! "hello\n"

export OpenSSL @default = module
  ::Cipher = module
    ...
```

## misc.

### staticスコープ
```
color = Color.BLUE
color: Color = BLUE

case color
  Color.BLUE ->
```

### try-catch
try
  req = http.get("http://example.com")
  req.onfinished = () ->
    if req.status == 200: throw req.response
    else throw Exception(req.statusText)
catch
  (res: http.Response) -> print! res.body
  (e: Excepiton) -> print! e.stackTrace
