PROGRAM practicaGrupalIP;

USES
	CRT,DOS;

CONST
	INI = 1;
	FINCARTON = 5;
	FINCARTONJUGADOR = 15;

TYPE
	B = 1..15;
	I = 16..30;
	N = 31..45;
	G = 46..60;
	O = 61..75;
	Tinteger = integer;

	TSubrango = ARRAY [INI..FINCARTON] OF Tinteger;
	TCarton = ARRAY [INI..FINCARTON, INI..FINCARTON ] OF Tinteger;

VAR

	t: TSubrango;
	c: TCarton;

FUNCTION busquedaDato(num:integer; t:TCarton): boolean;
VAR
	i,j: integer; aux: boolean;
BEGIN
	i := 0;
	j := 0;
	REPEAT
		i := SUCC (i);
		REPEAT
			BEGIN
   			j := SUCC (i);
   			aux:= t[i,j] = num;
   			END;
		UNTIL (aux {= TRUE}) OR (j = FINCARTON);
	UNTIL (aux {= TRUE}) OR (j = FINCARTON);
	busquedaDato := aux;
END;

PROCEDURE rellenarSubrango(VAR carton: TCarton);
VAR
	i,j:integer;
	numero1, numero2, numero3, numero4, numero5, numero: integer;
BEGIN

	FOR j := INI TO FINCARTON DO BEGIN;
		FOR i := INI TO FINCARTON DO
			BEGIN
			numero := random(75) + 1;
			numero1 := random(15) + 1;
			numero2 := random(15) + 16;
			numero3 := random(15) + 31;
			numero4 := random(15) + 46;
			numero5 := random(15) + 61;
				IF ((NOT busquedaDato(numero, carton)) AND ((numero > 0) AND (numero < 16))) THEN

					carton[j,i] := numero

				ELSE IF (( NOT busquedaDato(numero1, carton)) AND ((numero > 15) AND (numero < 31))) THEN

					carton[j,i] := numero

				ELSE IF (( NOT busquedaDato(numero1, carton)) AND ((numero > 30) AND (numero < 46))) THEN

					carton[j,i] := numero

				ELSE IF (( NOT busquedaDato(numero1, carton)) AND ((numero > 45) AND (numero < 61))) THEN

					carton[j,i]:= numero

				ELSE IF (( NOT busquedaDato(numero1, carton)) AND ((numero > 60) AND (numero < 76))) THEN

					carton[j,i] := numero;

		END;
	END;
END;




PROCEDURE mostrarSubrango (tablero: TCarton);
VAR
	i,j: integer;
BEGIN
	FOR j := INI TO FINCARTON DO BEGIN
		FOR i := INI TO FINCARTON DO
			write(tablero[j,i], '');
	END;
END;


BEGIN
	Randomize;
	rellenarSubrango(c);
	mostrarSubrango(c);
readln;
END.
