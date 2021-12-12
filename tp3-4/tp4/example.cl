
(*  Example cool program testing as many aspects of the code generator
    as possible.
 *)

class A {
    x : Int <- 10;
    y : String;
};

class B {
    a : Int;
    b : String <- "abc";
};

class Teste inherits A {
    z : Bool <- true;

    metodo() : Int { 0 };
};

class Main {
    main() : Int {
        0
    };
};