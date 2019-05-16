## comments
```
# This is a line comment from # to line ending
(#
  This is a block comment
  (# which can be nested #)
#)
```

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

if y < 0, y = 0 # single line
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

### constants
```
val x = 1
val x: Int = 1
val x @defer: Int # deferred assignment (@defer annotation required)
```

### variables
```
var x = 1
var x: Int = 1
var x: Int
```

### functions
```
c = 1     # constant function. difference between constant and constant function is evaluation strategy. constant functions are lazy
f x = x   # identity function
f(x: Int) = x # Int type
f(x: Int, y: String) = (x as String) + y # multiple arguments with different types 
f(x, y: Int): Int = x + y # multiple arguments with the same type 
k x y = x # curried

max(x, y) =
  if x < y
    return y
  return x

# overloading
fib 0 = 0
fib 1 = 1
fib[n > 1](n: Int) = fib(n - 1) + fib(n - 2)

# with side effect
_count = 0
count! = # if the function has side effects, either suffix! or @sideEffect annotation is required
  c = _count
  _count += 1
  return c
```

### lambda
```
succ = x -> x + 1
add = (x, y) -> x + y
curriedAdd = x -> y -> x + y
addInt = (x, y: Int) -> x + y
```

### polymorph types
```
# A => B is syntax sugar to (x: A) => B
F: K = A => B
```

### dependent types
```
F: K = (x: A) => B
f: F = (x: A) -> b
x: A = a
y: F[x] = f x
```

## trait
like abstract class in Java but one class can include two or more traits
```
TrA = trait
  val ::staticConst1 = 1
  ::staticMethod1(x) = ...
  
  var _var1 = 1 # when the name of variable starts with '_', it's private in default
  var _var2 @public = 1 # coerce public by @public annotation
  var var3 =
  
  _con1 = 1 # private const.
  con2 = 2 # public const.
  con3 @protected = 3 # protected const.

TrA.staticConst1
```

### class
Classes are new-able traits.
```
Counter = class
  var _count
  construct!(init: Int) = # constructor construct!
    _count = init
  count! =
    c = _count
    _count += 1
    return c
```

### (multiple) inheritance
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

## import
```
import "openssl"
import "./example1"
import "openssl" as OSSL
import {Cipher} from "openssl"
```

## export
```
import "std"
export main! _ = std.out.print! "hello\n"

export OpenSSL @default = module
  ::Cipher = module
    ...
```

## misc.

### static scope
```
color = Color.BLUE
color: Color = BLUE

case color
  Color.BLUE ->
```
