(*** Testando dispatch estático  ***)
class A inherits IO {
    say_hello() : Object {
        out_string("Ola da classe A\n")
    };
};

class B inherits A {
    say_hello() : Object {
        out_string("Ola da classe B\n")
    };
};

class C inherits B {
    say_hello() : Object {
        out_string("Ola da classe C\n")
    };
};

(*** Classe Main ***)
class Main inherits IO {
    c : C <- new C;
    main() : Object {
        {
            {
                out_string("Testando dispatch estático\n");
                c@A.say_hello();
            };
        }
    };
};