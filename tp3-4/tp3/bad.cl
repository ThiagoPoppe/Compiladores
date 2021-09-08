(* no error *)
class A {
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

(* error: “>” operator is not defined *)
class ClasseComOperadorMaior {
    iteracaoLoop : Int <- 5;
	metodoLoop(): Object { while iteracaoLoop > 0 loop iteracaoLoop <- iteracaoLoop - 1 pool }; 
};

(* error: loop expression must be of static type Object *)
class ClasseComTipoEstaticoErrado {
    iteracaoLoop : Int <- 5;
	metodoLoop(): Int { while 0 < iteracaoLoop loop iteracaoLoop <- iteracaoLoop - 1 pool }; 
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

(* error: missing “;” at the end of expression *)
class Soma {
    soma(a : Int, b: Int): Int { a + b }
};

(* error: if statement whitout an else *)
class TesteCondicao inherits Soma {
    zeraSeNegativo(a : Int): Int { if a > 5 then a <- 0 fi };
};

(* error: type Object of type a and b does not conform to Int *)
class NovaSoma {
    tres : Int <- soma(a(),b());
};

(* error: class name contains an unvalid character *)
class Teste() {
};