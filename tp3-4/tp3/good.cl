(*** As classes abaixo são para testar EXCLUSIVAMENTE a gramática (sintaxe) de COOL ***)

(* Testando classe sem herança e sem features *)
class ClasseVazia { };

(* Testando classe com herança e sem features *)
class ClasseComHerancaSemFeatures inherits ClasseVazia { };

(* Testando classe sem herança e com features *)
class ClasseSemHerancaComFeatures {
    io : IO <- new IO;
    meu_objeto : Object;
    meu_int : Int <- 42;

    metodo_sem_formals() : Object {
        io.out_string("metodo_sem_formals da classe ClasseSemHerancaComFeatures")
    };

    metodo_um_formal(f1 : Object) : Object {
        io.out_string("metodo_um_formal da classe ClasseSemHerancaComFeatures")
    };

    metodo_multiplos_formals(f1 : Int, f2 : String, f3 : Object) : Object {
        io.out_string("metodo_multiplos_formals da classe ClasseSemHerancaComFeatures")
    };
};

(* Testando classe com herança e com features *)
class ClasseComHerancaComFeatures inherits IO {
    meu_objeto : Object;
    meu_int : Int <- 42;

    metodo_sem_formals() : Object {
        out_string("metodo_sem_formals da classe ClasseComHerancaComFeatures")
    };

    metodo_um_formal(f1 : Object) : Object {
        out_string("metodo_um_formal da classe ClasseComHerancaComFeatures")
    };

    metodo_multiplos_formals(f1 : Int, f2 : String, f3 : Object) : Object {
        out_string("metodo_multiplos_formals da classe ClasseComHerancaComFeatures")
    };
};

(* Essa classe será usada para testarmos dispatch estático *)
class ClasseParaDispatchEstatico inherits ClasseComHerancaComFeatures {
    outro_objeto : Object;
    outro_int : Int <- 42;

    metodo_sem_formals() : Object {
        out_string("metodo_sem_formals da classe ClasseParaDispatchEstatico")
    };

    metodo_um_formal(f1 : Object) : Object {
        out_string("metodo_um_formal da classe ClasseParaDispatchEstatico")
    };

    metodo_multiplos_formals(f1 : Int, f2 : String, f3 : Object) : Object {
        out_string("metodo_multiplos_formals da classe ClasseParaDispatchEstatico")
    };
};

(* Testando todas as possíveis expressões (usaremos blocos para facilitar) *)
class ClasseComTodasAsExpressoes inherits IO {
    int : Int;
    bool : Bool;
    string : String;
    object : Object;
    teste_dispatch : ClasseParaDispatchEstatico;

    metodo_sem_formals() : Object {
        out_string("metodo_sem_formals da classe ClasseComTodasAsExpressoes")
    };

    metodo_um_formal(f1 : Object) : Object {
        out_string("metodo_um_formal da classe ClasseComTodasAsExpressoes")
    };

    metodo_multiplos_formals(f1 : Int, f2 : String, f3 : Object) : Object {
        out_string("metodo_multiplos_formals da classe ClasseComTodasAsExpressoes")
    };

    metodo_todas_expressoes_em_bloco() : Object {
        {
            (* Testando expressão como atribuição *)
            int <- 3;
            bool <- false;
            string <- "Minha String";
            teste_dispatch <- new ClasseParaDispatchEstatico;

            (* Testando expressões de dispatch *)
            teste_dispatch.metodo_sem_formals();
            teste_dispatch.metodo_um_formal(object);
            teste_dispatch.metodo_multiplos_formals(int, string, object);

            (* Testando expressões de dispatch estático *)
            teste_dispatch@ClasseComHerancaComFeatures.metodo_sem_formals();
            teste_dispatch@ClasseComHerancaComFeatures.metodo_um_formal(object);
            teste_dispatch@ClasseComHerancaComFeatures.metodo_multiplos_formals(int, string, object);

            (* Testando expressões de chamada de método sem expr no começo *)
            metodo_sem_formals();
            metodo_um_formal(object);
            metodo_multiplos_formals(int, string, object);

            (* Testando expressão como condicional *)
            if bool = true then
                out_string("bool assumiu valor true")
            else
                out_string("bool assumiu valor false")
            fi;

            (* Testando expressão como loop *)
            while 0 < int loop {
                out_string("Valor de int: ");
                out_int(int);
                out_string("\n");

                int <- int - 1;
            } pool;

            (* Testando expressão como let *)
            let x : Int in "Placeholder";
            let x : Int <- 10 in x + 10;
            let x : Int, y : Int in "Placeholder";
            let x : Int, y : Int <- 10 in "Placeholder";
            let x : Int <- 10, y : Int <- 10 in x + y;
            let x : Int, y : String, z : Bool in "Placeholder";
            let x : Int <- 10 in let y : Int <- 10 in x + y;

            (* Testando expressão como case *)
            case int of x : Int => out_string("Foi selecionado x\n"); esac;
            case bool of 
                x : Int => out_string("Foi selecionado x\n");
                default : Object => out_string("Foi selecionado default\n");
            esac;
        
            (* Testando expressão como new e isvoid *)
            new ClasseVazia;
            isvoid object;

            (* Testando expressões aritméticas e lógicas *)
            int + 10;
            20 - int;
            (~1) * int;
            int / 1;
            ~10;
            int < 10;
            int <= 20;
            int = 30;
            not bool;

            (* Testando expressão em parênteses *)
            ( 10 );

            (* Testando restante das expressões *)
            string;
            42;
            "string placeholder";
            true;
            false;

            (* Aqui teremos algumas expressões sintaticamente corretas mas semanticamente incorretas *)
            (* Favor remover esses testes caso queira executar esse arquivo com o compilador completo! *)
            let x : Int <- 10, y : String <- "abc" in x + y;
            not 10;
            ~true;
            not "isso esta semanticamente errado!";
            if 10 then "expr1" else "expr2" fi;
        }
    };
};

(* Testando uma expressão mais complexa *)
class X inherits IO {
    metodo() : Object { out_string("Ola da classe X\n") };
};

class Y inherits IO {
    metodo() : Object { out_string("Ola da classe Y\n") };
};

class TesteComplexo {
    x : Int <- 10;

    feature() : Object {
        (if x = 10 then (new X) else (new Y) fi).metodo()
    };
};

(*** Logo abaixo nós temos um programa "mais útil" que computa o Fibonnaci de N >= 0 ***)
class PrettyPrint inherits IO {
    print(str: String, val: Int) : Object {
        {
            out_string("\n");
            out_string(str);
            out_int(val);
            out_string("\n");
        }
    };
};

class Main inherits IO {
    n : Int;
    printer : PrettyPrint <- new PrettyPrint;

    fib(n : Int) : Int {
        if n = 0
            then 0
        else
            if n = 1
                then 1
            else
                fib(n-1) + fib(n-2)
            fi
        fi
    };

    main() : Object {
        {
            out_string("Insira um valor de N positivo: ");
            n <- in_int();

            printer.print("Valor computado = ", fib(n));
        }
    };
};