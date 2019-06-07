PROGRAM PracticaBingo;
USES DOS;
CONST
    INI=1;
    FIN=5;
    COL1=15;
    COL2=30;
    COL3=45;
    COL4=60;
    COL5=75;
    MINPPC=20;
    MAXPPC=100;
    NBOTS=3;
    CREDINI=25;
    TOPE=10;
TYPE
    (*------------------------------------JUGADORES-------------------------------------*)

    TRecords = RECORD
        numeros_acertados: integer;
        creditos_obtenidos: integer;
    END;
    TLista = ARRAY [INI..FIN] OF TRecords;
    TCadena = STRING [40];
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

	TListaJugadores = ARRAY[0..TOPE] OF TJugador;

    TFicheroJugador = FILE OF TJugador;

    (*------------------------------------FIN JUGADORES----------------------------------*)

	(*------------------------------------CARTON/TABLA-----------------------------------*)
	TCelda = RECORD
        contenido: integer;
        acertado: boolean;
	END;
    TCarton = ARRAY [INI..FIN, INI..FIN] OF TCelda;


    tTab = ARRAY [INI..FIN, INI..COL2] OF TCelda;
    TTabla = RECORD
        tablaGenerada: tTab;
    END;
    (*----------------------------------FIN CARTON/TABLA----------------------------------*)
VAR
	carton: TCarton;
    tabla: TTabla;
    jugador: TJugador;
    fich: TFicheroJugador;
    lista: TListaJugadores;
    topeJugadores, n_acertados: integer;

PROCEDURE generarTabla(VAR tab: TTabla; acer: boolean);	{PROCEDIMIENTO DE GENERACION DE LA TABLA 5x15}
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

PROCEDURE mostrarTabla(tab: TTabla);	{PROCEDIMIENTO GENERAL QUE MUESTRA LA TABLA DE 5x15}
var
    i, j: integer;
    bingo: string[5];
BEGIN
	bingo:='BINGO';
	writeln('ESTO ES EL TABLERO');
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

PROCEDURE insrtCoo(VAR car: TCarton; bola: integer; tab: TTabla);	{PROCEDIMIENTO QUE COMPRUEBA LA BOLA CON LA COORDENADA INSERTADA DEL JUGADOR}
VAR
	x, y, i, j: integer;
	valido: boolean;
	intento: char;
BEGIN
	valido:=FALSE;
	REPEAT
		writeln('Inserte las coordenadas de su carton preferido(x,y): ');
		readln(x, y);
		writeln(car[y,x].contenido);
		WITH car[y,x] DO BEGIN
			IF contenido=bola THEN BEGIN
				acertado:=TRUE;
				n_acertados:=succ(n_acertados);
				writeln('Buena!');
				generarTabla(tab, acertado);
				valido:=TRUE;
			END
			ELSE BEGIN
				writeln('No se encuentra el numero en las coordenadas (',x,',',y,'), volver a intentar?(s/n)');
				readln(intento);
			END;
		END;
	UNTIL (valido) OR (intento='n');
END;

FUNCTION eleccionInsertar: boolean;	{FUNCION QUE DEVUELVE SI EL JUGADOR DESEA INSERTAR LAS COORDENADAS DE SU CARTON}
VAR
	entrada: char;
BEGIN
	REPEAT
		writeln('Quiere insertar las coordenadas en su carton? S/N');
		readln(entrada);
	UNTIL(entrada='s') OR (entrada='n');
	IF entrada='s' THEN
		eleccionInsertar:=TRUE
	ELSE IF entrada='n' THEN
		eleccionInsertar:=FALSE;
END;

FUNCTION sortearNumero: integer;
BEGIN
	sortearNumero:=random(COL5)+INI;
END;
{_______________________________________________________VERIFICACIONES_DE_BINGO_______________________________________________________}
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
{___________________________________________________FIN_VERIFICACIONES_DE_BINGO_______________________________________________________}

FUNCTION gananBots(bolaBots: integer; VAR numeroBots: integer):boolean;	{FUNCION QUE DEVUELVE SI UNO DE LOS BOTS GANA LA PARIDA}
VAR
	aux1, aux2: integer;
BEGIN
	aux1:=random(COL5*23)+INI;
	aux2:=random(numeroBots)+INI;
	IF aux1 = aux2 THEN
		gananBots:= TRUE
	ELSE gananBots:= FALSE;

	numeroBots:=aux2;
END;

PROCEDURE generarNumTabla(VAR tab: TTabla; VAR car: TCarton; VAR bolaBots: integer);	{GENERA LA BOLA CON EL NUMERO SORTEADO}
VAR
	bola, i, j, contador, aux: integer;
	repe: boolean;
BEGIN
	repe:=TRUE;
	REPEAT
		bolaBots:= sortearNumero;
		bola:= sortearNumero;
		FOR i:=INI TO FIN DO BEGIN
			FOR j:=INI TO COL1 DO BEGIN
				WITH tab DO BEGIN
					IF (tablaGenerada[i, j].contenido=bola) THEN BEGIN
						tablaGenerada[i, j].contenido:=0;
						repe:=FALSE;
					END;
				END;
			END;
		END;
	UNTIL NOT repe AND (contador<=75);
	IF NOT repe THEN
		writeln('El numero sorteado es: ', bola);
	mostrarTabla(tab);
	IF eleccionInsertar THEN
		insrtCoo(car, bola, tab)
	ELSE
		writeln('Siguiente numero...');
END;

PROCEDURE repetido(a, b, x, z: integer; VAR car:TCarton);	{PROCEDIMIENTO PARA QUE NO SE REPITA EL NUMERO ALEATORIO DE CADA CELDA DEL CARTON}
VAR
    numGen, j, i:integer;
    esRepetido: boolean;
BEGIN
    numGen:=random(a)+b;
    esRepetido:=FALSE;
    FOR j:=INI TO z DO BEGIN
	    WITH car[x,j] DO BEGIN
	        IF(numGen=contenido) THEN BEGIN
	            esRepetido:=TRUE;
	        END;
	    END;
    END;
        IF NOT esRepetido THEN
        	car[x,z].contenido:=numGen
        ELSE
        	repetido(a, b, x, z, car);
END;

PROCEDURE generarCarton(VAR car: TCarton);	{GENERA EL CARTON AL JUGADOR PRINCIPAL}
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
END;{------------------------------------------ FIN GENERA EL CARTON AL JUGADOR PRINCIPAL}

PROCEDURE mostrarCarton(car: TCarton);	{MOSTRAR EL CARTON GENERADO DEL JUGADOR PRINCIPAL}
var
    i, j: integer;
    bingo: string[5];
BEGIN
	bingo:='BINGO';
    FOR i:=INI TO FIN DO BEGIN
    write(' ', bingo[i],' ');
        FOR j:=INI TO FIN DO BEGIN
            write(car[i,j].contenido:2, ' ');
        END;
        writeln('');
    END;
END;

PROCEDURE juego(bote: integer; VAR player: TJugador; rango: integer; numBots: integer; car: TCarton);	{JUEGO PRINCIPAL}
VAR
	contador, aux, i, j, k, contador2, bolaBots: integer;
	numAux, numAux2: TRecords;
	final, finalBots, okey: boolean;
BEGIN
	contador:=0;final:=FALSE;n_acertados:=0;okey:=FALSE;
	generarTabla(tabla, okey);
		writeln('*********************************************************************');
		writeln('+++++++++++ El bote es de ', bote,' creditos, A POR ELLO! +++++++++++');
		writeln('*********************************************************************');
	writeln('A continuacion se sortearan los numeros(pulsa [ENTER])');
	readln;
	REPEAT
		contador:=SUCC(contador);
		writeln('CONTADOR ', contador);
		generarNumTabla(tabla, car, bolaBots);
		mostrarCarton(car);
		final:= VerificarDD(car) OR VerificarDI(car) OR VerificarH(car) OR VerificarV(car);
		finalBots:= gananBots(bolaBots, numBots);
	UNTIL final OR finalBots OR (contador=75);
	IF contador=75 THEN BEGIN
		writeln('No hay mas numeros para sortear.');
		writeln('*********************************************************************');
		writeln('**********************- Se acabo la partida -************************');
		writeln('*********************************************************************');
	END
	ELSE IF final THEN BEGIN
		writeln('*********************************************************************');
		writeln('**********************- LINEA! GANASTE -************************');
		writeln('*********************************************************************');
		writeln('Numeros acertados: ', n_acertados);
		writeln('PREMIO: ', bote);
		i:=INI;
		numAux.numeros_acertados:=n_acertados;
		numAux.creditos_obtenidos:=bote;
		player.creditos:=player.creditos+bote;
		WHILE ((i<=FIN) AND (NOT okey)) DO BEGIN
			IF((player.lista[i].numeros_acertados=0)
					AND (player.lista[i].creditos_obtenidos=0)) THEN BEGIN
				player.lista[i]:=numAux;
				okey:=TRUE;
			END
			ELSE IF((n_acertados<=player.lista[i].numeros_acertados)
					AND (bote>=player.lista[i].creditos_obtenidos)) THEN BEGIN
				numAux2:=player.lista[i];
				player.lista[i]:=numAux;
				player.lista[i+1]:=numAux2;
				okey:=TRUE;
			END ELSE
				i:=succ(i);
		END;
	END
	ELSE BEGIN
		writeln('*********************************************************************');
		writeln('*****************- HA GANADO EL BOT ', numBots,'-*******************');
		writeln('*********************************************************************');
	END;
END;	{---------------------------------------------------------------------------------------------------FIN JUEGO PRINCIPAL}

PROCEDURE generarCartonesBots(VAR bote: integer; apuesta: integer; VAR player: TJugador; rango: integer; VAR numBots: integer);	{GENERACION DE CARTONES DE LOS BOTS}
VAR
	nJug, nCar, nCred, i, j: integer;
	l: TListaJugadores;
BEGIN

	nJug:= RANDOM(NBOTS)+INI;
	FOR i:=1 TO nJug DO BEGIN
		l[i].nombre:='Bot';
		nCar:= RANDOM(4)+1;
		FOR j:=1 TO nCar DO BEGIN
			nCred:=RANDOM(100)+21;
			writeln(l[i].nombre, j, ' tiene un carton de ', nCred, ' creditos. Suerte!');
			bote:=bote+nCred;
		END;
	END;
	numBots:=nJug;
	bote:=bote+apuesta;
END;

PROCEDURE comprarCarton(minCreditos, maxCreditos: integer; VAR jgdr: TJugador; rango: integer; l: TListaJugadores; VAR car: TCarton);	{PREPARACIONES PARA JUGAR AL BINGO}
VAR
	valido: boolean;
	apuesta, cantidad, bote, numBots: integer;
	comprar: char;
BEGIN
	bote:=0;valido:=FALSE;apuesta:=0;
	writeln('Minimo de creditos por cada carton: ', minCreditos);
	writeln('Maximo de creditos por cada carton: ', maxCreditos);
	writeln('Credito actual ', jgdr.creditos);
	REPEAT
		writeln('Cuantos creditos quiere apostar por este carton?');
		readln(apuesta);
		IF ((apuesta>=minCreditos) AND (apuesta<=maxCreditos) AND (apuesta<=jgdr.creditos)) THEN
			valido:=TRUE
		ELSE IF (apuesta<minCreditos) OR (apuesta>maxCreditos) THEN
			valido:=FALSE
		ELSE IF (apuesta>jgdr.creditos) THEN BEGIN
			REPEAT
				writeln('Insuficientes creditos, comprar?(s/n)');
				readln(comprar);
			UNTIL ((comprar='s') OR (comprar='n'));
			IF comprar='s' THEN BEGIN
				REPEAT
					writeln('Cantidad:');
					readln(cantidad);
					jgdr.creditos:=jgdr.creditos+cantidad;
					valido:=((apuesta>=minCreditos)AND(apuesta<=maxCreditos)
						AND(jgdr.creditos>=apuesta));
				UNTIL valido;
			END
			ELSE IF (comprar='n') THEN
				valido:=FALSE;
		END;
	UNTIL valido;
	IF valido THEN BEGIN
		jgdr.creditos:=jgdr.creditos-apuesta;
		writeln('Ha elegido este carton por ', apuesta, ' creditos, te quedan ', jgdr.creditos);
		generarCarton(car);
		mostrarCarton(car);
		writeln('A continuacion se generaran los cartones de los otros jugadores',
		' y los creditos que apostaron(pulsa [ENTER])');
		readln;
		generarCartonesBots(bote, apuesta, jgdr, rango, numBots);
		juego(bote, jgdr, rango, numBots, car);
	END;
END;	{----------------------------------------------------------------------------------------------------------FIN PREPARACIONES PARA JUGAR AL BINGO}

PROCEDURE mostrarRanking(l: TListaJugadores);	{PROCEDIMIENTO PARA VER EL RANKING DE 10 JUGADORES}
VAR
	i, j, k, cred_obt, num_acert: integer;
	dia_semana: string;
BEGIN
	writeln('***************TOP ', TOPE, ' MEJORES JUGADORES***************');
	FOR i:=0 TO TOPE DO BEGIN
		WITH l[i] DO BEGIN
			writeln('********** JUGADOR ', i, ' **********');
			writeln('NOMBRE: ', nombre);
			writeln('CREDITOS: ', creditos);
			writeln('Mejor de las 5 partidas');
			writeln('NUMEROS ACERTADOS: ', lista[INI].numeros_acertados);
			writeln('CREDITOS OBTENIDOS: ', lista[INI].creditos_obtenidos);
			CASE fecha.dia_sem OF
				0: dia_semana:='Domingo';
				1: dia_semana:='Lunes';
				2: dia_semana:='Martes';
				3: dia_semana:='Miercoles';
				4: dia_semana:='Jueves';
				5: dia_semana:='Viernes';
				6: dia_semana:='Sabado';
			END;
			writeln('ULTIMA FECHA: ', dia_semana, ', ', fecha.dia,' de ', fecha.mes, ' del ', fecha.anno);
			writeln();
		END;
	END;
END;

PROCEDURE ordenAlfabetico(l: TListaJugadores; rango: integer);	{PROCEDIMIENTO ORDENAR EL RANKING ALFABETICAMENTE}
VAR
	i,j: integer;
	player: TJugador;
BEGIN
	FOR i := 0 TO rango DO BEGIN
        FOR j := 0 TO rango-1 DO BEGIN
        	IF (l[j].nombre > l[j+1].nombre) THEN BEGIN
                player := l[j+1];
                l[j+1] := l[j];
                l[j] := player;
	        END;
	    END;
	END;
	mostrarRanking(l);
END;

PROCEDURE ordenPuntuacion(l: TListaJugadores; rango: integer);	{PROCEDIMIENTO ORDENAR EL RANKING POR PUNTUACION}
VAR
	i,j, k: integer;
	player: TJugador;
BEGIN
	FOR i := 0 TO rango DO BEGIN
        FOR j := 0 TO rango-1 DO BEGIN
        	FOR k:=INI TO FIN DO BEGIN
	        	IF (l[j].lista[k].numeros_acertados < l[j+1].lista[k].numeros_acertados) THEN BEGIN
	                player := l[j+1];
	                l[j+1] := l[j];
	                l[j] := player;
		        END;
		    END;
	    END;
	END;
	mostrarRanking(l);
END;

PROCEDURE verRanking(l: TListaJugadores; rango: integer);	{MENU DEL RANKING}
VAR
	i, entrada: integer;
BEGIN
	writeln('Recientes:');
	mostrarRanking(l);
	REPEAT
		writeln('Ordenar por: ');
		writeln('1- Alfabeticamente');
		writeln('2- Puntuacion');
		writeln('3- Salir');
		readln(entrada);
	    CASE entrada OF
	    	1:
	    	BEGIN
	    		ordenAlfabetico(l, rango);
	    	END;
	    	2:
	    	BEGIN
	    		ordenPuntuacion(l, rango);
	    	END;
	    END;
	 UNTIL(entrada=3);
END;

FUNCTION esSuperiorAUnMes(nJ: TJugador): boolean;	{RECOMPENSA MENSUAL}
VAR
	year, month, mday, wday: word;
	loEs: boolean;
	anioTotal, mesTotal, diaTotal: integer;
BEGIN
	loEs:= FALSE;
	GetDate(year, month, mday, wday);
	anioTotal := year-nJ.fecha.anno;
	mesTotal := month-nJ.fecha.mes;
	diaTotal := anioTotal*365 + mesTotal*30 + mday - nJ.fecha.mes;
	IF (diaTotal>=30) THEN
		loEs:=TRUE;
	esSuperiorAUnMes:=loEs;
END;

FUNCTION esSuperiorAUnDia(nJ: TJugador): boolean;	{RECOMPENSA DIARIA}
VAR
	year, month, mday, wday: word;
	loEs: boolean;
	anioTotal, mesTotal, diaTotal: integer;
BEGIN
	loEs:= FALSE;
	GetDate(year, month, mday, wday);
	anioTotal := year-nJ.fecha.anno;
	mesTotal := month-nJ.fecha.mes;
	diaTotal := anioTotal*365 + mesTotal*30 + mday - nJ.fecha.mes;
	IF (diaTotal>1) THEN
		loEs:=TRUE;
	esSuperiorAUnDia:=loEs;
END;

FUNCTION existeArchivo(VAR archivo: TFicheroJugador): boolean;	{COMPRUEBA SI EXISTE EL ARCHIVO O NO}
BEGIN
	{$I-}
	RESET(archivo);
	{$I+}
	existeArchivo := (IORESULT= 0);
END;

PROCEDURE cargarUsuariosGuardados(VAR fich: TFicheroJugador; VAR l: TListaJugadores; VAR rg: integer);	{CARGA EN LA LISTA DE LOS JUGADORES LOS REGISTROS DEL ARCHIVO}
VAR
	usuario: TJugador;
	i: integer;
BEGIN
	ASSIGN(fich, 'jugadores.bin');
	IF NOT existeArchivo(fich) THEN
		REWRITE(fich);
	rg:=filesize(fich)-1;
	FOR i:=0 TO rg DO
    BEGIN
		seek(fich,i);
        read(fich,usuario);
        l[i]:=usuario;
	END;
	CLOSE(fich);
END;

PROCEDURE guardarUsuario(player: TJugador; VAR fich: TFicheroJugador; registrado: boolean; numeroDeLista: integer); {GUARDA EL REGISTRO DEL JUGADOR EN EL ARCHIVO}
BEGIN
	ASSIGN(fich, 'jugadores.bin');
	IF NOT existeArchivo(fich) THEN
		REWRITE(fich);
	IF registrado THEN BEGIN
		seek(fich, numeroDeLista);
		write(fich, player);
	END
	ELSE BEGIN
		seek(fich, filesize(fich));
		write(fich, player);
	END;
	CLOSE(fich);
END;

PROCEDURE datosJugador(VAR nJ: TJugador; rg: integer; l: TListaJugadores; VAR encontrado: boolean; VAR i: integer); {PROCEDIMIENTO PRINCIPAL PARA IDENTIFICAR AL JUGADOR}
VAR
	nJug, k: integer;
	valido, nue: boolean;
	novato: char;
	nomb: string;
BEGIN
	REPEAT
		writeln('Escribe tu nombre');
		readln(nomb);
		writeln(nomb,', BIENVENIDO A BINGO.');
		REPEAT
			writeln('Es la primera vez que juegas al bingo?(s/n)');
			readln(novato);
		UNTIL (novato='s') OR (novato='n');

		IF (novato='s') THEN BEGIN
			i:=0;
			WHILE ((nomb<>l[i].nombre) AND (i<=rg)) DO
				i:=succ(i);
			IF i<=rg THEN BEGIN
				writeln('Ese nombre ya esta pillado. Escoge otro');
				encontrado:=FALSE;
			END ELSE BEGIN
				nJ.nombre:=nomb;
				nJ.nuevo:=TRUE;
				nJ.partidas:=0;
				encontrado:=TRUE;
			END;
		END
		ELSE IF (novato='n') THEN BEGIN
			encontrado:=FALSE;
			i:=0;
			WHILE ((NOT encontrado) AND (i<=rg)) DO BEGIN
				IF nomb=l[i].nombre THEN BEGIN
					nJ:=l[i];
					IF esSuperiorAUnDia(nJ) THEN BEGIN
						nJ.creditos := nJ.creditos + 5;
						writeln('RECOMPENSA DIARIA. Has conseguido +5 creditos!');
					END;
					writeln('  ********** TU TOP 5 MEJORES PARTIDAS **********');
					write('***** NUMEROS ACERTADOS ');	writeln(' CREDITOS OBTENIDOS *****');
					FOR k:=INI TO FIN DO BEGIN
						write('***********  ', nJ.lista[k].numeros_acertados, '  ***************  ');
						writeln(nJ.lista[k].creditos_obtenidos, '  ***********');
					END;
					writeln('  ********** ************************* **********');
					encontrado:=TRUE;
				END
				ELSE
					i:=succ(i);
			END;
			IF (NOT encontrado) THEN
				writeln('No se han encontrado coincidencias. Por favor, repita el proceso.');
		END;
	UNTIL encontrado;
	IF nJ.nuevo OR esSuperiorAUnMes(nJ) THEN BEGIN
		nJ.creditos := nJ.creditos + 25;
		writeln('RECOMPENSA. Has conseguido +25 creditos!');
	END;
END;{--------------------------------------------------------------------------------------- FIN PROCEDIMIENTO PRINCIPAL PARA IDENTIFICAR AL JUGADOR}

PROCEDURE bienvenida;	{PROCEDIMIENTO PRINCIPAL AUXILIAR}
VAR
	entrada, rg, numeroDeLista: integer;
	registrado: boolean;
	year, month, mday, wday: word;
BEGIN
	topeJugadores:= TOPE;
	writeln('Bienvenido a BINGO !!!');
	cargarUsuariosGuardados(fich, lista, rg);
	datosJugador(jugador, rg, lista, registrado, numeroDeLista);
	REPEAT
	    writeln('Que quiere hacer?');
	    writeln('1- Jugar');
	    writeln('2- Ver ranking');
	    writeln('5- Guardar y salir');
	    readln(entrada);
	    CASE entrada OF
	    	1:
	    	BEGIN
	    		comprarCarton(MINPPC, MAXPPC, jugador, rg, lista, carton);
	    	END;
	    	2:
	    	BEGIN
	    		verRanking(lista, rg);
	    	END;
	    END;
    UNTIL(entrada=5);
    IF(entrada=5) THEN BEGIN
    	GetDate(year, month, mday, wday);
    	WITH jugador DO BEGIN
    		fecha.anno:=year;
    		fecha.dia_sem:=wday;
    		fecha.mes:=month;
    		fecha.dia:=mday;
    		jugador.nuevo:=FALSE;
    	END;
    	guardarUsuario(jugador, fich, registrado, numeroDeLista);
    END;
END;	{--------------------------------------------------------FIN PROCEDIMIENTO PRINCIPAL AUXILIAR}


BEGIN
    RANDOMIZE;
    bienvenida;
    readln;
END.
