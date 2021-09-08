class A {
    say_hello() : String { "Ola da classe A\n" };
};

class B inherits A {
    say_hello() : String { "Ola da classe B\n" };
};

class Main inherits IO {
    input : String;

    main() : Object {
        {
            input <- in_string();
            out_string(if input = "A" then new A else new B fi.say_hello());
        }
    };
};