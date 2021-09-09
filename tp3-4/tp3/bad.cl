(* no error *)
class A { };

(* template class used to force at least 3 shifts *)
class NoError1 { 
    x : Int <- 42;
};

(* error:  b is not a type identifier *)
Class b inherits A {
};

(* error:  a is not a type identifier *)
Class C inherits a {
};

(* error:  keyword inherits is misspelled *)
Class D inherts A {
};

(* error:  closing brace is missing *)
Class E inherits A {
;

(* another class with no error *)
class NoError2 { 
    x : Int <- 42;
};

(* error: missing class TYPE *)
class inherits A { };

(* error: ">" operator is not defined *)
class ClasseComOperadorMaior {
    iteracaoLoop : Int <- 5;
	metodoLoop(): Object { while iteracaoLoop > 0 loop iteracaoLoop <- iteracaoLoop - 1 pool }; 
};

(* error: loop expression missing “pool” delimiter *)
class ClasseSemDelimitadorDeFim {
    iteracaoLoop : Int <- 5;
	metodoLoop(): Int { while 0 < iteracaoLoop loop iteracaoLoop <- iteracaoLoop - 1 }; 
};

(* error: mother class not especified *)
class Teste inherits {
    calculadora() : Int { soma(1,2) };
};

(* error: missing “;” at the end of feature *)
class Soma {
    soma(a : Int, b: Int): Int { a + b }
};

(* another class with no error *)
class NoError3 { 
    x : Int <- 42;
};

(* error: if statement without an else *)
class TesteCondicao inherits Soma {
    zeraSeNegativo(a : Int): Int { if a < 0 then a <- 0 fi };
};

(* error: class name contains an invalid character *)
class Teste() {
};

(* error: feature errors *)
class TestaFeatures {
    (* tipo is not a type, no error; and wrong assign operator *)
    a : tipo;
    b : String;
    c : Int = 42;

    (* wrong feature, missing { } *)
    m() : Object;

    (* wrong feature, missing type *)
    m() { "placeholder" };

    (* wrong feature, missing expression inside { } *)
    m() : Object { };
};

(* error: let declarations *)
class TestaLetDeclarations {
    feature() : String {
        let a:Int, b, c:String, d, x:Int, y, z: Bool in "vazio"
    };
};

(* error: block of expressions *)
class TestaBlocoExpressoes {
    x : Int <- 10;

    feature() : Object {
        {
            x + 20;
            case x of default : Object "vazio"; esac;
            not x;
            case x of default : Object => "vazio" esac;
            if x = 1 then 1 else 0;
            ~x;
            if x = 1 then 0 fi;
            1 / 0;
            ( 10;
            x <- 42;
            (10)
        }
    };
};