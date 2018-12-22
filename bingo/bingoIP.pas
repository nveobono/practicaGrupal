program HelloWorld;

CONST
    INI=1;
    FIN=5;
    COL1=15;
    COL2=30;
    COL3=45;
    COL4=60;
    COL5=75;
TYPE
    //------------------------------------JUGADORES-------------------------------------
    TCadena = STRING [40];
    TRecords = RECORD
        numeros_acertados: integer;
        creditos_obtenidos: integer;
    END;
    TLista = ARRAY [INI..FIN] OF TRecords;
    TFecha = RECORD
        anno: word;
        mes: word;
        dia: word;
        dia_sem: word;
    END;
    TJugador = RECORD
        nombre: TCadena;
        creditos: integer;
        lista: TLista;
        fecha: TFecha;
        {nuevo: boolean;}
    END;
    //------------------------------------FIN JUGADORES----------------------------------

    TCarton = ARRAY [INI..FIN, INI..FIN] OF integer;
    TCelda = RECORD
        contenido: integer;
        acertado: boolean;
    END;
    tTab = ARRAY [INI..FIN, INI..COL2] OF TCelda;
    
    TTabla = RECORD 
        tablaGenerada: tTab;
    END;
    
VAR
    carton: TCarton;
    tabla: TTabla;

PROCEDURE generarTabla(VAR tab: TTabla);
var
    contador, i, j: integer;
BEGIN
    contador:=INI;
    FOR i:=INI TO FIN DO BEGIN
        FOR j:=INI TO COL1 DO BEGIN
            WITH tab DO BEGIN
                WITH tablaGenerada[i,j] DO BEGIN
                    contenido:= contador;
                    acertado:= FALSE;
                END;
            END;
            contador:=succ(contador);
        END;
        
    END;
END;

PROCEDURE mostrarTabla(tab: TTabla);
var
    i, j: integer;
BEGIN
    FOR i:=INI TO FIN DO BEGIN
        FOR j:=INI TO COL1 DO BEGIN
            WITH tab DO BEGIN
                    write(tablaGenerada[i,j].contenido:2, ' ');
                    
            END;
            
        END;
        writeln('');
    END;
END;

PROCEDURE repetido(a, b, x, z: integer; VAR car:TCarton);
VAR
    numGen, j, i:integer;
BEGIN
    numGen:=random(a)+b;
    FOR j:=INI TO FIN DO BEGIN
        IF(numGen=car[x,j]) THEN
            numGen:=random(a)+b
        ELSE
            car[x,z]:=numGen;
    END;
END;

PROCEDURE generarCarton;
var
    contador, i, j: integer;
BEGIN
    contador:=INI;
    FOR i:=INI TO FIN DO BEGIN
        FOR j:=INI TO FIN DO BEGIN
            CASE i OF
                1:
                    repetido(COL1, INI, i, j, carton);
                2:
                    repetido(COL1, COL1+INI, i, j, carton);
                3:
                    repetido(COL1, COL2+INI, i, j, carton);
                4:
                    repetido(COL1, COL3+INI, i, j, carton);
                5:
                    repetido(COL1, COL4+INI, i, j, carton);
            END;
        END;
        
    END;
END;

PROCEDURE mostrarCarton(car: TCarton);
var
    i, j: integer;
BEGIN
    FOR i:=INI TO FIN DO BEGIN
        FOR j:=INI TO FIN DO BEGIN
            write(car[i,j]:2, ' ');
        END;
        writeln('');
    END;
END;

PROCEDURE bienvenida;
BEGIN
    writeln('Bienvenido a BINGO');
    writeln('Que quiere hacer?');
    writeln('1- Comprar carton');
    writeln('2- Sortear numeros');
    writeln('3- Salir');
END;


begin
    RANDOMIZE;
    bienvenida;
    generarTabla(tabla);
    mostrarTabla(tabla);
    generarCarton;
    mostrarCarton(carton);
end.
