PROGRAM Bingo;
USES CRT;
CONST
    INI = 1;
    FIN = 5;
    COL1 = 15;
    COL2 = 30;
    COL3 = 45;
    COL4 = 60;
    COL5 = 75;
    MINPPC = 20;
    MAXPPC = 100;
    NBOTS = 3;
    CREDINI = 25;
	TOPE = 10;
TYPE
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
        nuevo: boolean;
		partidas: integer;
    END;

	TListaJugadores = ARRAY [0..TOPE] OF TJugador;
	TFicheroJugador = FILE OF TJugador;

	TCelda = RECORD
        contenido: integer;
        acertado: boolean;
	END;
    TCarton = ARRAY [INI..FIN, INI..FIN] OF TCelda;


    tTab = ARRAY [INI..FIN, INI..COL2] OF TCelda;
    TTabla = RECORD
        tablaGenerada: tTab;
    END;

VAR
    carton: TCarton;
    tabla: TTabla;
    jugador: TJugador;
	fichero: TFicheroJugador;
	lista: TListaJugadores;
	topeJugadores, numeros_aciertos: integer;

PROCEDURE repetido(a, b, x, z: integer; VAR car:TCarton);
VAR
    numGen, j, i:integer;
    esRepetido: boolean;
BEGIN
    numGen:=random(a)+b;
    esRepetido:=FALSE;
    FOR j:=INI TO z DO
    BEGIN
	    WITH car[x,j] DO
	    BEGIN
	        IF(numGen=contenido) THEN
	        BEGIN
	            esRepetido:=TRUE;
	        END;
	    END;
    END;
    IF NOT esRepetido THEN
    	WITH car[x, z] DO
    		BEGIN
       			contenido:=numGen;
       		END
    ELSE
       repetido(a, b, x, z, car);
END;

FUNCTION VerificarV (c: TCarton): boolean;
VAR
	i, j: integer;
	ok: boolean;
BEGIN
	j:= INI;
	REPEAT
		i:= INI;
		ok:= TRUE;
		REPEAT
			WITH c[i,j] DO BEGIN
				ok:= (acertado = TRUE);
			END;
			i:= SUCC(i);
		UNTIL (i= FIN + 1) OR (NOT ok);
		j:= SUCC(j);
	UNTIL (j=FIN + 1) OR (ok);
	VerificarV := ok;
END;

FUNCTION VerificarH (c: TCarton): boolean;
VAR
	i, j: integer;
	ok: boolean;
BEGIN
	i:= INI;
	REPEAT
		j:=	INI;
		ok:= TRUE;
		REPEAT
			WITH c[i,j] DO BEGIN
				ok:= (acertado = TRUE);
			END;
			j:= SUCC(j);
		UNTIL (j= FIN + 1) OR (NOT ok);
		i:= SUCC(i);
	UNTIL (i= FIN + 1) OR (ok);
	VerificarH := ok;
END;

FUNCTION VerificarDI(c: TCarton): boolean;
VAR
	i, j: integer;
	ok: boolean;
BEGIN
	i:= INI; j:= FIN; ok:= FALSE;
	REPEAT
		WITH c[i,j] DO BEGIN
			ok:= (acertado = TRUE);
		END;
		i:= SUCC(i);
		j:= PRED(j);
	UNTIL (i= FIN + 1) OR (NOT ok);
	VerificarDI := ok;
END;

FUNCTION VerificarDD (c: TCarton): boolean;
VAR
	i, j: integer;
	ok: boolean;
BEGIN
	i:= INI; j:= INI; ok:= FALSE;
	REPEAT
		WITH c[i,j] DO BEGIN
			ok:= (acertado = TRUE);
		END;
		i:= SUCC(i);
		j:= SUCC(j);
	UNTIL (i= FIN + 1) OR (NOT ok);
	VerificarDD := ok;
END;

PROCEDURE generarTabla(VAR tab: TTabla; acer: boolean);
VAR
    contador, i, j: integer;
BEGIN
    contador:=INI;
    FOR i:=INI TO FIN DO BEGIN
        FOR j:=INI TO COL1 DO BEGIN
            WITH tab DO BEGIN
                WITH tablaGenerada[i,j] DO BEGIN
                    contenido:= contador;
                    acertado:= acer;
                END;
            END;
            contador:=succ(contador);
        END;
    END;
END;

PROCEDURE insertarCoo(VAR car: TCarton; numSor: integer; tab: TTabla);
VAR
	x,y, i, j: integer;
	valido: boolean;
	intento: char;
BEGIN
	valido:=FALSE;
	REPEAT
		writeln('Inserte las coordenadas (x,y): ');
		readln(x, y);
		writeln(car[y,x].contenido);
		WITH car[y,x] DO BEGIN
			IF contenido=numSor THEN BEGIN
				acertado:=TRUE;
				generarTabla(tab, acertado);
				valido:=TRUE;
			END
			ELSE BEGIN
				writeln('No se encuentra las coordenadas (',x,',',y,'), �vuelve a intentar?(s/n)');
				readln(intento);
			END;
		END;
	UNTIL (valido) OR (intento='n');
END;

PROCEDURE eleccionInsertar(nS: integer; tab: TTabla);
VAR
	entrada: char;
BEGIN
	REPEAT
		writeln('�Quiere insertar coordenadas en su carton? S/N');
		readln(entrada);
	UNTIL(entrada='s') OR (entrada='n');
	IF entrada='s' THEN
		insertarCoo(carton, nS, tab)
	ELSE IF entrada='n' THEN
		writeln('Siguiente numero...');
END;

PROCEDURE crearCarton(VAR car: TCarton);
VAR
    contador, i, j, y: integer;
BEGIN
    contador:=INI;
    FOR i:=INI TO FIN DO BEGIN
        FOR j:=INI TO FIN DO BEGIN
            CASE i OF
                1:
                    repetido(COL1, INI, i, j, car);
                2:
                    repetido(COL1, COL1+INI, i, j, car);
                3: BEGIN
                	repetido(COL1, COL2+INI, i, j, car);
   					WITH car[3,3] DO BEGIN
        				acertado:=TRUE;
        				contenido:=0;
   					END;
                   END;
                4:
                    repetido(COL1, COL3+INI, i, j, car);
                5:
                    repetido(COL1, COL4+INI, i, j, car);
            END;
        END;
    END;
END;

PROCEDURE mostrarCarton(carton: TCarton);
VAR
    i, j: integer;
    bingo: string[5];
BEGIN
	bingo:='BINGO';
    FOR i:=INI TO FIN DO BEGIN
    write(' ', bingo[i],' ');
        FOR j:=INI TO FIN DO BEGIN
            write(carton[i,j].contenido:2, ' ');
        END;
        writeln('');
    END;
END;

PROCEDURE mostrarTabla(tab: TTabla);
VAR
    i, j: integer;
    bingo: string[5];
BEGIN
	bingo:='BINGO';
	writeln('TABLERO');
	writeln;
    FOR i:=INI TO FIN DO BEGIN
    	write(' ', bingo[i], ' ');
        FOR j:=INI TO COL1 DO BEGIN
            WITH tab DO BEGIN
                    write(tablaGenerada[i,j].contenido:2, ' ');
            END;
        END;
        writeln('');
    END;
END;

FUNCTION ficheroExiste (VAR fichero: TFicheroJugador): boolean;
BEGIN
	{$I-}
	RESET(fichero);
	{$I+}
	ficheroExiste := (IORESULT = 0);
END;

PROCEDURE cargarDatos(VAR fichero: TFicheroJugador; VAR l: TListaJugadores; VAR n: integer);
VAR
	jugador: TJugador;
	i: integer;
BEGIN
	ASSIGN(fichero, 'jugadores.dat');
	IF NOT ficheroExiste(fichero) THEN
		REWRITE(fichero);
	n := FILESIZE(fichero) - 1;
	FOR i := 0 TO n DO
	BEGIN
		SEEK(fichero, i);
		READ(fichero, jugador);
		l[i] := jugador;
	END;
	CLOSE(fichero);
END;

PROCEDURE guardarDatos(jugador: TJugador; VAR fichero: TFicheroJugador; buscar: boolean; n: integer);
BEGIN
	ASSIGN(fichero, 'jugadores.dat');
	IF NOT ficheroExiste(fichero) THEN
		REWRITE(fichero);
	IF buscar THEN
		BEGIN
			SEEK(fichero, n);
			WRITE(fichero, jugador);
		END
	ELSE
		BEGIN
			SEEK(fichero, FILESIZE(fichero));
			WRITE(fichero, jugador);
		END;
END;

FUNCTION sortearNumero: integer;
BEGIN
	sortearNumero:=random(COL5)+INI;
END;

PROCEDURE generarNumTabla(VAR tab: TTabla);
VAR
	bola, i, j, contador, aux: integer;
	repe: boolean;
BEGIN
	repe:=TRUE;
	REPEAT
		bola:=sortearNumero;
		FOR i:=INI TO FIN DO BEGIN
			FOR j:=INI TO COL1 DO BEGIN
				WITH tab DO BEGIN
					IF (tablaGenerada[i, j].contenido=bola) THEN BEGIN
						tablaGenerada[i, j].contenido:=0;
						{contador:=succ(contador);}
						repe:=FALSE;
					END;
					{aux:=tablaGenerada[i, j].contenido;
					finPartida:= VerificarDD(tab) OR VerificarDI(tab)
									OR VerificarH(tab) OR VerificarV(tab)
										OR (contador=75);}
				END;
			END;
		END;
	UNTIL NOT repe AND (contador<=75);
	IF NOT repe THEN
		writeln('El numero sorteado es: ', bola);
	mostrarTabla(tab, bola);
END;

PROCEDURE juego(bote: integer);
VAR
	contador: integer;
	final: boolean;
BEGIN
	contador:=0;final:=FALSE;
		writeln('*********************************************************************');
		writeln('+++++++++++ El bote es de ', bote,' creditos, A POR ELLO! +++++++++++');
		writeln('*********************************************************************');
	writeln('A continuacion se sortearan los numeros(pulsa [ENTER])');
	readln;
	REPEAT
		generarNumTabla(tabla);
		contador:=SUCC(contador);
		writeln('CONTADOR ', contador);
		final:= VerificarDD(carton) OR VerificarDI(carton)
									OR VerificarH(carton) OR VerificarV(carton);

	UNTIL final OR (contador=75);
	IF contador=75 THEN BEGIN
		writeln('No hay mas numeros para sortear.');
		writeln('*********************************************************************');
		writeln('**********************- Se acabo la partida -************************');
		writeln('*********************************************************************');
	END
	ELSE IF final THEN
		writeln('*********************************************************************');
		writeln('**********************- LINEA! GANASTE -************************');
		writeln('*********************************************************************');
END;

PROCEDURE generarCartonesBots(VAR nJ: TJugadores; VAR bote: integer;
								apuesta: integer; VAR carton: TCarton);
VAR
	nJug, nCar, nCred, i, j: integer;
BEGIN

	nJug:= RANDOM(NBOTS)+INI;
	FOR i:=1 TO nJug DO BEGIN
		nJ[i].nombre:='Bot';
		nCar:= RANDOM(4)+1;
		FOR j:=1 TO nCar DO BEGIN
			nCred:=RANDOM(100)+21;
			writeln(nJ[i].nombre, i, ' tiene un carton de ', nCred, ' creditos. Suerte!');
			bote:=bote+nCred;
		END;
	END;
	bote:=bote+apuesta;
	juego(bote);
END;

PROCEDURE comprarCarton(minCreditos, maxCreditos: integer; VAR jgdr: TJugador);
VAR
	valido: boolean;
	apuesta, cantidad, bote: integer;
	comprar: char;
BEGIN
	bote:=0;
	writeln('Minimo de creditos por cada carton: ', minCreditos);
	writeln('Minimo de creditos por cada carton: ', maxCreditos);
	writeln('Credito actual ', jgdr.creditos);
	REPEAT
		writeln('Cuantos creditos quiere apostar por este carton?');
		readln(apuesta);
		IF (apuesta<minCreditos)OR(apuesta>maxCreditos) THEN
			valido:=FALSE
		ELSE BEGIN
			writeln('Insuficientes creditos, �comprar?(s/n)');
			readln(comprar);
			IF comprar='s' THEN BEGIN
				writeln('Cantidad:');
				readln(cantidad);
				jgdr.creditos:=jgdr.creditos+cantidad;
				valido:=(apuesta>=minCreditos)AND(apuesta<=maxCreditos)
					AND(jgdr.creditos>=apuesta);
			END;
		END;
	UNTIL valido;
	IF valido THEN BEGIN
		jgdr.creditos:=jgdr.creditos-apuesta;
		writeln('Ha elegido este carton por ', apuesta, ' creditos, te quedan ', jgdr.creditos);
		crearCarton(carton);
		mostrarCarton(carton);
		writeln('A continuacion se generaran los cartones de los otros jugadores',
		' y los creditos que apostaron(pulsa [ENTER])');
		readln;
		generarCartonesBots(jgs, bote, apuesta, carton);
	END;
END;

PROCEDURE datosJugador(VAR nJ: TJugadores);
VAR
	nJug, i: integer;
	valido, nue: boolean;
	novato: char;
BEGIN
	writeln('Escribe tu nombre');
	readln(nJ[INI].nombre);
	writeln(nJ[INI].nombre,', BIENVENIDO A BINGO.');
	REPEAT
		writeln('Es la primera vez que juegas al bingo?(s/n)');
		readln(novato);
	UNTIL (novato='s') OR (novato='n');
	IF (novato='s') THEN
		nue:=TRUE
	ELSE IF (novato='n') THEN
		nue:=FALSE;
	nJ[INI].nuevo:=nue;
	writeln(nJ[INI].nuevo);
END;

PROCEDURE bienvenida;
VAR
	entrada, x: integer;
	acertado: boolean;
BEGIN
	acertado:=FALSE;
	generarTabla(tabla, acertado);
	x:=1;
	writeln('Bienvenido a BINGO');
	datosJugador(jgs);
	REPEAT
	    writeln('Que quiere hacer?');
	    writeln('1- Jugar');
	    writeln('2- Ver ranking');
	    writeln('5- Salir');
	    readln(entrada);
	    CASE entrada OF
	    	1:
	    	BEGIN
	    		comprarCarton(MINPPC, MAXPPC, jugador);
	    	END;
	    	2:
	    	BEGIN
	    		{generarNumTabla(tabla);}
	    		writeln('Aun no se ha hecho');
	    	END;
	    END;
    UNTIL(entrada=5);
	IF entrada=5 THEN
		guardarDatos();
    readln;
END;
BEGIN
    RANDOMIZE;
	writeln('Hola mundo');

	crearCarton(carton);
	mostrarCarton(carton);
	 bienvenida;
readln;
END.
