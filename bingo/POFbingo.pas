program BingoIP;
USES CRT;
CONST
    INI=1;
    FIN=5;
    COL1=15;
    COL2=30;
    COL3=45;
    COL4=60;
    COL5=75;
TYPE
    {------------------------------------JUGADORES-------------------------------------}
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
    TJugadores = RECORD
        jugador: TJugador;
        numeroJ: integer;
    END;
    {------------------------------------FIN JUGADORES----------------------------------}

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
    jgs: TJugadores;

PROCEDURE generarTabla(VAR tab: TTabla);
VAR
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
VAR
    i, j: integer;
BEGIN
	writeln('ESTO ES EL TABLERO');
	writeln;
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
    esRepetido: boolean;
BEGIN
    numGen:=random(a)+b;
    esRepetido:=FALSE;
    FOR j:=INI TO z DO BEGIN
        IF(numGen=car[x,j]) THEN BEGIN
            esRepetido:=TRUE;
        END;
    END;
        IF NOT esRepetido THEN
        	car[x,z]:=numGen
        ELSE
        	repetido(a, b, x, z, car);
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

PROCEDURE mostrarCarton(car: TCarton; num: integer);
var
    i, j: integer;
BEGIN
	writeln('ESTO ES TU CARTON Nº ', num);
	writeln;
    FOR i:=INI TO FIN DO BEGIN
        FOR j:=INI TO FIN DO BEGIN
            write(car[i,j]:2, ' ');
        END;
        writeln('');
    END;
END;

PROCEDURE comprarCarton;
VAR
	nCartones, j: integer;
	valido: boolean;
BEGIN
	valido:= FALSE;
	REPEAT
		writeln('¿Cuantos cartones quiere para esta partida?(de 1 a 4)');
		readln(nCartones);
		IF(nCartones>=1)AND(nCartones<=4) THEN
			valido:=TRUE;
	UNTIL valido;
	IF(valido) THEN BEGIN
		FOR j:=INI TO nCartones DO BEGIN
			generarCarton;
			mostrarCarton(carton, j);
		END;
	END;
END;

{----------------------------------------INICIO VerificarV----------------------------------------}
FUNCTION VerificarV (t: TTabla; numero: integer): boolean;

VAR
	i, j: integer;
	ok: boolean;
BEGIN
	j:= INI;
	REPEAT
		i:= INI;
		ok:= TRUE;
		REPEAT
			WITH t DO BEGIN
				ok:= (tablaGenerada[i,j].contenido = numero);
			END;
			i:= SUCC(i);
		UNTIL (i= FIN + 1) OR (NOT ok);
		j:= SUCC(j);
	UNTIL (j=FIN + 1) OR (ok);
	VerificarV := ok;
END;

{----------------------------------------INICIO VerificarH----------------------------------------}
FUNCTION VerificarH (t: TTabla; numero: integer): boolean;

VAR
	i, j: integer;
	ok: boolean;
BEGIN
	i:= INI;
	REPEAT
		j:=	INI;
		ok:= TRUE;
		REPEAT
			WITH t DO BEGIN
				ok:= (tablaGenerada[i,j].contenido = numero);
			END;
			j:= SUCC(j);
		UNTIL (j= FIN + 1) OR (NOT ok);
		i:= SUCC(i);
	UNTIL (i= FIN + 1) OR (ok);
	VerificarH := ok;
END;
{----------------------------------------INICIO VerificarDI----------------------------------------}
FUNCTION VerificarDI(t: TTabla; numero: integer): boolean;

VAR
	i, j: integer;
	ok: boolean;
BEGIN
	i:= INI; j:= FIN; ok:= FALSE;
	REPEAT
		WITH t DO BEGIN
			ok:= (tablaGenerada[i,j].contenido = numero);
		END;
		i:= SUCC(i);
		j:= PRED(j);
	UNTIL (i= FIN + 1) OR (NOT ok);
	VerificarDI := ok;
END;

{----------------------------------------INICIO VerificarDD----------------------------------------}
FUNCTION VerificarDD (t: TTabla; numero: integer): boolean;

VAR
	i, j: integer;
	ok: boolean;
BEGIN
	i:= INI; j:= INI; ok:= FALSE;
	REPEAT
		WITH t DO BEGIN
			ok:= (tablaGenerada[i,j].contenido = numero);
		END;
		i:= SUCC(i);
		j:= SUCC(j);
	UNTIL (i= FIN + 1) OR (NOT ok);
	VerificarDD := ok;
END;

FUNCTION sortearNumero: integer;
BEGIN
	sortearNumero:=random(COL5)+INI;
END;

PROCEDURE tachar(VAR tab: TTabla);
VAR
	bola, i, j: integer;
BEGIN
	bola:=sortearNumero;
	writeln('El numero sorteado es: ', bola);
	FOR i:=INI TO 5 DO BEGIN
		FOR j:=INI TO 15 DO BEGIN
			WITH tab DO BEGIN
				IF tablaGenerada[i, j].contenido=bola THEN
					tablaGenerada[i, j].contenido:=0;
			END;
		END;
	END;
	mostrarTabla(tab);
END;

PROCEDURE insrtCoo;
VAR
	x,y,nCarton: integer;
BEGIN
	writeln('¿En que carton va a seleccionar sus coordenadas?');
	readln(nCarton);
	writeln('Inserte las coordenadas de su carton preferido: ');
	readln(x, y);
END;

PROCEDURE jugadores(VAR nJ: TJugadores);
VAR
	nJug: integer;
	valido: boolean;
BEGIN
	valido:= FALSE;
	REPEAT
		writeln('Inserte el numero de los jugadores(de 1 a 3): ');
		readln(nJug);
		IF (nJug<=3) AND (nJug>=1) THEN
			valido:=TRUE;
	UNTIL valido;
	IF valido THEN
		nJ.numeroJ:=nJug;
END;

PROCEDURE bienvenida;
VAR
	entrada: integer;
BEGIN
	REPEAT
	    writeln('Bienvenido a BINGO');
	    writeln('Que quiere hacer?');
	    writeln('1- Comprar carton');
	    writeln('2- Sortear numeros');
	    writeln('3- Insertar coordenadas');
	    writeln('4- Numero de jugadores');
	    writeln('5- Salir');
	    readln(entrada);
	    CASE entrada OF
	    	1:
	    	BEGIN
	    		comprarCarton;
	    	END;
	    	2:
	    	BEGIN
	    		generarTabla(tabla);
	    		tachar(tabla);
	    	END;
	    	3:
	    	BEGIN
	    		insrtCoo;
	    	END;
	    	4:
	    	BEGIN
	    		jugadores(jgs);
	    	END;
	    END;
    UNTIL(entrada=5);
    readln;
END;


BEGIN
	CLRSCR;
    RANDOMIZE;
    bienvenida;
    readln;
END.
