class A {
    metodo() : B {
        new B
    };
};

class B inherits IO {
    metodo() : Object {
        out_string("Deu Certo!\n")
    };
};

class Main {
    main() : Object {
        (new A).metodo().metodo()
    };
};