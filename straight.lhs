Compiler and interpreter for simple straight line programs.

A straight line program is just a list of assignment statements, where an
expression can contain variables, integer constants and arithmetic operators.

> data Prog = Prog [Stmt]
>             deriving (Show)

> data Stmt = Asgn Var Exp
>             deriving (Show)

> data Exp = Const Int
>          | Var Char
>      	   | Bin Op Exp Exp
>            deriving (Show)

> data Op = Plus | Minus | Times | Div | Equals
>           deriving (Show)

> data Cond = Cond RelOp Exp Exp
>           deriving (Show)

> data RelOp = Eq | Ne | Lt | Le | Gt | Ge
>           deriving (Show)

The store is a list of variable names and their values.  For now, a variable
now is just a single character and a value is an integer.

> type Store = [(Var, Val)]
 
> type Var = Char

> data Val = Int | Bool
>           deriving (Show)

Straight line programs are translated into code for a simple stack-oriented
virtual machine.

A VM code program is a list of commands, where a command is either a load
immdiate (which loads a constant onto the stack), load (which loads the value
of a variable onto the stack), store (which saves the value at the top of the
stack into memory, and deletes it), or an arithmetic operation (which applies
an operations to the two values at the top of the stack and replaces them by
the result).

> type Code = [Command]

> data Command = LoadI Val | Load Var | Store Var | BinOp Op | RelOp Op
>                deriving (Show)

> type Stack = [Val]

Run a program, by compiling and then executing the resulting code
The program is run with an initially empty store and empty stack, and the
output is just the resulting store.  This could be modified to provide an
initial store.

> run :: Prog -> Store
> run prog = snd (exec code ([], []))
>      	     where code = translate prog

Translate straight line program into stack machine code

> translate :: Prog -> Code
> translate (Prog stmts) = trans stmts

> trans :: [Stmt] -> Code
> trans [] = []
> trans (stmt : stmts) = (trans' stmt) ++ (trans stmts)

> trans' :: Stmt -> Code
> trans' (Asgn var exp) = (transexp exp) ++ [Store var]

> transexp :: Exp -> Code
> transexp (Const n) = [LoadI n]
> transexp (Var v) = [Load v]
> transexp (Bin op e1 e2) = transexp e1 ++ transexp e2 ++ [BinOp op]
> --this might be where to add conditionals...?

Execute a stack code program

> exec :: Code -> (Stack, Store) -> (Stack, Store)
> exec [] ss = ss
> exec (cmd : cmds) ss = exec cmds (exec' cmd ss)

> exec' :: Command -> (Stack, Store) -> (Stack, Store)
> exec' (LoadI n) (stack, store) = (n:stack, store) 
> exec' (Load v) (stack, store) = (x:stack, store)
> 	                             where x = getVal v store
> exec' (Store v) (x:stack, store) = (stack, store')
> 	                                where store' = setVal v x store
> exec' (BinOp op)  (x:y:stack, store) = (z:stack, store)
> 	                                 where z = apply op x y
> exec' (RelOp op)  (x:y:stack, store) = (z:stack, store)
> 	                                 where z = applyc op x y



>-- conditional..?

Apply an arithmetic operator

> apply :: Op -> Val -> Val -> Val
> apply Plus x y = x+y 
> apply Minus x y = x-y
> apply Times x y = x*y
> apply Div x y = x `div` y

Apply a conditional opperator:

> applyc :: RelOp -> Val -> Val -> Bool
> applyc Eq x y = x == y
> applyc Ne x y = x /= y
> applyc Lt x y = x < y
> applyc Le x y = x <= y
> applyc Gt x y = x > y
> applyc Ge x y = x >= y


Look up a variable in the store

> getVal :: Var -> Store -> Val
> getVal v s = foldr (\(u,x) r -> if u==v then x else r) (error "Variable not found") s

Assign a value to a variable in the store

> setVal :: Var -> Val -> Store -> Store
> setVal v x [] = [(v,x)]
> setVal v x ((u,_):s) | v == u = (v,x):s
> 	     	       | otherwise = setVal v x s

Some examples for testing

> e1 = Const 1

> e2 = Var 'a'

> e3 = Bin Plus e1 e1

> s1 = Asgn 'a' e3

> s2 = Asgn 'a' e2

> p1 = Prog [s1, s2]


