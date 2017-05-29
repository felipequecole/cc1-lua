/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

grammar Lua;
//Nomeatributo: [a-zA-Z] [a-zA-Z0-9_]* ('.' [a-zA-Z] [a-zA-Z0-9_]*)*;
Nome : [a-zA-Z] [a-zA-Z0-9_]* ;
Numero: [0-9][0-9]* ('.' [0-9]+)?;
Cadeia:  '"' ~('\n' | '\r' | '"')* '"' |  '\'' ~('\n' | '\r' | '\'')* '\'';
WS : [ \t\r\n]+ -> skip;
Comentario: '--' ~('\n')* '\n' -> skip;
//NomeAtributo: Nome ('.' Nome)+;

programa : trecho;
trecho : (comando (';')?)* (ultimocomando (';')?)?;
bloco : trecho;
comando :   listavar '=' listaexp |
            callfuncao |
            'do' bloco 'end' |
            'while' exp 'do' bloco 'end' |
            'repeat' bloco 'until' exp |
            'if' exp 'then' bloco ('elseif' exp 'then' bloco)* ('else' bloco)? 'end' |
            'for' Nome '=' exp ',' exp (',' exp)? 'do' bloco 'end' |
            'for' listadenomes 'in' listaexp 'do' bloco 'end' |
            'function' nomedafuncao corpodafuncao |
            'local function' nomedafuncao corpodafuncao |
            'local' listadenomes ('=' listaexp)?;

ultimocomando : 'return' (listaexp)? | 'break';
nomedafuncao : Nome {TabelaDeSimbolos.adicionarSimbolo($Nome.text, Tipo.FUNCAO);};
listavar : var (',' var)*;

var :   Nome {TabelaDeSimbolos.adicionarSimbolo($Nome.text, Tipo.VARIAVEL);}|
        Nome ('[' exp ']')+ {TabelaDeSimbolos.adicionarSimbolo($Nome.text, Tipo.VARIAVEL);}|
        Nome ('.' Nome)+ {TabelaDeSimbolos.adicionarSimbolo($Nome.text, Tipo.VARIAVEL);};

expprefixo :    var |
                callfuncao |
                '(' exp ')';

chamadadefuncao :   (args)+ |
                    (':' args)+;

listadenomes : Nome (',' Nome)*;

listaexp : (exp ',')* exp;

exp : 'nil' | 'false' | 'true' | Numero | Cadeia | '...' |
expprefixo | construtortabela | exp opbin exp | opunaria exp;

// regra para chamadas de funcao
callfuncao: nomedafuncao chamadadefuncao;

args : '(' (listaexp)? ')' | construtortabela | Cadeia;

// funcao : 'function' corpodafuncao;
corpodafuncao : '(' (listapar)? ')' bloco 'end';

listapar : listadenomes (',' '...')? | '...';

construtortabela : '{' (listadecampos)? '}';

listadecampos : campo (separadordecampos campo)* (separadordecampos)?;

campo : '[' exp ']' '=' exp | Nome '=' exp | exp;

separadordecampos : ',' | ';';

opbin : '+' | '-' | '*' | '/' | '^' | '%' | '..' |
'<' | '<=' | '>' | '>=' | '==' | '~=' |
'and' | 'or';

opunaria : '-' | 'not' | '#';

/*@members {
*   public static String grupo="<<Digite os RAs do grupo aqui>>";
*}
*/